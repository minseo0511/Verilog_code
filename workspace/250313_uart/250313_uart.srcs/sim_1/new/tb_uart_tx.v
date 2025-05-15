`timescale 1ns / 1ps

module tb_uart_tx();

    reg clk, rst, tx_start_trig;
    wire tx;

    send_tx_btn DUT(
        .clk(clk),
        .rst(rst),
        .btn_start(tx_start_trig),
        .tx(tx)
    );
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        tx_start_trig = 1'b0;

        #20 rst = 1'b0;
        #10000000 tx_start_trig = 1'b1;
        #10000000 tx_start_trig = 1'b0;
        #10000000 tx_start_trig = 1'b1;
        #10000000 tx_start_trig = 1'b0;

    end

endmodule
