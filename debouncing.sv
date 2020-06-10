module debouncing
#(
  parameter delay = 15
)
(
  input logic clk,
  input logic rst,

  input logic signal_in,

  output logic signal_out
);

// Bit Synchronizer
logic[1:0] sync;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    sync <= 2'b11;
  end else begin
    sync[1] <= signal_in;
    sync[0] <= sync[1];
  end
end

// Edge detector
logic signal_reg;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    signal_reg <= 1'b1;
  end else begin
    signal_reg <= sync[0];
  end
end

// Output SignalS
assign signal_out = ~sync[0] & signal_reg;

endmodule