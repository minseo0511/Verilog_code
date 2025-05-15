`timescale 1ns / 1ps

module TOP_DHT11(
    input clk,
    input reset,
    input btn_start,
    input sw_mode,
    input [7:0] data_in,
    input empty_rx_b,
    output [4:0] led,
    output wr_tx,
    output rd_tx,
    output [7:0]data_sensor_tx,
    output [7:0] fnd_font,
    output [3:0] fnd_comm,
    inout dht_io
    );

    wire w_tick_1us;
    wire w_left;
    wire [39:0] w_data_out;
    wire w_dht_done;

    wire [15:0] w_DHT11_decimal_data;
    reg [15:0] r_data_in;

    tick_1us #(.TICK_COUNT(100), .BIT_WIDTH(7)) U_tick_1us(
        .clk(clk), 
        .reset(reset),
        .o_tick(w_tick_1us)
    );

    btn_debounce U_Btn_left(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_start),
        .o_btn(w_left)
    );

    DHT11_CU U_DHT11_CU(
        .clk(clk),
        .reset(reset),
        .btn_start(w_left),
        .data_in(data_in),
        .empty_rx_b(empty_rx_b),
        .tick_1us(w_tick_1us),
        .data_out(w_data_out),
        .led(led[3:0]),
        .io_oe(io_oe),
        .dht_done(w_dht_done),
        .dht_io(dht_io)
    );

    Sensor_TX_FIFO_CU_DHT11 U_Sensor_TX_FIFO_CU_DHT11(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .dht_done(w_dht_done),
        .sw_mode(sw_mode),
        .DHT11_decimal_data(w_DHT11_decimal_data),
        .wr_tx(wr_tx),
        .rd_tx(rd_tx),
        .data_sensor_tx(data_sensor_tx)
    );

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(reset),
        .data_in(r_data_in),
        .DHT11_decimal_data(w_DHT11_decimal_data),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    check_sum U_Check(
        .data_in(w_data_out),
        .led(led[4])
    );

    always @(*) begin
        if(sw_mode) begin
            r_data_in = w_data_out[39:24];
        end
        else begin
            r_data_in = w_data_out[23:8];
        end
    end

endmodule
