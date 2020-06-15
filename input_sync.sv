module input_sync
#(
  parameter inv = 1'b1
)
(
  input logic clk,
  input logic rst,
  input logic enable,

  input logic signal_in,
  output logic signal_out
);

// Bit synchronizer & edge detector
logic [2:0] sync;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    sync <= {3{inv}};
  end else begin
    if (enable) begin
      sync[2] <= signal_in;
      sync[1] <= sync[2];
      sync[0] <= sync[1];
    end
  end
end

// Output signal
assign signal_out = ~sync[1] & sync[0];

endmodule

module edge_detect (
  input signal,
  input clk,
  input rst,

  output pulse
);

logic ff;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    ff <= 0;
  end else begin
    ff <= signal ;
  end
end

assign pulse = ~ff & signal;


endmodule