`timescale 1ns / 1ps

module TOP_SPI(
    input clk,
    input rst,
    input btn,
    input [13:0] swtich,
    output [3:0] fndCom,
    output [7:0] fndFont
    );

    wire [7:0] master_tx_data, master_rx_data;
    wire master_done, master_ready;
    wire start;
    wire SCLK;
    wire MOSI;
    wire MISO;
    wire CS_b;

    Master U_Master(
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .swtich(swtich),
        .start(start),
        .tx_data(master_tx_data),
        .done(master_done)
    );

    SPI_Master U_SPI_Master(
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(master_tx_data),
        .rx_data(master_rx_data),
        .done(master_done),
        .ready(master_ready),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .CS_b(CS_b)
    );

    SPI_Slave U_SPI_Slave(
        .clk(clk),
        .rst(rst),
        .start(start),
        .SCLK(SCLK),
        .MISO(MISO),
        .MOSI(MOSI),
        .CS_b(CS_b),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

endmodule
