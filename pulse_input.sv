module inputs(
  input logic clk,
  input logic rst,
  input logic signal_in,
  output logic pulse_out,
  output logic constant_out
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

// Pulse Output
assign pulse_out = ~sync[0] & signal_reg;

//Constant Output
assign constant_out = sync[0];

endmodule