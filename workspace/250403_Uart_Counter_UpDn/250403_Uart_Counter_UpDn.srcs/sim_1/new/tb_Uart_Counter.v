`timescale 1ns / 1ps

module tb_Uart_Counter();
    
    reg        clk;
    reg        reset;
    reg btn_left;
    reg btn_right;
    reg btn_up;
    reg btn_down;
    wire [3:0] fndCom;
    wire [7:0] fndFont;
    wire tx;
    reg rx;

    top_counter_up_down DUT (
        .clk(clk),
        .reset(reset),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .fndCom(fndCom),
        .fndFont(fndFont),
        .tx(tx),
        .rx(rx)
    );  

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        reset = 1;
        btn_left = 0;
        btn_right = 0;
        btn_up = 0;
        btn_down = 0;
        rx = 0;

        #100;
        reset = 0;
        #100;

        for(i=0;i<5;i=i+1) begin
            rx = 0; #104160; send_bit("r"); rx = 1; #104160;

            rx = 0; #104160; send_bit("s"); rx = 1; #104160;

            rx = 0; #104160; send_bit("c"); rx = 1; #104160;

            rx = 0; #104160; send_bit("m"); rx = 1; #104160;

              rx = 0; #104160; send_bit("m"); rx = 1; #104160;


            rx = 0; #104160; send_bit("t"); rx = 1; #104160;

          
        end
        

        #10000000;

        #1000;
         $stop;
    end

    task send_bit(input [7:0] data);
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #104160;
        end
    endtask

endmodule
