// ============================================================================
// TESTBENCH FOR OVDataCapture
// ============================================================================
`timescale 1ns / 1ns
`include "hardware/cam_read/cam_read.v"
`include "hardware/common/primitives.v"
module cam_read_TB ();
    reg clk_input;
    reg pixel_clk;
    reg vertical_sync;
    reg horizontal_ref;
    reg [7:0] data;
    reg en_xclk;
    reg reset;
    reg acknowledge_write;
    integer i,j;
  
    cam_read uut(
        .clk_pll(clk_input),
        .pclk(pixel_clk),    
        .vsync(vertical_sync),
        .href(horizontal_ref), 
        .input_data(data),
        .rst(reset),
        .enable_xclk(en_xclk)
        //.ack_write(acknowledge_write)
    );
    
    initial begin
        clk_input = 0;
        pixel_clk = 0;
        vertical_sync = 0;
        horizontal_ref = 0;
        acknowledge_write = 0;
        data = 8'b10101010;
        en_xclk = 1;
        reset = 0;
        #50;
        en_xclk = 0;
        #50;
        en_xclk = 1;
        #2000;
        en_xclk = 0;
        #2000;
        en_xclk = 1;
        for (j=0; j<5 ; j=j+1) begin
            vertical_sync = 1;
            #9408;
            vertical_sync = 0;
            #53312;
            for (i=0; i < 240 ; i=i+1) begin
                acknowledge_write = 1;
                horizontal_ref = 1;
                #100;
                acknowledge_write = 0;
                #1280;
                horizontal_ref = 0;
                #238;
            end
        end       
    end

    always clk_input = #20.833 ~clk_input;
    always pixel_clk = #1 ~pixel_clk;
    always begin
         data = #2 8'hCD; 
         data = #2 8'hAB;
         data = #2 8'hEF;
         data = #2 8'h10; 
    end

    initial begin: TEST_CASE
        $dumpfile("cam_read.vcd");
        $dumpvars(-1, uut);
        #1700000 $finish;
    end

endmodule
