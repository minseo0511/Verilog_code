`timescale 1ns / 1ps

module fnd_controller (
    input [7:0] bcd,
  //  input [1:0] seg_sel,
    output [7:0] seg,  //bcdtoseg에서 reg로 정의하였다고 reg X 연결만 
    output [3:0] seg_comm
);
    assign seg_comm = 4'b0000; // segment(anode) 0의 자리 on
    bcdtoseg U_bts (
        .bcd(bcd),
        .seg(seg)
    );
/*
    button_ctrl U_fnd_con(
        .seg_sel(seg_sel),
        .seg_ctrl(seg_comm)
    );
*/
endmodule
/*
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
*/
module bcdtoseg (
    input [7:0] bcd,  // [3:0]sum value
    output reg [7:0] seg  // seg의 type을 reg로 변환(기존 wire)
);
    //always문에서 출력이 wire일 수 없고 reg여야 한다.
    always @(bcd) begin

        case (bcd)
            8'h0: seg = 8'hC0;  //case문 내부에도 begin~end 사용가능
            8'h1: seg = 8'hF9;
            8'h2: seg = 8'hA4;
            8'h3: seg = 8'hB0;
            8'h4: seg = 8'h99;
            8'h5: seg = 8'h92;
            8'h6: seg = 8'h82;
            8'h7: seg = 8'hF8;
            8'h8: seg = 8'h80;
            8'h9: seg = 8'h90;
            8'hA: seg = 8'h88;
            8'hB: seg = 8'h83;
            8'hC: seg = 8'hC6;
            8'hD: seg = 8'hA1;
            8'hE: seg = 8'h86;
            8'hF: seg = 8'h8E;
            default: seg = 8'hFF;
        endcase
    end
endmodule
