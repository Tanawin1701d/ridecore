#!/bin/bash
verilator --threads 1 -O3 --top-module pipeline --cc --exe -j 1  *.v *.vh