`timescale 1ns / 1ps

module tb_I2C_Master();

    logic clk;
    logic reset;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic tx_done;
    logic ready;
    logic start;
    logic stop;
    logic SCL;
    wire SDA;

    logic rd_wr_reg;
    logic SDA_read;

    assign SDA = rd_wr_reg ?  SDA_read : 1'bz;

    I2C_Master dut(
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

    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1; stop = 0;
        #10;
        reset = 0;

        rd_wr_reg = 0;

        @(posedge clk);
        start = 1; tx_data = 8'h00;
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
        wait(SCL == 1);
        wait(SCL == 0);
        stop = 0;
        @(posedge clk);
       
        @(posedge clk);
        start = 1; tx_data = 8'h01;
        wait(SCL == 1);
        wait(SCL == 0);
        start = 0; 
        @(posedge clk);
        wait(tx_done == 1); 

        @(posedge clk);
        rd_wr_reg = 1;
        wait(SCL == 1);
        wait(SCL == 0);
        for(int i=0;i<4;i=i+1) begin
            wait(SCL == 1);
            SDA_read = 1'b1;
            wait(SCL == 0);

            wait(SCL == 1);
            SDA_read = 1'b0;
            wait(SCL == 0);
        end    
        @(posedge clk);
        wait(tx_done == 1); 
        @(posedge clk);
        stop = 1;
        @(posedge clk); 

        #2000;
        $finish;
    end

endmodule

