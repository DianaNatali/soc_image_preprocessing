
module FrequencyDivider #(parameter divider=10, parameter bitsNumber=4)(
	input   wire InputCLK,
    input   wire rst,
	output  reg  OutputCLK
	);
    reg [bitsNumber-1:0] count;
    
    //Inicializacion
    initial begin count=0; OutputCLK=0; end

    //Logica Secuencial
    always@(posedge InputCLK , posedge rst) begin
        if (rst == 1'b1) begin
            count <= 0;
            OutputCLK <= 0;
        end else if (count == divider/2 -1) begin
            count <= count+1;
            OutputCLK <= 1;
        end else if(count == divider-1) begin
            count <= 0;
            OutputCLK <= 0;
        end else begin
            count <= count+1;  
        end  
    end
    
endmodule