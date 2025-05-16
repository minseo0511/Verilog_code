`timescale 1ns / 1ps

module fsm (
    input clk,
    input rst,
    input [7:0] data,
    input CS_b,
    input done,
    output [13:0] fndData
);
    parameter IDLE = 0, L_BYTE = 1, H_BYTE = 2;
    reg [1:0] state, state_next;
    reg [13:0] fndData_reg, fndData_next;

    assign fndData = fndData_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= 0;
            fndData_reg <= 0;
        end
        else begin
            state <= state_next;
            fndData_reg <= fndData_next;
        end
    end

    always @(*) begin
        state_next = state;
        case (state)
            IDLE: begin
                if(CS_b == 0) begin
                    state_next = L_BYTE;
                end
            end 
            L_BYTE: begin
                if(CS_b == 0 && done == 1) begin
                    fndData_next[7:0] = data;
                    state_next = H_BYTE;
                end
            end 
            H_BYTE: begin
                if(CS_b == 0 && done == 1) begin
                    fndData_next[13:8] = data[5:0];
                    state_next = IDLE;
                end
            end  
        endcase
    end
endmodule
