`timescale 1ns / 1ps

module fndController(
    input clk,
    input reset,
    input [13:0] fndData,
    output [3:0] fndCom,
    output [7:0] fndFont
    );

    wire w_tick;
    wire [2:0] digit_sel;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000, w_bcd;
    wire [3:0] w_dot;
    wire [9:0] w_msec;

    clk_div_1khz #(.BIT_WIDTH(100_000)) U_CLK_DIV_1khz(
        .clk(clk),
        .reset(reset),
        .tick(w_tick) 
    );

    counter_8bit #(.BIT_WIDTH(8)) U_Counter_8bit(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .count(digit_sel)
    );

    counter_8bit #(.BIT_WIDTH(1000)) U_Counter_100(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .count(w_msec)
    );

    decoder_3x8 U_Dec_3X8 (
        .x(digit_sel),
        .y(fndCom)
    );

    digit_splitter U_Digit_Splitter (
        .fndData(fndData),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_8x1 U_Mux_8X1 (
        .sel(digit_sel),
        .x0(w_digit_1),
        .x1(w_digit_10),
        .x2(w_digit_100),
        .x3(w_digit_1000),
        .x4(4'hF),
        .x5(w_dot),
        .x6(4'hF),
        .x7(4'hF),
        .y(w_bcd)
    );

    bcdtoSEG U_BCDtoSEG(
        .bcd(w_bcd),
        .seg(fndFont)
    );

    printDot U_PrintDot(
        .msec(w_msec),
        .dot(w_dot)
    );

endmodule

module clk_div_1khz #(parameter BIT_WIDTH = 100_000)(
    input clk,
    input reset,
    output reg tick
);

    reg [$clog2(BIT_WIDTH)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end
        else begin
            if(div_counter == BIT_WIDTH - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end
            else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

module counter_8bit #(parameter BIT_WIDTH = 100)(
    input clk,
    input reset,
    input tick,
    output reg [$clog2(BIT_WIDTH)-1:0] count
);
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count <= 0;
        end
        else begin
            if(tick) begin
                if(count == BIT_WIDTH-1) begin
                    count <= 0;
                end
                else begin
                    count <= count + 1;  
                end
            end
        end
    end
endmodule

module decoder_3x8 (
    input [2:0] x,
    output reg [3:0] y
);

    always @(*) begin
        y = 4'b1111;
        case (x)
            3'b000: y = 4'b1110; 
            3'b001: y = 4'b1101; 
            3'b010: y = 4'b1011; 
            3'b011: y = 4'b0111; 
            3'b100: y = 4'b1110; 
            3'b101: y = 4'b1101; 
            3'b110: y = 4'b1011; 
            3'b111: y = 4'b0111; 
        endcase
    end    
endmodule

module digit_splitter (
    input [13:0] fndData,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = fndData % 10;
    assign digit_10 = fndData /10 % 10;
    assign digit_100 = fndData /100 % 10;
    assign digit_1000 = fndData /1000 % 10;
endmodule

module mux_8x1 (
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
        y = 4'b0000;
        case (sel)
            3'b000: y = x0; 
            3'b001: y = x1; 
            3'b010: y = x2; 
            3'b011: y = x3; 
            3'b100: y = x4; 
            3'b101: y = x5; 
            3'b110: y = x6; 
            3'b111: y = x7; 
        endcase
    end    
endmodule

module bcdtoSEG (
    input [3:0] bcd,
    output reg  [7:0] seg
);
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
            4'hE: seg = 8'h7F; //dot on
            4'hF: seg = 8'hFF; //dot off
            default: seg = 8'hFF;
        endcase
    end  
endmodule

module printDot (
    input [9:0] msec,
    output [3:0] dot
);

    assign dot = (msec<500) ? 4'hE : 4'hF;
endmodule