`timescale 1ns / 1ps

module FND_ASCII_to_Seg(
    input [7:0]rx_data,
    output reg [7:0] seg,
    output [3:0] seg_comm
);
    
    assign seg_comm = 4'b1110;

    always @(rx_data) begin
        case (rx_data)
            8'h30: seg = 8'hC0;  //case문 내부에도 begin~end 사용가능
            8'h31: seg = 8'hF9;
            8'h32: seg = 8'hA4;
            8'h33: seg = 8'hB0;
            8'h34: seg = 8'h99;
            8'h35: seg = 8'h92;
            8'h36: seg = 8'h82;
            8'h37: seg = 8'hF8;
            8'h38: seg = 8'h80;
            8'h39: seg = 8'h90;
            8'h41: seg = 8'h88;
            8'h42: seg = 8'h00;
            8'h43: seg = 8'hC6;
            8'h44: seg = 8'h40;
            8'h45: seg = 8'h86; 
            8'h46: seg = 8'h8E;
            default: seg = 8'hFF;
        endcase
    end
endmodule
