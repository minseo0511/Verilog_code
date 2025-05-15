`timescale 1ns / 1ps

module TOP_counter_9999(
    input clk,
    input reset,
    input sw_mode,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire w_tick_10ms;
    wire [$clog2(10000)-1:0] w_count;

    time_counter_10ms #(.BIT_WIDTH(10_000_000)) U_Time_Counter_10ms_2(
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick_10ms)
    );

    counter U_Counter_9999(
        .clk(clk),
        .reset(reset),
        .tick_10ms(w_tick_10ms),
        .sw_mode(sw_mode),
        .count(w_count)
    );

    fnd_ctrl U_FND_CTRL(
        .clk(clk),
        .reset(reset),
        .data_in(w_count),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );
endmodule
