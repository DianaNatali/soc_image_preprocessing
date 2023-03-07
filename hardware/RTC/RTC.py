from migen import *
from litex.soc.interconnect.csr import *

class RTC(Module,AutoCSR):
    def __init__(self):
        
    ## Inputs
        self.RTC_CLK                  = Signal()
        self.RTC_RESET                = Signal()

    ## Internal Registers     
        self.milisec_reg_CSR            = CSRStatus(32)
        self.milisec_reg                = Signal(32)

    ## Instances
        self.specials +=Instance("RTC", 
            i_clk                       = self.RTC_CLK,
            i_rst                       = self.RTC_RESET,    
            o_milisec_reg               = self.milisec_reg,  
        )

        self.comb += [
            self.milisec_reg_CSR.status.eq(self.milisec_reg),
        ]