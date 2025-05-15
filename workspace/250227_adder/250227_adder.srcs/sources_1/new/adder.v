`timescale 1ns / 1ps
module adder_4bit(
    input in1,
    input in2,
    input in3,
    input in4,
    input in5,
    input in6,
    input in7,
    input in8,
    output s1,
    output s2,
    output s3,
    output s4
);
    wire c1,c2,c3,c4;
   
    half_adder F_HA1(
        .a(in1),
        .b(in2),
        .s(s1),
        .c(c1),
    );
    
    full_adder F_FA1(
        .a(in3),
        .b(in4),
        .cin(c1),
        .s(s2),
        .c(c2)    
    );
    
    full_adder F_FA2(
        .a(in5),
        .b(in6),
        .cin(c2),
        .s(s3),
        .c(c3)    
    );
    
    full_adder F_FA1(
        .a(in7),
        .b(in8),
        .cin(c3),
        .s(s4),
        .c(c4)    
    );
    

endmodule

// 1bit full adder
module full_adder(
    input a,
    input b,
    input cin,
    output s,
    output c
);
    wire w_s; //wiring U_HA1 out s to U_HA2 in a
    wire w_c1, w_c2;
    
    half_adder U_HA1(
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_c1)
    );
    
    half_adder U_HA2(
        .a(w_s),
        .b(cin),
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
    // 1bit half adder
    assign s = a ^ b;
    assign c = a & b; 
endmodule
