`timescale 1ns / 1ps


module tb_fnd();

    reg clk, reset; 
    reg sw_mode; 
    reg [6:0] msec; 
    reg [5:0] sec, min; 
    reg [4:0] hour;
    wire fnd_font, fnd_comm;

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

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        reset = 1;
        sw_mode = 0; // 초기 모드 설정
        msec = 0;    // 초기 msec 값
        sec = 0;     // 초기 sec 값
        min = 0;     // 초기 min 값
        hour = 0;    // 초기 hour 값

        #10; 
        reset = 0;


        for(i=0; i<10000; i=i+1) begin
            msec = msec + 1;
            if (msec == 100) begin
                msec = 0;
                sec = sec + 1;
                if (sec == 60) begin
                    sec = 0;
                    min = min + 1;
                    if (min == 60) begin
                        min = 0;
                        hour = hour + 1;
                        if (hour == 24) begin
                            hour = 0;
                        end
                    end
                end
            end
            #10; // 10ns씩 대기하며 시간 증가
        end

        // 특정 시간 대기 (예: 2시간 대기)
        #1000; // 2시간 대기

        // 특정 시간에 대한 시나리오 확인
        // wait (hour == 2); // hour가 2일 때까지 기다리기
        // wait (hour == 1); // hour가 1일 때까지 기다리기
    end

endmodule