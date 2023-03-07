from migen import *
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

import math

# Main module
class sobel_control(Module,AutoCSR):
    def __init__(self):

        ## Parameters
            depth = 76800
            addrBits = math.ceil(math.log(depth,2))

        ## Inputs        
            self.SOBEL_CLK                      = Signal()         
            self.SOBEL_RESET                    = Signal()
            
            self.SOBEL_ACK_READ                 = Signal()
            self.SOBEL_INPUT_PX_GRAY            = Signal(15) 
            self.SOBEL_ACK_WRITE                = Signal()

            self.THRESHOLD_UP                   = Signal()
            self.THRESHOLD_DOWN                 = Signal()   
            
        ## Outputs
            self.SOBEL_RQ_READ                  = Signal()
            self.SOBEL_READING                  = Signal()
            self.SOBEL_READ_ADRR                = Signal(addrBits)
            self.SOBEL_READ_CLK                 = Signal() 
            self.SOBEL_RQ_WRITE                 = Signal()

            self.SOBEL_WRITING                  = Signal()
            self.SOBEL_OUTPUT_PX_SOBEL          = Signal(15)
            self.SOBEL_WRITE_ADDR               = Signal(addrBits)
            self.SOBEL_WRITE_CLK                = Signal()
            self.SOBEL_ENABLE_MEM               = Signal()

            self.SOBEL_THRESHOLD                = Signal(14)

        ## Internal Registers
            self.threshold_val_reg              = CSRStatus(14)

        ## Instances
            self.specials +=Instance("sobel_control",
                p_depth                         = depth,
                i_sobel_clk                     = self.SOBEL_CLK,
                i_reset                         = self.SOBEL_RESET,
                i_ack_read                      = self.SOBEL_ACK_READ,
                o_rq_read                       = self.SOBEL_RQ_READ,
                o_reading                       = self.SOBEL_READING,
                i_input_px_gray                 = self.SOBEL_INPUT_PX_GRAY,
                o_read_addr                     = self.SOBEL_READ_ADRR,
                o_read_clk                      = self.SOBEL_READ_CLK,
                i_ack_write                     = self.SOBEL_ACK_WRITE,
                o_rq_write                      = self.SOBEL_RQ_WRITE,
                o_writing                       = self.SOBEL_WRITING,
                o_output_px_sobel               = self.SOBEL_OUTPUT_PX_SOBEL, 
                o_write_addr                    = self.SOBEL_WRITE_ADDR,
                o_write_clk                     = self.SOBEL_WRITE_CLK,
                o_enable_mem                    = self.SOBEL_ENABLE_MEM,
                o_threshold_sobel_val           = self.SOBEL_THRESHOLD,
                i_threshold_up                  = self.THRESHOLD_UP,
                i_threshold_down                = self.THRESHOLD_DOWN,                
            )

            self.comb +=[
                self.threshold_val_reg.status.eq(self.SOBEL_THRESHOLD)
            ]
