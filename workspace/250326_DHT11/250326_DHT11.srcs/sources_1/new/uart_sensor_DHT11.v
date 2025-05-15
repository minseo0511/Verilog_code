`timescale 1ns / 1ps

module uart_sensor_DHT11(
    input clk,
    input reset,
    input rx,
    input btn_start,
    input sw_mode,
    output tx,
    output [4:0] led,
    output [7:0] fnd_font,
    output [3:0] fnd_comm,
    inout dht_io
    );

    wire w_rx_done, w_tx_done;
    wire full_rx, empty_rx, full_tx, empty_tx;
    wire [7:0] data_rx_tx, rdata_tx, wdata_rx, data_sensor_tx;
    wire w_wr_tx, w_rd_tx;

    TOP_DHT11 U_TOP_DHT11(
        .clk(clk),
        .reset(reset),
        .btn_start(btn_start),
        .sw_mode(sw_mode),
        .data_in(data_rx_tx),
        .led(led),
        .wr_tx(w_wr_tx),
        .rd_tx(w_rd_tx),
        .empty_rx_b(~empty_rx),
        .data_sensor_tx(data_sensor_tx),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm),
        .dht_io(dht_io)
    );

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
        .wdata(data_sensor_tx),
        .wr(w_wr_tx), // ~empty_rx     w_wr_tx
        .rd(~w_tx_done), //~w_tx_done    
        .full(full_tx),
        .empty(empty_tx),
        .rdata(rdata_tx)
    );

endmodule
