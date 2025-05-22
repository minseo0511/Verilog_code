`timescale 1ns / 1ps

module I2C_Slave(
    
    );
endmodule

module I2C_Slave_Intf (
    input clk,
    input reset,
    input SCL,
    inout SDA
);
    reg [7:0] slv_reg0, slv_reg1;

    localparam IDLE = 0, ADDR = 1, ACK = 2, DATA = 3, STOP = 4;
    localparam ADDR_VALUE = 7'h01;

    reg [2:0] state, state_next;
    reg [7:0] addr_reg, addr_next;
    reg [7:0] data_reg, data_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [$clog2(750)-1:0] clk_count_reg, clk_count_next;
    reg rd_wr_reg, rd_wr_next;
    reg SDA_read;
    reg ack_reg, ack_next;
    reg I2C_en_reg, I2C_en_next;
    reg flag;

    assign SDA = I2C_en_reg ? SDA_read : 1'bz;

    // always @(posedge clk, posedge reset) begin
    //     if(reset) begin
    //         clk_count_reg <= 0;
    //     end
    //     else begin
    //         clk_count_reg <= clk_count_next;
    //     end
    // end

    always @(negedge SCL) begin
        if(SDA == 0) begin
            flag <= 1;
        end else begin
            flag <= 0;
        end
    end

    always @(posedge SCL, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            addr_reg <= 0;
            bit_count_reg <= 0;
            clk_count_reg <= 0;
            rd_wr_reg <= 0;
            data_reg <= 0;
            ack_reg <= 0;
            I2C_en_reg <= 0;
        end
        else begin
            state <= state_next;
            addr_reg <= addr_next;
            bit_count_reg <= bit_count_next;
            clk_count_reg <= clk_count_next;
            rd_wr_reg <= rd_wr_next;
            data_reg <= data_next;
            ack_reg <= ack_next;
            I2C_en_reg <= I2C_en_next;
        end
    end

    always @(*) begin
        state_next = state;
        addr_next = addr_reg;
        bit_count_next = bit_count_reg;
        clk_count_next = clk_count_reg;
        rd_wr_next = rd_wr_reg;
        data_next = data_reg;
        ack_next = ack_reg;
        I2C_en_next = I2C_en_reg;
        case (state)
            IDLE: begin
                I2C_en_next = 1'b0;
                if(flag) begin //(SCL == 1) && 
                    state_next = ADDR;
                end
            end  
            ADDR: begin
                if(bit_count_reg == 7) begin
                    bit_count_next = 0;
                    if(addr_reg[6:0] == ADDR_VALUE) begin
                        rd_wr_next = SDA;
                        I2C_en_next = 1'b1;
                        state_next = ACK;
                    end
                    else begin
                        state_next = IDLE;
                    end
                end
                else begin
                    addr_next = {addr_reg[7:1], SDA};
                    bit_count_next = bit_count_reg + 1;
                end
            end  

            ACK: begin
                SDA_read = 1'b0;
                I2C_en_next = 1'b0;
                state_next = STOP;
            end

            DATA: begin
                if(rd_wr_reg) begin
                    I2C_en_next = 1'b1;
                    SDA_read = data_reg[bit_count_reg];
                    if(bit_count_reg == 7) begin
                        bit_count_next = 0;
                        I2C_en_next = 1'b1;
                        state_next = ACK;
                    end
                    else begin
                        bit_count_next = bit_count_reg + 1;
                    end
                end
                else begin
                    I2C_en_next = 1'b0;
                    data_next = {data_reg[6:0], SDA};
                    if(bit_count_reg == 7) begin
                        bit_count_next = 0;
                        I2C_en_next = 1'b1;
                        state_next = ACK;
                    end
                    else begin
                        bit_count_next = bit_count_reg + 1;
                    end
                end
            end  
            STOP: begin
                if(((SCL == 1) && (SDA == 0))) begin
                    state_next = IDLE;
                end
                else begin
                    state_next = DATA;
                end
            end  
        endcase
    end
endmodule