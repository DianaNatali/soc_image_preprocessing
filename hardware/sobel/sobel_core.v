module sobel_core (
        input wire  [14:0] px_0, 
        input wire  [14:0] px_1, 
        input wire  [14:0] px_2, 
        input wire  [14:0] px_3, 
        input wire  [14:0] px_5, 
        input wire  [14:0] px_6, 
        input wire  [14:0] px_7, 
        input wire  [14:0] px_8,  		
        output wire [14:0] out_sobel_core          						
    );

    wire signed [17:0] gx;
    wire signed [17:0] gy;    						         
    wire signed [17:0] abs_gx;
    wire signed [17:0] abs_gy;  				
    wire [17:0] sum;      								

    assign gx=((px_2-px_0)+((px_5-px_3)<<1)+(px_8-px_6));		
    assign gy=((px_0-px_6)+((px_1-px_7)<<1)+(px_2-px_8));		

    assign abs_gx = (gx[17]? ~gx+1 : gx);  		
    assign abs_gy = (gy[17]? ~gy+1 : gy);  		

    assign sum = (abs_gx + abs_gy);    
    assign out_sobel_core = (|sum[17:15])? 15'h7FFF : sum[14:0];  

endmodule