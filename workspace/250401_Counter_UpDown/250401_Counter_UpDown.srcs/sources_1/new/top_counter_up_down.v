`timescale 1ns / 1ps

module top_counter_up_down(
    input clk,
    input reset,
    input mode,
    output [3:0] fndCom,
    output [7:0] fndFont
    );

    wire [13:0] fndData;

    counter_up_down U_counter_up_down(
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .count(fndData)
    );

    fndController U_FND_CTRL(
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );
endmodule
