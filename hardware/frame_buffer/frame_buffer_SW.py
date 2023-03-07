from turtle import width
from migen import *
from litex.soc.interconnect.csr import *

import math

# Main module
class frame_buffer_SW(Module,AutoCSR):
    def __init__(self, DEBUG_READ_MODE=0):
    
    ##Parameters
        depth = 76800
        width = 15

        self.zero_signal                          = Signal()  

    ## Inputs        
        self.BUFFER_CLK                           = Signal()
        self.BUFFER_RESET                         = Signal()

        self.BUFFER_WRITE_CLK                     = Signal()                                 #write addressing signals 
        self.BUFFER_INPUT_PX_DATA                 = Signal(width)                               #write addressing signals 
        self.BUFFER_WRITE_ADDR                    = Signal(math.ceil(math.log(depth,2)))     #write addressing signals
        self.BUFFER_ENABLE_MEM                    = Signal()
        self.BUFFER_RQ_WRITE                      = Signal()                                 #write control signals
        self.BUFFER_WRITING                       = Signal()	                                #write control signals	                                #write control signals
        
    ## Outputs
        self.BUFFER_OUTPUT_PX_DATA                = Signal(width)    #read addressing signals 
        self.BUFFER_ACK_READ                      = Signal()      #read control signals
        self.BUFFER_ACK_WRITE                     = Signal()      #write control signals

    ## Internal Registers        
        self.read_clk_reg                  = CSRStorage()
        self.output_px_data_reg            = CSRStatus(15)
        self.read_addr_reg                 = CSRStorage(math.ceil(math.log(depth,2)))
        self.rq_read_reg                   = CSRStorage()
        self.reading_reg                   = CSRStorage()      
        self.ack_read_reg                  = CSRStatus()

    ## Instances
        self.specials +=Instance("frame_buffer",
            p_depth                      = depth,
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
            i_read_clk                   = self.read_clk_reg.storage,
            i_read_addr                  = self.read_addr_reg.storage,
            o_output_px_data             = self.BUFFER_OUTPUT_PX_DATA,
            i_rq_read                    = self.rq_read_reg.storage,
            i_reading                    = self.reading_reg.storage,
            o_ack_read                   = self.BUFFER_ACK_READ,
        )
        self.comb +=[
            self.zero_signal.eq(0),
            self.output_px_data_reg.status.eq(Cat(self.BUFFER_OUTPUT_PX_DATA[0:5],self.zero_signal,self.BUFFER_OUTPUT_PX_DATA[5:16])),
            self.ack_read_reg.status.eq(self.BUFFER_ACK_READ),
        ]
        