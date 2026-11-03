create_clock -name clk -period 10 [get_ports clk]
set_input_delay  2 -clock clk [get_ports {rst_n read_en data_in[*] address_in[*]}]
set_output_delay 2 -clock clk [get_ports {data_out address_out[*] chip_finish}]
