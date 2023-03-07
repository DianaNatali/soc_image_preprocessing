module SPI(
        input  wire        masterClk,    
        input  wire        rst,
        input  wire        MISO,
        output wire        MOSI,
        output wire        SCK,
        output wire        CS,
        output wire        DC,
        output wire        dataClockRegister, 
        output reg  [7:0]  inputDataRegister,
        input  wire [7:0]  outputDataRegister,
        input  wire        enableSPIRegister,
        input  wire        enableCSRegister,
        input  wire        enableDCRegister,
        input  wire [15:0] prescaler_reg
    );

    reg [7:0] outputData;
    wire [7:0] inputData;

    initial begin 
        inputDataRegister = 0;
        outputData = 0;
    end
	

    // modulo SPI
    SPI_phy spi(
        .masterClk(masterClk), 
        .rst(rst), 
        .inputData(inputData),
        .outputData(outputData),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCK(SCK),
        .dataClk(dataClockRegister),
        .enableSPI(enableSPIRegister),
        .CS(CS),
        .DC(DC),
        .enableCS(enableCSRegister),
        .enableDC(enableDCRegister),
        .prescaler_reg(prescaler_reg)
    );

    always@(posedge masterClk, posedge rst) begin
        if(rst)begin
            inputDataRegister <= 0;
            outputData <= 0;
        end else begin
            if(enableSPIRegister)begin 
                //lectura
                inputDataRegister<=inputData;
                //Escritura       
                outputData<=outputDataRegister;
            end  
        end
    end
    
    
    
    

   
    
      


endmodule
