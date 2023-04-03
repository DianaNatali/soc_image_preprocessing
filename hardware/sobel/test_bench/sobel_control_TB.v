// ============================================================================
// TESTBENCH FOR OVDataCapture
// ============================================================================
`timescale 1ns / 1ns
`include "../sobel/sobel_control.v"
`include "../sobel/sobel_core.v"
`include "../sobel/buffer_reader.v"
`include "../sobel/buffer_writer.v"

// `include "hardware/sobel/sobel_control.v"
// `include "hardware/sobel/sobel_core.v"
// `include "hardware/sobel/buffer_reader.v"
// `include "hardware/sobel/buffer_writer.v"

module sobel_control_TB #(parameter sizeOfLengthReal = 76800, INFILE="../test_bench/monarch_320x240.txt")();
    reg  sobel_clk;
    reg  reset;
    reg threshold_up;
    reg threshold_down;
    reg  ack_read;   
    reg  [14:0] input_px_gray;
    reg  ack_write;   
    
    integer output_image;
    
    reg [14: 0] image_memory [0: (sizeOfLengthReal-1) ];

    wire  [14:0] out_px_sobel;

    integer i,j;
      
    sobel_control uut(
        .sobel_clk(sobel_clk),
        .threshold_up(threshold_up),
        .threshold_down(threshold_down),
        .reset(reset),
        .ack_read(ack_read),   
        .input_px_gray(input_px_gray),
        .ack_write(ack_write),
        .output_px_sobel(out_px_sobel)
    );

    assign uut.VGND = 1'b0;
    assign uut.VPWR = 1'b1;

    
    initial begin
        input_px_gray = 15'd0;
        $readmemh(INFILE, image_memory, 0, sizeOfLengthReal-1);
        output_image = $fopen("../test_bench/output_image_sobel.txt","w");
        sobel_clk = 0;
        ack_read = 1;
        ack_write = 1;
        threshold_up = 0;
        threshold_down = 0; 
    end

    always sobel_clk = #20 ~sobel_clk;
    always@(posedge sobel_clk)begin
        for (i=0; i<76800; i=i+1)begin
            #60
            input_px_gray =  image_memory[i];
            #340
            $fwrite(output_image, "%x\n", out_px_sobel);
        end
    end   

    always@(posedge sobel_clk)begin
        

    end

    initial begin: TEST_CASE
        $dumpfile("sobel_control.vcd");
        $dumpvars(-1, uut);
        #30720050 $finish;
        //#26000000 $finish;
    end

endmodule
