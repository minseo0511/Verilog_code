`timescale 1ns / 1ps

module top_button(
    input clk,
    input reset,
    input btnL, 
    input btnR, 
    input btnU, 
    input btnD,
    output o_btnL, 
    output o_btnR, 
    output o_btnU, 
    output o_btnD
    );

    btn_debounce U_btnL(
        .clk(clk),
        .reset(reset),
        .i_btn(btnL),
        .o_btn(o_btnL)
    );

    btn_debounce U_btnR(
        .clk(clk),
        .reset(reset),
        .i_btn(btnR),
        .o_btn(o_btnR)
    );

    btn_debounce U_btnU(
        .clk(clk),
        .reset(reset),
        .i_btn(btnU),
        .o_btn(o_btnU)
    );

    btn_debounce U_btnD(
        .clk(clk),
        .reset(reset),
        .i_btn(btnD),
        .o_btn(o_btnD)
    );

endmodule
