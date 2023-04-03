module sobel_control #(parameter depth = 76800, parameter addrBits = $clog2(depth))(
        input wire    sobel_clk,
        input wire    reset,

        //Input threshold
        input wire    threshold_up,
        input wire    threshold_down,

        //Read buffer
        input wire    ack_read,   
        output wire   rq_read,
        output wire   reading,
        input wire    [14:0] input_px_gray,
        output wire   [addrBits-1:0] read_addr,
        output wire   read_clk,

        //Write buffer
        input wire    ack_write,   
        output wire   rq_write,
        output wire   writing,
        output wire   [14:0] output_px_sobel,
        output wire   [addrBits-1:0] write_addr,
        output wire   write_clk,
        output reg    enable_mem,

        output wire  [13:0] threshold_sobel_val
    );

    localparam MANAGER_IDLE = 0;
    localparam REQUESTING = 1;
    localparam PREPROCESSING = 2;

    localparam THRESHOLD_VAL = 'd60;

    reg reader_enable;
    reg writer_enable;
    wire reader_allowed;
    wire writer_allowed;
    reg prep_allowed;
    reg [1:0] manager_state;

    reg [13:0] threshold;

    reg [3:0] counter_sobel;
    reg [addrBits-1:0] count_addr;
    reg [7:0] i_sobel;
    reg [8:0] j_sobel;
    reg [addrBits-1:0] target_sobel_addr;
    
    reg [14:0] m_sobel [8:0];
    wire [14:0] out_sobel_core;
    reg [14:0] out_sobel;
    reg prep_completed;
    reg [addrBits-1:0] write_sobel_addr;

    initial begin
        manager_state = MANAGER_IDLE;
        reader_enable = 1'b0;
        writer_enable = 1'b0;
        enable_mem = 1'b0;
        prep_allowed = 1'b0;
        counter_sobel = 4'b0000;
        count_addr = 17'b0;
        i_sobel = 8'b00000000;
        j_sobel = 9'b000000000;
        target_sobel_addr = 17'b0;
        out_sobel = 15'b0;
        threshold = THRESHOLD_VAL;
        prep_completed = 1'b0;
        write_sobel_addr = 17'b0;
    end

    buffer_reader reader(
        .clk(sobel_clk),
        .reset(reset),
        .enable(reader_enable),
        .read_allowed(reader_allowed),
        .ack_read(ack_read),
        .rq_read(rq_read),
        .reading(reading)
    );

    buffer_writer writer(
        .clk(sobel_clk),
        .reset(reset),
        .enable(writer_enable),
        .write_allowed(writer_allowed),
        .ack_write(ack_write),
        .rq_write(rq_write),
        .writing(writing)
    );

    sobel_core sobel(
        .px_0(m_sobel[0]),
        .px_1(m_sobel[3]),
        .px_2(m_sobel[6]),
        .px_3(m_sobel[1]),
        .px_5(m_sobel[7]),
        .px_6(m_sobel[2]),
        .px_7(m_sobel[5]),
        .px_8(m_sobel[8]),
        .out_sobel_core(out_sobel_core)
    );

    always @(posedge sobel_clk)begin
        if(reset)begin
            manager_state <= MANAGER_IDLE;
            reader_enable <= 1'b0;
            writer_enable <= 1'b0;
            enable_mem <= 1'b0;
            prep_allowed <= 1'b0;
        end else begin
            case (manager_state)
                MANAGER_IDLE: begin
                    manager_state <= (~reader_allowed && ~writer_allowed)? REQUESTING : MANAGER_IDLE;
                end
                REQUESTING:begin
                    reader_enable <= 1'b1;
                    writer_enable <= 1'b1;
                    manager_state <= (reader_allowed && writer_allowed)? PREPROCESSING : REQUESTING;
                    prep_allowed <= (reader_allowed && writer_allowed)? 1'b1 : 1'b0 ;
                    enable_mem <= (reader_allowed && writer_allowed)? 1'b1 : 1'b0 ;
                end
                PREPROCESSING:begin
                    if(prep_completed)begin
                        reader_enable <= 1'b0;
                        writer_enable <= 1'b0;
                        manager_state <= MANAGER_IDLE;
                        prep_allowed <= 1'b0;
                        enable_mem <= 1'b0;
                    end 
                end
                default:begin
                    manager_state <= MANAGER_IDLE;
                end
            endcase
        end
    end 

    always @(posedge sobel_clk) begin
		if(reset) begin
			threshold <= THRESHOLD_VAL;
		end
		else begin
			threshold <= threshold_up? threshold+100 : threshold;  
			threshold <= threshold_down? threshold-100 : threshold;	
		end
	end

    always@(posedge sobel_clk)begin
        if(reset)begin
            counter_sobel <= 4'b0000;
            count_addr <= 17'b0;
            i_sobel <= 8'b00000000;
            j_sobel <= 9'b000000000;
            target_sobel_addr <= 17'b0;
            out_sobel <= 15'b0;
            prep_completed <= 1'b0;
            write_sobel_addr <= 17'b0;
        end else begin
            if(prep_allowed)begin
                if(j_sobel < 317) begin
                    if(counter_sobel <= 8)begin
                        case(counter_sobel % 3)
                            0: count_addr <= i_sobel + j_sobel*240;
                            1: count_addr <= i_sobel + (j_sobel*240) + 320; 
                            2:
                              begin
                                    count_addr = i_sobel + j_sobel*240 + 640;
				    	            j_sobel = (i_sobel == 239 ? (j_sobel + 1) : j_sobel); 	
				    	            i_sobel = (i_sobel+1)%240;	
                              end
                        endcase
                        if(counter_sobel == 4)begin 
                            target_sobel_addr <= count_addr;
                        end
                        m_sobel[counter_sobel] <= input_px_gray;
                        counter_sobel <= counter_sobel + 1;
                    end else begin 
                        counter_sobel <= 0;
                        i_sobel <= (i_sobel >= 2 ? (i_sobel - 2): i_sobel);
                        out_sobel <= (out_sobel_core < 200 ? 15'd0: 15'd32767);
                        write_sobel_addr <= target_sobel_addr;      
                    end
                end else begin
                    i_sobel <= 0;
                    j_sobel <= 0;
                    prep_completed <= 1'b1; 
                end 
            end else begin
                prep_completed <= 1'b0;
                out_sobel <= 15'b0;
            end
        end
    end
    
    assign read_clk = sobel_clk; 
    assign write_clk = sobel_clk;
    assign read_addr = count_addr;
    assign write_addr = write_sobel_addr;
    assign output_px_sobel = out_sobel; 
    assign threshold_sobel_val = threshold;
endmodule

