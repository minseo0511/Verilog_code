`timescale 1ns / 1ps

module tb_top_switch_clk_timer();

    // 입력 신호
    reg clk;
    reg reset;
    reg [1:0] sw;
    reg btnL, btnR, btnU, btnD;

    // 출력 신호
    wire [1:0] led;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    // 테스트할 DUT 인스턴스
    top_switch_clk_timer uut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .led(led),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );

    // 클럭 생성 : 100MHz (10ns 주기)
    always #5 clk = ~clk;

    // 초기화 및 테스트 벡터
    initial begin
        // 초기값 설정
        clk = 0;
        reset = 1;
        sw = 2'b00;
        btnL = 0;
        btnR = 0;
        btnU = 0;
        btnD = 0;

        // 초기화 기간 (리셋 유지)
        #100;
        reset = 0;

        // 테스트 시나리오 1: 스위치 0 (스톱워치 모드), 버튼 Left로 run, Right로 clear
        $display("------ Stopwatch Mode 테스트 시작 ------");
        sw = 2'b00; // 스톱워치 모드
        btnL = 1; #20; btnL = 0; // run 버튼 눌렀다 뗌
        #1000;

        btnR = 1; #20; btnR = 0; // clear 버튼 눌렀다 뗌
        #1000;

        // 테스트 시나리오 2: 스위치 1 (시간 설정 모드), 버튼으로 시간 증가
        $display("------ Clock 설정 Mode 테스트 시작 ------");
        sw = 2'b10; // 시간 설정 모드 (sw[1] = 1, sw[0] = 0)
        
        btnL = 1; #20; btnL = 0; // Hour 증가 (Left 버튼)
        #500;

        btnD = 1; #20; btnD = 0; // Minute 증가 (Down 버튼)
        #500;

        btnU = 1; #20; btnU = 0; // Second 증가 (Up 버튼)
        #500;

        // 테스트 시나리오 3: 스위치 상태 변경 확인 (swap_switch 동작 확인)
        $display("------ FND swap 테스트 시작 ------");
        sw = 2'b11; // sw[1]=1 (Clock 설정), sw[0]=1 (swap active)
        #1000;

        // 종료
        $display("------ 테스트 종료 ------");
        #5000;
        $stop;
    end
endmodule

