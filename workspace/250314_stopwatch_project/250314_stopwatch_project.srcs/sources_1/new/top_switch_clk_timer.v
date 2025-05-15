`timescale 1ns / 1ps

module top_switch_clk_timer(
    input clk,
    input reset,
    input [2:0]sw,
    input btnL, 
    input btnR, 
    input btnU, 
    input btnD,
    output [2:0] led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire w_btnL, w_btnR, w_btnU, w_btnD;
    wire o_btnL_sw, o_btnR_sw, o_btnU_c, o_btnD_c, o_btnL_c;
    wire w_clk_100hz;

    wire [6:0] msec, w_msec_sw, w_msec_c;
    wire [5:0] sec, w_sec_sw, w_sec_c;
    wire [5:0] min, w_min_sw, w_min_c;
    wire [4:0] hour, w_hour_sw, w_hour_c;

    top_button U_Debounce_All(
        .clk(clk),
        .reset(reset),
        .btnL(btnL), 
        .btnR(btnR), 
        .btnU(btnU), 
        .btnD(btnD),
        .o_btnL(w_btnL), 
        .o_btnR(w_btnR), 
        .o_btnU(w_btnU), 
        .o_btnD(w_btnD)
    );

    In_control_unit U_In_control_unit(
        .btnL(w_btnL),
        .btnR(w_btnR),
        .btnU(w_btnU),
        .btnD(w_btnD),
        .sw(sw[1]),
        .o_btnL_sw(o_btnL_sw),
        .o_btnR_sw(o_btnR_sw),
        .o_btnU_c(o_btnU_c),
        .o_btnD_c(o_btnD_c),
        .o_btnL_c(o_btnL_c)
    );

    clk_div_100hz U_clk_div_100hz(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    top_stopwatch U_TOP_Stopwatch(
        .clk(clk),
        .reset(reset),
        .i_btn_run(o_btnL_sw), //Left = run
        .i_btn_clear(o_btnR_sw), // Right = clear
        .clk_100hz(w_clk_100hz),
        .msec(w_msec_sw),
        .sec(w_sec_sw),
        .min(w_min_sw),
        .hour(w_hour_sw)
    );

    switch_led U_Switch_Led(
        .sw(sw),
        .led(led)
    );

    clk_dp U_CLK_DP(
        .clk(clk),
        .reset(reset),
        .ctrl_hour(o_btnL_c), //Left
        .ctrl_min(o_btnD_c), //Down
        .ctrl_sec(o_btnU_c), //Up
        .plus_minus(sw[2]),
        .clk_100hz(w_clk_100hz),
        .msec(w_msec_c),
        .sec(w_sec_c),
        .min(w_min_c),
        .hour(w_hour_c)
    );

    Out_control_unit U_Out_control_unit(
        .msec_sw(w_msec_sw),
        .sec_sw(w_sec_sw),
        .min_sw(w_min_sw),
        .hour_sw(w_hour_sw),
        .msec_c(w_msec_c),
        .sec_c(w_sec_c),
        .min_c(w_min_c),
        .hour_c(w_hour_c),
        .sw(sw[1]),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    fnd_controller U_FND_Ctrl(
        .clk(clk),
        .reset(reset),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .swap_switch(sw[0]),
        .fnd_font(fnd_font), 
        .fnd_comm(fnd_comm)
    );
endmodule

module In_control_unit (
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input sw,
    output reg o_btnL_sw,
    output reg o_btnR_sw,
    output reg o_btnU_c,
    output reg o_btnD_c,
    output reg o_btnL_c
);
    always @(*) begin
        case (sw)
            1'b0: begin
                o_btnL_sw = btnL;
                o_btnR_sw = btnR;
                o_btnU_c = 0;
                o_btnD_c = 0;
                o_btnL_c = 0;
            end 
            1'b1: begin
                o_btnL_sw = 0;
                o_btnR_sw = 0;
                o_btnU_c = btnU;
                o_btnD_c = btnD;
                o_btnL_c = btnL;
            end
            default: begin
                o_btnL_sw = 0;
                o_btnR_sw = 0;
                o_btnU_c = 0;
                o_btnD_c = 0;
                o_btnL_c = 0;
            end
        endcase
    end
endmodule

module clk_div_100hz (
    input clk,
    input reset,
    output o_clk
);
    parameter FCOUNT = 1_000_000; //1_000_000 -> 100Hz  10 -> 10MHz

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
        clk_next = 1'b0;
        if(count_next == FCOUNT - 1) begin
            count_next = 0;
            clk_next = 1;
        end
        else begin
            count_next = count_reg + 1;
            clk_next = 0;
        end    
    end
endmodule

module Out_control_unit (
    input [6:0] msec_sw,
    input [5:0] sec_sw,
    input [5:0] min_sw,
    input [4:0] hour_sw,
    input [6:0] msec_c,
    input [5:0] sec_c,
    input [5:0] min_c,
    input [4:0] hour_c,
    input sw,
    output reg [6:0] msec,
    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hour
);
    always @(*) begin
        case (sw)
            1'b0: begin
                msec = msec_sw;
                sec = sec_sw;
                min = min_sw;
                hour = hour_sw;
            end 
            1'b1: begin
                msec = msec_c;
                sec = sec_c;
                min = min_c;
                hour = hour_c;
            end
        endcase
    end
endmodule
