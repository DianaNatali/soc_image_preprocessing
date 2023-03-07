import os

from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer

from migen.genlib.io import CRG

from migen.genlib.cdc import MultiReg

from litex.build.generic_platform import *
from litex.build.xilinx import XilinxPlatform
from litex.build.xilinx.common import XilinxAsyncResetSynchronizerImpl

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.bitbang import I2CMaster
from litex.soc.cores.gpio import GPIOIn

from litex.soc.cores.clock import *

from hardware.SPI.SPI import SPI 
from hardware.cam_read.cam_read import cam_read
from hardware.frame_buffer.frame_buffer_HW import frame_buffer_HW
from hardware.frame_buffer.frame_buffer_SW import frame_buffer_SW 
from hardware.gray_scale.gray_scale_core import gray_scale_core
from hardware.sobel.sobel_control import sobel_control

# IOs ----------------------------------------------------------------------------------------------

_io = [
    ("user_sw",  2, Pins("G15"), IOStandard("LVCMOS33")),
        
    ("user_rgb_led", 0,
        Subsignal("r", Pins("Y11")),
        Subsignal("g", Pins("T5")),
        Subsignal("b", Pins("Y12")),
        IOStandard("LVCMOS33"),
    ),

    ("clk125", 0, Pins("K17"), IOStandard("LVCMOS33")),

    ("cpu_reset", 0, Pins("Y16"), IOStandard("LVCMOS33")),

    ("serial", 0,                                             #PMOD JE
        Subsignal("tx", Pins("J15")),
        Subsignal("rx", Pins("H15")),
        IOStandard("LVCMOS33"),
    ),

    ("threshold_up", 1, Pins("P16"), IOStandard("LVCMOS33")),
    ("threshold_down", 2, Pins("K18"), IOStandard("LVCMOS33")),

    ("cam_sync", 0,                                           #PMOD JB
        Subsignal("xclk",  Pins("V8")),                       #PIN 1
        Subsignal("vsync", Pins("W8")),                       #PIN 2
        Subsignal("href",  Pins("U7")),                       #PIN 3
        IOStandard("LVCMOS33"),
    ),                                                        #PMOD JB
    ("pclk", 0, Pins("Y7"), IOStandard("LVCMOS33")),          #PIN 7
    
    #cam read data                                            #PMOD JC
    ("cam_data", 0, Pins("U12"), IOStandard("LVCMOS33")),     #PIN 10
    ("cam_data", 1, Pins("T10"), IOStandard("LVCMOS33")),     #PIN 4
    ("cam_data", 2, Pins("T12"), IOStandard("LVCMOS33")),     #PIN 9
    ("cam_data", 3, Pins("T11"), IOStandard("LVCMOS33")),     #PIN 3
    ("cam_data", 4, Pins("Y14"), IOStandard("LVCMOS33")),     #PIN 8
    ("cam_data", 5, Pins("W15"), IOStandard("LVCMOS33")),     #PIN 2
    ("cam_data", 6, Pins("W14"), IOStandard("LVCMOS33")),     #PIN 7
    ("cam_data", 7, Pins("V15"), IOStandard("LVCMOS33")),     #PIN 1

    ("LCD_spi", 0,                                            #PMOD JD
        Subsignal("cs_n", Pins("T14")),                       #PIN 1
        Subsignal("dc_rs", Pins("T15")),                      #PIN 2
        Subsignal("mosi", Pins("P14")),                       #PIN 3
        Subsignal("clk", Pins("R14")),                        #PIN 4
        Subsignal("miso", Pins("U14")),                       #PIN 7
        IOStandard("LVCMOS33")
    ),

    ("i2c", 0,                                                #PMOD JB
        Subsignal("scl", Pins("V6")),                         #PIN 9
        Subsignal("sda", Pins("W6")),                         #PIN 10
        IOStandard("LVCMOS33")
    ),
    
]


# Platform -----------------------------------------------------------------------------------------

class Platform(XilinxPlatform):
    default_clk_name   = "clk125"
    default_clk_period = 1e9/125e6

    def __init__(self):
       XilinxPlatform.__init__(self, "xc7z020-clg400-1", _io, toolchain="vivado")
       #self.add_platform_command("set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cam_sync_pclk_IBUF]")


# Create our platform (fpga interface)
platform = Platform()

#platform.add_source("hardware/PWM/PWM.v")
platform.add_source("hardware/cam_read/cam_read.v")
platform.add_source("hardware/SPI/SPI.v")
platform.add_source("hardware/SPI/SPI_phy.v")
platform.add_source("hardware/frame_buffer/frame_buffer.v")
platform.add_source("hardware/frame_buffer/frame_memory.v")
platform.add_source("hardware/common/FF2_sync.v")
platform.add_source("hardware/gray_scale/gray_scale_core.v")
platform.add_source("hardware/common/buffer_reader.v")
platform.add_source("hardware/common/buffer_writer.v")
platform.add_source("hardware/sobel/sobel_control.v")
platform.add_source("hardware/sobel/sobel_core.v")

