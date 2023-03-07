module gray_scale_core#(parameter  depth = 76800, parameter addrBits = $clog2(depth))(
        input wire       px_clk,
        input wire       reset,

        input wire       [14:0] input_px_data,
        input wire       frame_flag,

        output wire      write_clk,          
        output wire      [14:0] output_px_grayscale, 
        output reg       [$clog2(depth)-1:0] write_addr, 

        input wire       ack_write, 
        output reg       rq_write,
        output reg       writing,
        output reg       enable_mem
    );

    localparam REQUESTING = 0;
    localparam WAITING_FRAME = 1;
    localparam WRITING = 2;
    localparam ENDING = 3;

    localparam PREP_IDLE = 0;
    localparam BYPASS = 1;
    localparam GRAYSCALE = 2;
    localparam WAITING = 3;


    reg enable_addr_counter;
    reg [1:0] state;
    wire px_clk_BUFG;
   
    reg [addrBits-1:0] count_addr;
    reg [14:0] data;
    wire reader_allowed;
    wire writer_allowed;
   
    reg [7:0] red;
    reg [7:0] green;
    reg [7:0] blue;
    reg [7:0] gray_scale_1;
    reg [7:0] gray_scale_2;
    reg [4:0] gray_scale;
    reg [14:0] output_grayscale_15b;

    initial begin
        state = REQUESTING;
        write_addr = 1'b0;
        rq_write = 1'b0;
        writing = 1'b0;
        enable_mem = 1'b0;
        enable_addr_counter = depth;
        red = 8'b0;
        green = 8'b0;
        blue = 8'b0;
        gray_scale_1 = 8'b0;
        gray_scale_2 = 8'b0;
        gray_scale = 5'b0;
        output_grayscale_15b = 15'b0;
    end


    BUFG BUFG_pxClk (
      .O(px_clk_BUFG), // 1-bit output: Clock output
      .I(px_clk)      // 1-bit input: Clock input
    );
    
    always@(posedge px_clk_BUFG, posedge reset)begin
        if(reset)begin
            state <= REQUESTING;
            rq_write <= 1'b0;
            writing <= 1'b0;
            enable_mem <= 1'b0;
            enable_addr_counter <= 1'b0;
        end else begin
            case (state)
                REQUESTING: begin
                    rq_write <= 1'b1;
                    if (ack_write)begin
                        state <= WAITING_FRAME;
                        rq_write <= 1'b0;
                    end
                end
                WAITING_FRAME: begin
                    if(frame_flag)begin
                        state <= WRITING;
                        writing <= 1'b1;
                        enable_mem <= 1'b1;
                        enable_addr_counter <= 1'b1;
                    end                   
                end
                WRITING: begin
                    if(write_addr >= depth)begin
                        enable_mem <= 1'b0;
                        state <= ENDING;
                        writing <= 1'b0;
                        enable_addr_counter <= 1'b0;
                    end
                end
                ENDING: begin
                    if(ack_write == 1'b0)begin
                        state <= REQUESTING;
                    end
                end 
                default: begin
                    state <= REQUESTING;
                end
            endcase
        end
    end

    always@(negedge px_clk_BUFG)begin
        if(reset)begin
            write_addr <= depth;
            red <= 8'b0;
            green <= 8'b0;
            blue <= 8'b0;
            gray_scale_1 <= 8'b0;
            gray_scale_2 <= 8'b0;
            gray_scale <= 5'b0;
            output_grayscale_15b <= 15'b0;
        end else begin
            if(enable_addr_counter)begin
                if(write_addr < depth)begin
                    write_addr <= write_addr+1;
                    //Stage 1
                    red <= input_px_data[14:10]<<3;
                    green <= input_px_data[9:5]<<3;
                    blue <= input_px_data[4:0]<<3;
                    //Stage 2
                    gray_scale_1 <= (red>>2)+(red>>5)+(green>>1)+(green>>4)+(blue>>4)+(blue>>5);
                    //Stage 3
                    gray_scale <= (gray_scale_1)>>3;
                    //Stage 4
                    output_grayscale_15b <= {3{gray_scale}};
                end else begin
                    write_addr <= 1'b0;
                end
            end else begin
                write_addr <= depth;
            end
        end
    end

    assign write_clk = px_clk_BUFG;
    assign output_px_grayscale = output_grayscale_15b;

endmodule
