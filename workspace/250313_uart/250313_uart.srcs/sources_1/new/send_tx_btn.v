`timescale 1ns / 1ps

module send_tx_btn(
    input clk,
    input rst,
    input btn_start,
    output tx
);
    wire w_start, w_tx_done;
    reg [7:0] send_tx_data_reg, send_tx_data_next; 

    btn_debounce U_Start_btn(
        .clk(clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );

    uart U_uart(
        .clk(clk),
        .rst(rst),
        .btn_start(w_start),
        .tx_data_in(send_tx_data_reg),
        .tx(tx),
        .tx_done(w_tx_done)
    );

    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            send_tx_data_reg <= 8'h30;
        end
        else begin
            send_tx_data_reg <= send_tx_data_next;
        end
    end

    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        if (w_start) begin
            if(send_tx_data_reg == "z") begin
                send_tx_data_next = "0";
            end
            else begin
                send_tx_data_next = send_tx_data_reg + 1;  // increase 1 for ASCII
            end
        end
    end
    
endmodule
