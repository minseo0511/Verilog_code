`timescale 1ns / 1ps

module top_stopwatch (
    input clk,
    input reset,
    input btn_left,
    input btn_right,
    input btn_down,
    input empty_rx_b,
    input [7:0] data_in,
    input [2:0] sw_mode, 
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [4:0] led
);
    wire run, clear;
    wire w_left, w_right, w_down;
    wire cu_sec, cu_min, cu_hour;
    wire uart_left, uart_right, uart_down, uart_mid;

    wire [6:0] st_msec;
    wire [5:0] st_sec, st_min;
    wire [4:0] st_hour;
    wire [6:0] clk_msec;
    wire [5:0] clk_sec, clk_min;
    wire [4:0] clk_hour;
    wire [6:0] msec;
    wire [5:0] sec, min;
    wire [4:0] hour;

    uart_cu_v2 U_UART_CU(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .empty_rx_b(empty_rx_b),
        .btn_left(uart_left),
        .btn_right(uart_right),
        .btn_down(uart_down)
    );

    stopwatch_cu U_stopwatch_cu1 (
        .clk(clk),
        .reset(reset),
        .btn_left(w_left | uart_left),
        .btn_right(w_right | uart_right),
        .sw_mode(sw_mode[1]),
        .o_run(run),
        .o_clear(clear)
    );

    stopwacth_dp U_stopwatch_dp1 (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .msec (st_msec),
        .sec  (st_sec),
        .min  (st_min),
        .hour (st_hour)
    );

    fnd_controller U_fnd_ctrl1 (
        .clk(clk),
        .reset(reset),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm),
        .sw_mode(sw_mode)
    );

    watch_cu U_watch_cu1 (
        .clk(clk),
        .reset(reset),
        .btn_left(w_left | uart_left),
        .btn_down(w_down | uart_down),
        .btn_right(w_right | uart_right),
        .sw_mode(sw_mode[1]),
        .o_sec_up(cu_sec),
        .o_min_up(cu_min),
        .o_hour_up(cu_hour)
    );

    wacth_dp U_watch_dp1 (
        .clk(clk),
        .reset(reset),
        .cu_sec_up(cu_sec),
        .cu_min_up(cu_min),
        .cu_hour_up(cu_hour),
        .msec(clk_msec),
        .sec(clk_sec),
        .min(clk_min),
        .hour(clk_hour),
        .sw_mode(sw_mode[2])
    );

    btn_debounce bd_left (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_left),
        .o_btn(w_left)
    );
    btn_debounce bd_right (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_right),
        .o_btn(w_right)
    );
    btn_debounce bd_down (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_down),
        .o_btn(w_down)
    );

    mux_8x4_choice_version U_mux_8x4 (
        .choice(sw_mode[1]),
        .stw_msec(st_msec),
        .stw_sec(st_sec),
        .stw_min(st_min),
        .stw_hour(st_hour),
        .wat_msec(clk_msec),
        .wat_sec(clk_sec),
        .wat_min(clk_min),
        .wat_hour(clk_hour),
        .final_msec(msec),
        .final_sec(sec),
        .final_min(min),
        .final_hour(hour)
    );
    led_on_off U_led1 (
        .sw_mode(sw_mode),
        .led(led)
    );

endmodule


module mux_8x4_choice_version (
    input choice,
    input [6:0] stw_msec,
    input [5:0] stw_sec,
    stw_min,
    input [4:0] stw_hour,
    input [6:0] wat_msec,
    input [5:0] wat_sec,
    wat_min,
    input [4:0] wat_hour,
    output reg [6:0] final_msec,
    output reg [5:0] final_sec,
    final_min,
    output reg [4:0] final_hour
);
    always @(choice) begin
        if (choice == 1'b0) begin
            final_msec = stw_msec;
            final_sec  = stw_sec;
            final_min  = stw_min;
            final_hour = stw_hour;
        end else if (choice == 1'b1) begin
            final_msec = wat_msec;
            final_sec  = wat_sec;
            final_min  = wat_min;
            final_hour = wat_hour;
        end
    end

endmodule


module led_on_off (
    input [2:0] sw_mode,
    output reg [4:0] led
);

    always @(*) begin
        if (sw_mode == 3'b000) begin
            led = 5'b00001;
        end else if (sw_mode == 3'b001) begin
            led = 5'b00010;
        end else if (sw_mode == 3'b010) begin
            led = 5'b00100;
        end else if (sw_mode == 3'b011) begin
            led = 5'b01000;
        end else begin
            led = 5'b10000;
        end
    end
endmodule
