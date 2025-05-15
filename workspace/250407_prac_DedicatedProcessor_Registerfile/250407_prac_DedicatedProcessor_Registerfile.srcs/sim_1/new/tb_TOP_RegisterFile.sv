`timescale 1ns / 1ps

module tb_TOP_RegisterFile();

    logic clk;
    logic reset;
    logic [7:0] outPort;

    TOP_Registerfile DUT(
        .clk(clk),
        .reset(reset),
        .outPort(outPort)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
    end
endmodule
