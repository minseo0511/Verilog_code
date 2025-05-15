`timescale 1ns / 1ps

module master(
    input logic clk,
    input logic reset,
    // CPU to master
    input logic [31:0] addr,
    input logic [31:0] wData,
    input logic we,
    input logic start,
    output logic ready,
    output logic [31:0] rData,
    // master to slave
    output logic [31:0]PADDR,
    output logic PWRITE,
    output logic PSEL,
    output logic PENABLE,
    output logic [31:0] PWDATA,
    input logic [31:0] PRDATA,
    input logic PREADY
    );

    assign ready = PREADY;
    assign PADDR = addr;
    assign PWDATA = wData;
    assign PRDATA = rData;
    assign PWRITE = we;

    typedef enum { IDLE, SETUP, ACCESS } state_e;
    state_e state, state_next;

    always_ff @( posedge clk, posedge reset ) begin
        if(reset) state <= IDLE;
        else state <= state_next;
    end

    always_comb begin
        state_next = state;
        case (state)
            IDLE: begin
                PSEL = 0;
                if(start) state_next = SETUP; 
            end
            SETUP: begin
                PSEL = 1;
                PENABLE = 0;
                state_next = ACCESS; // 1cycle 대기 후 ACCESS
            end
            ACCESS: begin
                PSEL = 1;
                PENABLE = 1;
                if(PREADY) state_next = SETUP;
            end  
        endcase
    end
endmodule
