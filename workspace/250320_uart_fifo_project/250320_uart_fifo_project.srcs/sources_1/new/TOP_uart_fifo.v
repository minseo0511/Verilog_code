`timescale 1ns / 1ps

module TOP_uart_fifo(
    input clk,
    input reset,
    input rx,
    input btn_left, btn_right, btn_down,
    input [2:0]sw_mode,
    output tx,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [4:0] led
    );

    wire w_rx_done, w_tx_done;
    wire full_rx, empty_rx, full_tx, empty_tx;
    wire [7:0] data_rx_tx, rdata_tx, wdata_rx;

    uart U_UART(
        .clk(clk),
        .rst(reset),
        .btn_start(~empty_tx),
        .tx_data_in(rdata_tx),
        .tx(tx),
        .tx_done(w_tx_done),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(wdata_rx)
    );

    fifo U_FIFO_RX(
        .clk(clk),
        .reset(reset),
        .wdata(wdata_rx),
        .wr(w_rx_done),
        .rd(~full_tx),
        .full(full_rx),
        .empty(empty_rx),
        .rdata(data_rx_tx)
    );

    fifo U_FIFO_TX(
        .clk(clk),
        .reset(reset),
        .wdata(data_rx_tx),
        .wr(~empty_rx),
        .rd(~w_tx_done), 
        .full(full_tx),
        .empty(empty_tx),
        .rdata(rdata_tx)
    );

    top_stopwatch U_TOP_STOPWATCH(
        .clk(clk),
        .reset(reset), 
        .btn_left(btn_left), 
        .btn_right(btn_right),
        .btn_down(btn_down),
        .sw_mode(sw_mode), 
        .data_in(data_rx_tx),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .led(led)
    );

endmodule
