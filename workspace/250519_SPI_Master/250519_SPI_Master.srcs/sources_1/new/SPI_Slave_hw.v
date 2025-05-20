`timescale 1ns / 1ps

// module SPI_Slave_hw(

//     );
// endmodule

module SPI_Slave_Intf_hw (
    input        SCLK,
    input        reset,
    input        MOSI,
    output       MISO,
    input        SS,
    // internal signals
    output       write,
    output [1:0] addr,
    output [7:0] wdata,
    input  [7:0] rdata
);

    localparam IDLE = 0, CP0 = 1, CP1 = 2;
    
    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next; 
    reg [7:0] temp_rx_data_reg, temp_rx_data_next; 
    reg [2:0] bit_count_reg, bit_count_next;

    reg write_reg, write_next;
    reg [1:0] addr_reg, addr_next;

    reg flag_reg, flag_next;

    assign wdata = temp_rx_data_next;
    assign MISO = SS ? 1'bz : temp_tx_data_reg[7];
    // assign write = flag_reg ? temp_rx_data_reg[7] : 1'bz;
    // assign addr = flag_reg ? temp_rx_data_reg[1:0] : 2'bz;
    assign write = write_reg;
    assign addr = addr_reg;

    always @(SCLK, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            temp_tx_data_reg <= 0;
            temp_rx_data_reg <= 0;
            bit_count_reg <= 0;
            flag_reg <= 0;
            write_reg <= 0;
            addr_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            temp_rx_data_reg <= temp_rx_data_next;
            bit_count_reg <= bit_count_next;
            flag_reg <= flag_next;
            write_reg <= write_next;
            addr_reg <= addr_next;
        end
    end

    always @(*) begin
        state_next = state;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        bit_count_next = bit_count_reg;
        flag_next = flag_reg;
        write_next = write_reg;
        addr_next = addr_reg;
        case (state)
            IDLE: begin
                temp_rx_data_next = 8'h00;
                if(SS == 1'b0) begin
                    temp_tx_data_next = rdata;
                    flag_next = 1'b1;
                    state_next = CP0;
                end
            end 
            CP0: begin
                if(flag_reg) begin
                    write_next = temp_tx_data_reg[7];
                    addr_next = temp_tx_data_reg[1:0];
                end
                if(SCLK) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], MOSI};
                    flag_next = 1'b0;
                    state_next = CP1;
                end
            end 
            CP1: begin
                if(SCLK == 0) begin
                    if(bit_count_reg == 7) begin
                        bit_count_next = 0;
                        flag_next = 1'b0;
                        state_next = IDLE; 
                    end
                    else begin
                        bit_count_next = bit_count_reg + 1;
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        state_next = CP0;
                    end
                end
            end 
        endcase
    end
endmodule