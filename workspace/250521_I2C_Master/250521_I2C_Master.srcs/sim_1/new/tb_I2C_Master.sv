`timescale 1ns / 1ps

module tb_I2C_Master();

    logic clk;
    logic reset;
    logic [7:0] tx_data;
    logic tx_done;
    logic ready;
    logic start;
    logic stop;
    logic SCL;
    logic SDA;

    I2C_Master dut(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .ready(ready),
        .start(start),
        .stop(stop),
        .SCL(SCL),
        .SDA(SDA)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1;
        #10;
        reset = 0;

        @(posedge clk);
        start = 1; tx_data = 8'h01;
        @(posedge clk);
        wait(tx_done == 1); 

        @(posedge clk);
        tx_data = 8'haa;
        @(posedge clk);
        wait(tx_done == 1); 
        
        @(posedge clk);
        tx_data = 8'h55;
        @(posedge clk);
        start = 0;
        wait(tx_done == 1); 
        
        @(posedge clk);
        stop = 1;
        @(posedge clk);

        #2000;
        $finish;
    end

endmodule
