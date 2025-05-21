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
    logic SS;

    SPI_Master U_SPI_Master (
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

    SPI_Slave U_SPI_Slave(
        .clk(clk),
        .reset(reset),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        .done(done)
    );

    always #5 clk = ~clk;
    initial begin
        clk   = 0;
        reset = 1;
        start = 0;
        #10;
        reset = 0;

        repeat (3) @(posedge clk);

        // address byte
        SS    = 1;
        @(posedge clk);
        tx_data = 8'b10000000; // MSB: read/write -> write, LSB[1:0]: addr = 2'b10
        start = 1;
        cpol = 0;
        cpha = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        // write data byte on 0x00 address
        @(posedge clk);
        tx_data = 8'h10;
        start = 1;
        cpol = 0;
        cpha = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        // write data byte on 0x01 address
        @(posedge clk);
        tx_data = 8'h20;
        start = 1;
        cpol = 0;
        cpha = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);
        
        // write data byte on 0x02 address
        @(posedge clk);
        tx_data = 8'h30;
        start = 1;
        cpol = 0;
        cpha = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        // write data byte on 0x03 address
        @(posedge clk);
        tx_data = 8'h40;
        start = 1;
        cpol = 0;
        cpha = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        SS = 1;

        repeat(5) @(posedge clk);
        SS = 0 ;
        @(posedge clk);
        tx_data = 8'b00000000; start = 1; cpol = 0; cpha = 0; 
        @(posedge clk);
        start = 0;
        wait(done == 1);
        @(posedge clk);
        @(posedge clk);
        for(int i=0;i<4;i=i+1) begin
            tx_data = 8'b00000000; start = 1; 
            @(posedge clk);
            start = 0;
            wait(done == 1);
            @(posedge clk);    
            @(posedge clk);    
        end

        SS = 1;

        #2000 $finish;
    end

endmodule
