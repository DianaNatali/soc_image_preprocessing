from migen import *
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

import math

# Main module
class gray_scale_core(Module,AutoCSR):
    def __init__(self):

        ## Parameters
            depth = 76800
            addrBits = math.ceil(math.log(depth,2))

        ## Inputs        
            self.PREP_CLK                       = Signal()         
            self.PREP_RESET                     = Signal()
            self.PREP_INPUT_PX_DATA             = Signal(15)       #Read buffer
            self.PREP_ACK_WRITE                 = Signal()         #Write buffer
            self.PREP_FRAME_FLAG                = Signal()
            
        ## Outputs
            self.PREP_RQ_WRITE                  = Signal()
            self.PREP_WRITING                   = Signal()
            self.PREP_OUTPUT_PX_GRAY            = Signal(15)
            self.PREP_WRITE_ADDR                = Signal(addrBits)
            self.PREP_WRITE_CLK                 = Signal()
            self.PREP_ENABLE_MEM                = Signal()

        ## Instances
            self.specials +=Instance("gray_scale_core",
                p_depth                         = depth,
                i_px_clk                        = self.PREP_CLK,
                i_reset                         = self.PREP_RESET,
                i_input_px_data                 = self.PREP_INPUT_PX_DATA,
                i_ack_write                     = self.PREP_ACK_WRITE,
                i_frame_flag                    = self.PREP_FRAME_FLAG,
                o_rq_write                      = self.PREP_RQ_WRITE,
                o_writing                       = self.PREP_WRITING,
                o_output_px_grayscale           = self.PREP_OUTPUT_PX_GRAY, 
                o_write_addr                    = self.PREP_WRITE_ADDR,
                o_write_clk                     = self.PREP_WRITE_CLK,
                o_enable_mem                    = self.PREP_ENABLE_MEM,
            )
