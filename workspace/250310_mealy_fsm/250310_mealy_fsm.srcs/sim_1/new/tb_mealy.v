`timescale 1ns / 1ps

module tb_mealy();
  reg clk, rst_n, x;
  wire z;
  
  fsm_mealy sd(
    .clk(clk), 
    .rst_n(rst_n), 
    .x(x), 
    .z(z)
);
  initial clk = 0;   
  always #5 clk = ~clk;
    
  initial begin
    x = 0;
    #10 rst_n = 0;
    #20 rst_n = 1;
    
    #10 x = 1;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 1;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10;
    $finish;
  end
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule