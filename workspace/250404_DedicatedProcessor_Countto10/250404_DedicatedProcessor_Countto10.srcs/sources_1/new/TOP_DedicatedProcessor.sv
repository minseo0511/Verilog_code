`timescale 1ns / 1ps

module TOP_DedicatedProcessor(
    input logic clk,
    input logic reset,
    output logic [7:0] outPort
    );

    wire w_ASrcMuxSel, w_AEn, w_Alt10, w_OutBuf;

    DataPath U_DataPath(
        .clk(clk),
        .reset(reset),
        .ASrcMuxSel(w_ASrcMuxSel),
        .AEn(w_AEn),
        .Alt10(w_Alt10),
        .OutBuf(w_OutBuf),
        .outPort(outPort)
    );


    ControlUnit U_ControlUnit(
        .clk(clk),
        .reset(reset),
        .ASrcMuxSel(w_ASrcMuxSel),
        .AEn(w_AEn),
        .Alt10(w_Alt10),
        .OutBuf(w_OutBuf)
    );

endmodule
