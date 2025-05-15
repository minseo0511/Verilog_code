`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/04 08:49:35
// Design Name: 
// Module Name: FND_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FND_ctrl(
    input [1:0]btn,
    input [7:0]s,
    output [3:0]seg_ctrl,
    output [7:0]seg_out
    );
    Decoder U_D1(
        .btn(btn),
        .seg_ctrl(seg_ctrl)
    );
    bcdtoseg U_BTS1(
        .bcd(s),
        .seg_out(seg_out)
    );

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