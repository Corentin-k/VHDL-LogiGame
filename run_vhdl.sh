#!/bin/bash
# chmod +x run_vhdl.sh
# ./run_vhdl.sh nom_dossier [--g]

if [ $# -lt 1 ]; then
  echo "Usage: $0 nom_dossier [--g]"
  exit 1
fi

DIR="$1"
TB_ENTITY="${DIR}_tb"
VHD="${DIR}.vhd"
TB_VHD="${DIR}_testbench.vhd"
VCD="${DIR}_gtkwave.vcd"
GTK=0

if [ "$2" == "--g" ]; then
  GTK=1
fi

cd "$DIR" || { echo "Dossier $DIR introuvable"; exit 1; }

ghdl -a "$VHD" "$TB_VHD" || exit 1
ghdl -e "$TB_ENTITY" || exit 1
ghdl -r "$TB_ENTITY" --vcd="$VCD" || exit 1

if [ $GTK -eq 1 ]; then
  gtkwave "$VCD"
fi