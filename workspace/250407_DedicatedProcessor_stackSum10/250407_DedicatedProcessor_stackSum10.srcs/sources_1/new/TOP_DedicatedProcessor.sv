`timescale 1ns / 1ps

module TOP_DedicatedProcessor(
    input logic clk,
    input logic reset,
    output logic [7:0] outPort
    );

    wire sumSrcMuxSel, iSrcMuxSel, sumEn, iEn, adderSrcMuxSel, outBuf, iLe10;

    DataPath U_DataPath(.*);
    //     .clk(clk),
    //     .reset(reset), 
    //     .sumSrcMuxSel(sumSrcMuxSel),
    //     .iSrcMuxSel(iSrcMuxSel),
    //     .sumEn(sumEn),
    //     .iEn(iEn),
    //     .adderSrcMuxSel(adderSrcMuxSel),
    //     .outBuf(outBuf),
    //     .iLe10(iLe10),
    //     .outPort(outPort)
    // );

    //DataPath U_DataPath(.*);

    ControlUnit U_ControlUnit(.*);
    //     .clk(clk),
    //     .reset(reset), 
    //     .iLe10(iLe10),
    //     .sumSrcMuxSel(sumSrcMuxSel),
    //     .iSrcMuxSel(iSrcMuxSel),
    //     .sumEn(sumEn),
    //     .iEn(iEn),
    //     .adderSrcMuxSel(adderSrcMuxSel),
    //     .outBuf(outBuf)
    // );
endmodule

    //ControlUnit U_ControlUnit(.*);
    // wire의 이름이 같으면 (.*);로 자동 연결