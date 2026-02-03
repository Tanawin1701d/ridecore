#!/bin/bash
rm -r obj_dir
/usr/bin/verilator -O3 -Wno-WIDTH -Wno-WIDTHCONCAT --top-module pipeline --cc --exe -j 1  *.v *.vh