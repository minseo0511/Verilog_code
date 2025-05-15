`timescale 1ns / 1ps

module stopwatch_dp(
    input clk,
    input reset,
    input run,
    input clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );

    wire w_tick_100hz;
    wire w_tick_msec, w_tick_sec, w_tick_min, w_tick_hour;
    

    clk_div_100hz U_Clk_Div_100hz(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .o_clk(w_tick_100hz)
    );

    time_counter #(.TICK_COUNTER(100)) U_Time_Msec(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_tick_msec)
    );

    time_counter #(.TICK_COUNTER(60)) U_Time_Sec(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_msec),
        .o_time(sec),
        .o_tick(w_tick_sec)
    );
    
    time_counter #(.TICK_COUNTER(60)) U_Time_Min(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_sec),
        .o_time(min),
        .o_tick(w_tick_min)
    );
    
    time_counter #(.TICK_COUNTER(24)) U_Time_Hour(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_min),
        .o_time(hour),
        .o_tick(w_tick_hour)
    );
endmodule

module time_counter (
    input clk,
    input reset,
    input tick,
    output [6:0]o_time,
    output o_tick
);
    parameter TICK_COUNTER = 100;
    reg [$clog2(TICK_COUNTER)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
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
        if(tick) begin
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

module clk_div_100hz (
    input clk,
    input reset,
    input run,
    input clear,
    output o_clk
);
    parameter FCOUNT = 1_000_000;

    reg [$clog2(FCOUNT)-1:0]count_reg, count_next;
    reg clk_reg, clk_next;

    assign o_clk = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            clk_reg <= 0;
        end
        else begin
            count_reg <= count_next;
            clk_reg <= clk_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        clk_next = clk_reg;
        if (run) begin
            if(count_next == FCOUNT - 1) begin
                count_next = 0;
                clk_next = 1;
            end
            else begin
                count_next = count_reg + 1;
                clk_next = 0;
            end    
        end
        else if(clear) begin
            count_next = 0;
            clk_next = 0;
        end
    end
endmodule
