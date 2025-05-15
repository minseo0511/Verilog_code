`timescale 1ns / 1ps

module tb_APB_fifo();

    logic        PCLK;
    logic        PRESET;
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;

    fifo_peri dut(
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
        PCLK       = 0;
        PRESET     = 1;
        #10 PRESET = 0;
        @(posedge PCLK);

        // write 3 in fwd
        PADDR      = 4;
        PWDATA     = 3;
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);

        // write 5 in fwd
        PADDR      = 4;
        PWDATA     = 5;
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);
        
        // write 6 in fwd
        PADDR      = 4;
        PWDATA     = 6;
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);

        // read 3 in fwd
        PADDR      = 8;
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);
        
        // write 7 in fwd
        PADDR      = 4;
        PWDATA     = 7;
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);
        
        // write 8 in fwd
        PADDR      = 4;
        PWDATA     = 8;
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);

        // write 9 in fwd  (full!)
        PADDR      = 4;
        PWDATA     = 9;
        PWRITE     = 1;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);


        // read 5 in fwd
        PADDR      = 8;
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;
        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);
        
        // read 6 in fwd
        PADDR      = 8;
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;

        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);

        // read 7 in fwd
        PADDR      = 8;
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;
        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);
       
        // read 8 in fwd
        PADDR      = 8;
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;
        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);
        
        // read 9 in fwd (empty)
        PADDR      = 8;
        PWRITE     = 0;
        PSEL       = 1;
        PENABLE    = 1;
        @(posedge PCLK);
        PSEL       = 0;
        PENABLE    = 0;
        wait(PREADY);
        @(posedge PCLK);
        @(posedge PCLK);
        @(posedge PCLK);

        end

endmodule
