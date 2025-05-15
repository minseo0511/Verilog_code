`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/07 13:43:20
// Design Name: 
// Module Name: tb_shift_register
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


module tb_shift_register();

    reg clk;
    reg reset;
    reg i_btn;
    wire o_btn;

    btn_debounce DUT(
        .clk(clk),
        .reset(reset),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        i_btn = 0;
        #10;
        reset = 0;

        #10;
        i_btn = 0;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 0;
        #10;
        i_btn = 1;
        #10;
        i_btn = 0;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 1;
        #10;
        i_btn = 0;

        #10;
        $stop();
    end

endmodule
