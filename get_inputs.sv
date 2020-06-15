module get_inputs
#(
  parameter N = 3
)
(
  input logic clk,
  input logic rst,

  input logic left,
  input logic right,
  input logic put,
  output logic [2:0] lrp_self,

  input logic left_data,
  input logic right_data,
  input logic receive_data,
  output logic [2:0] lrp_opponent
);

// Input from opponent
logic [2:0] lrp_data_edge;
input_sync #(.inv(1'b0)) left_dataline
(
  .clk(clk),
  .rst(rst),
  .enable(1'b1),
  .signal_in(left_data),
  .signal_out(lrp_data_edge[2])
);
input_sync #(.inv(1'b0)) right_dataline
(
  .clk(clk),
  .rst(rst),
  .enable(1'b1),
  .signal_in(right_data),
  .signal_out(lrp_data_edge[1])
);
input_sync #(.inv(1'b0)) receive_dataline
(
  .clk(clk),
  .rst(rst),
  .enable(1'b1),
  .signal_in(receive_data),
  .signal_out(lrp_data_edge[0])
);

// Extend opponent signals over 2^N cycles
// Synchronize self and opponent data rates
logic [N-1:0] counter;
logic enable;
assign enable = &counter;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    lrp_opponent <= '0;
    counter <= '0;
  end else begin
    counter <= counter + 1'b1;
    if (|lrp_data_edge | enable) begin
      lrp_opponent <= lrp_data_edge;
      counter <= '0;
    end
  end
end

// Input from self
logic [2:0] lrp_edge;
input_sync left_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable),
  .signal_in(left),
  .signal_out(lrp_edge[2])
);
input_sync right_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable),
  .signal_in(right),
  .signal_out(lrp_edge[1])
);
input_sync put_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable),
  .signal_in(put),
  .signal_out(lrp_edge[0])
);

// One-hot output
assign lrp_self[2] = lrp_edge[2];
assign lrp_self[1] = lrp_edge[1] & ~lrp_edge[2];
assign lrp_self[0] = lrp_edge[0] & ~lrp_edge[1] &~lrp_edge[2];

endmodule
