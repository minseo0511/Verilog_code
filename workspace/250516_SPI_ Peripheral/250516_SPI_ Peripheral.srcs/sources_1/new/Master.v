`timescale 1ns / 1ps

module Master(
    input clk,
    input rst,
    input btn,
    input [13:0] swtich,
    output start,
    output [7:0] tx_data,
    input done
    );

    assign start = btn;

    fsm_master U_fsm_master(
        .clk(clk),
        .rst(rst),
        .start(start),
        .swtich(swtich),
        .tx_data(tx_data),
        .done(done)
    );

    // btn_debounce U_btn_debounce(
    //     .clk(clk),
    //     .reset(rst),
    //     .i_btn(btn),
    //     .o_btn(start)
    // );

endmodule

module fsm_master (
    input clk,
    input rst,
    input start,
    input [13:0] swtich,
    output [7:0] tx_data,
    input done
);
    parameter IDLE = 0, L_BYTE = 1, H_BYTE = 2;
    reg [1:0] state, state_next;

    reg [7:0] tx_data_reg, tx_data_next;
    assign tx_data = tx_data_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= 0;
            tx_data_reg <= 0;
        end
        else begin
            state <= state_next;
            tx_data_reg <= tx_data_next;
        end
    end

    always @(*) begin
        state_next = state;
        tx_data_next = tx_data_reg;
        case (state)
            IDLE: begin
                if(start) begin
                    state_next = L_BYTE;
                end
            end 
            L_BYTE: begin
                tx_data_next = {2'b00, swtich[13:8]};
                state_next = H_BYTE;
            end 
            H_BYTE: begin
                if(done == 1) begin
                    tx_data_next = swtich[7:0];
                    state_next = IDLE;
                end
            end  
        endcase
    end
endmodule

module btn_debounce(
    input clk,
    input reset,
    input i_btn,
    output o_btn
);

    // state 
    
    reg [7:0] q_reg, q_next;  // shift register
    reg edge_detect;
    wire btn_debounce;

    // 1khz clk
    parameter COUNT_BIT = 100_000; //100_000
    reg [$clog2(COUNT_BIT)-1:0] counter_reg, counter_next; 
    reg r_1khz;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end
    // next
    always @(*) begin  // 100_000_000 = 100M
        counter_next = counter_reg;
        r_1khz = 0;
        if (counter_reg == COUNT_BIT) begin
            counter_next = 0;
            r_1khz = 1'b1;
        end else begin // 1khz 1tick.
            // 다음번 카운트 에는 현재 카운트 값에 1을 더해라
            counter_next = counter_reg + 1;
            r_1khz = 1'b0; 
        end
    end

    // state logic , shift register
    always @(posedge r_1khz, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    // next logic
    always @(i_btn, r_1khz) begin  // event i_btn, r_1khz
        // q_reg 현재의 상위 7bit를 다음 하위 7비트를 넣고,
        // 최상에는 i_btn을 넣어라라
        q_next = {i_btn, q_reg[7:1]};  // 8 shift 의 동작 설명.
    end

    // 8 input AND gate
    assign btn_debounce = &q_reg;

    // edge_detector , 100Mhz
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 0;
        end else begin
            edge_detect <= btn_debounce;
        end
    end

    assign o_btn = btn_debounce & (~edge_detect);
endmodule
