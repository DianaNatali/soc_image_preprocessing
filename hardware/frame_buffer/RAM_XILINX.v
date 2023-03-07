// Simple Dual-Port Block RAM with One Clock
//
// File: HDL_Coding_Techniques/rams/simple_dual_one_clock.v
//
module simple_dual_one_clock (
    input  wire         clk,
    input  wire         ena,
    input  wire         enb,
    input  wire         wea,
    input  wire [9:0]   addra,
    input  wire [9:0]   addrb,
    input  wire [15:0]  dia,
    output reg  [15:0]  dob
);

    
    reg[15:0] ram [1023:0];

    
    always @(posedge clk) begin
        if (ena) begin
            if (wea) ram[addra] <= dia;
        end
    end
    always @(posedge clk) begin
        if (enb) dob <= ram[addrb];
    end
endmodule

module simple_dual_two_clocks(
    input  wire         clka,
    input  wire         clkb,
    input  wire         ena,
    input  wire         enb,
    input  wire         wea,
    input  wire [9:0]   addra,
    input  wire [9:0]   addrb,
    input  wire [15:0]  dia,
    output reg  [15:0]  dob
);

    reg[15:0] ram [1023:0];

    always @(posedge clka) begin 
        if (ena)begin
            if (wea)
                ram[addra] <= dia;
        end
    end
    always @(posedge clkb) begin 
        if (enb)begin
            dob <= ram[addrb];
        end
    end
endmodule
