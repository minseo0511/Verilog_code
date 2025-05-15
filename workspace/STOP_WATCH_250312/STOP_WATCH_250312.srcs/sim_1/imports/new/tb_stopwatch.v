`timescale 1ns / 1ps

module tb_stopwatch();

    reg clk, reset, run, clear; 
    reg sw_mode; 
    reg [6:0] msec; 
    reg [5:0] sec, min; 
    reg [4:0] hour;
    wire fnd_font, fnd_comm;

    // dp를 불러와야지 time 불러올 수 있음 
    stopwatch_dp dut(
        .clk(clk), 
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec), 
        .sec(sec), 
        .min(min), 
        .hour(hour)
    );

    fnd_controller DUT(
        .clk(clk), 
        .reset(reset),
        .msec(msec), 
        .sec(sec), 
        .min(min), 
        .hour(hour),
        .sw_mode(sw_mode),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );




    always #5 clk = ~clk;   // clk 생성.

    initial begin
        // 초기화
        clk = 0; 
        reset = 1; 
        run = 0; 
        clear = 0;
        // vector. --> clk
        
        #10; // 10나노 뒤에 run 활성화
        reset = 0;
        run = 1;
        wait ( hour == 23 ); // 23시간 대기
        
        wait ( hour == 1 );

        #10; 
        run = 0;    // stop
        repeat(4) @(posedge clk) // 4번 반복, clk posedge 이벤트
        clear = 1;

    end

endmodule
