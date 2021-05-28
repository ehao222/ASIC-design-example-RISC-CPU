echo ok
if{[file exists [which floorplan.log]]}
 rm ../logs/floorplan.log
icc_shell -64 -f ../scripts/floorplan.tcl|tee -i ../logs/floorplan.log
