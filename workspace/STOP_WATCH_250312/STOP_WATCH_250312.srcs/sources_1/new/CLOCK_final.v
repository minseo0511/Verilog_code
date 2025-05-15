`timescale 1ns / 1ps

module CLOCK_final(
    input clk, reset,
    input sw_mode,
    input cs_clock, 
    input btn_left, btn_down, btn_right,
    output [6:0] clk_msec,
    output [5:0] clk_sec, clk_min,
    output [4:0] clk_hour
);
    
    wire w_sec, w_min, w_hour;


    CLOCK_CU U_CU_PLUS_MINUS(
        .cs(cs_clock), // 스위치
        // .cs_minus(cs_minus),
        .clk(clk), 
        .reset(reset),
        .btn_left(btn_left),
        .btn_down(btn_down), 
        .btn_right(btn_right), 
        .o_sec(w_sec), 
        .o_min(w_min), 
        .o_hour(w_hour)
    );

    CLOCK_DP U_DP(
        .clk(clk), 
        .reset(reset),
        .sw_mode(sw_mode), // 감소 스위치
        .contrl_unit_sec(w_sec), // 각 버튼들
        .contrl_unit_min(w_min),
        .contrl_unit_hour(w_hour), 
        .msec(clk_msec),
        .sec(clk_sec), 
        .min(clk_min), 
        .hour(clk_hour)
    );

endmodule



module CLOCK_CU(
    input clk, reset,
    input cs,
    input btn_left,
    input btn_down, 
    input btn_right, 
    output reg o_sec, o_min, o_hour
);

    parameter STOP = 2'b00, SEC = 2'b01, MIN = 2'b10, HOUR = 2'b11;  

    reg [1:0] cstate, nstate;

    // state register
    always@(posedge clk, posedge reset)begin
        if(reset) begin
            cstate <= STOP; 
        end else begin
            cstate <= nstate;
        end
    end

    // next state
    always@(*)begin
    nstate = cstate;
    if(cs == 1) begin
        case(cstate)
            SEC:   
                if(btn_left == 0) nstate = STOP;

            MIN:   
                if(btn_down == 0) nstate = STOP;

            HOUR:   
                if(btn_right == 0) nstate = STOP;

            STOP:
                if(btn_left == 1) nstate = SEC;
                else if(btn_down == 1) nstate = MIN;
                else if(btn_right == 1) nstate = HOUR;
                else nstate = STOP;
        endcase
        end
    end

    // output
    always@(*)begin
        o_sec = 1'b0;
        o_min = 1'b0;
        o_hour = 1'b0;
        case(cstate)
            SEC:
                begin
                o_sec = 1'b1;
                o_min = 1'b0;
                o_hour = 1'b0;  
                end
            MIN:
                begin
                o_sec = 1'b0;
                o_min = 1'b1;
                o_hour = 1'b0;  
                end
            HOUR:
                begin
                o_sec = 1'b0;
                o_min = 1'b0;
                o_hour = 1'b1;      
                end
    endcase
    end
endmodule





module CLOCK_DP(
    input clk, reset,
    input sw_mode,
    input contrl_unit_sec,
    input contrl_unit_min,
    input contrl_unit_hour, 
    output [6:0] msec,
    output [5:0] sec, min, 
    output [4:0] hour
);

    wire w_clk_100;
    wire w_msec_tick, w_sec_tick, w_min_tick;
    wire w_sec, w_min, w_hour;

    clk_div_100 U_clk_div(
    .clk(clk), 
    .reset(reset),
    .o_clk(w_clk_100)
    );

    time_counter_clk #(.TICK_COUNT(100), .BIT_WIDTH(7)) U_CLK_msec(
    .clk(clk), 
    .reset(reset),
    .tick(w_clk_100),
    .btn(1'b0),
    .tick_sw_minus(1'b0),
    .o_time(msec),
    .o_tick(w_msec_tick)
    );

    time_counter_clk #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_CLK_sec(
    .clk(clk), 
    .reset(reset),
    .tick(w_msec_tick),
    .btn(contrl_unit_sec),
    .tick_sw_minus(sw_mode),
    .o_time(sec),
    .o_tick(w_sec_tick)
    );

    time_counter_clk #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_CLK_min(
    .clk(clk), 
    .reset(reset),
    .tick(w_sec_tick),
    .btn(contrl_unit_min),
    .tick_sw_minus(sw_mode),
    .o_time(min),
    .o_tick(w_min_tick)
    );

    time_counter_clk #(.TICK_COUNT(24), .BIT_WIDTH(5), .RESET_VALUE(12)) U_CLK_hour(
    .clk(clk), 
    .reset(reset),
    .tick(w_min_tick),
    .btn(contrl_unit_hour),
    .tick_sw_minus(sw_mode), 
    .o_time(hour),
    .o_tick()
    );

endmodule


// clk div 
module clk_div_100(
    input clk, reset,
    output o_clk
);
    // for test --> 속도 10M정도로 올렷음
    parameter FCOUNT = 1_000_000; // 1_000_000_000 / 100 =  100hz 
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next; // 출력을 f/f으로 내보내기 위해서.

    assign o_clk = clk_reg; // 최종 출력. 

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            clk_reg <= 0;
        end else begin 
            count_reg <= count_next;
            clk_reg <= clk_next;
        end
    end

    always @(*) begin
    count_next = count_reg;
    clk_next = 1'b0; // clk_reg;

    if(count_reg == FCOUNT - 1) begin
        count_next = 0;
        clk_next = 1'b1; // 출력 high
        end else begin
            count_next = count_reg + 1;
            clk_next = 1'b0;
        end 
    end
endmodule


// time_counter --> sec
module time_counter_clk #(parameter TICK_COUNT = 100, BIT_WIDTH = 7, RESET_VALUE = 0)  ( 
    input clk, reset,
    input tick,
    input btn,
    input tick_sw_minus,
    output [BIT_WIDTH -1 : 0] o_time,
    output o_tick
);

    reg [$clog2(TICK_COUNT)-1:0]count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg; // 카운트
    assign o_tick = tick_reg; // sec 카운트


    always@(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= RESET_VALUE;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = 1'b0;   // 0 -> 1 -> 0 (바로 다음 clk에) 원래 0인 상태로 설정
//        if (clear == 1'b1) begin
//            count_next = 0;
//        end else 
        if (btn == 1'b1) begin
            if (tick_sw_minus) begin
                // 감소 모드
                if (count_reg == 0) begin
                    count_next = TICK_COUNT - 1;
                    tick_next = 1'b0;
                end else begin
                    count_next = count_reg - 1;
                    tick_next = 1'b0;
                end
            end else begin
                // 증가 모드
                if (count_reg == TICK_COUNT - 1) begin
                    count_next = 0;
                    tick_next = 1'b0;
                end else begin
                    count_next = count_reg + 1;
                    tick_next = 1'b0;
                end
            end
        end

        if (tick == 1'b1) begin
            // 증가 모드 (tick에 따라 증가)
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end
        end
    end


endmodule
