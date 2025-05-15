`timescale 1ns / 1ps

module tb_adder();
    
    reg a,b,cin; //reg
    wire c,s;
    
    full_adder u_full_adder( //modulte instance화
        .a(a),
        .b(b),
        .cin(cin), // FA input carry
        .s(s),
        .c(c)
    );
    initial
        begin  //begin ~ end 일때 시간이 누적이다. 
            #10 a=0; b=0; cin=0; //10ns
            #10 a=1; b=0; cin=0; //20ns
            #10 a=0; b=1; cin=0; //30ns
            #10 a=1; b=1; cin=0; //40ns
            #10 a=0; b=0; cin=1; //50ns
            #10 a=1; b=0; cin=1; //60ns
            #10 a=0; b=1; cin=1; //70ns
            #10 a=1; b=1; cin=1; //80ns
            #10
            $stop;
        end
    
endmodule
