#!/bin/bash
rm -r obj_dir
verilator --threads 1 -O3 --top-module pipeline --cc --exe -j 1  *.v *.vh