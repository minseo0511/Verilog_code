`timescale 1ns / 1ps

module tb_uart();

    reg clk, reset, tx_start, rx;
    reg [7:0] tx_data;
    wire tx_busy, tx_done, tx, rx_done;
    wire [7:0] rx_data;

    uart DUT(
    // global port
        .clk(clk),
        .reset(reset),
    // tx port
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx),
    // rx port
        .rx(tx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;

        #10;
        reset = 0;
        @(posedge clk);
        #1 tx_data = 8'b11001010; tx_start = 1;
        @(posedge clk);
        #1 tx_start = 0;
        @(posedge rx_done);
        #20;
        $finish;
    end
endmodule
