`timescale 1ns / 1ps

module tb_SPI();

    logic clk;
    logic reset;
    // master
    logic cpol;
    logic cpha;
    logic start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic done;
    logic ready;
    logic SCLK;
    logic MOSI;
    logic MISO;
    // slave    
    logic SS;
    logic write;
    logic [1:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;


    SPI_Master dut_master(
        .clk(clk),
        .reset(reset),
        .cpol(cpol),
        .cpha(cpha),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .done(done),
        .ready(ready),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    SPI_Slave_Intf_hw dut_slave(
        .SCLK(SCLK),
        .reset(reset),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        .write(write),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1; cpol = 0; cpha = 0 ; start = 0; tx_data = 8'hz; SS = 1; rdata = 8'hz;
        #10;
        reset = 0 ;
        #100;
        start = 1; SS = 0; tx_data = 8'ha0; rdata = 8'h0a;
        #20;
        start = 0;

        wait(done == 1);
        #200;
        $finish; 
    end

endmodule
