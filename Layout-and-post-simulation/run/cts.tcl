
echo ok
if{[file exists [which cts.log]]}
 rm ../logs/cts.log
icc_shell -64 -f ../scripts/cts.tcl | tee -i ../logs/cts.log

