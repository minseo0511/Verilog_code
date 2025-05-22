`timescale 1ns / 1ps

module tb_I2C();

    logic clk;
    logic reset;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic tx_done;
    logic ready;
    logic start;
    logic stop;
    
    wire SCL;
    wire SDA;

    I2C_Master U_I2C_Master(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .tx_done(tx_done),
        .ready(ready),
        .start(start),
        .stop(stop),
        .SCL(SCL),
        .SDA(SDA)
    );

    I2C_Slave_Intf U_I2C_Slave_Intf (
        .clk(clk),
        .reset(reset),
        .SCL(SCL),
        .SDA(SDA)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1; stop = 0;
        #10;
        reset = 0 ;

        @(posedge clk);
        start = 1; tx_data = 8'h02;
        @(posedge clk);
        wait(tx_done == 1);
        start = 0;

         @(posedge clk);
        tx_data = 8'haa;
        @(posedge clk);
        wait(tx_done == 1); 
        
        @(posedge clk);
        tx_data = 8'h55;
        @(posedge clk);
        wait(tx_done == 1); 

        @(posedge clk);
        stop = 1;

        #2000;
        $finish;

    end
endmodule
