from migen import *
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

import math

# Main module
class cam_read(Module,AutoCSR):
    def __init__(self):
     
    ##Parameters
        depth = 76800
        
    ## Inputs 
        self.CAM_CLK_PLL              = Signal()
        self.CAM_RESET                = Signal()       
        self.CAM_PCLK                 = Signal()
        self.CAM_VSYNC                = Signal()
        self.CAM_HREF                 = Signal()
        self.CAM_DATA                 = Signal(8)
    
    ## Outputs
        self.CAM_XCLK                 = Signal()
        self.CAM_CLK_WRITE            = Signal()
        self.CAM_FRAME_FLAG           = Signal()
        self.CAM_OUTPUT_PX_DATA       = Signal(15)
    
    ## Internal Registers        
        self.cam_enable_xclk         = CSRStorage()      
      
    ## Instances
        self.specials +=Instance("cam_read",
            p_depth                      = depth,
            i_clk_pll                    = self.CAM_CLK_PLL,
            i_pclk                       = self.CAM_PCLK,    
            i_vsync                      = self.CAM_VSYNC,
            i_href                       = self.CAM_HREF,
            i_input_data                 = self.CAM_DATA,
            i_rst                        = self.CAM_RESET,
            i_enable_xclk                = self.cam_enable_xclk.storage, 
            o_xclk                       = self.CAM_XCLK,
            o_clk_write                  = self.CAM_CLK_WRITE,
            o_frame_flag                 = self.CAM_FRAME_FLAG,
            o_output_px_data             = self.CAM_OUTPUT_PX_DATA,
        )
        