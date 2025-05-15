`timescale 1ns / 1ps

module uart_mem(

    input clk,
    input reset,
    input rx,
    output tx
    );

    wire w_tick;
    wire [7:0] w_rx_data, w_tx_data, w_rtx_data;
    wire 

    uart_tx U_uart_tx (
        .clk (clk),
        .rst (reset),
        .tick(w_tick),
        .start_trigger(),
        .data_in(w_tx_data), 
        .o_tx(tx),
        .tx_done(tx_done)
    );

    uart_rx U_uart_rx(
        .clk(clk),
        .rst(reset),
        .tick(w_tick),
        .rx(rx),
        .rx_done(),
        .rx_data(w_rx_data)
    );

    baud_tick_gen U_baud_tick_gen (
        .clk(clk),
        .rst(reset),
        .baud_tick(w_tick)
    );

    fifo U_FIFO_RX(
        .clk(clk),
        .reset(reset),
        .wdata(w_rx_data),
        .wr(),
        .rd(),
        .full(),
        .empty(),
        .rdata(w_rtx_data)
    );

    fifo U_FIFO_TX(
        .clk(clk),
        .reset(reset),
        .wdata(w_rtx_data),
        .wr(),
        .rd(),
        .full(),
        .empty(),
        .rdata(w_tx_data)
    );

endmodule
