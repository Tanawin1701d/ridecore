cp -r fpga fpgaCount
cd fpgaCount
rm -r obj_dir
cloc .
grep -R -o "///DC" . | wc -l