#spef.tcl
echo ok
if{[file exists [which spef.log]]}
 rm ../logs/spef.log
icc_shell -64 -f ../scripts/spef.tcl | tee -i ../logs/spef.log
echo finish
