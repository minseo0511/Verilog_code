`timescale 1ns / 1ps

module tb_final();

    reg clk, reset, sw_mode3, sw_mode2, sw_mode, btn_left, btn_down, btn_right;

    wire [4:0] led; 
    wire [3:0] fnd_comm; 
    wire [7:0] fnd_font;

    Final U_FINAL(
        .clk(clk), 
        .reset(reset),
        .sw_mode3(sw_mode3),
        .sw_mode2(sw_mode2),  
        .sw_mode(sw_mode),
        .btn_left(btn_left), 
        .btn_down(btn_down), 
        .btn_right(btn_right),  
        .led(led),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        sw_mode3 = 0;
        sw_mode2 = 0;
        sw_mode = 0;
        btn_left = 0;
        btn_down = 0;
        btn_right = 0;

        #10; 
        reset = 1;
        #10;         
        reset = 0;

        // sw_mode : msec_sec와 min_hour
        // sw_mode2 : stopwatch와 watch
        // sw_mode3 : minus switch

        #10;         
        reset = 0;
        // watch의 min_hour
        sw_mode = 1'b1;
        sw_mode2 = 1'b1;

        #10000000;
        btn_down = 1'b1;

        #10000000;
        btn_down = 1'b0;

        #10000000;
        btn_right = 1'b1;

        #10000000;
        btn_right = 1'b0;


        #10;           
        sw_mode3 = 1'b1;

        #10000000;
        btn_right = 1'b1;

        #10000000;
        btn_right = 1'b0;

        #10000000;
        btn_right = 1'b1;

        #10000000;
        btn_right = 1'b0;
    end

endmodule
