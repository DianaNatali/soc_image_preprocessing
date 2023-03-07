// ============================================================================
// TESTBENCH FOR RTC
// ============================================================================
`timescale 1ns / 1ns
`include "hardware/RTC/RTC.v"
module RTC_TB ();
    reg clk;
    reg Reset;
    wire [31:0] miliseconds;

    RTC uut(
        .clk(clk),    
        .rst(Reset),
        .milisec_reg(miliseconds) 
    );
    
    initial begin
        clk = 0;
        Reset = 0;
        #2;
        Reset = 1;
        #2;
        Reset = 0;
    end

    always clk = #4 ~clk;

    initial begin: TEST_CASE
        $dumpfile("RTC.vcd");
        $dumpvars(-1, uut);
        #20000000 $finish;
    end

endmodule
