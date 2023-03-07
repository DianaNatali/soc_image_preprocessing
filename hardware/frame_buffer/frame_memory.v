// Create a buffer to store pixels data for a frame of 320x240 pixels -> 76800 pixels,
// Data for each pixel is 15 bits  

module frame_memory #(parameter  depth = 76800, parameter DEBUG_READ_MODE = 0, parameter width = 15)(
    input wire write_clk,         
    input wire wr_enable, 
    input wire enableA,     
    input wire [width-1:0] input_data, 
    input wire [$clog2(depth)-1:0] write_addr, 

    input wire read_clk,  
    input wire enableB,        
    input wire [$clog2(depth)-1:0] read_addr,  
    output reg [width-1:0] output_data	  
);

    reg [width-1:0] mem[depth-1:0]; 

    initial begin
        output_data = 15'b0;
        //mem[depth/2] = 15'hFFFF;
        if(DEBUG_READ_MODE)begin
            $readmemh("imagehex.mem", mem);
        end
    end
    
    always @(posedge write_clk) begin
        if (enableA) begin
            if (wr_enable) begin
                mem[write_addr] <= input_data;
            end 
        end
    end

    always @(posedge read_clk) begin 
        if (enableB) begin
            if (!wr_enable) begin
               output_data <=  mem[read_addr];  
            end    
        end  
        
    end
endmodule   