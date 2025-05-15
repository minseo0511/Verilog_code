`timescale 1ns / 1ps

module tb_fsm_mealy_test();
    reg clk;
    reg reset;
    reg [2:0] sw;
    wire [2:0] led;
    parameter CLK_PERIOD = 10;

    // DUT (Device Under Test) 인스턴스화
    fsm_mealy_test DUT (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
    );

    // Clock 생성
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        // 초기 설정
        clk = 0;
        reset = 1;
        sw = 3'b000;
        #20;
        reset = 0;

        // Mealy Machine 테스트 (입력 변화에 즉각 반응 확인)
        $display("[Mealy Machine Test]");
        sw = 3'b001; // IDLE -> ST1, led = 001
        #10;
        sw = 3'b010; // ST1 -> ST2, led = 010
        #10;
        sw = 3'b100; // ST2 -> ST3, led = 100
        #10;
        sw = 3'b000; // ST3 -> IDLE, led = 000
        #10;
        sw = 3'b111; // IDLE 유지, led = 000
        #10;
        
        #100;
        $finish;
    end
endmodule
