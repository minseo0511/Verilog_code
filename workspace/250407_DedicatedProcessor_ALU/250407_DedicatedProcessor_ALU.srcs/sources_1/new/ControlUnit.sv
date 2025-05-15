`timescale 1ns / 1ps

module ControlUnit(
    input  logic       clk,
    input  logic       reset,
    input logic       iLe10,
    input logic comp_data,
    output  logic       RFSrcMuxSel,
    output  logic [2:0] readAddr1,
    output  logic [2:0] readAddr2,
    output  logic [2:0] writeAddr,
    output  logic       writeEn,
    output  logic       outBuf,
    output logic [2:0] aluOP
    );

    logic [14:0] outsignals;
    assign {RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, aluOP, outBuf} = outsignals;

    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7, S8 = 8, S9 = 9, S10 = 10,
              S11 = 11, S12 = 12, S13 = 13, S14 = 14, S15 = 15, S16 = 16, S17 = 17, S18 = 18;
    logic [3:0] state, next;

    always @(posedge clk, posedge reset) begin
        if(reset) state <= S0;
        else state <= next;
    end

    always @(*) begin
        next = state;
        outsignals = 0;
        case (state)
            S0: begin // R1 = 1
                outsignals = 15'b1_000_000_001_1_000_0;
                next = S1;
            end
            S1: begin // R2 = 0
                outsignals = 15'b0_000_000_010_1_000_0;
                next = S2;
            end
            S2: begin // R3 = 0
                outsignals = 15'b0_000_000_011_1_000_0;
                next = S3;
            end
            S3: begin // R4 = R1 + R1(2)
                outsignals = 15'b0_001_001_100_1_000_1;
                next = S4;
            end
            S4: begin // R5 = R4 + R4(4)
                outsignals = 15'b0_100_100_101_1_000_1;
                next = S5;
            end
            S5: begin // R6 = R5 - R1(3)
                outsignals = 15'b0_101_001_110_1_001_1;
                next = S6;
            end
            S6: begin // R2 = R6 & R4(2)
                outsignals = 15'b0_110_100_010_1_010_1;
                next = S7;
            end
            S7: begin // R3 = R2 | R5(6)
                outsignals = 15'b0_010_101_011_1_011_1;
                next = S8;
            end
            S8: begin // R7 = R3 ^ R2(4) 
                outsignals = 15'b0_011_010_111_1_100_1;
                next = S9;
            end
            S9: begin // R4 = ~R7(1111 1100)  
                outsignals = 15'b0_100_111_000_1_101_1;
                next = S10;
            end
            S10: begin // R7 > R4 
                outsignals = 15'b0_111_100_000_0_110_1;
                if(comp_data) next = S4;
                else next = S11;
            end
            S11: begin // halt
                outsignals = 15'b0_000_000_000_0_000_0;
                next = S11;
            end
        endcase
    end
endmodule
