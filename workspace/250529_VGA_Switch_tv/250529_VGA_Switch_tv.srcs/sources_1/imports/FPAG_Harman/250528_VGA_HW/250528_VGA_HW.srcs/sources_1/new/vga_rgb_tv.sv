`timescale 1ns / 1ps

module vga_rgb_tv (
    input logic DE,
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    output logic [3:0] red_port2,
    output logic [3:0] green_port2,
    output logic [3:0] blue_port2
);
    logic [3:0] red_port, green_port, blue_port;

    assign red_port2 = DE ? red_port : 4'b0000;
    assign green_port2 = DE ? green_port : 4'b0000;
    assign blue_port2 = DE ? blue_port : 4'b0000;


    always_comb begin
        // red_port = 4'b0000;
        // green_port = 4'b0000;
        // blue_port = 4'b0000;
        if(y_pixel <320) begin
            if(x_pixel <91) begin 
                red_port = 4'b1111;
                green_port = 4'b1111;
                blue_port = 4'b1111;
            end

            else if(x_pixel <91*2) begin 
                red_port = 4'b1111;
                green_port = 4'b1111;
                blue_port = 4'b0000;
            end

            else if(x_pixel <91*3) begin 
                red_port = 4'b0000;
                green_port = 4'b1111;
                blue_port = 4'b1111;
            end
            
            else if(x_pixel <91*4) begin 
                red_port = 4'b0000;
                green_port = 4'b1111;
                blue_port = 4'b0000;
            end
            
            else if(x_pixel <91*5) begin 
                red_port = 4'b1111;
                green_port = 4'b0000;
                blue_port = 4'b1111;
            end
            
            else if(x_pixel <91*6) begin 
                red_port = 4'b1111;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end
            
            else begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b1111;
            end
        end
        else if(y_pixel < 352) begin
            if(x_pixel <91) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b1111;
            end

            else if(x_pixel <91*2) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end

            else if(x_pixel <91*3) begin 
                red_port = 4'b1111;
                green_port = 4'b0000;
                blue_port = 4'b1111;
            end
            
            else if(x_pixel <91*4) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end
            
            else if(x_pixel <91*5) begin 
                red_port = 4'b0000;
                green_port = 4'b1111;
                blue_port = 4'b1111;
            end
            
            else if(x_pixel <91*6) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end
            
            else begin 
                red_port = 4'b1111;
                green_port = 4'b1111;
                blue_port = 4'b1111;
            end
        end
        else begin
            if(x_pixel <106) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b1000;
            end

            else if(x_pixel <106*2) begin 
                red_port = 4'b1111;
                green_port = 4'b1111;
                blue_port = 4'b1111;
            end
            
            else if(x_pixel <106*3) begin 
                red_port = 4'b1000;
                green_port = 4'b0000;
                blue_port = 4'b1000;
            end

            else if(x_pixel <106*4) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end

            else if(x_pixel <(106*4+35)) begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end
            else if(x_pixel <(106*4+35*2)) begin 
                red_port = 4'b0001;
                green_port = 4'b0001;
                blue_port = 4'b0001;
            end
            else if(x_pixel <(106*4+35*3)) begin 
                red_port = 4'b0010;
                green_port = 4'b0010;
                blue_port = 4'b0010;
            end

            else begin 
                red_port = 4'b0000;
                green_port = 4'b0000;
                blue_port = 4'b0000;
            end
        end
    end

endmodule
