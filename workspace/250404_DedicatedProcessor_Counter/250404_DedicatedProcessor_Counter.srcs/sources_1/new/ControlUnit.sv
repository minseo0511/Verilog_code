`timescale 1ns / 1ps

module ControlUnit (
    input logic clk,
    input logic reset,
    output logic ASrcMuxSel,
    output logic AEn,
    input logic Alt10,
    output logic OutBuf
);
    
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    reg [2:0] state, state_next;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= S0;
        end
        else begin
            state <= state_next;
        end
    end

    always_comb begin 
        state_next = state;
        ASrcMuxSel = 0;
        AEn = 0;
        OutBuf = 0;
        case (state)
            S0: begin
                ASrcMuxSel = 0;
                AEn = 1;
                OutBuf = 0;
                state_next = S1;
            end  
            S1: begin
                ASrcMuxSel = 0;
                AEn = 0;
                OutBuf = 0;
                if(Alt10) begin
                    state_next = S2;    
                end
                else begin
                    state_next = S4;   
                end
            end  
            S2: begin
                ASrcMuxSel = 0;
                AEn = 0;
                OutBuf = 1;
                state_next = S3;
            end  
            S3: begin
                ASrcMuxSel = 1;
                AEn = 1;
                OutBuf = 0;
                state_next = S1;
            end  
            S4: begin
                ASrcMuxSel = 0;
                AEn = 0;
                OutBuf = 0;
                state_next = S4;
            end 
        endcase
    end

endmodule