`timescale 1ns / 1ps

module tb_TOP_SPI();

    logic clk;
    logic rst;
    logic btn;
    logic [13:0] swtich;
    logic [3:0] fndCom;
    logic [7:0] fndFont;

    TOP_SPI dut(
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .swtich(swtich),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0; rst = 1;
        #10;
        rst = 0;
        
        #100;
        btn = 1; swtich = 14'b10_1100_0110_0011;
        #10000; btn = 0;

        #2000000;

        #100;
        btn = 1; swtich = 14'b11_1111_1111_1111;
        #10000; btn = 0;

        #2000;
        $finish;
    end

endmodule
