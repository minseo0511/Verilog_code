`timescale 1ns / 1ps

module tb_ultrasonic_sencor();

    reg clk;
    reg reset;
    reg btn_trig;
    reg echo;
    wire [8:0] distance;
    wire echo_done;

    TOP_UltrasonicSensor DUT(
        .clk(clk),
        .reset(reset),
        .btn_trig(btn_trig),
        .echo(echo),
        .distance(distance),
        .echo_done(echo_done)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        btn_trig = 0;
        echo = 0;

        #10;
        reset = 0;

        #100;
        btn_trig = 1;
        #10;
        btn_trig = 0;

        #5000 echo = 1;
        #1000000 echo = 0;  // 1ms
        
        #2000 btn_trig = 1;
        #2000 btn_trig = 0;
        #10000 echo = 1;
        #200000 echo = 0;

        #10;
        $stop;
    end
endmodule
