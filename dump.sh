#!/bin/bash
mips-mti-elf-objdump -x -w -s -D Demo/MIPSfpga_CodeScape/build/FPGA_Ram.elf > edump_spec
#mips-mti-elf-objdump -x -w -s -D Demo/MIPSfpga_CodeScape/build/FPGA_Ram.elf_bak > edump_spec_bak
