`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    input swap_switch,
    output [7:0] fnd_font, 
    output [3:0] fnd_comm
);

    wire [3:0] w_digit_msec_1, w_digit_msec_10,
                w_digit_sec_1, w_digit_sec_10,
                w_digit_min_1, w_digit_min_10, 
                w_digit_hour_1, w_digit_hour_10, 
                w_bcd;

    wire [2:0] w_seg_sel;
    wire w_clk_100hz;
    wire [3:0] w_dot;
    wire [3:0] w_msec_sec, w_min_hour;

    clk_divider U_clk_div(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_8 U_counter_8(
        .clk(w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );
    
    bcdtoseg U_bts (
        .bcd(w_bcd),
        .seg(fnd_font)
    );

    digit_splitter #(.BIT_WIDTH(7)) U_Msec_ds(
        .bcd(msec),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10)
    );
    
    digit_splitter #(.BIT_WIDTH(6)) U_Sec_ds(
        .bcd(sec),
        .digit_1(w_digit_sec_1),
        .digit_10(w_digit_sec_10)
    );
    
    digit_splitter #(.BIT_WIDTH(6)) U_Min_ds(
        .bcd(min),
        .digit_1(w_digit_min_1),
        .digit_10(w_digit_min_10)
    );
    
    digit_splitter #(.BIT_WIDTH(5)) U_Hour_ds(
        .bcd(hour),
        .digit_1(w_digit_hour_1),
        .digit_10(w_digit_hour_10)
    );

    comparator_msec U_comparator_msec(
        .msec(msec),
        .dot(w_dot)
    );
    
    mux_8X1 U_MUX_8X1_Msec_Sec (
        .sel(w_seg_sel),
        .x0(w_digit_msec_1),
        .x1(w_digit_msec_10),
        .x2(w_digit_sec_1),
        .x3(w_digit_sec_10),
        .x4(4'hF),
        .x5(4'hF),
        .x6(w_dot),
        .x7(4'hF),
        .y(w_msec_sec)
    );

    mux_8X1 U_MUX_8X1_Min_Hour (
        .sel(w_seg_sel),
        .x0(w_digit_min_1),
        .x1(w_digit_min_10),
        .x2(w_digit_hour_1),
        .x3(w_digit_hour_10),
        .x4(4'hF),
        .x5(4'hF),
        .x6(w_dot),
        .x7(4'hF),
        .y(w_min_hour)
    );

    mux_2X1 U_MUX_2X1_time_sel(
        .swap_switch(swap_switch),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );

    button_ctrl U_fnd_con(
        .seg_sel(w_seg_sel),
        .seg_ctrl(fnd_comm)
    );

endmodule

module clk_divider (
    input clk,
    input reset,
    output o_clk
);
    parameter FCOUNT = 250_000; // 250_000
    reg [$clog2(FCOUNT)-1:0] r_counter; // $clog2(1_000_000) => 해당 수의 필요한 비트 수 계산
    reg r_clk;
    assign o_clk = r_clk;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 1'b0;
        end else begin
            if(r_counter == FCOUNT-1) begin  //clk divide calculate
                r_counter <= 0;
                r_clk <= 1'b1;
            end
            else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end

    end
    
endmodule

module counter_8 (
    input clk,
    input reset,
    output [2:0] o_sel
);
    reg [2:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end
        else begin
            r_counter <= r_counter + 1;
        end
            
    end
    
endmodule

module button_ctrl (
    input [2:0]seg_sel,
    output reg [3:0] seg_ctrl
);
    always @(seg_sel) begin
        case (seg_sel)
            3'b000: seg_ctrl = 4'b1110;
            3'b001: seg_ctrl = 4'b1101;
            3'b010: seg_ctrl = 4'b1011;
            3'b011: seg_ctrl = 4'b0111; 
            3'b100: seg_ctrl = 4'b1110;
            3'b101: seg_ctrl = 4'b1101;
            3'b110: seg_ctrl = 4'b1011;
            3'b111: seg_ctrl = 4'b0111; 
            default: seg_ctrl = 4'b1111; 
        endcase
    end
endmodule

module digit_splitter #(parameter BIT_WIDTH = 7)(
    input [BIT_WIDTH-1:0] bcd, 
    output [3:0]digit_1,digit_10
);
    assign digit_1 = bcd % 10;
    assign digit_10 = bcd/10 % 10;
endmodule

module comparator_msec (
    input [6:0] msec,
    output [3:0] dot
);

    assign dot = (msec<50) ? 4'hE : 4'hF;
    
endmodule

module mux_8X1 (
    input [2:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    input [3:0] x4,
    input [3:0] x5,
    input [3:0] x6,
    input [3:0] x7,
    output reg [3:0] y
);
    
    always @(*) begin
        case (sel)
            3'b000 : y= x0; 
            3'b001 : y= x1; 
            3'b010 : y= x2; 
            3'b011 : y= x3; 
            3'b100 : y= x4; 
            3'b101 : y= x5; 
            3'b110 : y= x6; 
            3'b111 : y= x7; 
            default: y = 4'hX;
        endcase
    end
endmodule

module mux_2X1 (
    input swap_switch,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output reg [3:0] bcd
);
    always @(*) begin
        case (swap_switch)
            1'b0 : bcd = msec_sec; 
            1'b1 : bcd = min_hour;  
            default: bcd = 4'hX;
        endcase
    end

endmodule

module bcdtoseg (
    input [3:0] bcd,  // [3:0]sum value
    output reg [7:0] seg  // seg의 type을 reg로 변환(기존 wire)
);
    //always문에서 출력이 wire일 수 없고 reg여야 한다.
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hC0;  //case문 내부에도 begin~end 사용가능
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hF8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hA: seg = 8'h7F;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hC6;
            4'hD: seg = 8'hA1;
            4'hE: seg = 8'h7F; //dot output
            4'hF: seg = 8'hFF; //0 output
            default: seg = 8'hFF;
        endcase
    end
endmodule
