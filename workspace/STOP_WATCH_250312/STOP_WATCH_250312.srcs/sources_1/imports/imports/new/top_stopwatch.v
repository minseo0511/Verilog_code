`timescale 1ns / 1ps

module Final(
    input clk, reset,
    input sw_mode3,
    input sw_mode2,  
    input sw_mode,
    input btn_left, btn_down, btn_right,  
    output [4:0] led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
);
    wire [6:0] w_msec;
    wire [5:0] w_sec, w_min;
    wire [4:0] w_hour;
    
    wire [6:0] w_clk_msec;
    wire [5:0] w_clk_sec, w_clk_min;
    wire [4:0] w_clk_hour;

    wire [6:0] w_stopwatch_msec;
    wire [5:0] w_stopwatch_sec, w_stopwatch_min;
    wire [4:0] w_stopwatch_hour;

    // 시계 
    CLOCK_final U_CLOCK(
        .cs_clock(sw_mode2), // 증가
        .sw_mode(sw_mode3), // 감소
        .clk(clk), 
        .reset(reset),
        .btn_left(w_btn_left), 
        .btn_down(w_btn_down), 
        .btn_right(w_btn_right),
        .clk_msec(w_clk_msec),
        .clk_sec(w_clk_sec),
        .clk_min(w_clk_min),
        .clk_hour(w_clk_hour)
        // .led(led),
        // .fnd_comm(fnd_comm),
        // .fnd_font(fnd_font)
    );
    // 스탑워치
    top_stopwatch U_Stopwatch(
        .cs_stopwatch(sw_mode2),
        .clk(clk), 
        .reset(reset),
        .btn_left(w_btn_left),
        .btn_right(w_btn_right),
        .msec(w_stopwatch_msec),
        .sec(w_stopwatch_sec),
        .min(w_stopwatch_min),
        .hour(w_stopwatch_hour)
    );

    // MUX
    mux_8x4 U_MUX_8x4(
        .sw_mode2(sw_mode2),  // 시계 또는 스탑워치 모드 선택
        // .sw_mode3(sw_mode3),
        .msec(w_stopwatch_msec), 
        .sec(w_stopwatch_sec), 
        .min(w_stopwatch_min), 
        .hour(w_stopwatch_hour),
        .clk_msec(w_clk_msec), 
        .clk_sec(w_clk_sec), 
        .clk_min(w_clk_min), 
        .clk_hour(w_clk_hour),
        .bcd_msec(w_msec), 
        .bcd_sec(w_sec), 
        .bcd_min(w_min), 
        .bcd_hour(w_hour)
    );

    // FND 출력 제어
    fnd_controller U_Fnd_Ctrl(
        .clk(clk), 
        .reset(reset),
        .msec(w_msec), 
        .sec(w_sec), 
        .min(w_min), 
        .hour(w_hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm),
        .sw_mode(sw_mode)
    );

    btn_debounce U_Btn_DB_left(
        .clk(clk), 
        .reset(reset),
        .i_btn(btn_left),
        .o_btn(w_btn_left)
    );

    btn_debounce U_Btn_DB_down(
        .clk(clk), 
        .reset(reset),
        .i_btn(btn_down),
        .o_btn(w_btn_down)
    );

    btn_debounce U_Btn_DB_right(
        .clk(clk), 
        .reset(reset),
        .i_btn(btn_right),
        .o_btn(w_btn_right)
    );

    wire [2:0] sw;
    assign sw = {sw_mode3, sw_mode2, sw_mode}; // sw2 sw1 sw0

    led U_led(
        .sw(sw), 
        .led(led)
    );

endmodule



// MUX 
module mux_8x4(
    input sw_mode2,  // 모드 선택
    input [6:0] msec, 
    input [5:0] sec, min, 
    input [4:0] hour,
    input [6:0] clk_msec, 
    input [5:0] clk_sec, clk_min, 
    input [4:0] clk_hour,
    output reg [6:0] bcd_msec,
    output reg [5:0] bcd_sec, bcd_min,
    output reg [4:0] bcd_hour
);

    always@(*) begin
        case(sw_mode2)
            1'b0: begin  // 스탑워치 모드
                bcd_msec = msec;
                bcd_sec = sec;
                bcd_min = min;
                bcd_hour = hour;
            end
            1'b1: begin  // 시계 모드
                bcd_msec = clk_msec;
                bcd_sec = clk_sec;
                bcd_min = clk_min;
                bcd_hour = clk_hour;
            end
            default: begin  // 기본값
                bcd_msec = 7'b0000000;
                bcd_sec = 6'b000000;
                bcd_min = 6'b000000;
                bcd_hour = 5'b00000;
            end
        endcase
    end

endmodule




// 스탑워치
module top_stopwatch(
    input reset, clk,
    input cs_stopwatch,
    input btn_left,
    input btn_right,
    // input sw_mode,
    output [6:0] msec, 
    output [5:0] sec, min,
    output [4:0] hour
    // output [1:0] led,
    // output [3:0] fnd_comm,
    // output [7:0] fnd_font
    );

    wire run, clear;

    // instance
    stopwatch_dp U_Stopwatch_DP(
        .clk(clk), 
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec), 
        .sec(sec), 
        .min(min), 
        .hour(hour)
    );

    stopwatch_cu U_Stopwatch_CU(
        .cs(cs_stopwatch),
        .clk(clk), 
        .reset(reset), 
        .btn_left(btn_left), 
        .btn_right(btn_right), 
        .o_run(run), 
        .o_clear(clear)
    );

endmodule

module led(
    input [2:0] sw, 
    output reg [4:0] led
);
    always@(*) begin
    case(sw)
        3'b000: begin led = 5'b00001;  end // msec_sec
        3'b001: begin led = 5'b00010; end // min_hour
        3'b010: begin led = 5'b00100; end 
        3'b011: begin led = 5'b01000; end 
        default: begin led = 5'b10000; end
    endcase

    end

endmodule