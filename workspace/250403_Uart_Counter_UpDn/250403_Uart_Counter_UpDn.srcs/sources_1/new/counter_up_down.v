`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input btn_left,
    input btn_right,
    input btn_up,
    input btn_down,
    output [3:0] fndCom,
    output [7:0] fndFont,
    output tx,
    input rx
);  
    wire [13:0] fndData, data_time, data_out;
    wire [ 3:0] fndDot;
    wire en, clear, mode;
    wire [7:0] rx_data;
    wire rx_done;
    wire [7:0] tx_data;
    wire tx_start;
    wire tx_busy;
    wire tx_done;
    wire sel;
    wire w_btn_runstop, w_btn_clear, w_btn_updown, w_btn_mode;

    btn_debounce U_btn_left(
        .clk(clk),
        .reset(reset),
        .btn(btn_left),
        .o_btn(w_btn_runstop)
    );
    btn_debounce U_btn_right(
        .clk(clk),
        .reset(reset),
        .btn(btn_right),
        .o_btn(w_btn_clear)
    );
    btn_debounce U_btn_up(
        .clk(clk),
        .reset(reset),
        .btn(btn_up),
        .o_btn(w_btn_updown)
    );
    btn_debounce U_btn_down(
        .clk(clk),
        .reset(reset),
        .btn(btn_down),
        .o_btn(w_btn_mode)
    );

    // btn_debounce U_btn_left(
    //     .clk(clk),
    //     .reset(reset),
    //     .i_btn(btn_left),
    //     .o_btn(w_btn_runstop)
    // );
    // btn_debounce U_btn_right(
    //     .clk(clk),
    //     .reset(reset),
    //     .i_btn(btn_right),
    //     .o_btn(w_btn_clear)
    // );
    // btn_debounce U_btn_up(
    //     .clk(clk),
    //     .reset(reset),
    //     .i_btn(btn_up),
    //     .o_btn(w_btn_updown)
    // );
    // btn_debounce U_btn_down(
    //     .clk(clk),
    //     .reset(reset),
    //     .i_btn(btn_down),
    //     .o_btn(w_btn_mode)
    // );

    uart U_Uart(
    // global port
        .clk(clk),
        .reset(reset),
    // tx side port
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx),
    // rx side port
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx(rx)
    );

    control_unit U_ControlUnit (
        .clk        (clk),
        .reset      (reset),
        .btn_mode(w_btn_mode),
        .btn_runstop(w_btn_runstop),
        .btn_clear(w_btn_clear),
        .btn_updown(w_btn_updown),
        // tx side port
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        // rx side port
        .rx_data(rx_data),
        .rx_done(rx_done),
        // data path side
        .sel(sel),
        .en         (en),
        .clear      (clear),
        .mode       (mode)
    );

    stopwatch U_stopwatch(
        .clk(clk),
        .reset(reset),
        .en(en),
        .clear(clear),
        .data_time(data_time)
    );

    counter_up_down U_Counter (
        .clk     (clk),
        .reset   (reset),
        .en      (en),
        .clear   (clear),
        .mode    (mode),
        .sel (sel),
        .count   (fndData),
        .dot_data(fndDot)
    );

    mux_2x1 U_mux_2x1(
        .sel(sel),
        .x0(fndData),
        .x1(data_time),
        .y(data_out)
    );

    fndController U_FndController (
        .clk    (clk),
        .reset  (reset),
        // .sel(sel),
        .fndData(data_out),
        .fndDot (fndDot),
        .fndCom (fndCom),
        .fndFont(fndFont)
    );
endmodule


module btn_debounce (
    input clk,
    input reset,
    input btn,
    output o_btn
);
    parameter FCOUNT = 100_000;

    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg [7:0] shift_reg, shift_next;
    reg clk_1khz;
    reg edge_detect;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            shift_reg <= 0;
        end
        else begin
            count_reg <= count_next;
            shift_reg <= shift_next;
        end
    end

    always @(*) begin
        if(count_reg == FCOUNT-1) begin
            count_next = 0;
            clk_1khz = 1'b1;
        end
        else begin
            count_next = count_reg + 1;
            clk_1khz = 1'b0;
        end
    end

    always @(*) begin
        if(clk_1khz) begin
            shift_next = {btn,shift_reg[7:1]};
        end
    end

    assign btn_debounce = &shift_reg;

    // edge_detector , 100Mhz
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 0;
        end else begin
            edge_detect <= btn_debounce;
        end
    end

    assign o_btn = btn_debounce & (~edge_detect);
endmodule


module control_unit (
    input      clk,
    input      reset,
    input btn_mode,
    input btn_runstop,
    input btn_clear,
    input btn_updown,
    // tx side port
    output reg [7:0] tx_data,
    output reg tx_start,
    input tx_busy,
    input tx_done,
    // rx side port
    input [7:0] rx_data,
    input rx_done,
    // data path sode port
    output reg sel, // counter, stopwatch  sel
    output reg en, // run, stop 
    output reg clear, // clear
    output reg mode // up, down
);
    localparam STOP = 0, RUN = 1, CLEAR = 2;
    localparam UP = 0, DOWN = 1;
    localparam IDLE = 0, ECHO = 1;
    localparam STOPWATCH = 0, COUNTER = 1;
    reg [1:0] state, state_next;
    reg mode_state, mode_state_next;
    reg echo_state, echo_state_next;
    reg sel_state, sel_state_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            mode_state <= UP;
            echo_state <= IDLE;
            sel_state <= COUNTER;
        end else begin
            state <= state_next;
            mode_state <= mode_state_next;
            echo_state <= echo_state_next;
            sel_state <= sel_state_next;
        end
    end

    always @(*) begin
        sel_state_next = sel_state;
        sel = 0;
        case (sel_state)
            COUNTER: begin
                sel = 0;
                if(btn_mode) sel_state_next = STOPWATCH;
                if(rx_done) begin
                    if (rx_data == "t" || rx_data == "T") sel_state_next = STOPWATCH;
                end
            end 
            STOPWATCH: begin
                sel = 1;
                if(btn_mode) sel_state_next = COUNTER;
                if(rx_done) begin
                    if (rx_data == "t" || rx_data == "T") sel_state_next = COUNTER;
                end
            end 
        endcase
    end

    always @(*) begin
        echo_state_next = echo_state;
        tx_data = 0;
        tx_start = 1'b0;
        case(echo_state)
            IDLE: begin
                tx_data = 0;
                tx_start = 1'b0;
                if (rx_done) begin
                    echo_state_next = ECHO;
                    // echo_temp_next = rx_data;
                end
            end

            ECHO: begin
                if (tx_done) begin
                    echo_state_next = IDLE;
                end else begin
                    tx_data = rx_data;
                    tx_start = 1'b1;
                end
            end
        endcase
    end

    always @(*) begin
        mode_state_next = mode_state;
        mode = 1'b0;
        case (mode_state)
            UP: begin
                mode = 1'b0;
                if(btn_updown) mode_state_next = DOWN;
                if(rx_done) begin
                    if (rx_data == "m" || rx_data == "M") mode_state_next = DOWN;
                end
            end

            DOWN: begin
                mode = 1'b1;
                if(btn_updown) mode_state_next = UP;
                if(rx_done) begin
                    if (rx_data == "m" || rx_data == "M") mode_state_next = UP;
                end
            end
        endcase
    end

    always @(*) begin
        state_next = state;
        en         = 1'b0;
        clear      = 1'b0;
    //    mode       = 1'b0;
        case (state)
            STOP: begin
                en = 1'b0;
                clear = 1'b0;
                if(btn_runstop) state_next = RUN;
                else if(btn_clear) state_next = CLEAR;
                if (rx_done) begin
                    if (rx_data == "r" || rx_data == "R") state_next = RUN;
                    else if (rx_data == "c" || rx_data == "C") state_next = CLEAR;
                end
            end

            RUN: begin
                en = 1'b1;
                clear = 1'b0;
                if(btn_runstop) state_next = STOP;
                if (rx_done) begin
                    if (rx_data == "s" || rx_data == "S") state_next = STOP;
                end
            end

            CLEAR: begin
                en = 1'b0;
                clear = 1'b1;
                state_next = STOP;
            end
        endcase
    end
endmodule

module mux_2x1 (
    input      sel,
    input [13:0] x0,
    input [13:0] x1,
    output reg [13:0] y
);

    always @(*) begin
        y = 0;
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
        endcase
    end
endmodule

module stopwatch (
    input clk,
    input reset,
    input en,
    input clear,
    output [13:0] data_time
);
    
    wire w_tick_10hz, w_tick_msec, w_tick_sec;
    wire [3:0] msec;
    wire [5:0] sec;
    wire [3:0] min;
    assign data_time = {min, sec, msec};

    clk_div_10hz #(.FCOUNT(10_000_000)) U_Clk_Div_10Hz_1 ( //10_000_000
        .clk  (clk),
        .reset(reset),
        .tick (w_tick_10hz),
        .en   (en),
        .clear(clear)
    );

    time_counter #(.TICK_COUNT(10)) U_time_counter_msec(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_10hz),
        .data_time(msec),
        .o_tick(w_tick_msec) 
    );

    time_counter #(.TICK_COUNT(60)) U_time_counter_sec(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_msec),
        .data_time(sec),
        .o_tick(w_tick_sec) 
    );

    time_counter #(.TICK_COUNT(10)) U_time_counter_min(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_sec),
        .data_time(min),
        .o_tick() 
    );

endmodule

module time_counter #(parameter TICK_COUNT = 100) (
    input clk,
    input reset,
    input tick,
    output [$clog2(TICK_COUNT)-1:0] data_time,
    output o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next; 

    assign data_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = 1'b0;   
        if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
    end
endmodule

module comp_dot (
    input  [13:0] count,
    input sel,
    output reg [ 3:0] dot_data
);
    always @(*) begin
        if(sel == 0) begin
            dot_data = ((count % 10) < 5) ? 4'b1101 : 4'b1111;
        end
        else begin
            dot_data = ((count % 10) < 5) ? 4'b0101 : 4'b1111;
        end
    end
endmodule

module counter_up_down (
    input         clk,
    input         reset,
    input         en,
    input         clear,
    input         mode,
    input sel,
    output [13:0] count,
    output [ 3:0] dot_data
);
    wire tick;

    clk_div_10hz #(.FCOUNT(10_000_000))U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .en   (en),
        .clear(clear)
    );

    counter U_Counter_Up_Down (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .mode (mode),
        .en   (en),
        .clear(clear),
        .count(count)
    );

    comp_dot U_Comp_Dot (
        .count(count),
        .sel(sel),
        .dot_data(dot_data)
    );
endmodule


module counter (
    input         clk,
    input         reset,
    input         tick,
    input         mode,
    input         en,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (clear) begin
                counter <= 0;
            end else begin
                if (en) begin
                    if (mode == 1'b0) begin
                        if (tick) begin
                            if (counter == 9999) begin
                                counter <= 0;
                            end else begin
                                counter <= counter + 1;
                            end
                        end
                    end else begin
                        if (tick) begin
                            if (counter == 0) begin
                                counter <= 9999;
                            end else begin
                                counter <= counter - 1;
                            end
                        end
                    end
                end
            end
        end
    end
endmodule

module clk_div_10hz #(parameter FCOUNT = 10_000_000)(
    input clk,
    input reset,
    input en,
    input clear,
    output reg  tick
);
    reg [$clog2(FCOUNT)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (en) begin
                if (div_counter == FCOUNT - 1) begin
                    div_counter <= 0;
                    tick <= 1'b1;
                end else begin
                    div_counter <= div_counter + 1;
                    tick <= 1'b0;
                end
            end
            if (clear) begin
                div_counter <= 0;
                tick <= 1'b0;
            end
        end
    end
endmodule
