`timescale 1ns / 1ps

module Ultrasonic_Periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 4:0] PADDR,
    // input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // export signals
    input  logic        echo,
    output logic        trig,
    output logic  [6:0] d_state
);

    logic        usr;  //ultrasonic start register
    logic [11:0] udr;  //ultrasonic distance register
    logic [31:0] uar;  //ultrasonic ascii register
    // logic [ 7:0] ascii_digit_1000; //ultrasonic ascii register
    // logic [ 7:0] ascii_digit_100; //ultrasonic ascii register
    // logic [ 7:0] ascii_digit_10; //ultrasonic ascii register
    // logic [ 7:0] ascii_digit_1; //ultrasonic ascii register

    APB_SlaveIntf_Ultrasonic_Sensor U_APB_Intf_Ultrasonic_Sensor (.*);

    ultrasonic_sensor U_ultrasonic_sensor (
        .clk(PCLK),
        .reset(PRESET),
        .*,
        .error(),
        .done(),
        .d_state(d_state)
    );
endmodule

module APB_SlaveIntf_Ultrasonic_Sensor (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 4:0] PADDR,
    // input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic        usr,      //ultrasonic start register
    input  logic [11:0] udr,       //ultrasonic distance register
    input  logic [31:0] uar       //ultrasonic ascii register
    // input  logic [ 7:0] ascii_digit_1000, //ultrasonic ascii register
    // input  logic [ 7:0] ascii_digit_100, //ultrasonic ascii register
    // input  logic [ 7:0] ascii_digit_10, //ultrasonic ascii register
    // input  logic [ 7:0] ascii_digit_1 //ultrasonic ascii register
);
    reg [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4 ,slv_reg5;

    assign usr = slv_reg0[0];
    assign slv_reg1[11:0] = udr;
    assign slv_reg2[31:0] = uar;
    // assign slv_reg2[7:0] = ascii_digit_1000;
    // assign slv_reg3[7:0] = ascii_digit_100;
    // assign slv_reg4[7:0] = ascii_digit_10;
    // assign slv_reg5[7:0] = ascii_digit_1;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0;
            //slv_reg2 <= 0;

        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                    // case (PADDR[4:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;
                        2'd2: ;
                        // 3'd0: slv_reg0 <= PWDATA;
                        // 3'd1: ;
                        // 3'd2: ;
                        // 3'd3: ;
                        // 3'd4: ;
                        // 3'd5: ;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                    // case (PADDR[4:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 3'd0: PRDATA <= slv_reg0;
                        // 3'd1: PRDATA <= slv_reg1;
                        // 3'd2: PRDATA <= slv_reg2;
                        // 3'd3: PRDATA <= slv_reg3;
                        // 3'd4: PRDATA <= slv_reg4;
                        // 3'd5: PRDATA <= slv_reg5;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule





