`timescale 1ns / 1ps

module TOP_Count10(
    input logic clk,
    input logic reset,
    output logic [7:0] outPort
    );

    wire ASrcMuxSel, AEn, Alt10, OutBuf, SumEn;

    DataPath U_DP(
        .clk(clk),
        .reset(reset),
        .ASrcMuxSel(ASrcMuxSel),
        .AEn(AEn),
        .Alt10(Alt10),
        .OutBuf(OutBuf),
        .SumEn(SumEn),
        .outPort(outPort)
    );

    ControlUnit U_CU(
        .clk(clk),
        .reset(reset),
        .ASrcMuxSel(ASrcMuxSel),
        .AEn(AEn),
        .Alt10(Alt10),
        .OutBuf(OutBuf),
        .SumEn(SumEn)
    );

endmodule
