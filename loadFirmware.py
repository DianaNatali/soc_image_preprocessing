#!/usr/bin/env python3
import serial
import serial.tools.list_ports
import os

def findFTDI232Port():
    portList = list(serial.tools.list_ports.comports())
    for p in portList:
        if "FT232R USB UART - FT232R USB UART" in p[1]:
            return p[0]

serialPort= findFTDI232Port()

os.system("lxterm "+ serialPort+ " --kernel firmware/firmware.bin")
