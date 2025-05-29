#!/bin/bash
cd ./fsm
ghdl -a -fsynopsys ../lfsr/lfsr.vhd
ghdl -a -fsynopsys ../minuteur/minuteur.vhd
ghdl -a -fsynopsys ../score_compteur/score_compteur.vhd
ghdl -a -fsynopsys ../verif_resultat/verif_resultat.vhd
ghdl -a -fsynopsys fsm.vhd fsm_testbench.vhd


ghdl -e -fsynopsys fsm_tb


ghdl -r -fsynopsys fsm_tb --vcd=fsm_tb_gtkwave.vcd