`timescale 1ns / 1ps

module TOP_Registerfile(
    input logic clk,
    input logic reset,
    output logic [7:0] outPort
    );

    logic       RFSrcMuxSel;
    logic [2:0] readAddr1;
    logic [2:0] readAddr2;
    logic [2:0] writeAddr;
    logic       writeEn;
    logic       outBuf;
    logic       iLe10;


    DataPath U_DataPath (
        .clk(clk),
        .reset(reset),
        .RFSrcMuxSel(RFSrcMuxSel),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .outBuf(outBuf),
        .iLe10(iLe10),
        .outPort(outPort)
    );

    ControlUnit U_ControlUnit(
        .clk(clk),
        .reset(reset),
        .iLe10(iLe10),
        .RFSrcMuxSel(RFSrcMuxSel),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .outBuf(outBuf)
    );

endmodule
