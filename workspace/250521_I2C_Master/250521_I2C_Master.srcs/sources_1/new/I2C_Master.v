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
    input stop,
    // I2C signals
    output reg SCL,
    output reg SDA
    );

    localparam IDLE = 0, START1 = 1, START2 = 2, DATA1 = 3, DATA2 = 4, DATA3 = 5,
                DATA4 = 6, ACK = 7, HOLD = 8, STOP1 = 9, STOP2 = 10;
    reg [3:0] state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [$clog2(500)-1:0] clk_count_reg, clk_count_next; 
    reg [2:0] bit_count_reg, bit_count_next;
    reg flag_reg, flag_next;
    reg rd_wr_reg, rd_wr_next;
    reg tx_done_reg, tx_done_next; 

    assign tx_done = tx_done_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
            temp_tx_data_reg <= 0;
            clk_count_reg <= 0;
            bit_count_reg <= 0;
            flag_reg <= 0;
            rd_wr_reg <= 0;
            tx_done_reg <= 0;
            
        end
        else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            clk_count_reg <= clk_count_next;
            bit_count_reg <= bit_count_next;
            flag_reg <= flag_next;
            rd_wr_reg <= rd_wr_next;
            tx_done_reg <= tx_done_next;
        end
    end

    always @(*) begin
        state_next = state;
        SDA = 1'b1;
        SCL = 1'b1;
        temp_tx_data_next = temp_tx_data_reg;
        clk_count_next = clk_count_reg;
        bit_count_next = bit_count_reg;
        flag_next = flag_reg;
        rd_wr_next = rd_wr_reg;
        tx_done_next = tx_done_reg;
        case (state)
            IDLE: begin
                SDA = 1'b1;
                SCL = 1'b1;
                tx_done_next = 1'b0;
                temp_tx_data_next = tx_data;
                flag_next = 1'b1;
                if(start) begin
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
                    state_next = DATA1;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            DATA1: begin
                SDA = temp_tx_data_reg[7];
                SCL = 0;
                if(clk_count_reg == 249) begin
                    clk_count_next = 0;
                    state_next = DATA2;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            DATA2: begin
                SDA = temp_tx_data_reg[7];
                SCL = 1;
                if(clk_count_reg == 249) begin
                    clk_count_next = 0;
                    state_next = DATA3;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            DATA3: begin
                SDA = temp_tx_data_reg[7];
                SCL = 1;
                tx_done_next = 1'b0;
                if(clk_count_reg == 249) begin
                    clk_count_next = 0;
                    state_next = DATA4;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            DATA4: begin
                SDA = temp_tx_data_reg[7];
                SCL = 0;
                if(clk_count_reg == 249) begin
                    if(bit_count_reg == 7) begin
                        if(flag_reg == 1) begin
                            flag_next = 0;
                            rd_wr_next = SDA;
                        end
                        clk_count_next = 0;
                        bit_count_next = 0;
                        tx_done_next = 1'b1;
                        state_next = ACK;
                    end
                    else begin
                        clk_count_next = 0;
                        bit_count_next = bit_count_reg + 1;
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        state_next = DATA1;
                    end
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            ACK: begin
                SDA = 0;
                SCL = 0;
                tx_done_next = 1'b0;
                state_next = HOLD;
            end 
            HOLD: begin
                if(stop) begin
                    state_next = STOP1;
                end
                else begin
                    temp_tx_data_next = tx_data;
                    state_next = DATA1;
                end
            end
            STOP1: begin
                SDA = 0;
                SCL = 1;
                if(clk_count_reg == 499) begin
                    clk_count_next = 0;
                    state_next = STOP2;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
            STOP2: begin
                SDA = 1;
                SCL = 1;
                if(clk_count_reg == 499) begin
                    clk_count_next = 0;
                    state_next = IDLE;
                end
                else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end 
        endcase
    end
endmodule
