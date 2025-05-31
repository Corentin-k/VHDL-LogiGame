#!/bin/bash
cd ./fsm
ghdl -a -fsynopsys --std=08  ../lfsr/lfsr.vhd
ghdl -a -fsynopsys --std=08  ../minuteur/minuteur.vhd
ghdl -a -fsynopsys --std=08  ../score_compteur/score_compteur.vhd
ghdl -a -fsynopsys --std=08  ../verif_resultat/verif_resultat.vhd
ghdl -a -fsynopsys --std=08   fsm.vhd fsm_testbench.vhd


ghdl -e --std=08    -fsynopsys fsm_tb


ghdl -r --std=08    -fsynopsys fsm_tb --vcd=fsm_tb_gtkwave.vcd