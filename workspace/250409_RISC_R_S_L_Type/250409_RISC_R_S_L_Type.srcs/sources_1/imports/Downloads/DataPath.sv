`timescale 1ns / 1ps
`include "defines.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    // control unit side port
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    input  logic        aluSrcMuxSel,
    input  logic        RFWDSrcMuxSel,

    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    
    input  logic [31:0] dataRData,
    output logic [31:0] dataAddr,
    output logic [31:0] dataWData,
    
    input logic bitsplit
);
    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCSrcData, PCOutData;
    logic [31:0] immExt, aluSrcMuxOut;
    logic [31:0] RFWDSrcMuxOut;

    logic [31:0] RFwData;

    assign instrMemAddr = PCOutData;
    assign dataAddr = aluResult;  // RAM address input
    //assign dataWData = RFData2;  // RAM wData input

    mux_2X1 U_RFWDSrcMux (
        .sel(RFWDSrcMuxSel),
        .x0 (aluResult),
        .x1 (dataRData),
        .y  (RFWDSrcMuxOut)
    );

    bit_splitter U_bit_splitter_LType(
        .instrCode(instrCode),
        .RFWDSrcMuxOut(RFWDSrcMuxOut),
        .RFwData(RFwData)
    );

    RegisterFile U_RegFile (
        .clk(clk),
        .we(regFileWe),
        .RAddr1(instrCode[19:15]),
        .RAddr2(instrCode[24:20]),
        .WAddr(instrCode[11:7]),
        .WData(RFwData), // RFWDSrcMuxOut
        .RData1(RFData1),
        .RData2(RFData2)
    );

    mux_2X1 U_ALUSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (RFData2),
        .x1 (immExt),
        .y  (aluSrcMuxOut)
    );

    bit_splitter U_bit_splitter_SType(
        .instrCode(instrCode),
        .RFWDSrcMuxOut(RFData2),
        .RFwData(dataWData)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a(RFData1),
        .b(aluSrcMuxOut),
        .result(aluResult)
    );

    extend U_ImmExtend (
        .instrCode(instrCode),
        .immExt(immExt)
    );

    register U_PC (
        .clk(clk),
        .reset(reset),
        .d(PCSrcData),
        .q(PCOutData)
    );

    adder U_PC_Adder (
        .a(32'd4),
        .b(PCOutData),
        .y(PCSrcData)
    );

endmodule


module alu (
    input  logic [ 3:0] aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);

    always_comb begin
        case (aluControl)
            `ADD: result = a + b;  // ADD
            `SUB: result = a - b;  // SUB
            `SLL: result = a << b;  // SLL
            `SRL: result = a >> b;  // SRL
            `SRA: result = $signed(a) >>> b;  // b[4:0]; // SRA
            `SLT: result = ($signed(a) < $signed(b)) ? 1 : 0;  // SLT
            `SLTU: result = (a < b) ? 1 : 0;  // SLTU
            `XOR: result = a ^ b;  // XOR
            `OR: result = a | b;  // OR
            `AND: result = a & b;  // AND
            default: result = 32'bx;
        endcase
    end
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 0;
        else q <= d;
    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] RegFile[0:2**5-1];
    initial begin
        for (int i = 0; i < 31; i++) begin
            RegFile[i] = 10 + i;
        end
    end
    assign RegFile[31] = 32'b1100_0110_0011_1100_0110_0011_1100_0110;

    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end

    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 32'b0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 32'b0;
endmodule

module mux_2X1 (
    input logic sel,
    input logic [31:0] x0,
    input logic [31:0] x1,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            0: y = x0;
            1: y = x1;
            default: y = 32'bx;
        endcase
    end
endmodule

module extend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];
    always_comb begin
        case (opcode)
            `OP_TYPE_R: immExt = 32'bx;
            `OP_TYPE_L: begin
                immExt = {
                    {20{instrCode[31]}}, instrCode[31:20]
                };  // 반복 bit 사용    
            end
            `OP_TYPE_S: begin
                immExt = {
                    {20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]
                };
            end
            `OP_TYPE_I: begin
                if(instrCode[14:12] == 3'b001 || instrCode[14:12] == 3'b101) begin
                    immExt = {27'b0, instrCode[24:20]};
                end
                else  begin
                    immExt = {
                        {20{instrCode[31]}}, instrCode[31:20]
                    }; 
                end
            end
            default: immExt = 32'bx;
        endcase
    end
endmodule

module bit_splitter (
    input logic [31:0] instrCode,
    input logic bitsplit,
    input logic regFileWe,
    input logic [31:0] RFWDSrcMuxOut,
    output logic [31:0] RFwData
);
    wire [2:0] func3code = instrCode[14:12];

    always_comb begin 
        if (bitsplit) begin
            case (func3code)
                3'b000:  RFwData = {{24{RFWDSrcMuxOut[7]}},RFWDSrcMuxOut[7:0]};
                3'b001:  RFwData = {{16{RFWDSrcMuxOut[15]}},RFWDSrcMuxOut[15:0]};
                3'b010:  RFwData = RFWDSrcMuxOut;
                3'b100:  RFwData = {{24'b0},RFWDSrcMuxOut[7:0]};
                3'b101:  RFwData = {{16'b0},RFWDSrcMuxOut[15:0]};
                default: RFwData = RFWDSrcMuxOut;
            endcase
        end
    end
endmodule