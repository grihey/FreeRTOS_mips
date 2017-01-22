# microAptiv_UP makefile for MIPSfpga

ifndef MIPS_ELF_ROOT
$(error MIPS_ELF_ROOT must be set to point to toolkit installation root)
endif

BUILD_DIR=build
INCLUDE_DIRS= \
../../Source/include \
./src/include \
../../Source/portable/CodeScape/MIPSFpga \
../Common/include

INCLUDE_FLAGS=$(INCLUDE_DIRS:%=-I%)
SRC_DIR=src
RTOS_SOURCE_DIR=../../Source
MINIMAL_SOURCE_DIR=../Common/Minimal
PORT_SOURCE_DIR=../../Source/portable/CodeScape/MIPSFpga
MEM_MODEL_SOURCE_DIR=../../Source/portable/MemMang

CC=mips-mti-elf-gcc-4.9.2
LD=mips-mti-elf-gcc
OD=mips-mti-elf-objdump
OC=mips-mti-elf-objcopy
SZ=mips-mti-elf-size

CFLAGS = -mno-mcu -O0 -g -EL -c -msoft-float -march=m14kc $(INCLUDE_FLAGS)
LDFLAGS = -EL -msoft-float -march=m14kc -Wl,-Map=$(BUILD_DIR)/FPGA_Ram_map.txt

# Set up the link addresses for a bootable C program on MIPSfpga
LDFLAGS += -T boot-uhi32.ld
# Place the boot code (physical address). The virtual address for
# boot code entry point is hard-wired to 0x9fc00000.
LDFLAGS += -Wl,--defsym,__flash_start=0xbfc00000
# Place the application code (physical address)
LDFLAGS += -Wl,--defsym,__flash_app_start=0x80000000
# Place the application code (virtual address)
LDFLAGS += -Wl,--defsym,__app_start=0x80000000
# Set the stack to the top of the Code/Data RAM
LDFLAGS += -Wl,--defsym,__stack=0x80040000
# Cautiously set the size of memory as the 2015.01 toolchain uses
# this size as the amount of free memory between the end of the
# program data and the lowest address that the stack will reach.
#
# Max 2K for stack (0x800)
# Leaving 126K heap (0x1f800)
LDFLAGS += -Wl,--defsym,__memory_size=0x1f800
# Set the entry point to the true hard-reset address
LDFLAGS += -Wl,-e,0xbfc00000

ASOURCES= \
boot.S

SRC= \
main_blinky.c \
main.c 

MINIMAL_SOURCES = \
QueueOverwrite.c \
QueueSet.c \
EventGroupsDemo.c 

RTOS_SOURCES = \
timers.c \
event_groups.c \
tasks.c \
queue.c \
list.c

APORT_SOURCES = port_asm.S 
PORT_SOURCES = port.c

MEM_MODEL_SOURCES = heap_2.c

all: FPGA_RAM

AOBJECTS= \
$(ASOURCES:%.S=$(BUILD_DIR)/%.o) \
$(APORT_SOURCES:%.S=$(BUILD_DIR)/%.o)

COBJECTS= \
$(SRC:%.c=$(BUILD_DIR)/%.o) \
$(MINIMAL_SOURCES:%.c=$(BUILD_DIR)/%.o) \
$(RTOS_SOURCES:%.c=$(BUILD_DIR)/%.o) \
$(PORT_SOURCES:%.c=$(BUILD_DIR)/%.o) \
$(MEM_MODEL_SOURCES:%.c=$(BUILD_DIR)/%.o) 

test:
	@echo $(COBJECTS)

FPGA_RAM : $(AOBJECTS) $(COBJECTS) 
	$(LD)  $(LDFLAGS) $(AOBJECTS) $(COBJECTS) -o $(BUILD_DIR)/FPGA_Ram.elf
	$(SZ) $(BUILD_DIR)/FPGA_Ram.elf
	$(OD) -D -S -l $(BUILD_DIR)/FPGA_Ram.elf > $(BUILD_DIR)/FPGA_Ram_dasm.txt
	$(OD) -D -z $(BUILD_DIR)/FPGA_Ram.elf > $(BUILD_DIR)/FPGA_Ram_modelsim.txt
	$(OC) $(BUILD_DIR)/FPGA_Ram.elf -O srec $(BUILD_DIR)/FPGA_Ram.rec
	
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@
    
$(BUILD_DIR)/%.o: $(MINIMAL_SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@
    
$(BUILD_DIR)/%.o: $(RTOS_SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: $(MEM_MODEL_SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@
    
$(BUILD_DIR)/%.o: $(PORT_SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@
   
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	$(CC) $(CFLAGS) $< -o $@
    
$(BUILD_DIR)/%.o: $(PORT_SOURCE_DIR)/%.S
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(BUILD_DIR)/FPGA_Ram_dasm.txt
	rm -f $(BUILD_DIR)/FPGA_Ram_modelsim.txt
	rm -f $(BUILD_DIR)/FPGA_Ram_map.txt
	rm -f $(BUILD_DIR)/FPGA_Ram.rec
	rm -f $(BUILD_DIR)/FPGA_Ram.elf
	rm -f $(BUILD_DIR)/*.o
	rm -rf MemoryFiles

	
