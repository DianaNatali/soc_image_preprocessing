module buffer_reader (
    input wire clk,
    input wire reset,

    //Writer control signals
    input wire enable,
    output reg read_allowed,

    //Buffer control signales
    input wire ack_read,
    output reg rq_read,
    output reg reading
);

    localparam IDLE = 0;
    localparam REQUESTING = 1;
    localparam READING = 2; 
    localparam ENDING = 3; 

    reg [1:0] state;

    initial begin
        state = IDLE;
        read_allowed = 0;
        rq_read = 0;
        reading = 0;
    end

    always @(posedge clk, posedge reset)begin 
        if(reset)begin
            state <= IDLE;
            read_allowed <= 1'b0;
            rq_read <= 1'b0;
            reading <= 1'b0;        
        end else begin
            case (state)
                IDLE: begin
                    state <= (enable)? REQUESTING : IDLE;
                    read_allowed <= 1'b0;
                    reading <= 1'b0;
                end
                REQUESTING: begin
                    rq_read <= (ack_read)? 1'b0 : 1'b1;
                    state <= (ack_read)? READING : REQUESTING;
                    reading <= (ack_read)? 1'b1 : 1'b0;
                end
                READING: begin
                    read_allowed <= 1'b1;
                    reading <= (enable)? 1'b1 : 1'b0;
                    state <= (enable)? READING : ENDING;
                end
                ENDING: begin
                    if(ack_read == 1'b0)begin
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