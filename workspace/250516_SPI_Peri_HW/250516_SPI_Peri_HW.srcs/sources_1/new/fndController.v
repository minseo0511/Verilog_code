`timescale 1ns / 1ps

module fndController (
    input clk,
    input rst,
    input [13:0] fndData,
    output [3:0] fndCom,
    output [7:0] fndFont
);

    wire w_tick;
    wire [1:0] w_count4;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000, w_digit_out;

    clk_divider U_clk_divider (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    count_4 U_count_4 (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .count_4(w_count4)
    );

    decoder2X4 U_decoder2X4 (
        .decode_in (w_count4),
        .decode_out(fndCom)
    );

    digitsplitter U_digitsplitter (
        .data_in(fndData),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux4X1 U_mux4X1 (
        .sel(w_count4),
        .digit_1000(w_digit_1000),
        .digit_100(w_digit_100),
        .digit_10(w_digit_10),
        .digit_1(w_digit_1),
        .fndFont(w_digit_out)
    );

    FND U_FND (
        .digit_in(w_digit_out),
        .fndFont (fndFont)
    );
endmodule

module FND (
    input [3:0] digit_in,
    output reg [7:0] fndFont
);
    always @(*) begin
        case (digit_in)
            4'h0: fndFont = 8'hC0;
            4'h1: fndFont = 8'hf9;
            4'h2: fndFont = 8'ha4;
            4'h3: fndFont = 8'hb0;
            4'h4: fndFont = 8'h99;
            4'h5: fndFont = 8'h92;
            4'h6: fndFont = 8'h82;
            4'h7: fndFont = 8'hf8;
            4'h8: fndFont = 8'h80;
            4'h9: fndFont = 8'h90;
            4'hA: fndFont = 8'h88;
            4'hB: fndFont = 8'h83;
            4'hC: fndFont = 8'hC6;
            4'hD: fndFont = 8'hA1;
            4'hE: fndFont = 8'h86;
            4'hF: fndFont = 8'h8E;
            default: fndFont = 8'hC0;
        endcase
    end
endmodule

module clk_divider (
    input clk,
    input rst,
    output reg o_tick
);
    parameter FCOUNT = 500_000; //500_000
    reg [$clog2(FCOUNT)-1:0] count_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            o_tick <= 0;
        end else begin
            if (count_reg == FCOUNT) begin
                count_reg <= 0;
                o_tick <= 1'b1;
            end else begin
                count_reg <= count_reg + 1;
                o_tick <= 1'b0;
            end
        end
    end
endmodule

module count_4 (
    input clk,
    input rst,
    input tick,
    output reg [1:0] count_4
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_4 <= 0;
        end else begin
            if (tick) begin
                count_4 <= count_4 + 1;
            end
        end
    end
endmodule

module decoder2X4 (
    input [1:0] decode_in,
    output reg [3:0] decode_out
);
    always @(*) begin
        case (decode_in)
            2'b00:   decode_out = 4'b1110;
            2'b01:   decode_out = 4'b1101;
            2'b10:   decode_out = 4'b1011;
            2'b11:   decode_out = 4'b0111;
            default: decode_out = 4'b1111;
        endcase
    end
endmodule

module digitsplitter (
    input  [13:0] data_in,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);
    assign digit_1 = data_in % 10;
    assign digit_10 = data_in / 10 % 10;
    assign digit_100 = data_in / 100 % 10;
    assign digit_1000 = data_in / 1000 % 10;
endmodule

module mux4X1 (
    input [1:0] sel,
    input [3:0] digit_1000,
    input [3:0] digit_100,
    input [3:0] digit_10,
    input [3:0] digit_1,
    output reg [3:0] fndFont
);
    always @(*) begin
        case (sel)
            2'b00:   fndFont = digit_1;
            2'b01:   fndFont = digit_10;
            2'b10:   fndFont = digit_100;
            2'b11:   fndFont = digit_1000;
            default: fndFont = 4'h0;
        endcase
    end
endmodule
