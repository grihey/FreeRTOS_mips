#!/bin/bash
DATE=`date`
TOP_DIR=$(realpath $(dirname $0))
make -C Demo/MIPSfpga_CodeScape clean
make -C Demo/MIPSfpga_CodeScape
cp $TOP_DIR/Demo/MIPSfpga_CodeScape/build/FPGA_Ram.elf $TOP_DIR
cp $TOP_DIR/Demo/MIPSfpga_CodeScape/build/FPGA_Ram_dasm.txt $TOP_DIR/dasm
cp $TOP_DIR/Demo/MIPSfpga_CodeScape/build/FPGA_Ram_modelsim.txt $TOP_DIR/modelsim
mips-mti-elf-objdump -x -w -s -D Demo/MIPSfpga_CodeScape/build/FPGA_Ram.elf > edump_spec
