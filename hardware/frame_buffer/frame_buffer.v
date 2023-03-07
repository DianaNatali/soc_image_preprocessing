module frame_buffer #(parameter  depth = 76800, parameter  DEBUG_READ_MODE = 0, parameter width = 15)(
    input wire        buffer_clk,
    input wire        reset,
    
    //write addressing signals
    input wire        write_clk,          
    input wire        [width-1:0] input_px_data, 
    input wire        [$clog2(depth)-1:0] write_addr,
    input wire        enable_mem,
    
    //write control signals
    input wire        rq_write,
    input wire        writing,
    output reg        ack_write,
    
    //read addressing signals 
    input wire        read_clk,  
    input wire        [$clog2(depth)-1:0] read_addr,  
    output wire       [width-1:0] output_px_data,
    
    //read control signals
    input wire        rq_read,
    input wire        reading,
    output reg        ack_read 
);

    localparam IDLE = 0;
    localparam READ_STATE = 1;
    localparam WRITE_STATE = 2;

    wire rq_write_sync;
    wire writing_sync;
    reg [1:0] state;
    reg flag_idle;
    reg mem_ports_enable;
    reg mem_wr_enable;
    reg flag_writing;        // Detect negedge of writing reg to change to IDLE state
    reg flag_reading;        // Detect negedge of reading para cambiar al estado IDLE
    reg [1:0] past_state;

    initial begin
        state = IDLE;
        ack_write = 1'b0;
        ack_read = 1'b0;
        flag_idle = 1'b0;
        flag_writing = 1'b0;
        flag_reading = 1'b0;
        mem_wr_enable = 1'b0; 
        mem_ports_enable = 1'b0;
        past_state = IDLE;
    end

    FF2_sync FF2_sync1(
        .clk(buffer_clk),
        .reset(reset),
        .in(rq_write),
        .out(rq_write_sync)
    );

    FF2_sync FF2_sync2(
        .clk(buffer_clk),
        .reset(reset),
        .in(writing),
        .out(writing_sync)
    );

    frame_memory #(.depth(depth), .DEBUG_READ_MODE(DEBUG_READ_MODE)) mem (
        .write_clk(write_clk),
        .wr_enable(mem_wr_enable),
        .enableA(mem_ports_enable & enable_mem),  
        .input_data(input_px_data),
        .write_addr(write_addr),
        .read_clk(read_clk),
        .enableB(mem_ports_enable),
        .read_addr(read_addr),
        .output_data(output_px_data)
    );

    generate
        if(DEBUG_READ_MODE ==1)begin
            always @(posedge buffer_clk, posedge reset) begin
                if(reset)begin
                    state <= IDLE;
                    ack_write <= 1'b0;
                    ack_read <= 1'b0;
                    flag_idle <= 1'b0;
                    flag_writing <= 1'b0;
                    flag_reading <= 1'b0;
                    past_state <= IDLE;
                    mem_wr_enable <= 1'b0; 
                    mem_ports_enable <= 1'b0;
                end else begin
                    case (state)
                        IDLE: begin 
                            if(rq_read)begin
                                mem_wr_enable <= 1'b0;
                                mem_ports_enable <= 1'b1;
                                ack_read <= 1'b1;
                                state <= READ_STATE;
                                past_state <= IDLE;
                            end
                        end
                        WRITE_STATE:begin
                            if(writing_sync)begin
                                flag_writing <= 1'b1;
                            end else if(!writing_sync && flag_writing)begin
                                state <= IDLE;
                                mem_ports_enable <= 1'b0;
                                flag_idle <= 1'b0;
                                flag_writing <= 1'b0;
                                ack_write <= 1'b0;
                                past_state <= WRITE_STATE;
                            end
                        end
                        READ_STATE:begin
                            if(reading)begin
                                flag_reading <= 1'b1;
                            end else if(!reading && flag_reading)begin
                                state <= IDLE;
                                mem_ports_enable <= 1'b0;
                                flag_idle <= 1'b0;
                                flag_reading <= 1'b0;
                                ack_read <= 1'b0;
                                past_state <= READ_STATE;
                            end
                        end
                        default:begin
                            state <= IDLE;
                            past_state <= IDLE;
                        end
                    endcase
                end
            end
        end else begin
            always @(posedge buffer_clk, posedge reset) begin
                if(reset)begin
                    state <= IDLE;
                    ack_write <= 1'b0;
                    ack_read <= 1'b0;
                    flag_idle <= 1'b0;
                    flag_writing <= 1'b0;
                    flag_reading <= 1'b0;
                    past_state <= IDLE;
                    mem_wr_enable <= 1'b0; 
                    mem_ports_enable <= 1'b0;
                end else begin
                    case (state)
                        IDLE: begin
                            if(flag_idle == 1'b0)begin
                                flag_idle <= 1;
                            end else begin
                                case (past_state)
                                    IDLE: begin
                                        if(rq_write_sync)begin
                                            mem_wr_enable <= 1'b1;
                                            mem_ports_enable <= 1'b1;
                                            ack_write <= 1'b1;
                                            state <= WRITE_STATE;
                                            past_state <= IDLE;
                                        end
                                    end
                                    WRITE_STATE: begin
                                        if(rq_read)begin
                                            mem_wr_enable <= 1'b0;
                                            mem_ports_enable <= 1'b1;
                                            ack_read <= 1'b1;
                                            state <= READ_STATE;
                                            past_state <= IDLE;
                                        end
                                    end
                                    READ_STATE: begin
                                        if(rq_write_sync)begin
                                            mem_wr_enable <= 1'b1;
                                            mem_ports_enable <= 1'b1;
                                            ack_write <= 1'b1;
                                            state <= WRITE_STATE;
                                            past_state <= IDLE;
                                        end
                                    end
                                    default: begin
                                        past_state = IDLE; 
                                    end
                                endcase
                            end
                        end
                        WRITE_STATE:begin
                            if(writing_sync)begin
                                flag_writing <= 1'b1;
                            end else if(!writing_sync && flag_writing)begin
                                state <= IDLE;
                                mem_ports_enable <= 1'b0;
                                flag_idle <= 1'b0;
                                flag_writing <= 1'b0;
                                ack_write <= 1'b0;
                                past_state <= WRITE_STATE;
                            end
                        end
                        READ_STATE:begin
                            if(reading)begin
                                flag_reading <= 1'b1;
                            end else if(!reading && flag_reading)begin
                                state <= IDLE;
                                mem_ports_enable <= 1'b0;
                                flag_idle <= 1'b0;
                                flag_reading <= 1'b0;
                                ack_read <= 1'b0;
                                past_state <= READ_STATE;
                            end
                        end
                        default:begin
                            state <= IDLE;
                            past_state <= IDLE;
                        end
                    endcase
                end
            end
        end
    endgenerate

endmodule
