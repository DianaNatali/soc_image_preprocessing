`timescale 1ns / 1ps
`include "hardware/SPI/SPI.v"
`include "hardware/SPI/SPI_phy.v"
module SPI_TB ();
    reg clk_tb;
  
    SPI uut(
        .masterClk(clk_tb),    
        .rst(1'd0),
        .outputDataRegister(8'hAB),
        .enableSPIRegister(1'd1),
        .enableCSRegister(1'd1),
        .enableDCRegister(1'd0),
        .prescaler_reg(16'd125)
    );

    initial begin
        clk_tb = 0;
    end 

    always #1 clk_tb = ~clk_tb;

    initial begin: TEST_CASE
        $dumpfile("SPI.vcd");
        $dumpvars(-1, uut);
        #200000 $finish;
    end

endmodule
