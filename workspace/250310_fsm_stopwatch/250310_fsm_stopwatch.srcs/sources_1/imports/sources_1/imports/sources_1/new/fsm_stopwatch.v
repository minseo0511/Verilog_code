`timescale 1ns / 1ps
module fsm_stopwatch (
    input clk,
    input reset,
//  input [2:0] sw,
    input btn_run_stop,
    input btn_clear,
    output [7:0] seg,
    output [3:0] seg_comm
);
    wire [6:0] w_count_msec;
    wire [5:0] w_count_sec;
    wire [5:0] w_count_min;
    wire [4:0] w_count_hour;
    wire o_btn_run_stop, o_btn_clear;
    wire w_clk, w_run_stop, w_clear;

    wire w_tick_100hz, w_tick_sec, w_tick_min, w_tick_hour;

    wire w_sec_sel, w_min_sel;

    assign time_sel = {w_min_sel, w_sec_sel};

    counter_tick_msec U_counter_tick_msec (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_100hz),
        .clear(w_clear),
        .counter(w_count_msec),
        .o_tick(w_tick_sec)
    );

    counter_tick_sec U_counter_tick_sec (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_sec),
        .clear(w_clear),
        .counter(w_count_sec),
        .o_tick(w_tick_min),
        .sec_sel(w_sec_sel)
    );

    counter_tick_min U_counte_tick_min (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_min),
        .clear(w_clear),
        .counter(w_count_min),
        .o_tick(w_tick_hour),
        .min_sel(w_min_sel)
    );

    counter_tick_hour U_counte_tick_hour (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_hour),
        .clear(w_clear),
        .counter(w_count_hour)
    );

    tick_100hz U_tick_100hz(
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .o_tick_100hz(w_tick_100hz)
    );

    btn_debounce U_debounce_run(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_run_stop),
        .o_btn(o_btn_run_stop) 
    );

    btn_debounce U_debounce_clear(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_clear),
        .o_btn(o_btn_clear)
    );

    control_unit U_control_unit(
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_btn_run_stop),
        .i_clear(o_btn_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );
    
    fnd_controller FND(
        .count_msec(w_count_msec),
        .count_sec(w_count_sec), 
        .count_min(w_count_min),
        .count_hour(w_count_hour),
        .time_sel(time_sel),
        .clk(clk),
        .reset(reset),
        .seg(seg),
        .seg_comm(seg_comm)
    );
endmodule

module counter_tick_msec #(parameter TICK_COUNT = 100) (
    input clk,
    input reset,
    input tick,
    input clear,
    output [$clog2(TICK_COUNT)-1:0] counter,
    output o_tick
);
    // state 와 next 구문
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg r_tick;
    // 출력 구문
    assign counter = counter_reg;
    assign o_tick = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end
    // next를 위한 구문
    always @(*) begin
        counter_next = counter_reg; 
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 1'b0; 
        end else if (tick == 1'b1) begin // tick count
            if (counter_reg == TICK_COUNT-1) begin
                counter_next = 1'b0; 
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1; 
                r_tick= 1'b0;
            end
        end
    end
endmodule

module counter_tick_sec #(parameter TICK_COUNT = 60) (
    input clk,
    input reset,
    input tick,
    input clear,
    output [$clog2(TICK_COUNT)-1:0] counter,
    output o_tick,
    output sec_sel
);
    // state 와 next 구문
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg r_tick;

    reg r_sec_sel;
    assign sec_sel = r_sec_sel;

    // 출력 구문
    assign counter = counter_reg;
    assign o_tick = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            r_sec_sel <= 0;
        end else begin
            counter_reg <= counter_next;
            if (clear == 1'b1) begin
                r_sec_sel = 1'b0; 
            end 
            else if (tick == 1'b1) begin // tick count
                if (counter_reg == TICK_COUNT-1) begin
                    r_sec_sel = 1'b1;
                end
            end
        end
    end
    // next를 위한 구문
    always @(*) begin
        counter_next = counter_reg; 
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 1'b0; 
        end else if (tick == 1'b1) begin // tick count
            if (counter_reg == TICK_COUNT-1) begin
                counter_next = 1'b0; 
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
                r_tick= 1'b0;
            end
        end
    end
endmodule

module counter_tick_min #(parameter TICK_COUNT = 60) (
    input clk,
    input reset,
    input tick,
    input clear,
    output [$clog2(TICK_COUNT)-1:0] counter,
    output o_tick,
    output min_sel
);
    // state 와 next 구문
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg r_tick;

    reg r_min_sel;
    assign min_sel = r_min_sel;

    // 출력 구문
    assign counter = counter_reg;
    assign o_tick = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            r_min_sel <= 0;
        end else begin
            counter_reg <= counter_next;
            if (clear == 1'b1) begin
                r_min_sel = 1'b0; 
            end 
            else if (tick == 1'b1) begin // tick count
                if (counter_reg == TICK_COUNT-1) begin
                    r_min_sel = 1'b1;
                end
            end
        end
    end
    // next를 위한 구문
    always @(*) begin
        counter_next = counter_reg; 
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 1'b0; 
        end else if (tick == 1'b1) begin // tick count
            if (counter_reg == TICK_COUNT-1) begin
                counter_next = 1'b0; 
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
                r_tick= 1'b0;
            end
        end
    end
endmodule

module counter_tick_hour #(parameter TICK_COUNT = 24) (
    input clk,
    input reset,
    input tick,
    input clear,
    output [$clog2(TICK_COUNT)-1:0] counter,
    output o_tick
);
    // state 와 next 구문
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg r_tick;
    // 출력 구문
    assign counter = counter_reg;
    assign o_tick = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end
    // next를 위한 구문
    always @(*) begin
        counter_next = counter_reg; 
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 1'b0; 
        end else if (tick == 1'b1) begin // tick count
            if (counter_reg == TICK_COUNT-1) begin
                counter_next = 1'b0; 
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1; 
                r_tick= 1'b0;
            end
        end
    end
endmodule

module tick_100hz (
    input  clk,
    input  reset,
    input run_stop,
    output o_tick_100hz
);

    reg [$clog2(100_0000)-1:0] r_counter;  
    reg r_tick_100hz;

    assign o_tick_100hz = r_tick_100hz;
 
    always @(posedge clk, posedge reset) begin 
        if (reset) begin
            r_counter <= 0;  
            r_tick_100hz <= 0;
        end else begin 
            if(run_stop == 1'b1) begin
                if (r_counter == 1_000_000 - 1) begin
                    r_counter <= 0;
                    r_tick_100hz <= 1'b1;  // r_clk : 0 -> 1
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick_100hz <= 1'b0; 
                end 
            end 
        end
    end
endmodule

module control_unit (
    input clk,
    input reset,
    input i_run_stop,
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    reg [2:0] state, next;
    // state를 관리해주는 코드
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        case (state)
            STOP: begin
                if (i_run_stop == 1'b1) begin
                    next = RUN;
                end else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end else next = STOP;
            end
            RUN: begin
                if (i_run_stop == 1'b1) begin
                    next = STOP;
                end else next = RUN;
            end
            CLEAR: begin
                if (i_clear == 1'b1) begin
                    next = STOP;
                end else next = CLEAR;
            end
            default: begin
                next = state;
            end
        endcase
    end

    // combinational output logic
    always @(*) begin
        o_run_stop = 1'b0;
        o_clear = 1'b0;
        case (state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR: begin
                //o_run_stop = 1'b1;
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
