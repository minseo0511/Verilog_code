`timescale 1ns / 1ps

module FND_ASCIItoSeg(
    input [7:0] ASCII,  // [3:0]sum value
    output reg [7:0] seg  // seg의 type을 reg로 변환(기존 wire)
);
    //always문에서 출력이 wire일 수 없고 reg여야 한다.
    always @(ASCII) begin

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