`timescale 1ns / 1ps

module calculator (
     input clk,
     input reset,     
     input [7:0]a,
     input [7:0]b,
     output [7:0] seg, 
     output [3:0] seg_comm
);
    wire w_carry;
    wire [7:0]w_s;

    fa_8 U_fa1(
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_carry)
    );

    fnd_controller U_fnd_con(
        .bcd({w_carry, w_s}),  //9bit w_carry, w_s[7:0]
        .clk(clk),
        .reset(reset),
        .seg(seg),
        .seg_comm(seg_comm)
    );

endmodule

module fa_8 (
    input [7:0]a, 
    input [7:0]b,
    output [7:0]s,
    output c
);
    wire w_c1;

    fa_4 U_fa4_1(
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .s(s[3:0]),
        .c(w_c1)
    );  

    fa_4 U_fa4_2(
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(w_c1),
        .s(s[7:4]),
        .c(c)
    );  
endmodule


module fa_4 (
    input [3:0]a, //4bit vector형
    input [3:0]b,
    input cin,
    output [3:0]s,
    output c
);
    wire [2:0]w_c;

    full_adder U_fa0(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .c(w_c[0])
    );
    full_adder U_fa1(
        .a(a[1]),
        .b(b[1]),
        .cin(w_c[0]),
        .s(s[1]),
        .c(w_c[1])
    );
    full_adder U_fa2(
        .a(a[2]),
        .b(b[2]),
        .cin(w_c[1]),
        .s(s[2]),
        .c(w_c[2])
    );
    full_adder U_fa3(
        .a(a[3]),
        .b(b[3]),
        .cin(w_c[2]),
        .s(s[3]),
        .c(c)
    );
endmodule

module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output c
);
    wire w_s, w_c1, w_c2;

    half_adder U_HA1 (
        .a  (a),
        .b  (b),
        .s(w_s),
        .c  (w_c1)
    );

    half_adder U_HA2 (
        .a  (w_s),
        .b  (cin),
        .s(s),
        .c  (w_c2)
    );
    or (c,w_c1,w_c2);

endmodule

module half_adder (
    input  a,    // 1bit wire
    input  b,
    output s,
    output c
);
    //기존 사용한 assign 방식
    //assign sum = a ^ b;
    //assign c = a & b;

    // 게이트 프리미티브 방식
    // Verilog library에서 기본 제공
    xor (s, a, b);  // xor (출력,입력1,입력2,...);
    and (c, a, b);

endmodule
