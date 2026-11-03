`timescale 1ns/1ps
module tb_NVM_reader;
  reg clk, rst_n, read_en;
  reg [7:0] data_in, address_in;
  wire data_out, chip_finish;
  wire [7:0] address_out;

  NVM_reader uut (.clk(clk), .rst_n(rst_n), .read_en(read_en),
                  .data_in(data_in), .address_in(address_in),
                  .data_out(data_out), .address_out(address_out),
                  .chip_finish(chip_finish));

  always #5 clk = ~clk;

  task do_read(input [7:0] d, input [7:0] a);
    begin
      data_in = d; address_in = a;
      @(posedge clk); #1 read_en = 1;
      @(posedge clk); #1 read_en = 0;
      repeat (14) @(posedge clk);
    end
  endtask

  initial begin
    $dumpfile("nvm_reader_tb.vcd");
    $dumpvars(0, tb_NVM_reader);
    clk = 0; rst_n = 0; read_en = 0; data_in = 0; address_in = 0;
    #25 rst_n = 1;
    do_read(8'b1011_0010, 8'hA5);
    do_read(8'b1100_1101, 8'h3F);
    do_read(8'b0110_1010, 8'h7E);
    $finish;
  end

  always @(posedge clk)
    $display("%0t\tread_en=%b data_in=%b data_out=%b addr_out=%h chip_finish=%b",
             $time, read_en, data_in, data_out, address_out, chip_finish);
endmodule