class PLLRST_sync(Module):

    def __init__(self, input_clk, input_rst, input_pclk, input_clk_freq, desired_domains:list):
        self.clock_domains.cd_pclk = ClockDomain()
        self.comb += [
            self.cd_pclk.clk.eq(input_pclk)
        ]
        platform.add_period_constraint(self.cd_pclk.clk, int((1e9)/(desired_domains[1]/2)))
        self.submodules.cd_pclk_rstsync = XilinxAsyncResetSynchronizerImpl(self.cd_pclk, input_rst)
        count = 0
        self.submodules.pll = pll = S7MMCM(speedgrade = -1)
        pll.register_clkin(input_clk, input_clk_freq)
        for i in desired_domains:
            if count == 0:
                self.clock_domains.cd_sys = ClockDomain()
                pll.create_clkout(self.cd_sys, desired_domains[0], with_reset = False)
                platform.add_period_constraint(self.cd_sys.clk, int((1e9)/desired_domains[0]))
                self.submodules.cd_sys_rstsync = XilinxAsyncResetSynchronizerImpl(self.cd_sys, input_rst)
            elif count == 1:
                self.clock_domains.cd_app1 = ClockDomain()
                pll.create_clkout(self.cd_app1, desired_domains[1], with_reset = False)
                platform.add_period_constraint(self.cd_app1.clk, int((1e9)/desired_domains[1]))
                self.submodules.cd_app1_rstsync = XilinxAsyncResetSynchronizerImpl(self.cd_app1, input_rst)
            elif count == 2:
                self.clock_domains.cd_app2 = ClockDomain()
                pll.create_clkout(self.cd_app2, desired_domains[2], with_reset = False)
                platform.add_period_constraint(self.cd_app2.clk, int((1e9)/desired_domains[2]))
                self.submodules.cd_app2_rstsync = XilinxAsyncResetSynchronizerImpl(self.cd_app2, input_rst)
            elif count == 3:
                self.clock_domains.cd_app3 = ClockDomain()
                pll.create_clkout(self.cd_app3, desired_domains[3], with_reset = False)
                platform.add_period_constraint(self.cd_app3.clk, int((1e9)/desired_domains[3]))
                self.submodules.cd_app3_rstsync = XilinxAsyncResetSynchronizerImpl(self.cd_app3, input_rst)
            count+=1

class UserButtonPress(Module):
    def __init__(self, user_btn):
        self.rising = Signal()

        # # #

        _user_btn = Signal()
        _user_btn_d = Signal()

        # resynchronize user_btn
        self.specials += MultiReg(user_btn, _user_btn)
        # detect rising edge
        self.sync += [
            _user_btn_d.eq(user_btn),
            self.rising.eq(_user_btn & ~_user_btn_d)
        ]

