#!/usr/bin/env python3
import os
os.system("clear")
os.system("cd firmware && make clean && make all")
os.system("cd ..")
os.system("python3 loadFirmware.py")