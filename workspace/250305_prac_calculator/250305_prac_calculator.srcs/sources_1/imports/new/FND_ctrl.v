`timescale 1ns / 1ps

module FND_ctrl(
    input clk,
    input reset,
    input [13:0]s,
    output [3:0]seg_ctrl,
    output [7:0]seg_out
    );
    wire [13:0]w_sum;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000, w_mux_out;
    wire w_clk_div;
    wire [1:0] w_mux_sel;

    clk_divider U_clk_div_1(
        .clk(clk),
        .reset(reset),
        .clk_div(w_clk_div)
    );

    counter_4 count_1(
        .clk(w_clk_div),
        .reset(reset),
        .count(w_mux_sel)
    );

    digit_splitter U_digit_split(
        .sum(s),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    MUX_4X1 U_Mux_1(
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .mux_sel(w_mux_sel),
        .muxtobcd(w_mux_out)
    );

    Decoder U_D1(
        .btn(w_mux_sel),
        .seg_ctrl(seg_ctrl)
    );
    bcdtoseg U_BTS1(
        .bcd(w_mux_out),
        .seg_out(seg_out)
    );

endmodule

module clk_divider (
    input clk,
    input reset,
    output reg clk_div
);
    
    parameter CLK_CTRL = 250_000; // 기존 100MHz/CLK_CTRL = clk_div
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

module counter_4 (
    input clk,
    input reset,
    output reg [1:0]count
);
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

module digit_splitter (
    input [13:0]sum,
    output [3:0]digit_1,digit_10,digit_100,digit_1000
);
    assign digit_1 = sum%10;
    assign digit_10 = sum/10%10;
    assign digit_100 = sum/100%10;
    assign digit_1000 = sum/1000%10;
    
endmodule

module MUX_4X1 (
    input [3:0]digit_1,digit_10,digit_100,digit_1000,
    input [1:0]mux_sel,
    output reg [3:0]muxtobcd
);
    always @(*) begin
        case (mux_sel)
            2'b00 : muxtobcd = digit_1;  
            2'b01 : muxtobcd = digit_10;  
            2'b10 : muxtobcd = digit_100;  
            2'b11 : muxtobcd = digit_1000;  
            default: muxtobcd = 4'b0000;
        endcase
    end    
endmodule

module Decoder (
    input [1:0]btn,
    output reg [3:0]seg_ctrl
);
    always @(btn) begin   
        case (btn)
            2'b00 : seg_ctrl = 4'b1110;
            2'b01 : seg_ctrl = 4'b1101;
            2'b10 : seg_ctrl = 4'b1011;
            2'b11 : seg_ctrl = 4'b0111; 
            default: seg_ctrl = 4'b1111;
        endcase
    end
endmodule 

module bcdtoseg(
    input [7:0]bcd,
    output reg [7:0]seg_out
);
    always @(bcd) begin
        case (bcd)
            4'h0 : seg_out = 8'hC0;
            4'h1 : seg_out = 8'hF9;
            4'h2 : seg_out = 8'hA4;
            4'h3 : seg_out = 8'hB0;
            4'h4 : seg_out = 8'h99;
            4'h5 : seg_out = 8'h92;
            4'h6 : seg_out = 8'h82;
            4'h7 : seg_out = 8'hF8;
            4'h8 : seg_out = 8'h80;
            4'h9 : seg_out = 8'h90;
            4'hA : seg_out = 8'h88;
            4'hB : seg_out = 8'h83;
            4'hC : seg_out = 8'hC6;
            4'hD : seg_out = 8'hA1;
            4'hE : seg_out = 8'h86;
            4'hF : seg_out = 8'h8E; 
            default: seg_out = 8'h00;
        endcase
    end
endmodule