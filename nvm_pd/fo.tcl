read_liberty sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog netlist_nolp.v
link_design NVM_reader
read_sdc nvm.sdc
report_checks -path_delay max -digits 3 -fields {fanout capacitance slew} \
  -from [all_registers -clock_pins] -to [all_registers -data_pins]
