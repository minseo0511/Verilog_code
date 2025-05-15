`timescale 1ns / 1ps

module tb_fsm_hw1;

    reg clk;
    reg reset; 
    reg din_bit;
    wire o_detect_twice;
    parameter CLK_PERIOD = 10;

    fsm_hw1 DUT(
        .clk(clk),
        .reset(reset),
        .din_bit(din_bit),
        .o_detect_twice(o_detect_twice)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        // 초기 설정
        clk = 0;
        reset = 1;
        din_bit = 0;
        #20;
        reset = 0;

        #5;
        din_bit = 0; //rd0_once
        #5;
        din_bit = 0; //rd0_twice => output=1 check
        #5;
        din_bit = 0; //1
        #5;
        din_bit = 1;
        #5;
        din_bit = 1; //1
        #5;
        din_bit = 0; 
        #5;
        din_bit = 0; //1
        #5;
        din_bit = 1; 
        #5;
        din_bit = 1; //1
        #5;
        din_bit = 1; //1

        #20;
        $finish;
    end

endmodule
