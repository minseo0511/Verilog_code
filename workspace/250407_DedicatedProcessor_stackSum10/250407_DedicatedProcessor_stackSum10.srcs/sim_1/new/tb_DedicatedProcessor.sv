`timescale 1ns / 1ps

module tb_DedicatedProcessor();

    logic clk, reset;
    logic [7:0] outPort;

    TOP_DedicatedProcessor DUT(.*);

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;

        #10;
        reset = 0;

    end
endmodule
