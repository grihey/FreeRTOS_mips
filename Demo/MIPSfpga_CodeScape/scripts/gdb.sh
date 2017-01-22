#!/bin/bash
TOP_DIR=$(realpath $(dirname $0))
echo $TOP_DIR
#mips-mti-linux-gnu-gdb -q $1 -x $TOP_DIR/startup
mips-mti-elf-gdb -q /home/grihey/STUD/FreeRTOS_mips/FPGA_Ram.elf -x $TOP_DIR/startup
