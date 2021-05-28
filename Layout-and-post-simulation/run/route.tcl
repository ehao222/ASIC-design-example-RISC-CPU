
echo ok
if{ [file exists [which route.log]]}
  rm ../logs/route.log
icc_shell -64 -f ../scripts/route.tcl | tee -i ../logs/route.log
