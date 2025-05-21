`timescale 1ns / 1ps

module I2C_Master(
    // global signals
    input clk,
    input reset,
    // internal signals
    input [7:0] tx_data,
    output tx_done,
    output ready,
    input start,
    // I2C signals
    output reg SCL,
    output reg SDA
    );

    localparam IDLE = 0, START1 = 1, START2 = 2, DATA1 = 3, DATA2 = 4, DATA3 = 5,
                DATA4 = 6, ACK = 7, STOP1 = 8, STOP2 = 9;
    reg [3:0] state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [$clog2(500)-1:0] clk_count_reg, clk_count_next; 

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
            temp_tx_data_reg <= 0;
            clk_count_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            clk_count_reg <= clk_count_next;
        end
    end

    always @(*) begin
        state_next = state;
        SDA = 1'b1;
        SCL = 1'b1;
        temp_tx_data_next = temp_tx_data_reg;
        clk_count_next = clk_count_reg;
        case (state)
            IDLE: begin
                SDA = 1'b1;
                SCL = 1'b1;
                if(start) begin
                    temp_tx_data_next = tx_data;
                    state_next = START1;
                end
            end 
            START1: begin
                SDA = 1'b0;
                SCL = 1'b1;
                if(clk_count_reg == 499) begin
                    clk_count_next = 0;
                    state_next = START2;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            START2: begin
                SDA = 1'b0;
                SCL = 1'b1;
                if(clk_count_reg == 499) begin
                    clk_count_next = 0;
                    state_next = START2;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            DATA1: begin
                
            end 
            DATA2: begin
                
            end 
            DATA3: begin
                
            end 
            DATA4: begin
                
            end 
            ACK: begin
                
            end 
            STOP1: begin
                
            end 
            STOP2: begin
                
            end 
        endcase
    end
endmodule
