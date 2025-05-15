`timescale 1ns / 1ps

module tb_uart_sensor();

    reg clk, reset, rx, btn_left, echo;
    wire trigger, tx;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    uart_sensor DUT(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .btn_left(btn_left),
        .echo(echo),
        .trigger(trigger),
        .tx(tx),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        reset = 1;
        rx = 0;
        btn_left = 0;
        echo = 0;

        #1000;
        reset = 0;
        #1000;

        for(i=0;i<5;i=i+1) begin
            rx = 0; #104160; send_bit("T"); rx = 1; #104160;

            #5000 echo = 1;
            #1000000 echo = 0;  // 1ms

            rx = 0; #104160; send_bit("T"); rx = 1; #104160;

            #5000 echo = 1;
            #3000000 echo = 0;  // 3ms

            rx = 0; #104160; send_bit("T"); rx = 1; #104160;

            #5000 echo = 1;
            #10000 echo = 0;  // 10us

            rx = 0; #104160; send_bit("T"); rx = 1; #104160;

            #5000 echo = 1;
            #2000000 echo = 0;  // 20ms
        end
        

        #10000000;

        #1000;
         $stop;
    end

    /* Button 동작
    initial begin
        clk = 0;
        reset = 1;
        rx = 0;
        btn_left = 0;
        echo = 0;

        #10;
        reset = 0 ;
        #1000;
        btn_left = 1;
        #10000000;
        btn_left = 0;

        #5000 echo = 1;
        #1000000 echo = 0;  // 1ms

        #10000000;

        btn_left = 1;
        #10000000;
        btn_left = 0;

        #5000 echo = 1;
        #3000000 echo = 0;  // 3ms

        #10000000;

        btn_left = 1;
        #10000000;
        btn_left = 0;

        #5000 echo = 1;
        #10000 echo = 0;  // 10us

        #10000000;

        btn_left = 1;
        #10000000;
        btn_left = 0;

        #5000 echo = 1;
        #2000000 echo = 0;  // 20ms

        #10000000;

        #1000;
         $stop;
    end
    */

    task send_bit(input [7:0] data);
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #104160;
        end
    endtask

endmodule
