#!/bin/bash

ghdl -a -fsynopsys ../mem_instructions/mem_instructions.vhd
ghdl -a -fsynopsys ../ual/ual.vhd
ghdl -a -fsynopsys ../interconnexion/interconnexion.vhd
ghdl -a -fsynopsys ../bufferNbits/bufferCMD/bufferCMD.vhd
ghdl -a -fsynopsys ../bufferNbits/bufferUAL/bufferUAL.vhd
ghdl -a -fsynopsys mem_instructions_testbench.vhd

# Élaboration du testbench
ghdl -e -fsynopsys mem_instructions_tb

# Lancement de la simulation avec génération du VCD
ghdl -r -fsynopsys mem_instructions_tb --vcd=simu.vcd