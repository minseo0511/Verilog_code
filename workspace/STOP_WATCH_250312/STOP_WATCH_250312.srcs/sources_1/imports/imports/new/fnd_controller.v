`timescale 1ns / 1ps

module fnd_controller(
    input clk, reset,
    input [6:0] msec, 
    input [5:0] sec, min, 
    input [4:0] hour,
    input sw_mode,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);

    wire [3:0] w_bcd;

    wire [2:0] w_seg_sel;
    
    wire [3:0] w_digit_msec_1, w_digit_msec_10,
               w_digit_sec_1, w_digit_sec_10,
               w_digit_min_1, w_digit_min_10,
               w_digit_hour_1, w_digit_hour_10;

    wire [3:0] w_msec_sec;
    wire [3:0] w_min_hour;

    wire clk_100hz;

    wire [3:0] w_dot;

    // instance
    clk_divider U_clk_divider(.clk(clk), .reset(reset), .o_clk(clk_100hz));

    counter_8 U_Counter_8(.clk(clk_100hz), .reset(reset), .o_sel(w_seg_sel));

    decoder_3x8 U_decoder_3x8(
        .seg_sel(w_seg_sel), 
        .seg_comm(fnd_comm)
    );

    digit_splitter#(.BIT_WIDTH(7)) U_Msec_ds(
        .bcd(msec), 
        .digit_1(w_digit_msec_1), 
        .digit_10(w_digit_msec_10)
    );

    digit_splitter#(.BIT_WIDTH(6)) U_Sec_ds(
        .bcd(sec), 
        .digit_1(w_digit_sec_1), 
        .digit_10(w_digit_sec_10)
    );

    digit_splitter#(.BIT_WIDTH(6)) U_Min_ds(
        .bcd(min), 
        .digit_1(w_digit_min_1), 
        .digit_10(w_digit_min_10)
    );

    digit_splitter#(.BIT_WIDTH(5)) U_Hour_ds(
        .bcd(hour), 
        .digit_1(w_digit_hour_1), 
        .digit_10(w_digit_hour_10)
    );

    mux_8x1 U_Mux_8x1_Msec_Sec (
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

    mux_8x1 U_Mux_8x1_Min_Hour (
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

    mux_2x1 U_Mux_2x1_Mode(
        .sw_mode(sw_mode),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );

    comparator_msec U_Comp_dot(
        .counter_msec(msec), 
        .dot(w_dot)
    );


    // dot_on_off U_Dot_on_off(
    // .counter_msec(msec), 
    // .clk(clk), 
    // .reset(reset),
    // .dot(w_dot)
    // );


    // mux_4x1 U_Mux_4x1_msec_sec (
    //     .bcd(w_bcd),
    //     .sel(w_seg_sel), 
    //     .digit_1(w_digit_msec_1), 
    //     .digit_10(w_digit_msec_10), 
    //     .digit_100(w_digit_sec_1), 
    //     .digit_1000(w_digit_sec_10)
    // );


    //assign seg_comm = 4'b1110; // segment 0의 자리 on, seg는 anode type
    bcdtoseg U_bcdtoseg(
        .bcd(w_bcd), // [3:0] sum값
        .seg(fnd_font),
        .dot(w_dot)
        );

   // assign seg_comm = 4'b0000;

    // always @(BTN) begin
    // case(BTN)
    // 2'b00: seg_comm = 4'b1110; //0이 켜지는 거래..
    // 2'b01: seg_comm = 4'b1101;
    // 2'b10: seg_comm = 4'b1011;
    // 2'b11: seg_comm = 4'b0111;
    // endcase
    // end

endmodule


module clk_divider(
    input clk,reset,
    output o_clk
);

    //parameter FCOUNT = 500_000; // 상수화 하기, 변수개념

    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [19:0] r_counter; //20비트 또는 19자리에 $clog2(1_000_000)하면 비트수 계산됨
    reg r_clk;
    
    assign o_clk = r_clk;
    
    always@(posedge clk, posedge reset) begin
        if(reset) begin
        r_counter <= 0; //non-blocking 구문
        r_clk <= 1'b0;
        end else begin
            if(r_counter == 99_999) begin // clock divide 계산, 100Mh -> 100hz
                r_counter <=0; //백만개를 셋을 때 r_counter로 보내기
                r_clk <= 1'b1; // r_clk : 0 -> 1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0; // r_clk : 0으로 유지
            end
        end
    end
endmodule


module counter_8( //8진 카운터
    input clk, reset,
    output [2:0] o_sel
);

    reg [2:0] r_counter;
    assign o_sel = r_counter;

    always@(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1; // 0 1 2 3 0 1 2 3 ... 
            // 조합논리와 다르게 edge만 체크함
            // 조합회로는 항상<=
        end
    end

endmodule


// 3x8
module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] seg_comm
);

// 3x8 decoder
always @(seg_sel) begin
    case(seg_sel)
    3'b000:  seg_comm=4'b1110;
    3'b001:  seg_comm=4'b1101;
    3'b010:  seg_comm=4'b1011;
    3'b011:  seg_comm=4'b0111;
    3'b100:  seg_comm=4'b1110;
    3'b101:  seg_comm=4'b1101;
    3'b110:  seg_comm=4'b1011;
    3'b111:  seg_comm=4'b0111;
    default: seg_comm=4'b1111;
    endcase
end

endmodule

module digit_splitter #(parameter BIT_WIDTH = 7) (
    input [BIT_WIDTH -1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);

assign digit_1 = bcd % 10; //10의 1의 자리
assign digit_10 = bcd / 10 % 10; //10의 10의 자리


endmodule

// module digit_splitter_sec(
//     input [12:0] bcd_sec,
//     output [3:0] digit_100_sec,
//     output [3:0] digit_1000_sec
// );

// assign digit_100_sec = bcd_sec / 100 % 10; //10의 100의 자리
// assign digit_1000_sec = bcd_sec / 1000 % 10; //10의 1000의 자리

// endmodule

module mux_8x1(
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
        case(sel)
            3'b000: y = x0;
            3'b001: y = x1;
            3'b010: y = x2;
            3'b011: y = x3;
            3'b100: y = x4;
            3'b101: y = x5;
            3'b110: y = x6;
            3'b111: y = x7;
            default: y = 4'hf;
        endcase

    end

endmodule

module mux_2x1(
    input sw_mode, 
    input [3:0] msec_sec, // 8비트에서 나온 4비트 값이기에 4비트로 선언
    input [3:0] min_hour,
    output reg [3:0] bcd
);
    always@(*)begin
    case(sw_mode)
        1'b0: begin bcd = msec_sec;  end // msec_sec
        1'b1: begin bcd = min_hour;  end // min_hour
        default: bcd = 4'hf;
    endcase
    end

endmodule


module bcdtoseg(
    input [3:0] bcd, //[3:0] sum값
    input dot,
    output reg [7:0] seg
);
    // always구문은 출력으로 wire가 될 수 없음. 항상 reg type을 가져야 한다. 
    always @(bcd) begin // 항상 대상이벤트를 감시
        
        case(bcd) //case문 안에서 assign문 사용안함
        4'h0: seg = 8'hc0; //8비트의 헥사c0값
        4'h1: seg = 8'hF9;
        4'h2: seg = 8'hA4;
        4'h3: seg = 8'hB0;
        4'h4: seg = 8'h99;
        4'h5: seg = 8'h92;
        4'h6: seg = 8'h82;
        4'h7: seg = 8'hf8;
        4'h8: seg = 8'h80;
        4'h9: seg = 8'h90;
        4'hA: seg = 8'h88;
        4'hB: seg = 8'h83;
        4'hC: seg = 8'hc6;
        4'hD: seg = 8'ha1;
        4'hE: seg = 8'h7f;
        4'hF: seg = 8'hff; // 7f : dot on  // ff : all segment off 
        default: seg = 8'hff;
        endcase
    end

endmodule


module comparator_msec (
    input [6:0] counter_msec, 
    output [3:0] dot
);
    assign dot = (counter_msec < 50) ? 4'he: 4'hf; // dot on, off
    
endmodule



