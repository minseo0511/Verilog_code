`timescale 1ns / 1ps

module tb_send_tx_btn();

    reg clk;
    reg rst;
    reg btn_start;
    wire tx;

    send_tx_btn DUT(
        .clk(clk),
        .rst(rst),
        .btn_start(btn_start),          // 버튼 입력
        .tx(tx)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        btn_start = 0;

        #10;
        rst = 0;
        #10;
        btn_start = 1;
        #104160;
        btn_start = 0;
        $stop;
    end

endmodule
