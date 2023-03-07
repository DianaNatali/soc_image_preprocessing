
module RTC #(parameter divisor=125, bitsNumber=31)(
        input wire       clk,
        input wire       rst,
        output wire [bitsNumber:0] milisec_reg
    );

    reg [bitsNumber:0] miliseconds;
    reg clock_1KHz_enable;
    reg [bitsNumber:0] counter;

    initial begin
        counter = 32'b0;
        miliseconds = 32'b0;
        clock_1KHz_enable = 1'b0;
    end

    always@(posedge clk, posedge rst)begin
        if(rst)begin
            counter <= 32'd0;
            clock_1KHz_enable <= 1'b0;        
        end else begin
            if(counter == divisor-1)begin
                counter  <= 32'd0; 
                clock_1KHz_enable <= 1'b1;
            end else begin
                counter <= counter + 1;
                clock_1KHz_enable <= 1'b0;
            end
        end
    end

    always@(posedge clk, posedge rst)begin
        if(rst)begin
            miliseconds <= 32'b0;
        end else if(clock_1KHz_enable)begin
            miliseconds <= miliseconds + 1;
        end
    end

    assign milisec_reg = miliseconds;


endmodule
