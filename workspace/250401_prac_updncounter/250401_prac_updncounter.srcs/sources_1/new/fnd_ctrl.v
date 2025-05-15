`timescale 1ns / 1ps

module fnd_ctrl(
    input clk,
    input reset,
    input [13:0] data_in,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire w_tick, w_clk;
    wire [1:0] w_sel;
    wire [3:0] w_digit_data;

    digit_splitter U_Digit_Splitter (
        .data_in(data_in),
        .digit_1000(w_digit_1000),
        .digit_100(w_digit_100), 
        .digit_10(w_digit_10), 
        .digit_1(w_digit_1)
    );

    clk_div_100hz U_clk_div_100hz(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk)
);

    count_4 U_Count_4 (
        .clk(w_clk),
        .reset(reset),
        .sel(w_sel)
    );

    mux_4X1 U_MUX_4X1 (
        .sel(w_sel),
        .digit_1000(w_digit_1000),
        .digit_100(w_digit_100),
        .digit_10(w_digit_10),
        .digit_1(w_digit_1),
        .digit_out(w_digit_data)
    );
    
    decoder_2X4 U_Decoder_2X4 (
        .sel(w_sel),
        .fnd_comm(fnd_comm)
    );

    bcdtoseg U_BCD_to_SEG(
        .digit_data(w_digit_data),
        .fnd_font(fnd_font)
    );
endmodule

module clk_div_100hz (
    input clk,
    input reset,
    output o_clk
);
    parameter FCOUNT = 100_000;
    reg [$clog2(FCOUNT)-1:0] count_reg;
    reg clk_reg;

    assign o_clk = clk_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            clk_reg <= 0;
        end
        else if(count_reg == FCOUNT-1) begin
            count_reg <= 0;
            clk_reg <= 1;
        end
        else begin
            count_reg <= count_reg + 1;
            clk_reg <= 0; 
        end
    end
    
endmodule

module digit_splitter (
    input [13:0] data_in,
    output [3:0] digit_1000,
    output [3:0] digit_100, 
    output [3:0] digit_10, 
    output [3:0] digit_1
);

    assign digit_1000 = data_in/1000 % 10;
    assign digit_100 = data_in/100 % 10;
    assign digit_10 = data_in/10 % 10;
    assign digit_1 = data_in % 10;
    
endmodule

module mux_4X1 (
    input [1:0] sel,
    input [3:0] digit_1000,
    input [3:0] digit_100,
    input [3:0] digit_10,
    input [3:0] digit_1,
    output reg [3:0] digit_out
);
    always @(*) begin
        case (sel)
            2'b00: digit_out = digit_1;
            2'b01: digit_out = digit_10;
            2'b10: digit_out = digit_100;
            2'b11: digit_out = digit_1000;
            default: digit_out = 4'hF;
        endcase
    end
endmodule

module count_4 (
    input clk,
    input reset,
    output [1:0] sel
    );

    reg  [1:0] count_reg, count_next;

    assign sel = count_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
        end
        else begin
            count_reg <= count_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        if(count_reg == 4) begin
            count_next = 0;
        end 
        else begin
            count_next = count_reg + 1;
        end
    end
endmodule

module decoder_2X4 (
    input [1:0] sel,
    output reg [3:0] fnd_comm
);

    always @(*) begin
        case (sel)
            2'b00: fnd_comm = 4'b1110;  
            2'b01: fnd_comm = 4'b1101;
            2'b10: fnd_comm = 4'b1011;
            2'b11: fnd_comm = 4'b0111; 
            default: fnd_comm = 4'b1111;
        endcase
    end
endmodule

module bcdtoseg (
    input [3:0] digit_data,
    output reg [7:0] fnd_font
);

    always @(*) begin
        case (digit_data)
            4'h0: fnd_font = 8'hc0; 
            4'h1: fnd_font = 8'hF9;
            4'h2: fnd_font = 8'hA4;
            4'h3: fnd_font = 8'hB0;
            4'h4: fnd_font = 8'h99;
            4'h5: fnd_font = 8'h92;
            4'h6: fnd_font = 8'h82;
            4'h7: fnd_font = 8'hf8;
            4'h8: fnd_font = 8'h80;
            4'h9: fnd_font = 8'h90;
            4'hA: fnd_font = 8'h88;
            4'hB: fnd_font = 8'h83;
            4'hC: fnd_font = 8'hc6;
            4'hD: fnd_font = 8'ha1;
            4'hE: fnd_font = 8'h7f; 
            4'hF: fnd_font = 8'hff; 
            default: fnd_font = 8'hff;
        endcase
    end
    
endmodule