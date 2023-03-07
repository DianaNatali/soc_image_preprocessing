module full_pipeline #(parameter depth = 76800)(
        input wire       clk_PLL,            
        input wire       pclk,              
        input wire       vsync,             
        input wire       href,              
        input wire [7:0] input_data,         
        input wire       rst,
        input wire       buffer_clk,      
        input wire       prep_clk               
);
    wire ack_write_buf1_wire;
    wire rq_write_buf1_wire;
    wire writing_buf1_wire;
    wire enable_mem_buf1_wire;
    wire clk_write_buf1_wire;
    wire [14:0] out_cam_in_buf1_px_data_wire;
    wire [$clog2(depth)-1:0] write_addr_buf1_wire;
    wire ack_read_buf1_wire;
    wire rq_read_buf1_wire;
    wire reading_buf1_wire;
    wire clk_read_buf1_wire;
    wire [$clog2(depth)-1:0] read_addr_buf1_wire;
    wire [14:0] out_buf1_in_prep_px_data_wire;
    wire ack_write_buf2_wire;
    wire rq_write_buf2_wire;
    wire writing_buf2_wire;
    wire clk_write_buf2_wire;
    wire [14:0] out_prep_in_buf2_px_data_wire;
    wire [$clog2(depth)-1:0] write_addr_buf2_wire;
    wire ack_read_buf2_wire;
    wire rq_read_buf2_wire;
    wire reading_buf2_wire;
    wire clk_read_buf2_wire;
    wire [$clog2(depth)-1:0] read_addr_buf2_wire;
    wire [14:0] out_buf2_in_prep2_px_data_wire;
    wire ack_write_buf3_wire;
    wire rq_write_buf3_wire;
    wire writing_buf3_wire;
    wire [14:0] out_prep2_in_buf3_px_data_wire;
    wire [$clog2(depth)-1:0] write_addr_buf3_wire;
    wire clk_write_buf3_wire;
    wire enable_mem_buf3_wire;
    wire ack_read_external;   
        
    reg rq_read_external;
    reg reading_external;
    reg state_external;

    initial begin      
        rq_read_external = 1'b0;
        reading_external = 1'b0;
        state_external = 1'b0;  
    end


    always@(posedge prep_clk)begin
        case(state_external)
            1'b0:begin
                if(ack_read_external)begin
                    reading_external <= 1'b1;
                    state_external <= 1'b1;
                    rq_read_external <= 1'b0;
                end else begin
                    rq_read_external <= 1'b1;
                end
            end
            1'b1:begin
                reading_external<=1'b0;
                if(ack_read_external == 1'b0)begin
                    state_external <=1'b0;
                end
            end
            default:begin
                state_external <= 1'b0;
            end
        endcase
    end

    cam_read cam_read(
        .clk_PLL(clk_PLL),            
        .pclk(pclk),              
        .vsync(vsync),             
        .href(href),              
        .input_data(input_data),         
        .rst(rst),                   
        .enable_xclk(1'b1),  
        .ack_write(ack_write_buf1_wire), 
        .rq_write(rq_write_buf1_wire),
        .writing(writing_buf1_wire),
        .enable_mem(enable_mem_buf1_wire),  
        .clk_write(clk_write_buf1_wire),          
        .output_px_data(out_cam_in_buf1_px_data_wire), 
        .write_addr(write_addr_buf1_wire)   
    );

    frame_buffer frame_buffer1(
        .buffer_clk(buffer_clk),
        .reset(rst),

        .write_clk(clk_write_buf1_wire),          
        .input_px_data(out_cam_in_buf1_px_data_wire), 
        .write_addr(write_addr_buf1_wire),
        .enable_mem(enable_mem_buf1_wire),

        .rq_write(rq_write_buf1_wire),
        .writing(writing_buf1_wire),
        .ack_write(ack_write_buf1_wire),
        
        .ack_read(ack_read_buf1_wire),            
        .rq_read(rq_read_buf1_wire),
        .reading(reading_buf1_wire),

        .read_clk(clk_read_buf1_wire),
        .read_addr(read_addr_buf1_wire),
        .output_px_data(out_buf1_in_prep_px_data_wire)
    );

    preprocessor preprocesor1(
        .prep_clk(prep_clk),
        .reset(rst),
        .enable_mode_reg(1'b0),
        .filter_reg(2'b0),

        .ack_read(ack_read_buf1_wire),
        .rq_read(rq_read_buf1_wire),
        .reading(reading_buf1_wire),

        .read_clk(clk_read_buf1_wire),
        .read_addr(read_addr_buf1_wire),
        .input_px_data(out_buf1_in_prep_px_data_wire),

        .ack_write(ack_write_buf2_wire),
        .rq_write(rq_write_buf2_wire),
        .writing(writing_buf2_wire),

        .output_px_data(out_prep_in_buf2_px_data_wire),
        .write_addr(write_addr_buf2_wire),
        .write_clk(clk_write_buf2_wire),
        .enable_mem(enable_mem_buf2_wire)   
    );

    frame_buffer frame_buffer2(
        .buffer_clk(buffer_clk),
        .reset(rst),

        .write_clk(clk_write_buf2_wire),          
        .input_px_data(out_prep_in_buf2_px_data_wire), 
        .write_addr(write_addr_buf2_wire),
        .enable_mem(enable_mem_buf2_wire),

        .rq_write(rq_write_buf2_wire),
        .writing(writing_buf2_wire),
        .ack_write(ack_write_buf2_wire),
        
        .ack_read(ack_read_buf2_wire),            
        .rq_read(rq_read_buf2_wire),
        .reading(reading_buf2_wire),

        .read_clk(clk_read_buf2_wire),
        .read_addr(read_addr_buf2_wire),
        .output_px_data(out_buf2_in_prep2_px_data_wire)
    );

       preprocessor preprocesor2(
        .prep_clk(prep_clk),
        .reset(rst),
        .enable_mode_reg(1'b0),
        .filter_reg(2'b1),

        .ack_read(ack_read_buf2_wire),
        .rq_read(rq_read_buf2_wire),
        .reading(reading_buf2_wire),

        .read_clk(clk_read_buf2_wire),
        .read_addr(read_addr_buf2_wire),
        .input_px_data(out_buf2_in_prep2_px_data_wire),

        .ack_write(ack_write_buf3_wire),  ///Desde acá
        .rq_write(rq_write_buf3_wire),
        .writing(writing_buf3_wire),

        .output_px_data(out_prep2_in_buf3_px_data_wire),
        .write_addr(write_addr_buf3_wire),
        .write_clk(clk_write_buf3_wire),
        .enable_mem(enable_mem_buf3_wire)   
    );

        frame_buffer frame_buffer3(
        .buffer_clk(buffer_clk),
        .reset(rst),

        .write_clk(clk_write_buf3_wire),          
        .input_px_data(out_prep2_in_buf3_px_data_wire), 
        .write_addr(write_addr_buf3_wire),
        .enable_mem(enable_mem_buf3_wire),

        .rq_write(rq_write_buf3_wire),
        .writing(writing_buf3_wire),
        .ack_write(ack_write_buf3_wire),
        
        .ack_read(ack_read_external),            
        .rq_read(rq_read_external),
        .reading(reading_external)

        // .read_clk(clk_read_buf2_wire),
        // .read_addr(read_addr_buf2_wire),
        // .output_px_data(out_buf2_in_prep2_px_data_wire)
    );

    
endmodule