`timescale 1ns / 1ps

module fsm_stopwatch(
    input clk,
    input reset,
    input [2:0]sw,
    output [7:0] seg,  
    output [3:0] seg_comm
);
    wire [13:0] w_o_count;
    wire w_clear, w_run_stop;
    wire w_tick_100hz;

    tick_100hz U_tick_100hz(
        .clk(clk),
        .reset(reset),
        .o_tick_100hz(w_tick_100hz)
    );  

    counter_to_10000 U_Count_1(
        .clk(w_tick_100hz),
        .reset(reset),
        .clear(w_clear),
        .run_stop(w_run_stop),
        .o_count(w_o_count)
    );

    fnd_controller U_FND_control(
        .bcd(w_o_count),
        .clk(clk),
        .reset(reset),
        .seg(seg),   
        .seg_comm(seg_comm)
    );

    control_unit U_Conrol_unit(
        .clk(clk),
        .reset(reset),
        .i_run_stop(sw[1]),
        .i_clear(sw[0]),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );
    
endmodule


module counter_to_10000(
    input clk,
    input reset,
    input clear,
    input run_stop,
    output [13:0] o_count
    );
    reg [13:0] r_counter;
    assign o_count = r_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
        end

        else if(clear) begin
            r_counter <= 0;
        end
        
        else if(run_stop) begin
            r_counter <= r_counter;
        end

        else begin
            if(r_counter == 9999) begin
                r_counter <= 0;
            end
            else begin
                r_counter <= r_counter + 1;
            end
        end
    end
endmodule

// 100Hztick generator
module tick_100hz (
    input clk, //100Mhz CLK
    input reset,
    output o_tick_100hz //100Hz tick
);
    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] r_counter; // $clog2(1_000_000) => 해당 수의 필요한 비트 수 계산
    reg r_tick_100hz;
    assign o_tick_100hz = r_tick_100hz;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_tick_100hz <= 1'b0;
        end 
        else if(r_counter == FCOUNT-1) begin
            r_counter <= 0;
            r_tick_100hz <= 1;
        end
        else begin
            r_counter <= r_counter + 1;
            r_tick_100hz <= 0;
        end
    end
endmodule

module control_unit (
    input clk,
    input reset,
    input i_run_stop,
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    // state 관리
    reg [2:0] state, next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end
        else begin
            state <= next;
        end
    end

    always @(*) begin
        case (state)
            STOP: begin
                if (i_clear == 1) begin
                    next = CLEAR;
                end
                else if (i_run_stop == 1) begin
                    next = RUN;
                end
                else begin
                    next = state;
                end
            end 
            RUN: begin
                if (i_run_stop == 0) begin
                    next = STOP;
                end
                else begin
                    next = state;
                end
            end 
            CLEAR: begin
                if (i_clear == 0) begin
                    next = STOP;
                end
                else begin
                    next = state;
                end
            end 
            default: next = state;
        endcase
    end

    always @(*) begin
        case (state)
            STOP: begin
                o_run_stop = 0;
                o_clear = 0;
            end 
            RUN: begin
                o_run_stop = 1;
                o_clear = 0;
            end 
            CLEAR: begin
                o_run_stop = 0;
                o_clear = 1;
            end 
            default: begin
                o_run_stop = 0;
                o_clear = 0;                
            end
        endcase
    end

endmodule

