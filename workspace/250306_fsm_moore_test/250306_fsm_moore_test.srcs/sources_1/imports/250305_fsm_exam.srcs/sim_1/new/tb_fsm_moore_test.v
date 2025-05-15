module fsm_moore_tb;
    reg clk;
    reg reset;
    reg [2:0] sw;
    wire [2:0] led_moore;
    parameter CLK_PERIOD = 10;

    // Moore FSM DUT
    fsm_exam DUT_moore (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led_moore)
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

        // Moore Machine 테스트
        $display("[Moore Machine Test]");
        sw = 3'b001; // IDLE -> ST1, led = 000 (클록 엣지 후 변경)
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        sw = 3'b010; // ST1 -> ST2
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        sw = 3'b100; // ST2 -> ST3
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        sw = 3'b000; // ST3 -> IDLE
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        #5;
        $display("Time=%0t, LED=%b", $time, led_moore);
        
        #100;
        $finish;
    end
endmodule