`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    output [7:0] fnd_font, 
    output [3:0] fnd_comm
);

    wire [3:0] w_digit_msec_1, w_digit_msec_10,
                w_digit_sec_1, w_digit_sec_10,
                w_digit_min_1, w_digit_min_10, 
                w_digit_hour_1, w_digit_hour_10, 
                w_bcd;

    wire [1:0] w_seg_sel;
    wire w_clk_100hz;

    clk_divider U_clk_div(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_4 U_counter_4(
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

    mux_4X1 U_Mux_4X1 (
        .sel(w_seg_sel),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10),
        .digit_100(w_digit_sec_1),
        .digit_1000(w_digit_sec_10),
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
    parameter FCOUNT = 250_000;
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

module counter_4 (
    input clk,
    input reset,
    output [1:0] o_sel
);
    reg [1:0] r_counter;
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
    input [1:0]seg_sel,
    output reg [3:0] seg_ctrl
);
    always @(seg_sel) begin
        case (seg_sel)
            2'b00: seg_ctrl = 4'b1110;
            2'b01: seg_ctrl = 4'b1101;
            2'b10: seg_ctrl = 4'b1011;
            2'b11: seg_ctrl = 4'b0111; 
            default: seg_ctrl = 4'b0000; 
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

module mux_4X1 (
    input [1:0] sel,
    input [3:0] digit_1,digit_10,digit_100,digit_1000,
    output [3:0] bcd
);
    reg [3:0]r_bcd;
    assign bcd = r_bcd;
    
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            2'b00 : r_bcd = digit_1;
            2'b01 : r_bcd = digit_10;
            2'b10 : r_bcd = digit_100;
            2'b11 : r_bcd = digit_1000; 
            default: r_bcd = 4'bx;
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
            4'hA: seg = 8'h88;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hC6;
            4'hD: seg = 8'hA1;
            4'hE: seg = 8'h86;
            4'hF: seg = 8'h8E;
            default: seg = 8'hFF;
        endcase
    end
endmodule
