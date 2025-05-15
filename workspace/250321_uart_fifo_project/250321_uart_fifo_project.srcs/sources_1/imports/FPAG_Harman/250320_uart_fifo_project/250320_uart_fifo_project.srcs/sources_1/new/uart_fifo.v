`timescale 1ns / 1ps

module uart_fifo(
    input clk,
    input reset,
    input rx,
    output tx
    );

    wire w_rx_done, w_tx_done;
    wire full_rx, empty_rx, full_tx, empty_tx;
    wire [7:0] data_rx_tx, rdata_tx, wdata_rx;

    uart DUT_uart(
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

    fifo DUT_fifo_RX(
        .clk(clk),
        .reset(reset),
        .wdata(wdata_rx),
        .wr(w_rx_done),
        .rd(~full_tx),
        .full(full_rx),
        .empty(empty_rx),
        .rdata(data_rx_tx)
    );

    fifo DUT_fifo_TX(
        .clk(clk),
        .reset(reset),
        .wdata(data_rx_tx),
        .wr(~empty_rx),
        .rd(~w_tx_done&~empty_rx), //?
        .full(full_tx),
        .empty(empty_tx),
        .rdata(rdata_tx)
    );


    

endmodule
