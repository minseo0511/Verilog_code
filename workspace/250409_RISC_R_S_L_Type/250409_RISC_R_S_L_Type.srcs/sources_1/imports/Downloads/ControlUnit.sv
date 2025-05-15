`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic        RFWDSrcMuxSel,

    output logic bitsplit
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5], func3}

    logic [4:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, bitsplit} = signals;
    always_comb begin
        signals = 0;
        case (opcode)
            // {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, bitsplit}
            `OP_TYPE_R: signals = 5'b1_0_0_0_0;  // R-Type
            `OP_TYPE_S: signals = 5'b0_1_1_0_1;  // S-Type
            `OP_TYPE_L: signals = 5'b1_1_0_1_1;  // L-Type
            `OP_TYPE_I: signals = 5'b1_1_0_0_0;  // I-Type
        endcase
    end

    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_R: aluControl = operators;
            `OP_TYPE_S: aluControl = `ADD;  // 주소값 add 연산만 있다.  
            `OP_TYPE_L: aluControl = `ADD;  // 주소값 add 연산만 있다.  
            `OP_TYPE_I: aluControl = (operators == 4'b1000) ? `ADD : operators;
        endcase
    end
endmodule
