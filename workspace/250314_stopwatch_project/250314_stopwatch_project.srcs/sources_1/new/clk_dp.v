`timescale 1ns / 1ps

module clk_dp(
    input clk,
    input reset,
    input ctrl_hour, //Left
    input ctrl_min, //Down
    input ctrl_sec, //Up
    input plus_minus,
    input clk_100hz,
    output [6:0]msec,
    output [5:0]sec,
    output [5:0]min,
    output [4:0]hour
    );

    wire w_tick_msec, w_tick_sec, w_tick_min, w_tick_hour;

    time_counter_c #(.TICK_COUNTER(100)) U_Time_Msec_c(
        .clk(clk),
        .reset(reset),
        .tick(clk_100hz),
        .time_c(1'b0),
        .plus_minus(plus_minus),
        .o_time(msec),
        .o_tick(w_tick_msec)
    );

    time_counter_c #(.TICK_COUNTER(60)) U_Time_Sec_c(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_msec),
        .time_c(ctrl_sec),
        .plus_minus(plus_minus),
        .o_time(sec),
        .o_tick(w_tick_sec)
    );
    
    time_counter_c #(.TICK_COUNTER(60)) U_Time_Min_c(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_sec),
        .time_c(ctrl_min),
        .plus_minus(plus_minus),
        .o_time(min),
        .o_tick(w_tick_min)
    );
    
    time_counter_c #(.TICK_COUNTER(24), .HOUR_FIRST(12)) U_Time_Hour_c(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_min),
        .time_c(ctrl_hour),
        .plus_minus(plus_minus),
        .o_time(hour),
        .o_tick(w_tick_hour)
    );
endmodule

module time_counter_c (
    input clk,
    input reset,
    input tick,
    input time_c,
    input plus_minus,
    output [6:0]o_time,
    output o_tick
);
    parameter TICK_COUNTER = 100;
    parameter HOUR_FIRST = 0;
    reg [$clog2(TICK_COUNTER)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= HOUR_FIRST;
            tick_reg <= 0;
        end
        else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = 0;

        if(plus_minus == 1'b1) begin
            if(count_reg == TICK_COUNTER - 1) begin
                count_next = TICK_COUNTER - 1;
            end
            else begin
               count_next = count_reg - 1; 
            end
        end
        else if(plus_minus == 1'b0) begin
            count_next = count_reg + 1;
        end
        else if(tick) begin
            if (count_reg == TICK_COUNTER - 1) begin
                count_next = 0;
                tick_next = 1;
            end
            else begin
                count_next = count_reg + 1;
                tick_next = 0;
            end    
        end
    end
endmodule