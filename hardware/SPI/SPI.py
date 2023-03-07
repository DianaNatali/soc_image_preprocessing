from migen import *
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

# Main module
class SPI(Module,AutoCSR):
    def __init__(self):

    ## Interruptions
        self.submodules.ev = EventManager()
        self.ev.DataClock  = EventSourceProcess(edge ="rising") 
        
    ## Inputs        
        self.CLK                         = Signal()
        self.RESET                       = Signal()
        self.MISO                        = Signal()
    
    ## Outputs
        self.MOSI                        = Signal()
        self.SCK                         = Signal()
        self.CS                          = Signal()
        self.DC                          = Signal()
   
    ## Internal Registers        
        self.outputDataRegister          = CSRStorage(8)
        self.enableSPIRegister           = CSRStorage()
        self.enableCSRegister            = CSRStorage()
        self.enableDCRegister            = CSRStorage()
        self.prescaler_reg               = CSRStorage(16)

        self.inputDataRegisterCSR        = CSRStatus(8)
        self.dataClockRegisterCSR        = CSRStatus()       
        self.inputDataRegister           = Signal(8)
        self.dataClockRegister           = Signal()
      
    ## Instances
        self.specials +=Instance("SPI",
            i_masterClk                  = self.CLK,    
            i_rst                        = self.RESET,
            i_MISO                       = self.MISO,
            o_MOSI                       = self.MOSI,
            o_SCK                        = self.SCK,
            o_CS                         = self.CS, 
            o_DC                         = self.DC,            
            o_dataClockRegister          = self.dataClockRegister,
            o_inputDataRegister          = self.inputDataRegister,    
            i_outputDataRegister         = self.outputDataRegister.storage, 
            i_enableSPIRegister          = self.enableSPIRegister.storage,
            i_enableCSRegister           = self.enableCSRegister.storage,
            i_enableDCRegister           = self.enableDCRegister.storage,
            i_prescaler_reg              = self.prescaler_reg.storage
        )
        self.comb +=[
            self.inputDataRegisterCSR.status.eq(self.inputDataRegister),
            self.dataClockRegisterCSR.status.eq(self.dataClockRegister),
            self.ev.DataClock.trigger.eq( self.dataClockRegister==1)            
        ]
