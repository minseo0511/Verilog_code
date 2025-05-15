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
    // instr memory side port
    output logic [31:0] instrMemAddr,
    input  logic [31:0] instrCode,
    // data memory side port
    output logic [31:0] dataAddr,
    output logic [31:0] dataWData,
    input  logic [31:0] dataRData,
    // B-type MuxSel
    input logic branch,
    // LU-type MuxSel
    input logic luSrcMuxSel,
    // AU-type MuxSel
    input logic auSrcMuxSel,
    // J-type MuxSel
    input logic jSrcMuxSel,
    // JL-type MuxSel
    input logic jlSrcMuxSel,
    // bitsplliter Sel
    input logic bitsplitSel_wd, bitsplitSel_rd
);
    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCOutData;
    logic [31:0] immExt, aluSrcMuxOut, RFWDSrcMuxOut;
    logic [31:0] PC_4_AdderResult, PC_Imm_AdderResult, PCSrcMuxOut;
    logic btaken, PCSrcMuxSel;
    logic [31:0] RFWD_Ext_SrcMuxOut;
    logic [31:0] RFWD_PC_MuxOut;
    logic [31:0] RFWD_J_MuxOut;
    logic [31:0] PC_JL_MuxOut;
    logic [31:0] splitdataRData;


    assign instrMemAddr = PCOutData;
    assign dataAddr     = aluResult;
    //assign dataWData    = RFData2;
    assign PCSrcMuxSel  = btaken & branch;

    bit_splitter U_Bit_Splitter_wdRAM(
        .instrCode(instrCode),
        .bitsplitSel(bitsplitSel_wd),
        .RFWDSrcMuxOut(RFData2),
        .RFwData(dataWData)
    );

    bit_splitter U_Bit_Splitter_rdRAM(
        .instrCode(instrCode),
        .bitsplitSel(bitsplitSel_rd),
        .RFWDSrcMuxOut(dataRData),
        .RFwData(splitdataRData)
    );
    RegisterFile U_RegFile (
        .clk(clk),
        .we(regFileWe),
        .RAddr1(instrCode[19:15]),
        .RAddr2(instrCode[24:20]),
        .WAddr(instrCode[11:7]),
        .WData(RFWD_J_MuxOut),
        .RData1(RFData1),
        .RData2(RFData2)
    );

    mux_2x1 U_ALUSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (RFData2),
        .x1 (immExt),
        .y  (aluSrcMuxOut)
    );

    mux_2x1 U_RFWDSrcMux (
        .sel(RFWDSrcMuxSel),
        .x0 (aluResult),
        .x1 (splitdataRData),
        .y  (RFWDSrcMuxOut)
    );
    
    mux_2x1 U_RFWD_Ext_SrcMux (
        .sel(luSrcMuxSel),
        .x0 (RFWDSrcMuxOut),
        .x1 (immExt),
        .y  (RFWD_Ext_SrcMuxOut)
    );

    mux_2x1 U_RFWD_jtype_SrcMux (
        .sel(jSrcMuxSel),
        .x0 (RFWD_PC_MuxOut),
        .x1 (PC_4_AdderResult),
        .y  (RFWD_J_MuxOut)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a(RFData1),
        .b(aluSrcMuxOut),
        .btaken(btaken),
        .result(aluResult)
    );

    extend U_ImmExtend (
        .instrCode(instrCode),
        .immExt(immExt)
    );


    adder U_PC_Imm_Adder (
        .a(immExt),
        .b(PCOutData),
        .y(PC_Imm_AdderResult)
    );

    adder U_PC_Adder (
        .a(32'd4),
        .b(PCOutData),
        .y(PC_4_AdderResult)
    );

    mux_2x1 U_RFWD_PC_SrcMux (
        .sel(auSrcMuxSel),
        .x0 (RFWD_Ext_SrcMuxOut),
        .x1 (PC_Imm_AdderResult),
        .y  (RFWD_PC_MuxOut)
    );
    mux_2x1 U_PCSrcMux (
        .sel(PCSrcMuxSel | jSrcMuxSel),
        .x0 (PC_4_AdderResult),
        .x1 (PC_Imm_AdderResult),
        .y  (PCSrcMuxOut)
    );
    mux_2x1 U_PC_JL_SrcMux (
        .sel(jlSrcMuxSel),
        .x0 (PCSrcMuxOut),
        .x1 (RFWDSrcMuxOut),
        .y  (PC_JL_MuxOut)
    );
    register U_PC (
        .clk(clk),
        .reset(reset),
        .d(PC_JL_MuxOut),
        .q(PCOutData)
    );

endmodule


module alu (
    input logic [3:0] aluControl,
    input logic [31:0] a,
    input logic [31:0] b,
    output logic btaken,
    output logic [31:0] result
);
    always_comb begin
        case (aluControl)
            `ADD:    result = a + b;
            `SUB:    result = a - b;
            `SLL:    result = a << b;
            `SRL:    result = a >> b;
            `SRA:    result = $signed(a) >>> b[4:0];
            `SLT:    result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU:   result = (a < b) ? 1 : 0;
            `XOR:    result = a ^ b;
            `OR:     result = a | b;
            `AND:    result = a & b;
            default: result = 32'bx;
        endcase
    end

    always_comb begin : branch_processor
        case (aluControl[2:0])
            `BEQ: btaken = (a == b);
            `BNE: btaken = (a != b);
            `BLT: btaken = ($signed(a) < $signed(b));
            `BGE: btaken = ($signed(a) >= $signed(b));
            `BLTU: btaken = (a < b);
            `BGEU: btaken = (a >= b);
            default: btaken = 1'b0;
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

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            1'b0:    y = x0;
            1'b1:    y = x1;
            default: y = 32'bx;
        endcase
    end
endmodule

module extend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];
    wire [2:0] func3 = instrCode[14:12];

    always_comb begin
        immExt = 32'bx;
        case (opcode)
            `OP_TYPE_R: immExt = 32'bx;
            `OP_TYPE_L: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
            `OP_TYPE_S:
            immExt = {{20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]};
            `OP_TYPE_I: begin
                case (func3)
                    3'b001:  immExt = {27'b0, instrCode[24:20]};
                    3'b101:  immExt = {27'b0, instrCode[24:20]};
                    3'b011:  immExt = {20'b0, instrCode[31:20]};
                    default: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
                endcase
            end
            `OP_TYPE_B:
            immExt = {
                {20{instrCode[31]}},
                instrCode[7],
                instrCode[30:25],
                instrCode[11:8],
                1'b0
            };
            `OP_TYPE_LU: immExt = {instrCode[31:12], 12'b0};
            `OP_TYPE_AU: immExt = {instrCode[31:12], 12'b0};
            `OP_TYPE_J: immExt = {{12{instrCode[31]}}, instrCode[19:12], instrCode[20], instrCode[30:21], 1'b0};
            `OP_TYPE_JL: immExt = {{21{instrCode[31]}}, instrCode[30:20]};
            default: immExt = 32'bx;
        endcase
    end
endmodule

module bit_splitter (
    input logic [31:0] instrCode,
    input logic bitsplitSel,
    input logic [31:0] RFWDSrcMuxOut,
    output logic [31:0] RFwData
);
    wire [2:0] func3 = instrCode[14:12];

    always_comb begin 
        if (bitsplitSel) begin
            case (func3)
                3'b000:  RFwData = {{24{RFWDSrcMuxOut[7]}},RFWDSrcMuxOut[7:0]};
                3'b001:  RFwData = {{16{RFWDSrcMuxOut[15]}},RFWDSrcMuxOut[15:0]};
                3'b010:  RFwData = RFWDSrcMuxOut;
                3'b100:  RFwData = {{24'b0},RFWDSrcMuxOut[7:0]};
                3'b101:  RFwData = {{16'b0},RFWDSrcMuxOut[15:0]};
                default: RFwData = RFWDSrcMuxOut;
            endcase
        end
        else RFwData = RFWDSrcMuxOut;
    end
endmodule