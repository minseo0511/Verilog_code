`timescale 1ns / 1ps


// dp = datapath
module stopwacth_dp(
    input clk, reset,
    input run,
    input clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );

    wire w_clk_100hz;
    wire w_msec_tick, w_sec_tick, w_min_tick;

    time_counter #(.TICK_COUNT(100), .BIT_WIDTH(7)) U_Time_Msec(
        .clk(clk), .reset(reset), .clear(clear), .tick(w_clk_100hz), .o_time(msec), .o_tick(w_msec_tick)
    );
    time_counter #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_Time_Sec(
        .clk(clk), .reset(reset), .clear(clear), .tick(w_msec_tick), .o_time(sec), .o_tick(w_sec_tick)
    );
    time_counter #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_Time_Min(
        .clk(clk), .reset(reset), .clear(clear), .tick(w_sec_tick), .o_time(min), .o_tick(w_min_tick)
    );
    time_counter #(.TICK_COUNT(24), .BIT_WIDTH(5)) U_Time_Hour(
        .clk(clk), .reset(reset), .clear(clear), .tick(w_min_tick), .o_time(hour), .o_tick()
    );

    clk_div_100 U_CLK_Div(
        .clk(clk), .reset(reset), .run(run), .clear(clear), .o_clk(w_clk_100hz)
    );
endmodule

module time_counter #(parameter TICK_COUNT = 100, BIT_WIDTH = 7) (
    input clk, 
    input reset,
    input clear,
    input tick,
    output [BIT_WIDTH-1:0] o_time,
    output o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;  // 출력용

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = 1'b0;   // 0 -> 1 -> 0 (바로 다음 clk에) 원래 0인 상태로 설정
        if (clear == 1'b1) begin
            count_next = 0;
        end else if (tick == 1'b1) begin
            if(count_reg == TICK_COUNT-1) begin
                count_next = 0;
                tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end
        end
    end
    
endmodule

module clk_div_100 (
    input clk, reset,
    input run, clear,
    output o_clk   // 이것이 tick으로 들어간다.
);
    parameter FCOUNT = 1_000_000;   //1_000_000      //테스트벤츠용으로 빠른결과를 보기위해선선 10으로변경
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next;  // 출력을 ff으로 내보내기 위해서 만듦.

    assign o_clk = clk_reg;  // 최종 출력. 

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
        clk_next = 1'b0;    // 틱이 발생하고, 초기화를 통해 다시 발생하지 않도록 함.
        if(run == 1'b1) begin
            if (count_reg == FCOUNT - 1) begin
                count_next = 0;
                clk_next = 1'b1;   // 출력 high
            end else begin
                count_next = count_reg + 1;
                clk_next = 1'b0;
            end
        end else if(clear == 1'b1) begin
            count_next = 0;
            clk_next =0;
        end
    end
endmodule

