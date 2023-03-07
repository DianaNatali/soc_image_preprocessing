// ============================================================================
// TESTBENCH FOR OVDataCapture
// ============================================================================
`timescale 1ns / 1ns
`include "hardware/sobel/sobel_control.v"
`include "hardware/sobel/sobel_core.v"
`include "hardware/common/buffer_reader.v"
`include "hardware/common/buffer_writer.v"

module sobel_control_TB ();
    reg  sobel_clk;
    reg  reset;
    reg  ack_read;   
    reg  [14:0] input_px_gray;
    reg  ack_write;   
    integer i,j;
      
    sobel_control uut(
        .sobel_clk(sobel_clk),
        .reset(reset),
        .ack_read(ack_read),   
        .input_px_gray(input_px_gray),
        .ack_write(ack_write)
    );
    
    initial begin
        sobel_clk = 0;
        ack_read = 0;
        input_px_gray = 15'd25000;
        #50;
        for (j=0; j<5 ; j=j+1) begin
            #53312;
            for (i=0; i < 240 ; i=i+1) begin
                ack_read = 1;
                ack_write = 1;
                #100;
                ack_read = 0;
                ack_write = 0;
                #1280;
            end
        end       
    end

    always sobel_clk = #20.833 ~sobel_clk;
    always begin
        input_px_gray = #2 15'd31478; 
        input_px_gray = #2 15'd14567;
        input_px_gray = #2 15'd00567;
        input_px_gray = #2 15'd32100; 
    end

    initial begin: TEST_CASE
        $dumpfile("sobel_control.vcd");
        $dumpvars(-1, uut);
        #1700000 $finish;
    end

endmodule
