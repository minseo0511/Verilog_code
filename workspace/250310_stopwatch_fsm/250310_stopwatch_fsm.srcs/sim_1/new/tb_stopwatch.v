`timescale 1ns / 1ps

module tb_stopwatch();

    reg clk, reset, run, clear;
    wire [6:0]msec;
    wire [5:0]sec, min;
    wire [4:0] hour;
    
    stopwatch_dp DUT(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; run = 0; clear = 0;
        // vector
        #10;
        reset = 0; 
        run = 1;
        
        wait(sec == 2); 

        #10; run = 0;
    end

endmodule
