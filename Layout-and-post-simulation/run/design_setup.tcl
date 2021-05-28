#Design_setup.tcl
echo ok
if{[file exists [which design_setup.log]]}
 rm ../logs/design_setup.log
icc_shell -64 -f ../scripts/design_setup.tcl | tee -i ../logs/design_setup.log

