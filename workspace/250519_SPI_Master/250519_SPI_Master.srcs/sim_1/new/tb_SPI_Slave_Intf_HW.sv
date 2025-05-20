`timescale 1ns / 1ps

module tb_SPI_Slave_Intf_HW();

    logic SCLK;
    logic reset;
    logic MOSI;
    logic MISO;
    logic SS;
    logic write;
    logic [1:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;

    SPI_Slave_Intf_hw dut(
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

    always #5 SCLK = ~SCLK;
    initial begin
       SCLK = 0; reset = 1; SS = 1;
       #7; reset = 0;
       

        SS = 0; rdata = 8'haa; // write addr = 2
        //1
        @(negedge SCLK);
        MOSI = 1;
        //2
        @(negedge SCLK);
        MOSI = 0;
        //3
        @(negedge SCLK);
        MOSI = 1;
        //4
        @(negedge SCLK);
        MOSI = 0;
        //5
        @(negedge SCLK);
        MOSI = 1;
        //6
        @(negedge SCLK);
        MOSI = 0;
        //7
        @(negedge SCLK);
        MOSI = 1;
        //8
        @(negedge SCLK);
        MOSI = 0;
       @(negedge SCLK);
       

       @(posedge SCLK);
        SS = 0; rdata = 8'haf; // write 
        //1
        @(negedge SCLK);
        MOSI = 1;
        //2
        @(negedge SCLK);
        MOSI = 0;
        //3
        @(negedge SCLK);
        MOSI = 1;
        //4
        @(negedge SCLK);
        MOSI = 0;
        //5
        @(negedge SCLK);
        MOSI = 1;
        //6
        @(negedge SCLK);
        MOSI = 0;
        //7
        @(negedge SCLK);
        MOSI = 1;
        //8
        @(negedge SCLK);
        MOSI = 0;
       @(negedge SCLK);

        @(posedge SCLK);
        SS = 1; 
       @(negedge SCLK);


       @(posedge SCLK);
        SS = 0; rdata = 8'h0a; // read 
        repeat(8) @(negedge SCLK);

        #200;
        $finish;
    end
endmodule


