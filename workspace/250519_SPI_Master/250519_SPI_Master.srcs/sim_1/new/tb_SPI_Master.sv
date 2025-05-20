`timescale 1ns / 1ps

module tb_SPI_Master ();

    logic clk;
    logic reset;
    logic start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic done;
    logic ready;
    logic SCLK;
    logic MOSI;
    logic MISO;
    logic cpol;
    logic cpha;

    SPI_Master dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .done(done),
        .ready(ready),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .cpol(cpol),
        .cpha(cpha)
    );

    assign MISO = MOSI;  // loop 형성

    always #5 clk = ~clk;
    initial begin
        clk   = 0;
        reset = 1;
        start = 0;
        #10;
        reset = 0;

        repeat (3) @(posedge clk);
        tx_data = 8'haa;
        start = 1;
        cpol = 1;
        cpha = 1;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        @(posedge clk);
        tx_data = 8'h55;
        start = 1;
        cpol = 0;
        cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        #200 $finish;
    end

endmodule
