`timescale 1ns / 1ps

module fifo_peri(
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

    logic wr_en;
    logic rd_en;
    logic full;
    logic empty;
    logic [7:0] wData;
    logic [7:0] rData;

    fifo U_FIFO(
        .clk(PCLK),
        .reset(PRESET),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wData(wData),
        .rData(rData),
        .full(full),
        .empty(empty)
    );

    APB_SlaveIntf_fifo U_APB_SlaveIntf_fifo(
        .PCLK(PCLK),
        .PRESET(PRESET),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PSEL(PSEL),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .fsr({full, empty}), // {full, empty}
        .fwd(wData), // write data
        .frd(rData)  // read data
    );
    
endmodule

module APB_SlaveIntf_fifo (
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
    output logic wr_en,
    output logic rd_en,
    input logic [ 1:0] fsr, // {full, empty}
    output logic [ 7:0] fwd, // write data
    input logic [ 7:0] frd  // read data
);
    typedef enum logic [1:0] { IDLE, READ, WRITE, WAIT } state_e;
    state_e state, state_next;

    logic [31:0] slv_reg0, slv_reg1, slv_reg2; //slv_reg3;

    assign slv_reg0[1:0] = fsr;
    assign fwd = slv_reg1[7:0];
    assign slv_reg2[7:0] = frd;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            // slv_reg0 <= 0;
            slv_reg1 <= 0;
            // slv_reg2 <= 0;
            // slv_reg3 <= 0;
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    always_comb begin
        state_next = state;
        wr_en = 0;
        rd_en = 0;
        PREADY = 1'b0;
        case (state)
            IDLE: begin
                PREADY = 1'b0;
                if (PSEL && PENABLE) begin
                    if (PWRITE) begin 
                        wr_en = 0;
                        rd_en = 0;
                        state_next = WRITE;
                    end
                    else begin
                        wr_en = 0;
                        rd_en = 0;
                        state_next = READ;
                    end
                end
            end 
            READ: begin
                if(!fsr[0]) begin
                    wr_en = 0;
                    rd_en = 1;
                    PRDATA = 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA = slv_reg0;
                        2'd1: PRDATA = slv_reg1;
                        2'd2: PRDATA = slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                    state_next = WAIT;
                end
                else begin
                    state_next = IDLE;
                end
            end 
            WRITE: begin
                if(!fsr[1]) begin
                    wr_en = 1;
                    rd_en = 0;
                    case (PADDR[3:2])
                        2'd0: ;  // FND control register(0x00)
                        2'd1: slv_reg1 <= PWDATA;  // Write Data register(0x04)
                        2'd2: ;                    // Read Data register(0x08)
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                    state_next = WAIT;
                end
                else begin
                    state_next = IDLE;
                end
            end 
            WAIT: begin
                wr_en = 0;
                rd_en = 0;
                PREADY = 1'b1;
                state_next = IDLE;
            end 
        endcase
    end
endmodule

