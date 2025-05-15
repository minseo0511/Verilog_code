`timescale 1ns / 1ps


module calculator(
    input clk,
    input reset,
    input clear,
    input run_stop,
    output [3:0] seg_ctrl,
    output [7:0] seg_out,
    output c
    );

    wire [13:0]w_count;
    wire w_clk_div;
    wire w_reset, w_clk;
    assign w_reset = reset | clear;
    assign w_clk = run_stop & clk;

    clk_divider_cnt U_clk_div_cnt1(
        .clk(w_clk),
        .reset(w_reset),
        .clk_div(w_clk_div)
    );

    counter U_Counter1(
        .clk(w_clk_div),
        .reset(w_reset),
        .count(w_count)
    );

    FND_ctrl U_FND1(
        .clk(w_clk),
        .reset(w_reset),
        .s(w_count),
        .seg_ctrl(seg_ctrl),
        .seg_out(seg_out)
    );

endmodule

module clk_divider_cnt (
    input clk,
    input reset,
    output reg clk_div
);
    
    parameter CLK_CTRL = 10_000_000; // 기존 100MHz/CLK_CTRL = clk_div
    reg [$clog2(CLK_CTRL)-1:0]count;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count <= 0;
            clk_div <= 0;
        end
        else if(count == CLK_CTRL-1) begin
            count <= 0;
            clk_div <= 1;
        end
        else if(count == CLK_CTRL/2-1) begin
            clk_div <= 0;
            count <= count + 1; 
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

module counter (
    input clk,
    input reset,
    output [13:0]count
);
    parameter o_COUNT = 10_000_000;
    reg [$clog2(o_COUNT)-1:0]w_count;
    assign count = w_count;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            w_count <= 0;
        end
        else if (w_count == o_COUNT-1) begin
            w_count <= 0;
        end
        else begin
            w_count <= w_count + 1;
        end
    end
endmodule