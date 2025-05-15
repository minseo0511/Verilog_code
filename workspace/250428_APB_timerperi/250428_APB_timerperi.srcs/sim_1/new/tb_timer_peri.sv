`timescale 1ns / 1ps

module tb_timer_peri();

    logic        PCLK;
    logic        PRESET;
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;

    timer_peri dut(
        .PCLK(PCLK),
        .PRESET(PRESET),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PSEL(PSEL),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );
    always #5 PCLK = ~PCLK;
    initial begin
        PCLK = 0; PRESET = 1;
        #10; PRESET = 0;
        @(posedge PCLK);

        // write enable in TCR
        @(posedge PCLK);
        PADDR      = 0;
        PWDATA     = 1; // clear = 0, enable = 1
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 0;
        @(posedge PCLK);
        PSEL       = 1;
        PENABLE    = 1;
        wait(PREADY);
        
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        // write enable in PSC
        @(posedge PCLK);
        PADDR      = 8;
        PWDATA     = 100000; // FCOUNT
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 0;
        @(posedge PCLK);
        PSEL       = 1;
        PENABLE    = 1;
        wait(PREADY);
        
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        // write enable in ARR
        @(posedge PCLK);
        PADDR      = 12;
        PWDATA     = 100; // count data
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        PSEL       = 1;
        PENABLE    = 0;
        @(posedge PCLK);
        PSEL       = 1;
        PENABLE    = 1;
        wait(PREADY);
        
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        #90000000;
        // read TCNT 
        @(posedge PCLK);
        PADDR      = 4;
        PWDATA     = 0; 
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 0;
        @(posedge PCLK);
        PENABLE    = 1;
        wait(PREADY);
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;
        #1000;
        $finish;
    end
endmodule
