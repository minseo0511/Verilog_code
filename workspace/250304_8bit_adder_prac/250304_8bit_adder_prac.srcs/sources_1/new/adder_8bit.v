`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/04 08:32:36
// Design Name: 
// Module Name: adder_8bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_8bit(
    input [7:0] a,b,
    output [7:0] s,
    output c
    );
    wire [7:0] w_cin;

    half_adder U_HA3(
        .a(a[0]),
        .b(b[0]),
        .s(s[0]),
        .c(w_cin[0])
    );

    full_adder U_FA1(
        .a(a[1]),
        .b(b[1]),
        .cin(w_cin[0]),
        .s(s[1]),
        .c(w_cin[2])
    );

    full_adder U_FA2(
        .a(a[2]),
        .b(b[2]),
        .cin(w_cin[1]),
        .s(s[2]),
        .c(w_cin[3])
    );

    full_adder U_FA3(
        .a(a[3]),
        .b(b[3]),
        .cin(w_cin[2]),
        .s(s[3]),
        .c(w_cin[4])
    );
    full_adder U_FA4(
        .a(a[4]),
        .b(b[4]),
        .cin(w_cin[3]),
        .s(s[4]),
        .c(w_cin[5])
    );
    full_adder U_FA5(
        .a(a[5]),
        .b(b[5]),
        .cin(w_cin[4]),
        .s(s[5]),
        .c(w_cin[6])
    );
    full_adder U_FA6(
        .a(a[6]),
        .b(b[6]),
        .cin(w_cin[5]),
        .s(s[6]),
        .c(w_cin[7])
    );
    full_adder U_FA7(
        .a(a[7]),
        .b(b[7]),
        .cin(w_cin[6]),
        .s(s[7]),
        .c(c)
    );

endmodule

module full_adder (
    input a,
    input b,
    input cin,
    output s,
    output c
);
    wire w_c1, w_c2, w_s;

    half_adder U_HA1(
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_c1)
    );

    half_adder U_HA2(
        .a(w_s),
        .b(b),
        .s(s),
        .c(w_c2)
    );
    assign c = w_c1 | w_c2;

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