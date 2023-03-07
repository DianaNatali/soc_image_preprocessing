module cam_read #(parameter  picture_width = 320, picture_heigth =240, depth = 76800)(
        input wire       clk_pll,            
        input wire       pclk,              
        input wire       vsync,             
        input wire       href,              
        input wire       [7:0] input_data,         
        input wire       rst,                    
        input wire       enable_xclk,

        output wire      xclk,
        output wire      clk_write,   
        output wire      frame_flag,       
        output wire      [14:0] output_px_data

    );



    reg VGA_sync;           //Data sync flag: 0 not syncronized and 1 yncronized
    reg current_byte;       //Byte flag: 0 First Byte y 1 Second Byte 
    reg [4:0] red_data;
    reg [4:0] green_data;
    reg [4:0] blue_data;
    reg px_clk_reg;
    
    reg begin_frame;
    reg [9:0] x_position;         
    reg [8:0] y_position;
    reg [4:0] red_px_data;
    reg [4:0] green_px_data;
    reg [4:0] blue_px_data;
 

    //Inicializacion
    initial begin 
        x_position = 10'b0000000000; 
        y_position = 9'b000000000; 
        red_data = 5'b00000;
        green_data = 5'b00000;
        blue_data = 5'b00000;
        VGA_sync = 1'b0;
        current_byte = 1'b0;
        red_px_data = 5'b00000;
        green_px_data = 5'b00000;
        blue_px_data = 5'b00000;
        begin_frame = 1'b0;
        px_clk_reg = 1'b1;
    end

    always@(posedge pclk, posedge rst) begin
        if (rst == 1'b1) begin
            x_position <= 10'b0000000000; 
            y_position <= 9'b000000000; 
            red_data <= 5'b00000;    
            green_data <= 5'b00000;
            blue_data <= 5'b00000;
            VGA_sync <= 1'b0;
            begin_frame <= 1'b0;
            current_byte <= 1'b0;
        end else if (VGA_sync == 1'b1) begin
            if (href == 1'b1) begin
                if (current_byte == 0) begin
                    green_data[4:3] <= input_data[1:0];
                    red_data <= input_data[6:2];
                    current_byte <= 1'b1;
                    if (x_position == 1'b0 && y_position == 1'b0) begin
                        begin_frame <= 1'b1;
                    end else begin
                        begin_frame <= 1'b0;
                    end
                end else begin
                    current_byte <= 1'b0;
                    green_data[2:0] <= input_data[7:5];
                    blue_data <= input_data[4:0]; 
                    if (x_position < picture_width - 1) begin
                        x_position <= x_position + 1;
                    end else begin
                        x_position <= 0;
                        if (y_position < picture_heigth - 1) begin
                            y_position <= y_position + 1; 
                        end else begin
                            y_position <= 1'b0;
                            VGA_sync <= 1'b0;
                        end
                    end
                end 
            end else begin 
                x_position <= 0;
            end 
        end else begin 
            if (vsync == 1'b1) begin 
                VGA_sync <= 1'b1;
                x_position <= 10'b0000000000; 
                y_position <= 9'b000000000; 
            end
        end 
    end 

    always@(negedge pclk, posedge rst) begin
        if (rst == 1'b1) begin
            red_px_data <= 5'b00000;
            green_px_data <= 5'b00000;
            blue_px_data <= 5'b00000;
            px_clk_reg <= 1'b0;
        end else begin
            if (current_byte == 1'b0)begin
                px_clk_reg <= 1'b0;
                red_px_data <= red_data;
                green_px_data <= green_data;
                blue_px_data <= blue_data;    
            end else if (current_byte == 1'b1)begin
                px_clk_reg <= 1'b1;
            end
        end
    end


    assign frame_flag = begin_frame;
    assign output_px_data = {red_px_data, green_px_data, blue_px_data};
    assign xclk = (enable_xclk) ? clk_pll : 1'b0;
    assign clk_write = px_clk_reg;
    
endmodule