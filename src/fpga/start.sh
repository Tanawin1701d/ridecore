#!/bin/bash
rm -r obj_dir
/usr/bin/verilator -O3 --top-module pipeline --cc --exe -j 1  *.v *.vh