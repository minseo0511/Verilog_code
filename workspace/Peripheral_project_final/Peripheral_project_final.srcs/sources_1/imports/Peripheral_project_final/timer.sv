`timescale 1ns / 1ps

module timer_periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY
);

    logic        en;
    logic        clear;
    logic [31:0] tcnt;
    logic [31:0] psc;
    logic [31:0] arr;

    APB_SlaveIntf_Timer U_APB_Intf_Timer (.*);
    timer U_Timer (
        .clk  (PCLK),
        .reset(PRESET),
        .*
    );
endmodule

module APB_SlaveIntf_Timer (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal side signals
    output logic        en,
    output logic        clear,
    input  logic [31:0] tcnt,
    output logic [31:0] psc,
    output logic [31:0] arr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    assign en       = slv_reg0[0];
    assign clear    = slv_reg0[1];
    assign slv_reg1 = tcnt;
    assign psc      = slv_reg2;
    assign arr      = slv_reg3;


    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;  //slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule




module timer (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic        clear,
    input  logic [31:0] psc,
    input  logic [31:0] arr,
    output logic [31:0] tcnt
);
    logic tim_tick;

    prescaler U_PSC (.*);
    tim_counter U_TCNT (.*);

endmodule


module prescaler (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic        clear,
    input  logic [31:0] psc,
    output logic        tim_tick
);
    logic [31:0] counter;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter  <= 0;
            tim_tick <= 1'b0;
        end else begin
            if (en) begin
                if (counter == psc) begin // hardware 부담 줄이기 위해 psc-1 대신 softward에서 pssc을 -1한 값 넣어줘야
                    counter  <= 0;
                    tim_tick <= 1'b1;
                end else begin
                    counter  <= counter + 1;
                    tim_tick <= 1'b0;
                end
            end
            if (clear) begin
                counter  <= 0;
                tim_tick <= 1'b0;
            end
        end
    end
endmodule

module tim_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        clear,
    input  logic        tim_tick,
    input  logic [31:0] arr,
    output logic [31:0] tcnt
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            tcnt <= 0;
        end else begin
            if (tim_tick) begin
                if (tcnt == arr) begin // harware 부담 줄이기 위해 arr-1 대신 softward에서 arr을 -1한 값 넣어줘야
                    tcnt <= 0;
                end else tcnt <= tcnt + 1;
            end
            if (clear) begin
                tcnt <= 0;
            end
        end
    end
endmodule
