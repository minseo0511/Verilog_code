`timescale 1ns / 1ps

module uart_sensor(
    input clk,
    input reset,
    input rx,
    input btn_left,
    input echo,
    output trigger,
    output tx,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output led
    );

    assign led = echo;

    wire w_rx_done, w_tx_done;
    wire full_rx, empty_rx, full_tx, empty_tx;
    wire [7:0] data_sensor_tx, data_rx_tx, rdata_tx, wdata_rx;
    wire [8:0] w_distance;
    wire w_echo_done;
    wire w_wr_tx, w_rd_tx;

    wire [11:0] w_distance_digit;

    TOP_UltrasonicSensor U_TOP_Sensor(
        .clk(clk),
        .reset(reset),
        .btn_trig(btn_left),
        .echo(echo),
        .empty_rx_b(~empty_rx),
        .data_in(data_rx_tx),
        .trigger(trigger),
        .distance(w_distance),
        .echo_done(w_echo_done)
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

    Sensor_TX_FIFO_CU U_Sensor_TX_FIFO_CU(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        //.echo(echo),
        .echo_done(w_echo_done),
        .distance_digit(w_distance_digit),
        .wr_tx(w_wr_tx),
        .rd_tx(w_rd_tx),
        .data_sensor_tx(data_sensor_tx)
    );

    fifo U_FIFO_TX(
        .clk(clk),
        .reset(reset),
        .wdata(data_sensor_tx),
        .wr(w_wr_tx), // ~empty_rx     w_wr_tx
        .rd(~w_tx_done), //~w_tx_done    w_tx_done & empty_rx
        .full(full_tx),
        .empty(empty_tx),
        .rdata(rdata_tx)
    );

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(reset),
        .distance(w_distance),
        .distance_digit(w_distance_digit),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );
endmodule
