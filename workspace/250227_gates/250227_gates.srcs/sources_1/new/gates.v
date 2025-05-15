`timescale 1ns / 1ps

module gates( //Top module
    input a,
    input b,
    output y0,
    output y1,
    output y2,
    output y3,
    output y4,
    output y5
);
    assign y0 = a & b; //AND
    assign y1 = a | b; //OR
    assign y2 = ~(a & b); //NAND
    assign y3 = a ^ b; //XOR
    assign y4 = ~(a | b); //NOR
    assign y5 = ~a; //NOT
    
endmodule
