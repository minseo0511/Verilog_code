`timescale 1ns / 1ps


module DataPath(
    input logic clk,
    input logic reset,
    input logic ASrcMuxSel,
    input logic AEn,
    output logic Alt10,
    input logic OutBuf,
    output logic [7:0] outPort
    );



    MUX2X1 U_MUX2X1(
        .sel(ASrcMuxSel),
        .x0(0),
        .x1(),
        .y(y)
    );

    register U_register(
        .clk(clk),
        .reset(reset),
        .en(AEn),
        .d(),
        .q()
    );

    adder U_adder(
        .a(),
        .b(),
        .sum()
    );

    comparator U_comparator (
        .a(),
        .b(),
        .Alt10()
    );

endmodule

module MUX2X1 (
    input logic sel,
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic y
);
    always @(*) begin
        y = 0;
        case (sel)
            1'b0: y = x0; 
            1'b1: y = x1; 
        endcase
    end
endmodule

module register (
    input logic clk,
    input logic reset,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
);
    // ff로 사용하면 ff가 아닐 시 warning을 표시한다.
    always_ff @( posedge clk, posedge reset ) begin 
        if(reset) begin
            q <= 0;
        end
        else begin
            if(en) begin
                q <= d;
            end
        end
    end
endmodule

module adder (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic Alt10
);
    assign Alt10 = a < b;
endmodule