`timescale 1ns / 1ps

module tb_uart_tx();

    reg clk, rst;
    //wire tx;
    reg rx;
    wire w_tick, w_rx_done;
    wire [7:0] rx_data;

    baud_tick_gen U_BAUD_TICK(
        .clk(clk),
        .rst(rst),
        .baud_tick(w_tick)
    );

    uart_rx DUT_rx (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(rx_data)
    );
/*
    send_tx_btn DUT(
        .clk(clk),
        .rst(rst),
        .btn_start(tx_start_trig),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        tx_start_trig = 1'b0;

        #20 rst = 1'b0;
        #100000 tx_start_trig = 1'b1;
        #100000 tx_start_trig = 1'b0;
    end
*/

    always #5 clk = ~clk;

        initial begin
            clk = 0;
            rst = 1;
            rx = 1;
            #10;
            rst = 0;
            #100;
            rx = 0; // start
            #104160; // 9600 1bit
            rx = 1; // data0
            #104160;
            rx = 0; // data1
            #104160;
            rx = 0; // data2
            #104160; // 9600 1bit
            rx = 0; // data3
            #104160;
            rx = 1; // data4
            #104160;
            rx = 1;// data5
            #104160; // 9600 1bit
            rx = 0;// data6
            #104160;
            rx = 0; // data7
            #104160;
            rx = 1; // stop
            #10000;
            $stop;
        end

endmodule
