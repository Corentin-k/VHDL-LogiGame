#!/bin/bash
cd ./mem_instructions
ghdl -a -fsynopsys ../mem_instructions/mem_instructions.vhd
ghdl -a -fsynopsys ../hearth_ual/hearth_ual.vhd
ghdl -a -fsynopsys ../interconnexion/interconnexion.vhd
ghdl -a -fsynopsys ../buffer_ual/buffer_ual.vhd
ghdl -a -fsynopsys mem_instructions_testbench.vhd


ghdl -e -fsynopsys mem_instructions_tb


ghdl -r -fsynopsys mem_instructions_tb --vcd=mem_instructions_gtkwave.vcd