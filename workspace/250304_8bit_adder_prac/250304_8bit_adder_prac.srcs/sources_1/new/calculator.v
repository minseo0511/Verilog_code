`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/04 09:04:48
// Design Name: 
// Module Name: calculator
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


module calculator(
    input [1:0] btn,
    input [7:0] a,b,
    output [3:0] seg_ctrl,
    output [7:0] seg_out,
    output c
    );

    wire [7:0]w_s;

    adder_8bit U_A8_1(
        .a(a),
        .b(b),
        .s(w_s),
        .c(c)
    );

    FND_ctrl U_FND1(
        .btn(btn),
        .s(w_s),
        .seg_ctrl(seg_ctrl),
        .seg_out(seg_out)
    );

endmodule
