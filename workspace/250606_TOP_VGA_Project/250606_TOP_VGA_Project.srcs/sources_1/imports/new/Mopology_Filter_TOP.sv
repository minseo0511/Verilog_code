module Mopology_Filter_TOP (
    input logic clk,
    input logic reset,
    input logic [11:0] i_data1,   
    input logic [11:0] i_data2,   
    // input logic [11:0] i_data3,   
    input logic [9:0] x_coor,
    input logic [9:0] y_coor,
    input logic DE,            
    // input logic DE_in1,            
    // input logic DE_in2,            
    // output logic DE_mopol1,            
    // output logic DE_mopol2,            
    output logic [11:0] o_data1,
    output logic [11:0] o_data2
    // output logic [11:0] o_data3
);
    Mopology_Filter #(.IMG_WIDTH(640)) U_Mopology_Filter1(
        .clk(clk),
        .reset(reset),
        .i_data(i_data1),   
        .x_coor(x_coor),
        .y_coor(y_coor),
        .DE(DE),             
        // .DE_out(DE_mopol1),             
        .o_data(o_data1)  
    );
    
    Mopology_Filter #(.IMG_WIDTH(640)) U_Mopology_Filter2(
        .clk(clk),
        .reset(reset),
        .i_data(i_data2),   
        .x_coor(x_coor),
        .y_coor(y_coor),
        .DE(DE),             
        // .DE_out(DE_mopol2),             
        .o_data(o_data2)  
    );
    
    // Mopology_Filter #(.IMG_WIDTH(640)) U_Mopology_Filter3(
    //     .clk(clk),
    //     .reset(reset),
    //     .i_data(i_data3),   
    //     .x_coor(x_coor),
    //     .y_coor(y_coor),
    //     .DE(DE),             
    //     .o_data(o_data3)  
    // );
endmodule

module Mopology_Filter #(
    parameter IMG_WIDTH = 640
)(
    input logic clk,
    input logic reset,
    input logic [11:0] i_data,   
    input logic [9:0] x_coor,
    input logic [9:0] y_coor,
    input logic DE,             
    // output logic DE_out,             
    // output logic oe,            
    output logic [11:0] o_data  
);

    
    logic [0:IMG_WIDTH-1] erode_line1, erode_line2;
    logic erode_p11, erode_p12, erode_p13;
    logic erode_p21, erode_p22, erode_p23;
    logic erode_p31, erode_p32, erode_p33;
    logic [2:0] erode_valid_pipeline;
    logic [11:0] erode_o_data_internal;
    logic erode_oe_internal;

    
    logic [0:IMG_WIDTH-1] dilate_line1, dilate_line2;
    logic dilate_p11, dilate_p12, dilate_p13;
    logic dilate_p21, dilate_p22, dilate_p23;
    logic dilate_p31, dilate_p32, dilate_p33;
    logic [2:0] dilate_valid_pipeline;

    
    always_ff @(posedge clk) begin
        if (reset) begin
            erode_line1 <= '0;
            erode_line2 <= '0;
        end else if (DE) begin
            erode_line2[x_coor] <= erode_line1[x_coor];
            erode_line1[x_coor] <= i_data[11];
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            {erode_p11, erode_p12, erode_p13, erode_p21, erode_p22, erode_p23, erode_p31, erode_p32, erode_p33} <= 9'b0;
            erode_valid_pipeline <= 3'b0;
        end else if (DE) begin
            erode_p13 <= erode_line2[x_coor];
            erode_p12 <= erode_p13;
            erode_p11 <= erode_p12;

            erode_p23 <= erode_line1[x_coor];
            erode_p22 <= erode_p23;
            erode_p21 <= erode_p22;

            erode_p33 <= i_data[11];
            erode_p32 <= erode_p33;
            erode_p31 <= erode_p32;

            erode_valid_pipeline <= {erode_valid_pipeline[1:0], (x_coor >= 2 && y_coor >= 2)};
        end else begin
            erode_valid_pipeline <= {erode_valid_pipeline[1:0], 1'b0};
        end
    end

    
    always_ff @(posedge clk) begin
        if (reset) begin
            erode_o_data_internal <= 12'h000;
            erode_oe_internal <= 1'b0;
        end else if (erode_valid_pipeline[2]) begin
            erode_oe_internal <= 1'b1;
            if (erode_p11 & erode_p12 & erode_p13 & erode_p21 & erode_p22 & erode_p23 & erode_p31 & erode_p32 & erode_p33)
                erode_o_data_internal <= 12'hFFF;
            else
                erode_o_data_internal <= 12'h000;
        end else begin
            erode_oe_internal <= 1'b0;
            erode_o_data_internal <= 12'h000;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            dilate_line1 <= '0;
            dilate_line2 <= '0;
        end else if (erode_oe_internal) begin
            dilate_line2[x_coor] <= dilate_line1[x_coor];
            dilate_line1[x_coor] <= erode_o_data_internal[11];
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            {dilate_p11, dilate_p12, dilate_p13, dilate_p21, dilate_p22, dilate_p23, dilate_p31, dilate_p32, dilate_p33} <= 9'b0;
            dilate_valid_pipeline <= 3'b0;
        end else if (erode_oe_internal) begin
            dilate_p13 <= dilate_line2[x_coor];
            dilate_p12 <= dilate_p13;
            dilate_p11 <= dilate_p12;

            dilate_p23 <= dilate_line1[x_coor];
            dilate_p22 <= dilate_p23;
            dilate_p21 <= dilate_p22;

            dilate_p33 <= erode_o_data_internal[11];
            dilate_p32 <= dilate_p33;
            dilate_p31 <= dilate_p32;

            dilate_valid_pipeline <= {dilate_valid_pipeline[1:0], (x_coor >= 2 && y_coor >= 2)};
        end else begin
            dilate_valid_pipeline <= {dilate_valid_pipeline[1:0], 1'b0};
        end
    end

    
    always_ff @(posedge clk) begin
        if (reset) begin
            o_data <= 12'h000;
            // DE_out <= 1'b0;
        end else if (dilate_valid_pipeline[2]) begin
            // DE_out <= 1'b1;
            if (dilate_p11 | dilate_p12 | dilate_p13 | dilate_p21 | dilate_p22 | dilate_p23 | dilate_p31 | dilate_p32 | dilate_p33)
                o_data <= 12'hFFF;
            else
                o_data <= 12'h000;
        end else begin
            o_data <= 12'h000;
            // DE_out <= 1'b0;
        end
    end

endmodule