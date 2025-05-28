#!/bin/bash

cd ./top_level

ghdl -a -fsynopsys ../mem_instructions/mem_instructions.vhd
ghdl -a -fsynopsys ../hearth_ual/hearth_ual.vhd
ghdl -a -fsynopsys ../interconnexion/interconnexion.vhd
ghdl -a -fsynopsys ../buffer_ual/buffer_ual.vhd
ghdl -a -fsynopsys ../top_level/top_level.vhd
ghdl -a -fsynopsys top_level_testbench.vhd

ghdl -e -fsynopsys top_level_tb

ghdl -r -fsynopsys top_level_tb --vcd=top_level_gtkwave.vcd