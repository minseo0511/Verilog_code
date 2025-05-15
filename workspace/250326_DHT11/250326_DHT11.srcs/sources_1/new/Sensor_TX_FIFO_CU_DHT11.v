`timescale 1ns / 1ps

module Sensor_TX_FIFO_CU_DHT11(
    input clk,
    input reset,
    input [7:0] data_in,
    input dht_done,
    input sw_mode,
    input [15:0] DHT11_decimal_data,
    output wr_tx,
    output rd_tx,
    output [7:0] data_sensor_tx
    );
/*
    parameter STOP = 0, DIGIT_1000 = 1, DIGIT_100 = 2, DIGIT_10 = 3, DIGIT_1 = 4, 
              WAIT_1000 = 5, WAIT_100 = 6, WAIT_10 = 7, WAIT_1 = 8,
              PRINT_DOT = 9, PRINT_C = 10, PRINT_PER = 11,
              WAIT_DOT = 12, WAIT_C = 13, WAIT_PER = 14, PRINT_SPACE = 15, WAIT_SPACE = 16;
*/

    parameter STOP = 0, PRINT_HUMIDITY = 1, PRINT_TEMP = 2, WAIT_TX = 3,
              DIGIT_1000 = 4, DIGIT_100 = 5, DIGIT_10 = 6, DIGIT_1 = 7,
              PRINT_DOT = 8, PRINT_PERCENT = 9, PRINT_NEWLINE = 10;

    reg [3:0] pre_state, state, next;
    reg [7:0] data_sensor_tx_reg, data_sensor_tx_next;  
    reg wr_tx_reg, wr_tx_next, rd_tx_reg, rd_tx_next;
    reg [2:0] count_reg;
    reg [2:0] count_next;

    wire [7:0] r_data_digit_1000, r_data_digit_100, r_data_digit_10, r_data_digit_1;
    wire [3:0] w_data_digit_1000, w_data_digit_100, w_data_digit_10, w_data_digit_1;

    wire [31:0]r_data_digit;

    assign w_data_digit_1000 = DHT11_decimal_data[15:12];
    assign w_data_digit_100 = DHT11_decimal_data[11:8];
    assign w_data_digit_10 = DHT11_decimal_data[7:4];
    assign w_data_digit_1 = DHT11_decimal_data[3:0];
   
   assign data_sensor_tx = data_sensor_tx_reg;
   assign wr_tx = wr_tx_reg;
   assign rd_tx = rd_tx_reg;

    decimaltoASCII U_Deci_to_ASCII_1 (
        .data_digit(w_data_digit_1),
        .data_ASCII(r_data_digit_1)
    );

    decimaltoASCII U_Deci_to_ASCII_10 (
        .data_digit(w_data_digit_10),
        .data_ASCII(r_data_digit_10)
    );

    decimaltoASCII U_Deci_to_ASCII_100 (
        .data_digit(w_data_digit_100),
        .data_ASCII(r_data_digit_100)
    );
    
    decimaltoASCII U_Deci_to_ASCII_1000 (
        .data_digit(w_data_digit_1000),
        .data_ASCII(r_data_digit_1000)
    );

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
            data_sensor_tx_reg <= 0;
            wr_tx_reg <= 0;
            rd_tx_reg <= 0;
            count_reg <= 0;
        end
        else begin
            state <= next;
            data_sensor_tx_reg <= data_sensor_tx_next;
            wr_tx_reg <= wr_tx_next;
            rd_tx_reg <= rd_tx_next;
            count_reg <= count_next;
        end
    end

    always @(*) begin
        next = state;
        data_sensor_tx_next = data_sensor_tx_reg;
        wr_tx_next = wr_tx_reg;
        rd_tx_next = rd_tx_reg;
        count_next = count_reg;
        
        case (state)
        STOP: begin
            if (dht_done) begin
                count_next = 0;
                next = sw_mode ? PRINT_HUMIDITY : PRINT_TEMP;
            end
        end 
        PRINT_HUMIDITY: begin
            pre_state = state;
            case (count_reg)
                0: data_sensor_tx_next = "h";
                1: data_sensor_tx_next = "u";
                2: data_sensor_tx_next = "m";
                3: data_sensor_tx_next = " ";
                4: data_sensor_tx_next = "=";
                5: data_sensor_tx_next = " ";
                default: next = WAIT_TX;
            endcase
            wr_tx_next = 1;
            rd_tx_next = 0;
            count_next = count_reg + 1;
            end

        PRINT_TEMP: begin
            pre_state = state;
            case (count_reg)
                0: data_sensor_tx_next = "t";
                1: data_sensor_tx_next = "e";
                2: data_sensor_tx_next = "m";
                3: data_sensor_tx_next = "p";
                4: data_sensor_tx_next = " ";
                5: data_sensor_tx_next = "=";
                6: data_sensor_tx_next = " ";
                default: next = WAIT_TX; 
            endcase
            wr_tx_next = 1;
            rd_tx_next = 0;
            count_next = count_reg + 1;    
        end

        WAIT_TX: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            case (pre_state)
                PRINT_TEMP: next = DIGIT_1000;
                DIGIT_1000: next = DIGIT_100;
                DIGIT_100: next = PRINT_DOT;
                PRINT_DOT: next = DIGIT_10;
                DIGIT_10: next = DIGIT_1;
                DIGIT_1: next = PRINT_PERCENT;
                PRINT_PERCENT: next = PRINT_NEWLINE;
                PRINT_NEWLINE: next = STOP;
                default: next = STOP;
            endcase
        end

        DIGIT_1000: begin
            pre_state = state;
            data_sensor_tx_next = r_data_digit_1000;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_TX;
        end

        DIGIT_100: begin
            pre_state = state;
            data_sensor_tx_next = r_data_digit_100;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_TX;
        end  

        PRINT_DOT: begin
            pre_state = state;
            data_sensor_tx_next = "."; // '.'
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_TX;
        end

        DIGIT_10: begin
            pre_state = state;
            data_sensor_tx_next = r_data_digit_10;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_TX;
        end  

        DIGIT_1: begin
            pre_state = state;
            data_sensor_tx_next = r_data_digit_1;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_TX;
        end  

        PRINT_PERCENT: begin
            pre_state = state;
            data_sensor_tx_next = "%";
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_TX;
        end

        PRINT_NEWLINE: begin
            pre_state = state;
            data_sensor_tx_next = " "; // Newline (\n)
            wr_tx_next = 1;
            rd_tx_next = 0; 
            next = WAIT_TX;
        end
        endcase    
    end

/*
    always @(*) begin
        next = state;
        data_sensor_tx_next = data_sensor_tx_reg;
        wr_tx_next = wr_tx_reg;
        rd_tx_next = rd_tx_reg;
        count_next = count_reg;
        case (state)
        STOP: begin
            if (dht_done) begin
                count_next = 0;
                next = DIGIT_1000;
            end
        end 
        DIGIT_1000: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_1000;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_1000;
        end  
        WAIT_1000: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next =DIGIT_100;
        end
        DIGIT_100: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_100;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_100;
        end  
        WAIT_100: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next = PRINT_DOT;
        end

        PRINT_DOT: begin
            data_sensor_tx_next = 8'h2E;  //.
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_DOT;
        end
        WAIT_DOT: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next = DIGIT_10;
        end

        DIGIT_10: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_10;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_10;
        end  
        WAIT_10: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next = DIGIT_1;
        end
        DIGIT_1: begin // 100의 자리 처리
            data_sensor_tx_next = r_data_digit_1;
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_1;
        end  
        WAIT_1: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            if(sw_mode) begin
                next = PRINT_PER;
            end
            else begin
                next = PRINT_C;
            end
        end
        
        PRINT_C: begin
            data_sensor_tx_next = 8'h43; //C
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_C;
        end
        WAIT_C: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next = PRINT_SPACE;
        end
        PRINT_PER: begin
            data_sensor_tx_next = 8'h25; //%
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_PER;
        end
        WAIT_PER: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next = PRINT_SPACE;
        end

        PRINT_SPACE: begin
            data_sensor_tx_next = 8'h20; //space
            wr_tx_next = 1;
            rd_tx_next = 0;
            next = WAIT_SPACE;
        end
        WAIT_SPACE: begin
            wr_tx_next = 0;
            rd_tx_next = 1;
            next = STOP;
        end
        endcase    
    end
    */
endmodule
