`timescale 1ns / 1ps

module FND_Periph (
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
    output logic [ 3:0] fnd_Comm,
    output logic [ 7:0] fnd_Font
);
    logic       fcr;
    logic [3:0] fmr;
    logic [3:0] fdr;

    APB_SlaveIntf_FND U_APB_SlaveIntf_FND (.*);
    FND U_FND (.*);
endmodule

module APB_SlaveIntf_FND (
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
    output logic        fcr,
    output logic [ 3:0] fmr,
    output logic [ 3:0] fdr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;  //, slv_reg3;

    assign fcr = slv_reg0[0];
    assign fmr = slv_reg1[3:0];
    assign fdr = slv_reg2[3:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;  // FND control register(0x00)
                        2'd1: slv_reg1 <= PWDATA;  // FND COM register(0x04)
                        2'd2: slv_reg2 <= PWDATA;  // FND Data register(0x08)
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module FND (
    input logic fcr,
    input logic [3:0] fmr,
    input logic [3:0] fdr,
    output logic [3:0] fnd_Comm,
    output logic [7:0] fnd_Font
);

    assign fnd_Comm = (fcr) ? (~fmr) : 4'b1111;

    always_comb begin
        if (fcr) begin
            case (fdr)
                4'h0: fnd_Font = 8'hC0;
                4'h1: fnd_Font = 8'hf9;
                4'h2: fnd_Font = 8'ha4;
                4'h3: fnd_Font = 8'hb0;
                4'h4: fnd_Font = 8'h99;
                4'h5: fnd_Font = 8'h92;
                4'h6: fnd_Font = 8'h82;
                4'h7: fnd_Font = 8'hf8;
                4'h8: fnd_Font = 8'h80;
                4'hA: fnd_Font = 8'h88;
                4'hB: fnd_Font = 8'h83;
                4'hC: fnd_Font = 8'hC6;
                4'hD: fnd_Font = 8'hA1;
                4'hE: fnd_Font = 8'h86;
                4'hF: fnd_Font = 8'h8E;
                default: fnd_Font = 8'hC0;
            endcase
        end else fnd_Font = 8'hC0;
    end

endmodule
