`timescale 1ns / 1ps

module SPI_Slave(
    // Global port
    input clk,
    input rst,
    
    input start,
    input [7:0] tx_data,
    output [7:0] rx_data,
    output done,
    output ready,
    
    input SCLK,
    output wire MISO,
    input MOSI,
    input CS_b,
    // fndController
    output [3:0] fndCom,
    output [7:0] fndFont
    );

    // wire [7:0] data;
    wire [13:0] w_fndData;

    SPI U_SPI(
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data), // data
        .done(done),
        .ready(ready),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .CS_b(CS_b)
    );

    fsm U_fsm(
        .clk(clk),
        .rst(rst),
        .data(rx_data),
        .CS_b(CS_b),
        .done(done),
        .fndData(w_fndData)
    );

    fndController U_fndController(
        .clk(clk),
        .rst(rst),
        .fndData(w_fndData),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

endmodule

module SPI (
    input clk,
    input rst,
    input start,
    input [7:0] tx_data,
    output [7:0] rx_data, // data
    output done,
    output ready,
    //SPI_Master to SPI_Slave port
    input  SCLK,
    input  MOSI,
    output MISO,
    input CS_b
);

    parameter IDLE = 2'b00, CP0 = 2'b01, CP1 = 2'b10;
    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [$clog2(7)-1:0] bit_count_reg, bit_count_next;
    reg done_reg, done_next;
    reg ready_reg, ready_next;

    assign done = done_reg;
    assign MISO = temp_tx_data_reg[7];
    assign rx_data = rx_data_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= 0;
            temp_tx_data_reg <= 0;
            rx_data_reg <= 0;
            bit_count_reg <= 0;
            done_reg <= 0;
            ready_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg <= bit_count_next;
            done_reg <= done_next;
            ready_reg <= ready_next;
        end
    end

    always @(*) begin
        state_next = state;
        temp_tx_data_next = temp_tx_data_reg;
        rx_data_next = rx_data_reg;
        bit_count_next = bit_count_reg;
        done_next = done_reg;
        ready_next = ready_reg;
        case (state)
            IDLE: begin
                done_next = 0;
                ready_next = 1;
                if(start) begin
                    temp_tx_data_next = tx_data;
                    ready_next = 0;
                    state_next = CP0;
                end
            end 
            CP0: begin
                if(SCLK == 0) begin
                    rx_data_next = {rx_data_reg[6:0], MOSI};
                    state_next = CP1;
                end
            end 
            CP1: begin
                if(SCLK == 1) begin
                    if(bit_count_reg == 7) begin
                        done_next = 1;
                        bit_count_next = 0;
                        state_next = IDLE;
                    end
                    else begin
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        bit_count_next = bit_count_reg + 1;
                        state_next = CP0;
                    end
                end
            end
        endcase
    end

endmodule



