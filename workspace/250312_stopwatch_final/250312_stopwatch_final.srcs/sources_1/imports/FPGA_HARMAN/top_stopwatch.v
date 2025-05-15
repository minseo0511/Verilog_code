`timescale 1ns / 1ps

module top_stopwatch(
    input clk,
    input reset,
    input [1:0] switch_mode,
    input btn_left,
    input btn_up,
    input btn_down,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led
    );

    wire w_btn_left, w_btn_down, w_btn_up;
    wire run, clear;

    wire [6:0] msec; 
    wire [5:0] sec, min;
    wire [4:0] hour;
    wire [6:0] msec_wch; 
    wire [5:0] sec_wch, min_wch;
    wire [4:0] hour_wch;
    wire [6:0] final_msec; 
    wire [5:0] final_sec, final_min;
    wire [4:0] final_hour;

    stopwatch_DP u_stopwatch_dp(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .run(run), 
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
    stopwatch_CU u_stopwatch_CU(
        .clk(clk),
        .reset(reset),
        .chip_select(switch_mode[1]), ///변경
        .i_btn_up(w_btn_up),
        .i_btn_down(w_btn_down),
        .o_run(run),
        .o_clear(clear)
    );
    led_2X4 u_led_2x4(
        .switch_mode(switch_mode), 
        .led(led)
    );
    fnd_controller u_fnd_controller(
        .clk(clk), 
        .reset(reset),
        .switch_mode(switch_mode),
        .msec(final_msec),
        .sec(final_sec),
        .min(final_min),
        .hour(final_hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    button_debounce u_button_debounce_up(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_up),
        .o_btn(w_btn_up)
    );
    button_debounce u_button_debounce_left(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_left),
        .o_btn(w_btn_left)
    );

    button_debounce u_button_debounce_down(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_down),
        .o_btn(w_btn_down)
    );

    chip_8x4 u_chip_8x4(
        .chip_select(switch_mode[1]),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .msec_wch(msec_wch),
        .sec_wch(sec_wch),
        .min_wch(min_wch),
        .hour_wch(hour_wch),
        .to_fnd_msec(final_msec),
        .to_fnd_sec(final_sec),
        .to_fnd_min(final_min),
        .to_fnd_hour(final_hour)
);
    watch_dp u_watch_dp(
        .clk(clk),
        .reset(reset),
        .i_sec(w_o_sec),
        .i_min(w_o_min),
        .i_hour(w_o_hour),
        .msec_wch(msec_wch),
        .sec_wch(sec_wch),
        .min_wch(min_wch),
        .hour_wch(hour_wch)
    );
    watch_cu u_watch_cu(
        .clk(clk),
        .reset(reset),
        .chip_select(switch_mode[1]), ///변경경
        .i_btn_left(w_btn_left),
        .i_btn_up(w_btn_up),
        .i_btn_down(w_btn_down),
        .o_sec(w_o_sec),
        .o_min(w_o_min),
        .o_hour(w_o_hour)
    );
endmodule

module chip_8x4(
    input chip_select,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    input [6:0] msec_wch,
    input [5:0] sec_wch,
    input [5:0] min_wch,
    input [4:0] hour_wch,
    output reg [6:0] to_fnd_msec,
    output reg [5:0] to_fnd_sec,
    output reg [5:0] to_fnd_min,
    output reg [4:0] to_fnd_hour
);
    always@(*)
        begin if (chip_select == 1'b0) begin 
            to_fnd_msec = msec; 
            to_fnd_sec = sec; 
            to_fnd_min = min; 
            to_fnd_hour = hour; 
        end
        else if (chip_select == 1'b1)begin 
            to_fnd_msec = msec_wch; 
            to_fnd_sec = sec_wch; 
            to_fnd_min = min_wch; 
            to_fnd_hour = hour_wch; 
            end
        end
endmodule

module led_2X4(
    input [1:0]switch_mode, 
    output reg [3:0] led
);
always @(*)
    begin
        case(switch_mode)
            2'b00 : begin
                led = 4'b0001;
            end
            2'b01 : begin
                led = 4'b0010;
            end
            2'b10 : begin
                led = 4'b0100;
            end
            2'b11 : begin
                led = 4'b1000;
            end
        endcase
    end
endmodule

