from migen import *
from litex.soc.interconnect.csr import *

import math

# Main module
class frame_buffer_HW(Module,AutoCSR):
    def __init__(self, DEBUG_READ_MODE=0):
    
    ##Parameters
        depth = 76800
        width = 15

    ## Inputs        
        self.BUFFER_CLK                  = Signal()
        self.BUFFER_RESET                = Signal()

        self.BUFFER_WRITE_CLK            = Signal()                                 #write addressing signals 
        self.BUFFER_WRITE_ADDR           = Signal(math.ceil(math.log(depth,2)))     #write addressing signals
        self.BUFFER_ENABLE_MEM           = Signal()
        self.BUFFER_RQ_WRITE             = Signal()                                 #write control signals
        self.BUFFER_WRITING              = Signal()	                                #write control signals
    
        self.BUFFER_READ_CLK             = Signal()                                 #read addressing signals 
        self.BUFFER_READ_ADDR            = Signal(math.ceil(math.log(depth,2)))     #read addressing signals
        self.BUFFER_RQ_READ              = Signal()                                 #read control signals
        self.BUFFER_READING              = Signal()	                                #read control signal
        self.BUFFER_INPUT_PX_DATA        = Signal(width)                               #write addressing signals 

    ## Outputs
        self.BUFFER_OUTPUT_PX_DATA       = Signal(width)    #read addressing signals 
        self.BUFFER_ACK_READ             = Signal()      #read control signals
        self.BUFFER_ACK_WRITE            = Signal()      #write control signals

    ## Instances
        self.specials +=Instance("frame_buffer",
            p_depth                      = depth,
            p_width                      = width,
            p_DEBUG_READ_MODE            = DEBUG_READ_MODE,
            i_buffer_clk                 = self.BUFFER_CLK,    
            i_reset                      = self.BUFFER_RESET,
            i_write_clk                  = self.BUFFER_WRITE_CLK,
            i_input_px_data              = self.BUFFER_INPUT_PX_DATA,
            i_write_addr                 = self.BUFFER_WRITE_ADDR,
            i_enable_mem                 = self.BUFFER_ENABLE_MEM,
            i_rq_write                   = self.BUFFER_RQ_WRITE,
            i_writing                    = self.BUFFER_WRITING,
            o_ack_write                  = self.BUFFER_ACK_WRITE,
            i_read_clk                   = self.BUFFER_READ_CLK,
            i_read_addr                  = self.BUFFER_READ_ADDR,
            o_output_px_data             = self.BUFFER_OUTPUT_PX_DATA,
            i_rq_read                    = self.BUFFER_RQ_READ,
            i_reading                    = self.BUFFER_READING,
            o_ack_read                   = self.BUFFER_ACK_READ,
        )
       
        