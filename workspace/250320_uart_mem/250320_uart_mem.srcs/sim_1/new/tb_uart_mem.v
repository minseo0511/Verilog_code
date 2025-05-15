`timescale 1ns / 1ps

module tb_uart_mem();

    reg clk;
    reg reset;
    reg wr;
    reg rd;
    reg rx;
    wire tx;
    wire full;
    wire empty;

    uart_mem DUT(
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .rd(rd),
        .rx(rx),
        .tx(tx),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;
    reg rx_reg;

    parameter BIT = 20;
    integer i;

    initial begin
        clk = 0;
        reset = 1;
        wr = 0;
        rd = 0;
        rx = 0;

        #10;
        reset = 0;
        @(posedge clk);
        wr = 1;
        for (i = 0;i < 2**BIT-1; i = i + 1) begin
            @(posedge clk);
            rx_reg = $random % 1'b1;
            rx = rx_reg;
        end
        wr = 0;
        rd = 1;
        $stop;
    end

endmodule
