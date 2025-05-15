`timescale 1ns / 1ps

module UltraSensor_Periph (
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

    input logic btn_trig,
    input logic echo,
    output logic trigger
    // output logic [8:0] distance
);

    // logic btn_trig;
    logic [8:0] distance;

    TOP_UltrasonicSensor U_TOP_UltrasonicSensor (
        .clk(PCLK),
        .reset(PRESET),
        .btn_trig(btn_trig),
        .echo(echo),
        .trigger(trigger),
        .distance(distance)
    );

    APB_SlaveIntf_UltraSensor U_APB_SlaveIntf_UltraSensor(.*);

endmodule

module APB_SlaveIntf_UltraSensor (
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
    // export signals
    // output logic        btn_trig,
    input  logic [ 8:0] distance
);
    logic [31:0] slv_reg0, slv_reg1; //, slv_reg2;  //slv_reg3;

    // assign btn_trig = slv_reg0[0];
    assign slv_reg0[8:0] = distance;
    // assign fpr = slv_reg2[3:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            // slv_reg0 <= 0;
            // slv_reg1 <= 0;
            // slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: ;  // FND control register(0x00)
                        // 2'd1: slv_reg1 <= PWDATA;  // FND Data register(0x04)
                        // 2'd2: slv_reg2 <= PWDATA;  // FND DP register(0x08)
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        // 2'd1: PRDATA <= slv_reg1;
                        // 2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end
endmodule
