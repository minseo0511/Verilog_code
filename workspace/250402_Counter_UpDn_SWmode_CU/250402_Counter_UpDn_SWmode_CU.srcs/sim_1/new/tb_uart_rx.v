`timescale 1ns / 1ps
module tb_uart_rx();

    reg clk, reset, rx;
    wire [3:0] fndCom;
    wire [7:0] fndFont;


    top_counter_up_down DUT (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .fndCom(fndCom),
        .fndFont(fndFont)
);

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        reset = 1;
        rx = 0;

        #1000;
        reset = 0;
        #1000;

        for(i=0;i<5;i=i+1) begin
            rx = 0; #104160; send_bit("r"); rx = 1; #104160;

            rx = 0; #104160; send_bit("s"); rx = 1; #104160;

            rx = 0; #104160; send_bit("c"); rx = 1; #104160;

            rx = 0; #104160; send_bit("m"); rx = 1; #104160;

            #10416000;
            
            rx = 0; #104160; send_bit("p"); rx = 1; #104160;

          
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