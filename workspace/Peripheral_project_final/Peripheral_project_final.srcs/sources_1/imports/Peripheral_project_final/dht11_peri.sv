`timescale 1ns / 1ps

module dht11_peri (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 4:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,

    // export port
    inout logic dht_io  // dht11 sensor inout port
);

    logic        w_tick_1us;
    logic [39:0] w_data_out;
    logic [ 3:0] mode_state_led;
    logic        checksum_led;

    // GPI
    logic [ 1:0] dcr;  // dcr[1] = modesel, dcr[0] = enable 
    //GPO
    logic [15:0] ddr;

    logic        dht_done;
    logic [15:0] mode_data;
    logic [ 7:0] int_data;
    logic [ 7:0] frac_data;

    tick_1us #(
        .TICK_COUNT(100),
        .BIT_WIDTH (7)
    ) U_Tick_1us (
        .clk(PCLK),
        .reset(PRESET),
        .o_tick(w_tick_1us)
    );

    dht11_cu U_dht11_cu (
        .clk(PCLK),
        .reset(PRESET),
        .start(dcr[0]), //start_pulse
        .tick_1us(w_tick_1us),
        .data_out(w_data_out),
        .led(mode_state_led),
        .dht_done(dht_done),
        .dht_io(dht_io)
    );

    checksum U_checksum (
        .data_in(w_data_out),
        .led(checksum_led)
    );

    always @(*) begin
        if (dcr[1])
            mode_data = w_data_out[39:24];
        else
            mode_data = w_data_out[23:8];
        int_data = mode_data[15:8];
        frac_data = mode_data[7:0];
        ddr = (int_data * 100) + frac_data;
    end

    APB_SlaveIntf_DHT11 U_APB_SlaveIntf_DHT11 (
        .PCLK    (PCLK),
        .PRESET  (PRESET),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PWRITE  (PWRITE),
        .PENABLE (PENABLE),
        .PSEL    (PSEL),
        .PRDATA  (PRDATA),
        .PREADY  (PREADY),
        .dht_done(dht_done),
        .dcr     (dcr),
        .ddr     (ddr)
    );

endmodule

module APB_SlaveIntf_DHT11 (
    input  logic        PCLK,
    input  logic        PRESET,
    input  logic [ 4:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,

    input  logic        dht_done,
    output logic [ 1:0] dcr,
    input  logic [15:0] ddr
);

    typedef enum logic [1:0] {IDLE, SETUP, ACCESS, RESPOND} state_t;
    state_t state, next_state;

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5;
    logic [3:0]  digit_1000, digit_100, digit_10, digit_1;

    assign dcr = slv_reg0[1:0];

    // FSM
    always_ff @(posedge PCLK or posedge PRESET) begin
        if (PRESET)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:    next_state = (PSEL && !PENABLE) ? SETUP : IDLE;
            SETUP:   next_state = (PSEL &&  PENABLE) ? ACCESS : SETUP;
            ACCESS:  next_state = (PWRITE && !dht_done) ? ACCESS : RESPOND;
            RESPOND: next_state = (!PSEL && !PENABLE) ? IDLE : RESPOND;
            default: next_state = IDLE;
        endcase
    end

    // 레지스터, PREADY, PRDATA
    always_ff @(posedge PCLK or posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 32'd0;
            slv_reg1 <= 32'd0;
            slv_reg2 <= 32'd0;
            slv_reg3 <= 32'd0;
            slv_reg4 <= 32'd0;
            slv_reg5 <= 32'd0;
            PRDATA   <= 32'd0;
            PREADY   <= 1'b0;
        end else begin

            if (state == ACCESS && PWRITE && PSEL && PENABLE) begin
                case (PADDR[4:2])
                    3'd0: slv_reg0 <= PWDATA;
                    default: ;
                endcase
            end

            if (dht_done) begin 
                slv_reg0[1:0]  <= 2'b00;                // start clear
                slv_reg1[15:0] <= ddr;                  // original data
                slv_reg2[3:0]  <= ddr / 1000 % 10;
                slv_reg3[3:0]  <= ddr / 100  % 10;
                slv_reg4[3:0]  <= ddr / 10   % 10;
                slv_reg5[3:0]  <= ddr        % 10;
            end

            case (state)
                IDLE: begin
                    PREADY <= 1'b0;
                    PRDATA <= 32'd0;
                end
                ACCESS: begin
                    if (!PWRITE) begin
                        PREADY <= 1'b1;
                        case (PADDR[4:2])
                            3'd0: PRDATA <= {30'd0, slv_reg0[1:0]};
                            3'd1: PRDATA <= {16'd0, slv_reg1};
                            3'd2: PRDATA <= {28'd0, slv_reg2};
                            3'd3: PRDATA <= {28'd0, slv_reg3};
                            3'd4: PRDATA <= {28'd0, slv_reg4};
                            3'd5: PRDATA <= {28'd0, slv_reg5};
                            default: PRDATA <= 32'd0;
                        endcase
                    end else begin
                        PREADY <= dht_done;
                    end
                end
                RESPOND: begin
                    PREADY <= 1'b0;
                end
            endcase
        end
    end
endmodule