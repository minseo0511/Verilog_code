`timescale 1ns / 1ps
module tb_adder_4bit();

    reg in1,in_1,in2,in_2,in3,in_3,in4,in_4;
    wire s1,s2,s3,s4; 
    
    adder_4bit u_adder_4bit( //modulte instance화
        .in1(in1),
        .in_1(in_1),
        .in2(in2),
        .in_2(in_2),
        .in3(in3),
        .in_3(in_3),
        .in4(in4),
        .in_4(in_4),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .s4(s4)
    );
    initial
        begin  //begin ~ end 일때 시간이 누적이다. 
            #10 in_4=0; in4=0; in_3=0; in3=0; in_2=0; in2=0; in_1=0; in1=0; //10ns
            #10 in_4=0; in4=0; in_3=0; in3=0; in_2=0; in2=0; in_1=0; in1=1; //10ns
            #10 in_4=0; in4=0; in_3=0; in3=0; in_2=0; in2=0; in_1=1; in1=1; //10ns
            #10 in_4=0; in4=0; in_3=0; in3=0; in_2=0; in2=1; in_1=1; in1=1; //10ns
            #10 in_4=0; in4=0; in_3=0; in3=0; in_2=1; in2=1; in_1=1; in1=1; //10ns
            #10 in_4=0; in4=0; in_3=0; in3=1; in_2=1; in2=1; in_1=1; in1=1; //10ns
            #10 in_4=0; in4=0; in_3=1; in3=1; in_2=1; in2=1; in_1=1; in1=1; //10ns
            #10 in_4=0; in4=1; in_3=1; in3=1; in_2=1; in2=1; in_1=1; in1=1; //10ns
            #10 in_4=1; in4=1; in_3=1; in3=1; in_2=1; in2=1; in_1=1; in1=1; //10ns            
            #10
            $stop;
        end
endmodule
