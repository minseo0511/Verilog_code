module SPI_Master (
    // global signals
    input            clk,
    input            reset,
    // internal signals
    input            cpol,
    input            cpha,
    input            start,
    input      [7:0] tx_data,
    output     [7:0] rx_data,
    output 		     done,
    output reg       ready,
    //external port
    output           SCLK,
    output           MOSI,
    input            MISO
);
    localparam IDLE = 0, CP_DELAY = 1, CP0 = 2, CP1 = 3;

    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_next, temp_tx_data_reg;
    reg [7:0] temp_rx_data_next, temp_rx_data_reg;
    reg [$clog2(50)-1:0] sclk_counter_next, sclk_counter_reg;
    reg [$clog2(7)-1:0] bit_counter_next, bit_counter_reg;
	reg done_reg, done_next;
    reg start_reg, start_prev;
	reg done_flag;
	
	wire r_sclk;
	wire start_edge;
    assign MOSI = temp_tx_data_reg[7];
    assign rx_data = temp_rx_data_reg;
    assign r_sclk = (state_next == CP1 && ~cpha) || (state_next == CP0 && cpha);
    assign SCLK = cpol ? ~r_sclk : r_sclk;
	assign done = done_flag;
	assign start_edge = (start_reg == 1) && (start_prev == 0);
 
    // clocked logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_tx_data_reg <= 0;
            temp_rx_data_reg <= 0;
            sclk_counter_reg <= 0;
            bit_counter_reg <= 0;
            done_reg <= 0;
            start_reg <= 0;
            start_prev <= 0;
			done_flag <= 0;
        end else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            temp_rx_data_reg <= temp_rx_data_next;
            sclk_counter_reg <= sclk_counter_next;
            bit_counter_reg <= bit_counter_next;
            done_reg <= done_next;
            start_prev <= start_reg;
            start_reg <= start;
			if(done_next) begin
				done_flag <= 1'b1;
			end
			else if(start_edge) begin
				done_flag <= 1'b0;
			end
        end
    end

    always @(*) begin
        state_next        = state;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        ready             = 0;
        sclk_counter_next = sclk_counter_reg;
        bit_counter_next  = bit_counter_reg;
		done_next = done_reg;
        case (state)
            IDLE: begin
                temp_tx_data_next = 0;
                done_next              = 0;
                ready             = 1;
                if (start_edge) begin
                    temp_tx_data_next = tx_data;
                    ready             = 0;
                    sclk_counter_next = 0;
                    bit_counter_next  = 0;
                    state_next        = cpha ? CP_DELAY : CP0;
                end
            end
            CP_DELAY: begin
                if (sclk_counter_reg == 49) begin
                    sclk_counter_next = 0;
                    state_next = CP0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            CP0: begin
                if (sclk_counter_reg == 49) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], MISO};
                    sclk_counter_next = 0;
                    state_next        = CP1;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            CP1: begin
                if (sclk_counter_reg == 49) begin
                    if (bit_counter_reg == 7) begin
                        done_next       = 1;
                        state_next = IDLE;
                    end else begin
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        sclk_counter_next = 0;
                        bit_counter_next  = bit_counter_reg + 1;
                        state_next        = CP0;
                    end
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
        endcase
    end
endmodule