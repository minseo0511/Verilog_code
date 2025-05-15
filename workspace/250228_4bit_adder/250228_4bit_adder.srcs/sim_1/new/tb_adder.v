`timescale 1ns / 1ps


module tb_adder();
    reg [7:0]a,b;
    wire [7:0]s;
    wire c;
    
    // uut(Unit Under Test), dut(Design Under Test)
    fa_8 dut (
        .a(a),
        .b(b), 
        .s(s),
        .c(c)
    );
    integer i,j;
    initial begin
        a = 8'h0;
        b = 8'h0;
        #10;
        for(j=1; j<256; j=j*4) begin
            b=j;
            #10;
            for(i = 1; i < 256; i = i *4) begin //verilog 자동 증가 연산X
                a=i;
                #10;
            end
        end
        #10;
        $stop;
    end

endmodule
