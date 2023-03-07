module SPI_phy(
    input  wire        masterClk,
    input  wire        rst,
    input  wire [7:0]  outputData,
    input  wire        MISO,
    input  wire        enableSPI,
    input  wire        enableCS,
    input  wire        enableDC,
    input  wire [15:0] prescaler_reg,
    output reg  [7:0]  inputData,
    output wire        dataClk,    
    output wire        MOSI,
    output wire        SCK,
    output reg         CS,
    output reg         DC
    );

    reg [15:0] prescaler_count;
    reg        clock_enable;
    reg        out_clock;
    reg [2:0]  count;
    reg [7:0]  inData;
    reg [7:0]  outData;
    reg        dataClkReg;
    reg        enableMOSI;

    initial begin 
        prescaler_count = 16'b0;
        count=7;      
        dataClkReg=0;   
        CS=1;
        DC=1;
        inData= 0;
        outData=0;
        enableMOSI=0;
        clock_enable = 1'b0;
        out_clock = 1'b0;
    end

    always@(posedge masterClk, posedge rst)begin
        if(rst)begin
            out_clock <= 1'b0;
            prescaler_count <= 16'b0;
        end else begin
            if(prescaler_count == (prescaler_reg - 16'b1))begin
                prescaler_count <= 16'b0;
                out_clock <= ~out_clock;
            end else begin
                prescaler_count <= prescaler_count + 16'b1;
            end
        end
    end

    always@(negedge masterClk, posedge rst)begin
        if(rst)begin
            clock_enable <= 1'b0;
        end else begin 
            if(prescaler_count >= (prescaler_reg - 16'b1))begin
                clock_enable <= (out_clock)? 1'b1 : 1'b0;
            end else begin
                clock_enable <= 1'b0;
            end
        end
    end

    // Testeo 2.5MHz ---> 25-1 / 50-1
    // SoC 0v7670 12.5MHz ---> 5-1 / 10-1
    //            20.83333MHz ---> 3-1 / 6-1 ?
    // always@(posedge masterClk, posedge rst)begin 
    //     if(rst)begin
    //         spiCount <= 0;
    //         inputClk <= 0;
    //     end else begin 
    //         if(spiCount<25)begin
    //             spiCount<=spiCount+1;
    //             inputClk<=0;
    //         end else if(spiCount<49)begin
    //             spiCount<=spiCount+1;
    //             inputClk<=1;
    //         end else begin
    //             spiCount<=0;
    //             inputClk<=0;
    //         end
    //     end
    // end

    always@(negedge masterClk, posedge rst) begin
        if(rst)begin
            dataClkReg <= 0;
            inputData <= 0;
            outData <= 0;
            CS <= 1;
            DC <= 1;
            count <= 7;
            enableMOSI <= 0;
        end else if (clock_enable)begin 
            if (count==7) begin   
                dataClkReg<=1'b1;
                inputData<=inData;
                outData<=outputData;
                DC<=(enableDC && enableSPI && enableCS)? 1'b0:1'b1;
                CS<=(enableCS && enableSPI)? 1'b0:1'b1; 
                enableMOSI<=enableCS && enableSPI;                      
            end else if (count==3) begin     
                dataClkReg<=1'b0;
            end
            count<=count+1;
        end        
    end

    // always@(posedge inputClk, posedge rst)begin
    //     if(rst) begin
    //         inData <= 0;
    //     end else begin
    //         inData[7-count]<=MISO;
    //     end  
    // end

    assign MOSI=(enableMOSI)? outData[7-count]: 1;
    assign SCK=(enableMOSI)? out_clock : 0;
    assign dataClk=dataClkReg;
endmodule