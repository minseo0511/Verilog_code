`timescale 1ns / 1ps

module top_stopwatch(
    input clk,
    input reset,
    input i_btn_run,
    input i_btn_clear,
    input clk_100hz,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );

    wire w_run, w_clear;

    stopwatch_dp U_stopwatch_dp(
        .clk(clk),
        .reset(reset),
        .run(w_run),
        .clear(w_clear),
        .clk_100hz(clk_100hz),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    stopwatch_cu U_stopwatch_cu(
        .clk(clk),
        .reset(reset),
        .i_btn_run(i_btn_run),
        .i_btn_clear(i_btn_clear),
        .o_run(w_run),
        .o_clear(w_clear)
    );

endmodule