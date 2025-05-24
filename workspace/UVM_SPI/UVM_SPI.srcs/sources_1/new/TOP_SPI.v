`timescale 1ns / 1ps

module TOP_SPI(
    // global signals
    input            clk,
    input            reset,
    // internal signals
    input            cpol,
    input            cpha,
    input            start,
    input            SS,
    input      [7:0] tx_data,
    output     [7:0] rx_data
    );
    wire done;
    wire ready;
    wire SCLK;
    wire MOSI;
    wire MISO;

    SPI_Master U_SPI_Master(
        .clk(clk),
        .reset(reset),
        .cpol(cpol),
        .cpha(cpha),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .donee(done),
        .ready(ready),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    SPI_Slave U_SPI_Slave(
        .clk(clk),
        .reset(reset),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        .done(done)
    );
endmodule
