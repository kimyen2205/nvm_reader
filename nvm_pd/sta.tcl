read_liberty sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog netlist.v
link_design NVM_reader
read_sdc nvm.sdc

report_checks -path_delay max -digits 3
report_checks -path_delay min -digits 3
report_worst_slack -max -digits 3
report_worst_slack -min -digits 3
report_tns -digits 3
report_wns -digits 3
