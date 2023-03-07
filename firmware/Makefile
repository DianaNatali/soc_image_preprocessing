
BUILD_DIR?=../liteXBuild/

include $(BUILD_DIR)/software/include/generated/variables.mak
include $(SOC_DIRECTORY)/software/common.mak

OBJECTS = isr.o main.o spi.o timer.o ili9341.o read_buffer.o cam_config.o defaults.o

CFLAGS +=-Wextra

ifdef WITH_CXX
	OBJECTS += main.o
endif

all: firmware.bin

# pull in dependency info for *existing* .o files
-include $(OBJECTS:.o=.d)

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@
	chmod -x $@

firmware.elf: $(OBJECTS)
	$(CC) $(LDFLAGS) \
		-T linker.ld \
		-N -o $@ \
		$(BUILD_DIR)/software/libbase/crt0.o \
		$(OBJECTS) \
		-L$(BUILD_DIR)/software/libbase \
		-L$(BUILD_DIR)/software/libcompiler_rt \
		-lbase-nofloat -lcompiler_rt
	chmod -x $@

main.o: main.c 
	$(compile)

donut.o: CFLAGS += -w

helloc.o: CFLAGS += -w

hellocpp.o: CXXFLAGS += -w

%.o: %.cpp
	$(compilexx)

%.o: %.c
	$(compile)

%.o: %.S
	$(assemble)

clean:
	$(RM) $(OBJECTS) $(OBJECTS:.o=.d) firmware.elf firmware.bin .*~ *~

showFlags:
	echo "CFlags: " + $(CFLAGS)

.PHONY: all main.o clean load showFlags