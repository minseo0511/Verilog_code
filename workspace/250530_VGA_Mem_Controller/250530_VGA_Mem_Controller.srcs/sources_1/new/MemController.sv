`timescale 1ns / 1ps

module MemController(
    input logic PCLK,
    input logic reset,
    input logic HREF,
    input logic Vsync,
    input logic [7:0] Data,
    output logic FCLK,
    output logic [15:0] wAddr,
    output logic [15:0] wData,
    output logic We
    );

    localparam IDLE = 0, DATA0 = 1, DATA1 = 2;
    logic [1:0] state, state_next;

    logic [15:0] temp_wData_reg, temp_wData_next;
    logic pclk_b;
    logic [1:0] addr_counter;
    logic [1:0] state_counter_reg, state_counter_next;

    assign pclk_b = ~PCLK;

    always_ff @( posedge PCLK, posedge reset ) begin
        if(reset) begin
            state <= 0;
            temp_wData_reg <= 0;
            wAddr <= 0;
            state_counter_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_wData_reg <= temp_wData_next;
            state_counter_reg <= state_counter_next;
            if(addr_counter == 3) begin
                addr_counter <= 0;
                wAddr <= wAddr + 1;
            end
            else begin
                addr_counter <= addr_counter + 1;
            end
        end
    end

    always_comb begin
        state_next = state;
        temp_wData_next = temp_wData_reg;
        state_counter_next = state_counter_reg;
        FCLK = 0;
        We = 0;
        case (state)
            IDLE: begin
                FCLK = 0;
                We = 0;
                if(HREF == 0) begin
                    state_next = DATA0;
                end
            end  
            DATA0: begin
                We = 1;
                if(state_counter_reg == 1) begin
                    state_counter_next = 0;
                    state_next = DATA1;
                end
                else begin
                    if(pclk_b) begin
                        FCLK = 1;
                    end
                    FCLK = 0;
                    temp_wData_next[15:8] = Data; 
                    state_counter_next = state_counter_reg + 1;
                end
            end  
            DATA1: begin
                We = 1;
                if(state_counter_reg == 1) begin
                    state_counter_next = 0;
                    state_next = IDLE;
                    if(pclk_b) begin
                        FCLK = 0;
                        wData = temp_wData_reg;
                    end
                end
                else begin
                    FCLK = 1;
                    temp_wData_next[7:0] = Data; 
                    state_counter_next = state_counter_reg + 1;
                end
            end  
        endcase
    end

endmodule
