`timescale 1ns / 1ps

module tb_uart_tx_periph;

    logic        PCLK;
    logic        PRESET;
    logic [ 4:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        tx;

    UART_Periph dut (
        .PCLK(PCLK),
        .PRESET(PRESET),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PSEL(PSEL),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .tx(tx)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK; // 100MHz

    // Test procedure
    initial begin
        PRESET = 1;
        PADDR  = 0;
        PWDATA = 0;
        PWRITE = 0;
        PENABLE = 0;
        PSEL = 0;

        #20; PRESET = 0;

        // 1. Set baud rate = 16 (just fast for sim)
        apb_write(5'h0C, 32'h00000010); // BRR register

        // 2. Enable UART (UCR: enable=1, tx_enable=1, trigger=0)
        apb_write(5'h10, 32'b0000_0000_0000_0000_0000_0000_0000_0011);

        // 3. Write 4 bytes
        apb_write(5'h04, 32'h000000A5);
        @(posedge PCLK);
        apb_write(5'h04, 32'h0000005A);
        @(posedge PCLK);
        apb_write(5'h04, 32'h0000006A);
        @(posedge PCLK);
        apb_write(5'h04, 32'h0000007A);
        @(posedge PCLK);

        // 4. read
        apb_read(5'h08);

        // 5. Trigger UART TX (UCR[3] = 1)
        apb_write(5'h10, 32'b0000_0000_0000_0000_0000_0000_0000_1011);
        // @(posedge PCLK);
        // apb_write(5'h10, 32'b0000_0000_0000_0000_0000_0000_0000_0011);


        // 5. Poll FSR (watch for tx_done)
        repeat (20) begin
            apb_read(5'h00);
            #20;
        end

        #200;
        $finish;
    end

    // APB Write task
    task apb_write(input logic [4:0] addr, input logic [31:0] data);
    begin
        @(posedge PCLK);
        PSEL   <= 1'b1;
        PENABLE <= 1'b0;
        PWRITE <= 1'b1;
        PADDR  <= addr;
        PWDATA <= data;

        @(posedge PCLK);
        PENABLE <= 1'b1;

        wait (PREADY == 1);
        @(posedge PCLK);
        PSEL <= 0;
        PENABLE <= 0;
        PWRITE <= 0;
        PWDATA <= 0;
    end
    endtask

    // APB Read task
    task apb_read(input logic [4:0] addr);
    begin
        @(posedge PCLK);
        PSEL   <= 1'b1;
        PENABLE <= 1'b0;
        PWRITE <= 1'b0;
        PADDR  <= addr;

        @(posedge PCLK);
        PENABLE <= 1'b1;

        wait (PREADY == 1);
        @(posedge PCLK);
        $display("[%0t ns] READ Addr=0x%0h -> Data=0x%0h", $time, addr, PRDATA);

        PSEL <= 0;
        PENABLE <= 0;
    end
    endtask

endmodule