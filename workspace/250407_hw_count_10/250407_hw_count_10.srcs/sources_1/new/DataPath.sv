module DataPath(
    input logic clk,
    input logic reset,
    input logic ASrcMuxSel,
    input logic AEn,
    output logic Alt10,
    input logic OutBuf,
    input logic SumEn,
    output logic [7:0] outPort
    );

    wire [7:0] w_A, w_mux, w_reg, w_B, sumRegOut, sumInput;

    assign outPort = (OutBuf) ? sumRegOut : 8'hZZ;

    MUX2X1 U_MUX2X1(
        .sel(ASrcMuxSel),
        .x0(8'h00),
        .x1(w_A),
        .y(w_mux)
    );

    register U_register(
        .clk(clk),
        .reset(reset),
        .en(AEn),
        .d(w_mux),
        .q(w_reg)
    );

    adder U_adder_1(
        .a(w_reg),
        .b(8'h01),
        .sum(w_A)
    );

    adder U_adder_AB(
        .a(sumRegOut),
        .b(w_reg),
        .sum(sumInput)
    );

    register U_sumReg(
        .clk(clk),
        .reset(reset),
        .en(SumEn),
        .d(sumInput),
        .q(sumRegOut)
    );

    comparator U_comparator (
        .a(w_reg),
        .b(8'h0B),  // 11보다 작을 때까지만 동작
        .Alt10(Alt10)
    );

endmodule

module MUX2X1 (
    input logic sel,
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic [7:0] y
);
    always @(*) begin
        y = 0;
        case (sel)
            1'b0: y = x0; 
            1'b1: y = x1; 
        endcase
    end
endmodule

module register (
    input logic clk,
    input logic reset,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
);
    // ff로 사용하면 ff가 아닐 시 warning을 표시한다.
    always_ff @( posedge clk, posedge reset ) begin 
        if(reset) begin
            q <= 0;
        end
        else begin
            if(en) begin
                q <= d;
            end
        end
    end
endmodule

module adder (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic Alt10
);
    assign Alt10 = (a < b) ? 1'b1 : 1'b0;
endmodule