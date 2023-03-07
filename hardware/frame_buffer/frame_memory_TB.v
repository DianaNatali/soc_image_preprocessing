`timescale 1ns / 100ps
`include "hardware/frame_buffer/frame_memory.v"
module frame_memory_TB ();
    reg write_clk;        
    reg wr_enable;   
    reg [14:0] input_data; 
    reg [16:0] write_addr;

    reg read_clk;
    reg read_enable;           
    reg [16:0] read_addr;

    wire [14:0] output_data;

    integer i;

    frame_memory uut(
        .write_clk(write_clk),
        .wr_enable(wr_enable),
        .enableA(1'b1),         
        .input_data(input_data),
        .write_addr(write_addr),
        .read_clk(read_clk),
        .enableB(1'b1),
        .read_addr(read_addr),
        .output_data(output_data) 
    );

    always #0.5 write_clk = ~write_clk;
    always #1 read_clk = ~read_clk; 

    initial begin
        write_clk = 1;
        read_clk = 0;
        wr_enable = 0;     
        input_data = 0;
        write_addr = 0;
        read_clk = 1;
        #0.5;
        #10;
        wr_enable = 1;
        for(i=1; i <= 76800; i=i+1)begin
            input_data = i;
            write_addr = i-1;
            #1;
        end
        #0.5;
        wr_enable = 0;
        for(i=1; i <= 76800; i=i+1)begin
            read_addr = i-1;
            #2;
        end
        read_enable = 0;
    end 

    initial begin: TEST_CASE
        $dumpfile("frame_memory.vcd");
        $dumpvars(-1, uut);
        #6000000 $finish;
    end

endmodule
	