class BaseSoC(SoCCore):
    def __init__(self, platform):

        sys_clk_freq = 125e6
        in_clk_freq = 125e6

        # SoC with CPU
        SoCCore.__init__(self, platform,
            cpu_type                 = "vexriscv",
            csr_data_width           = 32,
            clk_freq                 = sys_clk_freq,
            ident                    = "LiteX CPU Test SoC", ident_version=True,
            integrated_rom_size      = 0x8000,
            integrated_main_ram_size = 0x4800)

        external_rst = platform.request("cpu_reset") 
        clk125 = platform.request("clk125")  
        pclk_in = platform.request("pclk")

        self.submodules.crg = PLLRST_sync(clk125, external_rst, pclk_in,
                                          in_clk_freq, [sys_clk_freq, 16e6, 25e6, 8e6])


        #BUTTONS
        threshold_up = UserButtonPress(platform.request("threshold_up"))
        threshold_down = UserButtonPress(platform.request("threshold_down"))
        self.submodules += threshold_up, threshold_down
        
        #CAMERA -> PREPROCESSOR
        cam_sync = platform.request("cam_sync")
        self.submodules.cam_read= cam_read()
        self.add_csr("cam_read")
        cam_data = Cat(*[platform.request("cam_data", i) for i in range(8)])
        self.submodules.gray_scale= gray_scale_core()
        self.comb += [
            cam_sync.xclk.eq(self.cam_read.CAM_XCLK),
            self.cam_read.CAM_CLK_PLL.eq(self.crg.cd_app1.clk),
            self.cam_read.CAM_RESET.eq(self.crg.cd_pclk.rst),
            self.cam_read.CAM_PCLK.eq(self.crg.cd_pclk.clk),
            self.cam_read.CAM_VSYNC.eq(cam_sync.vsync),
            self.cam_read.CAM_HREF.eq(cam_sync.href),
            self.cam_read.CAM_DATA.eq(cam_data),
            self.gray_scale.PREP_RESET.eq(ResetSignal()),
            self.gray_scale.PREP_CLK.eq(self.cam_read.CAM_CLK_WRITE),
            self.gray_scale.PREP_FRAME_FLAG.eq(self.cam_read.CAM_FRAME_FLAG),
            self.gray_scale.PREP_INPUT_PX_DATA.eq(self.cam_read.CAM_OUTPUT_PX_DATA)
        ]

        #PREPROCESSOR -> BUFF1 
        self.submodules.input_buffer = frame_buffer_HW()
        self.comb += [
            self.gray_scale.PREP_ACK_WRITE.eq(self.input_buffer.BUFFER_ACK_WRITE),
            self.input_buffer.BUFFER_CLK.eq(ClockSignal()),
            self.input_buffer.BUFFER_RESET.eq(ResetSignal()),
            self.input_buffer.BUFFER_RQ_WRITE.eq(self.gray_scale.PREP_RQ_WRITE),
            self.input_buffer.BUFFER_WRITING.eq(self.gray_scale.PREP_WRITING),
            self.input_buffer.BUFFER_ENABLE_MEM.eq(self.gray_scale.PREP_ENABLE_MEM),
            self.input_buffer.BUFFER_WRITE_CLK.eq(self.gray_scale.PREP_WRITE_CLK),
            self.input_buffer.BUFFER_INPUT_PX_DATA.eq(self.gray_scale.PREP_OUTPUT_PX_GRAY),
            self.input_buffer.BUFFER_WRITE_ADDR.eq(self.gray_scale.PREP_WRITE_ADDR)
        ]

        # BUFF1 -> SOBEL
        self.submodules.sobel_core = sobel_control()
        self.add_csr("sobel_core")
        self.comb += [
            self.input_buffer.BUFFER_READ_CLK.eq(self.sobel_core.SOBEL_READ_CLK),
            self.input_buffer.BUFFER_READ_ADDR.eq(self.sobel_core.SOBEL_READ_ADRR),
            self.input_buffer.BUFFER_RQ_READ.eq(self.sobel_core.SOBEL_RQ_READ),
            self.input_buffer.BUFFER_READING.eq(self.sobel_core.SOBEL_READING),
            self.sobel_core.SOBEL_CLK.eq(ClockSignal()),
            self.sobel_core.SOBEL_RESET.eq(ResetSignal()),
            self.sobel_core.SOBEL_ACK_READ.eq(self.input_buffer.BUFFER_ACK_READ),
            self.sobel_core.SOBEL_INPUT_PX_GRAY.eq(self.input_buffer.BUFFER_OUTPUT_PX_DATA),
            self.sobel_core.THRESHOLD_UP.eq(threshold_up.rising),
            self.sobel_core.THRESHOLD_DOWN.eq(threshold_down.rising)
        ]

        # SOBEL -> BUFF2
        self.submodules.sobel_buffer = frame_buffer_SW()
        self.add_csr("sobel_buffer")
        self.comb += [
            self.sobel_core.SOBEL_ACK_WRITE.eq(self.sobel_buffer.BUFFER_ACK_WRITE),
            self.sobel_buffer.BUFFER_CLK.eq(ClockSignal()),
            self.sobel_buffer.BUFFER_RESET.eq(ResetSignal()),
            self.sobel_buffer.BUFFER_WRITE_CLK.eq(self.sobel_core.SOBEL_WRITE_CLK),
            self.sobel_buffer.BUFFER_INPUT_PX_DATA.eq(self.sobel_core.SOBEL_OUTPUT_PX_SOBEL),
            self.sobel_buffer.BUFFER_WRITE_ADDR.eq(self.sobel_core.SOBEL_WRITE_ADDR),
            self.sobel_buffer.BUFFER_RQ_WRITE.eq(self.sobel_core.SOBEL_RQ_WRITE),
            self.sobel_buffer.BUFFER_ENABLE_MEM.eq(self.sobel_core.SOBEL_ENABLE_MEM),
            self.sobel_buffer.BUFFER_WRITING.eq(self.sobel_core.SOBEL_WRITING)
        ]

        #SPI LCD
        SPI_conn = platform.request("LCD_spi")
        self.submodules.SPI= SPI()
        self.add_csr("SPI")
        self.comb += [
            SPI_conn.cs_n.eq(self.SPI.CS),
            SPI_conn.dc_rs.eq(self.SPI.DC),
            SPI_conn.clk.eq(self.SPI.SCK),
            SPI_conn.mosi.eq(self.SPI.MOSI),
            self.SPI.MISO.eq(SPI_conn.miso),
            self.SPI.CLK.eq(ClockSignal()),
            self.SPI.RESET.eq(ResetSignal())
        ]

        #IA -> BUFF3 -> LCD
        self.submodules.output_buffer= frame_buffer_SW()
        self.add_csr("out_buffer")
        self.comb += [
            self.output_buffer.BUFFER_CLK.eq(ClockSignal()),
            self.output_buffer.BUFFER_RESET.eq(ResetSignal()),
        ]

        #I2C
        self.submodules.i2c = I2CMaster(platform.request("i2c"))
        self.add_csr("i2c")


        #SWITCHES
        switches_conn = platform.request("user_sw")
        self.submodules.switches = GPIOIn(switches_conn)
        self.add_csr("switches")

         
def main():
    os.system("rm -r liteXBuild")
    
    soc = BaseSoC(platform)

    # Build --------------------------------------------------------------------------------------------
    builder = Builder(soc, output_dir="liteXBuild", csr_csv="memoryMap.csv", generate_doc="x.doc")
    builder.build(build_name="top")

if __name__ == "__main__":
    main()