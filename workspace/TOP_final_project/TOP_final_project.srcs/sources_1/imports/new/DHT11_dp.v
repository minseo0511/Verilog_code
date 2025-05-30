`timescale 1ns / 1ps

module DHT11_dp(
    input clk,
    input reset,
    input dht_done,
    input [2:0] sw_tem_hum,
    input [39:0] data_in, // DHT11_cu input
    input [15:0] DHT11_decimal_data, // fnd output
    output [15:0] data_out, // fnd input
    output wr_tx,
    output [7:0] data_sensor_tx
    );

    parameter STOP = 0, DIGIT_1000 = 1, DIGIT_100 = 2, DIGIT_10 = 3, DIGIT_1 = 4, 
              WAIT_1000 = 5, WAIT_100 = 6, WAIT_10 = 7, WAIT_1 = 8,
              PRINT_DOT = 9, PRINT_C = 10, PRINT_PER = 11,
              WAIT_DOT = 12, WAIT_C = 13, WAIT_PER = 14, PRINT_SPACE = 15, WAIT_SPACE = 16;

    reg [5:0] state, next;
    reg [7:0] data_sensor_tx_reg, data_sensor_tx_next;  
    reg wr_tx_reg, wr_tx_next;
    reg [15:0] data_out_reg, data_out_next;
    reg [2:0] sw_tem_hum_reg;

    wire [7:0] r_data_digit_1000, r_data_digit_100, r_data_digit_10, r_data_digit_1;
    wire [3:0] w_data_digit_1000, w_data_digit_100, w_data_digit_10, w_data_digit_1;

    wire [31:0]r_data_digit;

    assign w_data_digit_1000 = DHT11_decimal_data[15:12];
    assign w_data_digit_100 = DHT11_decimal_data[11:8];
    assign w_data_digit_10 = DHT11_decimal_data[7:4];
    assign w_data_digit_1 = DHT11_decimal_data[3:0];
   
   assign data_sensor_tx = data_sensor_tx_reg;
   assign wr_tx = wr_tx_reg;
   assign data_out = data_out_reg;

    deci_to_ASCII U_Deci_to_ASCII_1 (
        .data_digit(w_data_digit_1),
        .data_ASCII(r_data_digit_1)
    );

    deci_to_ASCII U_Deci_to_ASCII_10 (
        .data_digit(w_data_digit_10),
        .data_ASCII(r_data_digit_10)
    );

    deci_to_ASCII U_Deci_to_ASCII_100 (
        .data_digit(w_data_digit_100),
        .data_ASCII(r_data_digit_100)
    );
    
    deci_to_ASCII U_Deci_to_ASCII_1000 (
        .data_digit(w_data_digit_1000),
        .data_ASCII(r_data_digit_1000)
    );

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
            data_sensor_tx_reg <= 0;
            wr_tx_reg <= 0;
            data_out_reg <= 0;
            sw_tem_hum_reg <= 0;
        end
        else begin
            state <= next;
            data_sensor_tx_reg <= data_sensor_tx_next;
            wr_tx_reg <= wr_tx_next;
            data_out_reg <= data_out_next;
            sw_tem_hum_reg <= sw_tem_hum;
        end
    end

    always @(*) begin
        next = state;
        data_sensor_tx_next = data_sensor_tx_reg;
        wr_tx_next = wr_tx_reg;
        sw_tem_hum_reg = sw_tem_hum;
        case (state)
        STOP: begin
            if (dht_done) begin
                next = DIGIT_1000;
            end
        end 
        DIGIT_1000: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_1000;
            wr_tx_next = 1;
            next = WAIT_1000;
        end  
        WAIT_1000: begin
            wr_tx_next = 0;
            next =DIGIT_100;
        end
        DIGIT_100: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_100;
            wr_tx_next = 1;
            next = WAIT_100;
        end  
        WAIT_100: begin
            wr_tx_next = 0;
            next = PRINT_DOT;
        end

        PRINT_DOT: begin
            data_sensor_tx_next = 8'h2E;  //.
            wr_tx_next = 1;
            next = WAIT_DOT;
        end
        WAIT_DOT: begin
            wr_tx_next = 0;
            next = DIGIT_10;
        end

        DIGIT_10: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_10;
            wr_tx_next = 1;
            next = WAIT_10;
        end  
        WAIT_10: begin
            wr_tx_next = 0;
            next = DIGIT_1;
        end
        DIGIT_1: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_1;
            wr_tx_next = 1;
            next = WAIT_1;
        end  
        WAIT_1: begin
            wr_tx_next = 0;
            if(sw_tem_hum_reg == 3'b111) begin
                next = PRINT_PER;
            end
            else begin
                next = PRINT_C;
            end
        end
        
        PRINT_C: begin
            data_sensor_tx_next = 8'h43; //C
            wr_tx_next = 1;
            next = WAIT_C;
        end
        WAIT_C: begin
            wr_tx_next = 0;
            next = PRINT_SPACE;
        end
        PRINT_PER: begin
            data_sensor_tx_next = 8'h25; //%
            wr_tx_next = 1;
            next = WAIT_PER;
        end
        WAIT_PER: begin
            wr_tx_next = 0;
            next = PRINT_SPACE;
        end

        PRINT_SPACE: begin
            data_sensor_tx_next = 8'h20; //space
            wr_tx_next = 1;
            next = WAIT_SPACE;
        end
        WAIT_SPACE: begin
            wr_tx_next = 0;
            next = STOP;
        end
        endcase    
    end

    // Output temp or hum select
    always @(*) begin
        sw_tem_hum_reg = sw_tem_hum;
        data_out_next = data_out_reg;
        if(sw_tem_hum_reg == 3'b110) begin
            data_out_next = data_in[39:24];
        end
        else if(sw_tem_hum_reg == 3'b111) begin
            data_out_next = data_in[23:8];
        end
    end
endmodule
