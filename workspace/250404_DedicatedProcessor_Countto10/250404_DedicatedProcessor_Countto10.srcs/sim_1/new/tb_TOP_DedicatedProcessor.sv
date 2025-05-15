`timescale 1ns / 1ps

module tb_TOP_DedicatedProcessor();
    reg clk;
    reg reset;
    wire [7:0] outPort;

    TOP_DedicatedProcessor DUT(
        .clk(clk),
        .reset(reset),
        .outPort(outPort)
    );

    always #5 clk = ~clk;
    integer i;
    initial begin
        clk = 0;
        reset = 1;

        #10;
        reset = 0;
        #200;
        $stop;
    end 
endmodule
