`timescale 1ns / 1ps

module play_fsm(
    // global signals
    input logic clk,
    input logic reset,

    // buzzer signals
    input logic start_btn,
    input logic buzzer_done,
    output logic buzzer_start,

    // motion_detect signals
    input logic motion_detected,
    input logic motion_done,
    output logic play_start
    );

    logic [$clog2(300_000_000)-1:0] count_3sec_reg, count_3sec_next;

    typedef enum { IDLE, BUZZER, PLAY, COMPARE} state_e;
    state_e state, state_next;

    always_ff @( posedge clk, posedge reset ) begin
        if(reset) begin
            state <= IDLE;
            count_3sec_reg <= 0;
        end
        else begin
            state <= state_next;
            count_3sec_reg <= count_3sec_next;
        end
    end

    always_comb begin
        state_next = state;
        buzzer_start = 0;
        play_start = 0;
        count_3sec_next = count_3sec_reg;
        case (state)
            IDLE: begin
                count_3sec_next = 0;
                if(start_btn) begin
                    buzzer_start = 1'b1;
                    state_next = BUZZER;
                end
            end 
            BUZZER: begin
                buzzer_start = 1'b0;
                if(buzzer_done) begin
                    play_start = 1'b1;
                    state_next = PLAY;
                end
            end 
            PLAY: begin
                play_start = 1'b1;
                if(count_3sec_reg == 300_000_000-1) begin
                    count_3sec_next = 0;
                    play_start = 1'b0;
                    state_next = IDLE;
                end
                else begin
                    count_3sec_next = count_3sec_reg + 1;
                end
            end 
            // COMPARE: begin
                
            // end 
        endcase
    end

endmodule
