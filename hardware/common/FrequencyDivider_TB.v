// ============================================================================
// TESTBENCH FOR SD_SPI
// ============================================================================
`timescale 1ns / 1ps
module FrequencyDivider_TB ();
    reg clk;
    reg Reset;
    wire Output;
    FrequencyDivider #(.divider(10), .bitsNumber(4)) uut(
        .InputCLK(clk),    
        .Rst(Reset),
        .OutputCLK(Output) 
    );
    initial begin
        clk = 0;
        Reset = 0;
        #2;
        Reset = 1;
        #2;
        Reset = 0;
    end

    always clk = #1 ~clk;

    initial begin: TEST_CASE
        $dumpfile("FrequencyDivider.vcd");
        $dumpvars(-1, uut);
        #8000 $finish;
    end

endmodule
