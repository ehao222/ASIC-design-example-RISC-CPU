
echo ok
if{[file exists [which place.log]]}
 rm ../logs/place.log
icc_shell -64 -f ../scripts/place.tcl | tee -i ../logs/place.log


