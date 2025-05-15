`timescale 1ns / 1ps

module DataPath(
    input logic clk,
    input logic reset, // 일반적으로 negedge reset을 많이 사용용
    input logic sumSrcMuxSel,
    input logic iSrcMuxSel,
    input logic sumEn,
    input logic iEn,
    input logic adderSrcMuxSel,
    input logic outBuf,
    output logic iLe10,
    output logic [7:0] outPort
    );

    logic [7:0] adderResult, sumSrcMuxData, iSrcMuxData, sumRegData,
                iRegData, addSrcMuxData;

    mux_2x1 U_sumSrcMux(
        .sel(sumSrcMuxSel),
        .x0(8'b0),
        .x1(adderResult),
        .y(sumSrcMuxData)
    );
    mux_2x1 U_iSrcMux(
        .sel(iSrcMuxSel),
        .x0(8'b0),
        .x1(adderResult),
        .y(iSrcMuxData)
    );
    register U_SumReg(
        .clk(clk),
        .reset(reset),
        .en(sumEn),
        .d(sumSrcMuxData),
        .q(sumRegData)
    );
    register U_iReg(
        .clk(clk),
        .reset(reset),
        .en(iEn),
        .d(iSrcMuxData),
        .q(iRegData)
    );
    mux_2x1 U_addSrcMux(
        .sel(adderSrcMuxSel),
        .x0(sumRegData),
        .x1(8'b1),
        .y(addSrcMuxData)
    );
    comparator U_comparator(
        .a(iRegData),
        .b(8'h0A),
        .le(iLe10)
    );    
    adder U_Adder(
        .a(addSrcMuxData),
        .b(iRegData),
        .sum(adderResult)
    );

    // register를 사용하면 zz없이 값 표현
    register U_outBufReg(
        .clk(clk),
        .reset(reset),
        .en(outBuf),
        .d(sumRegData),
        .q(outPort)
    );
    //assign outPort = outBuf ? sumRegData : 8'bz;
endmodule

module mux_2x1 (
    input logic sel,
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic [7:0] y
);
    always_comb begin : mux
        y = 8'b0;
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
    always_ff @( posedge clk, posedge reset ) begin : register
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

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic le
);
    assign le = (a <= b);
endmodule

module adder (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule