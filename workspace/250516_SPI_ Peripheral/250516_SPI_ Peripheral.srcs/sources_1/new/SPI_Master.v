`timescale 1ns / 1ps

module SPI_Master(
    // Global port
    input clk,
    input rst,
    // SPI_Master to Master port
    input start,
    input [7:0] tx_data,
    output [7:0] rx_data,
    output done,
    output ready,
    //SPI_Master to SPI_Slave port
    output SCLK,
    output MOSI,
    input MISO,
    output CS_b
    );

    wire tick_1Mhz;

    clk_div_1Mhz U_clk_div_1Mhz(
        .clk(clk),
        .rst(rst),
        .tick_1Mhz(tick_1Mhz)
    );

    parameter IDLE = 2'b00, CP0 = 2'b01, CP1 = 2'b10;
    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [$clog2(50)-1:0] SCLK_counter_reg, SCLK_counter_next;
    reg [$clog2(7)-1:0] bit_count_reg, bit_count_next;
    reg done_reg, done_next;
    reg ready_reg, ready_next;
    reg CS_b_reg, CS_b_next;
    reg SCLK_reg, SCLK_next;

    assign CS_b = CS_b_reg;
    assign done = done_reg;
    assign ready = ready_reg;
    assign SCLK = SCLK_reg;
    assign MOSI = temp_tx_data_reg[7];

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= 0;
            temp_tx_data_reg <= 0;
            rx_data_reg <= 0;
            SCLK_counter_reg <= 0;
            bit_count_reg <= 0;
            done_reg <= 0;
            ready_reg <= 0;
            CS_b_reg <= 0;
            SCLK_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            rx_data_reg <= rx_data_next;
            SCLK_counter_reg <= SCLK_counter_next;
            bit_count_reg <= bit_count_next;
            done_reg <= done_next;
            ready_reg <= ready_next;
            CS_b_reg <= CS_b_next;
            SCLK_reg <= SCLK_next;
        end
    end

    always @(*) begin
        state_next = state;
        temp_tx_data_next = temp_tx_data_reg;
        rx_data_next = rx_data_reg;
        SCLK_counter_next = SCLK_counter_reg;
        bit_count_next = bit_count_reg;
        done_next = done_reg;
        ready_next = ready_reg;
        CS_b_next = CS_b_reg;
        SCLK_next = SCLK_reg;
        case (state)
            IDLE: begin
                temp_tx_data_next = 8'hz;
                done_next = 0;
                ready_next = 1;
                CS_b_next = 1;
                if(start) begin
                    temp_tx_data_next = tx_data;
                    ready_next = 0;
                    CS_b_next = 0;
                    state_next = CP0;
                end
            end 
            CP0: begin
                SCLK_next = 0;
                if(tick_1Mhz) begin
                    if(SCLK_counter_reg == 49) begin
                        rx_data_next = {rx_data_reg[6:0], MISO};
                        SCLK_counter_next = 0;
                        state_next = CP1;
                    end
                    else begin
                        SCLK_counter_next = SCLK_counter_reg + 1;
                    end
                end
            end 
            CP1: begin
                SCLK_next = 1;
                if(tick_1Mhz) begin
                    if(bit_count_reg == 7) begin
                        done_next = 1;
                        CS_b_next = 1;
                        state_next = IDLE;
                    end
                    else begin
                        if(SCLK_counter_reg == 49) begin
                            temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                            SCLK_counter_next = 0;
                            bit_count_next = bit_count_reg + 1;
                            state_next = CP0;
                        end
                        else begin
                            SCLK_counter_next = SCLK_counter_reg + 1;
                        end
                    end
                end
            end
        endcase
    end
endmodule

module clk_div_1Mhz (
    input clk,
    input rst,
    output reg tick_1Mhz
);
    reg [$clog2(100)-1:0] count_clk;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            tick_1Mhz <= 1'b0;
            count_clk <= 0;
        end
        else begin
            if(count_clk == 99) begin
                count_clk <= 0;
                tick_1Mhz <= 1'b1;
            end
            else begin
                count_clk <= count_clk + 1;
                tick_1Mhz <= 1'b0;
            end
        end
    end
endmodule