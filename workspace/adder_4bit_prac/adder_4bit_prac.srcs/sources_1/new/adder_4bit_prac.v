`timescale 1ns / 1ps

module adder_4bit_prac(
    input a[3:0],
    input b[3:0],
    output s[4:0]
    );
    wire c[2:0];
    half_adder HA1_1(
        .a(a[0]),
        .b(b[0]),
        .s(s[0]),
        .c(c[0])
    );
    
    full_adder FA1(
        .a(a[1]),
        .b(b[1]),
        .cin(c[0]),
        .s(s[1]),
        .c(c[1])
    );
    
    full_adder FA2(
        .a(a[2]),
        .b(b[2]),
        .cin(c[1]),
        .s(s[2]),
        .c(c[2])
    );
    
    full_adder FA3(
        .a(a[3]),
        .b(b[3]),
        .cin(c[2]),
        .s(s[3]),
        .c(s[4])
    );
endmodule

module half_adder(
    input a,
    input b,
    output s,
    output c
);
    assign s = a ^ b;
    assign c = a & b;
endmodule

module full_adder(
    input a,
    input b,
    input cin,
    output s,
    output c
);
    half_adder HA1(
        .a(a),
        .b(b),
        .s(s1),
        .c(c1)
    );
    half_adder HA2(
        .a(s1),
        .b(cin),
        .s(s),
        .c(c2)
    );
    
    wire s1, c1, c2;
    
    assign c = c1 | c2;
    
endmodule