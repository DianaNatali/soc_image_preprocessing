module FF2_sync ( 
    input wire clk,
    input wire reset,
    input wire in,
    output wire out
    );

    reg FF1;
    reg FF2;

    initial begin 
        FF1 = 1'b0;
        FF2 = 1'b0;
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            FF1 <= 1'b0;
            FF2 <= 1'b0;
        end else begin
            FF1 <= in;
            FF2 <= FF1;
        end
    end
    assign out = FF2;
endmodule