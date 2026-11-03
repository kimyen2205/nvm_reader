read_liberty sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog netlist_nolp.v
link_design NVM_reader
read_sdc nvm.sdc
replace_cell _29_ sky130_fd_sc_hd__nor2b_4
puts "SIZE nor2b_4"
report_checks -path_delay max -digits 3 -fields {fanout slew}   -from [all_registers -clock_pins] -to [all_registers -data_pins]
