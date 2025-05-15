`timescale 1ns / 1ps

module ControlUnit(
    input logic clk,
    input logic reset,
    input logic       iLe10,
    output  logic       RFSrcMuxSel,
    output  logic [2:0] readAddr1,
    output  logic [2:0] readAddr2,
    output  logic [2:0] writeAddr,
    output  logic       writeEn,
    output  logic       outBuf
    );

    typedef enum {S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7} state_char;
    state_char state, state_next; 
    
    always_ff @( posedge clk, posedge reset) begin
        if(reset) begin
            state <= S0;
        end
        else begin
            state <= state_next;
        end
    end

    always @(*) begin
        state_next = state;
        RFSrcMuxSel = 0;
        readAddr1 = 0;
        readAddr2 = 0;
        writeAddr = 0;
        writeEn = 0;
        outBuf = 0;
        case (state)
            S0: begin
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 1;
                writeEn = 1;
                outBuf = 0;  
                state_next = S1;
            end 
            S1: begin
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 2;
                writeEn = 1;
                outBuf = 0;  
                state_next = S2;
            end 
            S2: begin
                RFSrcMuxSel = 1;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 3;
                writeEn = 1;
                outBuf = 0;  
                state_next = S3;
            end 
            S3: begin
                RFSrcMuxSel = 0;
                readAddr1 = 1;
                readAddr2 = 0;
                writeAddr = 0;
                writeEn = 0;
                outBuf = 0;  
                if(iLe10) state_next = S4;
                else state_next = S7;
            end 
            S4: begin
                RFSrcMuxSel = 0;
                readAddr1 = 1;
                readAddr2 = 2;
                writeAddr = 2;
                writeEn = 1;
                outBuf = 0;  
                state_next = S5;
            end 
            S5: begin
                RFSrcMuxSel = 0;
                readAddr1 = 1;
                readAddr2 = 3;
                writeAddr = 1;
                writeEn = 1;
                outBuf = 0;  
                state_next = S6;
            end 
            S6: begin
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 2;
                writeAddr = 0;
                writeEn = 0;
                outBuf = 1;  
                state_next = S3;
            end 
            S7: begin
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 0;
                writeEn = 0;
                outBuf = 0;  
                state_next = S7;
            end 
        endcase
    end

endmodule
