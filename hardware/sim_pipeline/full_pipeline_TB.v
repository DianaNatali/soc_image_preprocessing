// ============================================================================
// TESTBENCH FOR OVDataCapture
// ============================================================================
`timescale 1ns / 1ns
`include "hardware/cam_read/cam_read.v"
`include "hardware/common/primitives.v"
`include "hardware/frame_buffer/frame_buffer.v"
`include "hardware/preprocessor/preprocessor.v"
`include "hardware/common/buffer_reader.v"
`include "hardware/common/buffer_writer.v"
`include "hardware/sim_pipeline/full_pipeline.v"
`include "hardware/frame_buffer/frame_memory.v"
`include "hardware/common/FF2_sync.v"
module full_pipeline_TB ();
    reg clk_input;
    reg pixel_clk;
    reg vertical_sync;
    reg horizontal_ref;
    reg [7:0] input_Data;
    reg EnXclk;
    reg Rst;
    reg buffer_clk;
    reg prep_clk;
    integer i,j;
  
    full_pipeline uut(
        .clk_PLL(clk_input),
        .pclk(pixel_clk),    
        .vsync(vertical_sync),
        .href(horizontal_ref), 
        .input_data(input_Data),
        .rst(Rst),
        .buffer_clk(buffer_clk),
        .prep_clk(prep_clk)
    );
    
    initial begin
        clk_input = 0;
        pixel_clk = 0;
        buffer_clk = 0;
        prep_clk = 0;
        vertical_sync = 0;
        horizontal_ref = 0;
        input_Data = 8'b10101010;
        EnXclk = 1;
        Rst = 0;
        #50;
        EnXclk = 0;
        #50;
        EnXclk = 1;
        #2000;
        EnXclk = 0;
        #2000;
        EnXclk = 1;
        for (j=0; j<20 ; j=j+1) begin
            vertical_sync = 1;
            #28224;
            vertical_sync = 0;
            #159936;
            for (i=0; i < 240 ; i=i+1) begin
                horizontal_ref = 1;
                #3840;
                horizontal_ref = 0;
                #714;
            end
        end       
    end

    always clk_input = #3 ~clk_input;
    always pixel_clk = #3 ~pixel_clk;
    always buffer_clk = #1 ~buffer_clk;
    always prep_clk = #1 ~prep_clk;
    
    always begin
        input_Data = #6 $random%32768;  
    end

    initial begin: TEST_CASE
        $dumpfile("full_pipeline.vcd");
        $dumpvars(-1, uut);
        #5200000 $finish;
    end

endmodule
