module PISO (
  input  wire clk, shift, load, rst_n,
  input  wire [7:0] data_in,
  output reg  data_out
);
  reg [7:0] tmp;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tmp <= 8'b0; data_out <= 1'b0;
    end else if (load && !shift)
      tmp <= data_in;
    else if (shift && !load) begin
      data_out <= tmp[7];
      tmp <= {tmp[6:0], 1'b0};
    end else
      data_out <= 1'b0;
  end
endmodule

module Counter (
  input  wire clk, rst_n, en,
  output wire finish
);
  reg [2:0] q;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)  q <= 3'b000;
    else if (en) q <= q + 1'b1;
  end
  assign finish = (q == 3'b111);
endmodule

module fsm (
  input  wire clk, rst_n, read_en, finish,
  output wire load, shift
);
  localparam [1:0] IDLE = 2'b00, LOAD = 2'b01, SHIFT = 2'b10;
  reg [1:0] current_state, next_state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
  end

  always @* begin
    next_state = IDLE;
    case (current_state)
      IDLE:    next_state = read_en ? LOAD : IDLE;
      LOAD:    next_state = SHIFT;
      SHIFT:   next_state = finish ? IDLE : SHIFT;
      default: next_state = IDLE;
    endcase
  end

  assign load  = (current_state == LOAD);
  assign shift = (current_state == SHIFT) & ~finish;
endmodule

module Controller (
  input  wire clk, rst_n, read_en,
  output wire load, shift,
  output reg  chip_finish
);
  wire finish;
  reg  en;
  fsm     u_fsm (.clk(clk), .rst_n(rst_n), .read_en(read_en),
                 .finish(finish), .load(load), .shift(shift));
  Counter u_counter (.clk(clk), .rst_n(rst_n), .en(en), .finish(finish));

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin en <= 1'b0; chip_finish <= 1'b0; end
    else begin en <= shift; chip_finish <= finish; end
  end
endmodule

module NVM_reader (
  input  wire clk, rst_n, read_en,
  input  wire [7:0] data_in, address_in,
  output wire data_out,
  output wire [7:0] address_out,
  output wire chip_finish
);
  wire load, shift;
  Controller controller_inst (.clk(clk), .rst_n(rst_n), .read_en(read_en),
                              .load(load), .shift(shift), .chip_finish(chip_finish));
  PISO piso_inst (.clk(clk), .rst_n(rst_n), .shift(shift), .load(load),
                  .data_in(data_in), .data_out(data_out));
  assign address_out = load ? address_in : 8'h00;
endmodule
