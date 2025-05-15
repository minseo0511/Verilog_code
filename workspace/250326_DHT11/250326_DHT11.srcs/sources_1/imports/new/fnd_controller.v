`timescale 1ns / 1ps

// sw = 0 => temperature 16bit[integer 8bit, fractional 8bit] select => splitter 2개 input
module fnd_controller (
    input clk,
    input reset,
    input [15:0] data_in,
    output [15:0] DHT11_decimal_data,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);
    wire [1:0] w_seg_sel;
    wire [3:0] w_digit_int_1, w_digit_int_10, w_digit_frac_1, w_digit_frac_10;

    wire [3:0] w_bcd;
    wire clk_100hz;

    assign DHT11_decimal_data = {w_digit_int_10, w_digit_int_1, w_digit_frac_10, w_digit_frac_1};

    clk_divider U_clk_divider (
        .clk  (clk),
        .reset(reset),
        .o_clk(clk_100hz)
    );

    counter_4 U_counter_4 (
        .clk  (clk_100hz), //clk_1Mhz
        .reset(reset),
        .o_sel(w_seg_sel)
    );

    decoder_2x4 U_decoder_2x4 (
        .seg_sel (w_seg_sel),
        .seg_comm(fnd_comm)
    );

    digit_splitter #(.BIT_WIDTH(8)) U_Splitter_int (
        .bcd(data_in[15:8]),
        .digit_1(w_digit_int_1),
        .digit_10(w_digit_int_10)
    );

    digit_splitter #(.BIT_WIDTH(8)) U_Splitter_frac (
        .bcd(data_in[7:0]),
        .digit_1(w_digit_frac_1),
        .digit_10(w_digit_frac_10)
    );

    mux_4x1 U_mux_4x1(  
        .sel(w_seg_sel),
        .x0(w_digit_frac_1),
        .x1(w_digit_frac_10),
        .x2(w_digit_int_1),
        .x3(w_digit_int_10),
        .y(w_bcd)
    );

    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),  
        .seg(fnd_font)
    );

endmodule

module clk_divider(  // clk이 너무 빨라서 fnd 안에서 쓸 속도 조절 모듈
    input  clk,
    input reset,
    output o_clk
);
    parameter FCOUNT = 100_000; 

    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [$clog2(FCOUNT)-1:0] r_counter;  //20비트 또는 19자리에 $clog2(1_000_000)하면 비트수 계산됨
    reg r_clk;

    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;  //non-blocking 구문
            r_clk <= 1'b0;
        end else begin
            if(r_counter == FCOUNT-1) begin // clock divide 계산, 100Mh -> 100hz
                r_counter <=0; //백만개를 셋을 때 r_counter로 보내기
                r_clk <= 1'b1;  // r_clk : 0 -> 1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 0으로 유지
            end
        end
    end

endmodule


module counter_4( 
    input clk,
    input reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1; 
        end
    end
endmodule


module decoder_2x4 (  // 어떤 LED를 켤지 정해주는 모듈 // 8개인 이유는 점까지 표시하기 위해
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);
    //3x8 decoder
    always @(seg_sel) begin
        case (seg_sel)
            2'b00:  seg_comm = 4'b1110;
            2'b01:  seg_comm = 4'b1101;
            2'b10:  seg_comm = 4'b1011;
            2'b11:  seg_comm = 4'b0111;
        endcase
    end
endmodule



module digit_splitter #(parameter BIT_WIDTH = 9) (  // 1의 자리 10자리를 표현하기 위한 모듈
    input [BIT_WIDTH-1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1  = bcd % 10; 
    assign digit_10 = bcd / 10 % 10; 
endmodule


module mux_4x1 (  // counter_8에서 값을 받아와 8가지 경우가 차례대로 실행
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y
);
    always @(*) begin
        case (sel)
            2'b00:  y = x0;
            2'b01:  y = x1;
            2'b10:  y = x2;
            2'b11:  y = x3;
            default: y = 4'hf;
        endcase
    end

endmodule

module bcdtoseg(   
    input [3:0] bcd,  //[3:0] sum값
    output reg [7:0] seg
);

    // always구문은 출력으로 wire가 될 수 없음. 항상 reg type을 가져야 한다. 
    always @(bcd) begin  // 항상 대상이벤트를 감시

        case (bcd)  //case문 안에서 assign문 사용안함
            4'h0: seg = 8'hC0; 
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
            default: seg = 8'hff;
        endcase
    end

endmodule
