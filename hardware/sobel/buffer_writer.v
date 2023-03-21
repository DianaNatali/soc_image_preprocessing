module buffer_writer (
    input wire clk,
    input wire reset,

    //Writer control signals
    input wire enable,
    output reg write_allowed,

    //Buffer control signals
    input wire ack_write,
    output reg rq_write,
    output reg writing
);

    localparam IDLE = 0;
    localparam REQUESTING = 1;
    localparam WRITING = 2;
    localparam ENDING = 3; 

    reg [1:0] state;

    initial begin
        state = IDLE;
        write_allowed = 0;
        rq_write = 0;
        writing = 0;
    end

    always @(posedge clk, posedge reset)begin 
        if(reset)begin
            state <= IDLE;
            write_allowed <= 1'b0;
            rq_write <= 1'b0;
            writing <= 1'b0;        
        end else begin
            case (state)
                IDLE: begin
                    state <= (enable)? REQUESTING : IDLE;
                    write_allowed <= 1'b0;
                    writing <= 1'b0;
                end
                REQUESTING: begin
                    rq_write <= (ack_write)? 1'b0 : 1'b1;
                    state <= (ack_write)? WRITING : REQUESTING;
                    writing <= (ack_write)? 1'b1 : 1'b0;
                end
                WRITING: begin
                    write_allowed <= 1'b1;
                    writing <= (enable)? 1'b1 : 1'b0;
                    state <= (enable)? WRITING : ENDING;
                end
                ENDING: begin
                    if(ack_write == 1'b0)begin
                        state <= IDLE;
                    end
                end  
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule