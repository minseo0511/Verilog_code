`timescale 1ns / 1ps

module tb_fifo_loop();

    reg clk, reset; 
    reg rx;
    wire tx;

    wire w_rx_done, w_tx_done;
    wire full_rx, empty_rx, full_tx, empty_tx;
    wire [7:0] data_rx_tx, rdata_tx, wdata_rx;

    uart DUT_uart(
        .clk(clk),
        .rst(reset),
        .btn_start(~empty_tx),
        .tx_data_in(rdata_tx),
        .tx(tx),
        .tx_done(w_tx_done),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(wdata_rx)
    );

    fifo DUT_fifo_RX(
        .clk(clk),
        .reset(reset),
        .wdata(wdata_rx),
        .wr(w_rx_done),
        .rd(~full_tx),
        .full(full_rx),
        .empty(empty_rx),
        .rdata(data_rx_tx)
    );

    fifo DUT_fifo_TX(
        .clk(clk),
        .reset(reset),
        .wdata(data_rx_tx),
        .wr(~empty_rx),
        .rd(~w_tx_done), 
        .full(full_tx),
        .empty(empty_tx),
        .rdata(rdata_tx)
    );
    always #1 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        rx = 1;

        #20 
        reset = 0;
        #2
        rx = 0; #10417; send_bit(8'h68); rx = 1; #31248; // 'h'
        #2
        rx = 0; #10417; send_bit(8'b01100101); rx = 1; #31248; // 'e'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h6F); rx = 1; #31248; // 'o'

        #500;

        rx = 0; #10417; send_bit(8'h77); rx = 1; #31248; // 'w'
        #2
        rx = 0; #10417; send_bit(8'h6F); rx = 1; #31248; // 'o'
        #2
        rx = 0; #10417; send_bit(8'h72); rx = 1; #31248; // 'r'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h64); rx = 1; #31248; // 'd'
        #2
        rx = 0; #10417; send_bit(8'h68); rx = 1; #31248; // 'h'
        #2
        rx = 0; #10417; send_bit(8'b01100101); rx = 1; #31248; // 'e'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h6F); rx = 1; #31248; // 'o'
        #2
        rx = 0; #10417; send_bit(8'h68); rx = 1; #31248; // 'h'
        #2
        rx = 0; #10417; send_bit(8'b01100101); rx = 1; #31248; // 'e'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h6C); rx = 1; #31248; // 'l'
        #2
        rx = 0; #10417; send_bit(8'h6F); rx = 1; #31248; // 'o'

        #10000;
        $finish;
    end

    task send_bit(input [7:0] data);
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #20834;
        end
    endtask

endmodule