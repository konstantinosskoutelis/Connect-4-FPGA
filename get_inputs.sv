module get_inputs
#(
  parameter N = 6
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
      counter2 <= '0;
    end
  end
end

// Input from self
logic [2:0] lrp_edge;
input_sync left_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable2),
  .signal_in(left),
  .signal_out(lrp_edge[2])
);
input_sync right_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable2),
  .signal_in(right),
  .signal_out(lrp_edge[1])
);
input_sync put_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable2),
  .signal_in(put),
  .signal_out(lrp_edge[0])
);

// One-hot output
assign lrp_self[2] = lrp_edge[2];
assign lrp_self[1] = lrp_edge[1] & ~lrp_edge[2];
assign lrp_self[0] = lrp_edge[0] & ~lrp_edge[1] &~lrp_edge[2];

endmodule

module tb;

// SIGNALS
logic clk;
logic rst;
logic left1;
logic right1;
logic put1;
logic [2:0] lrp1;
logic left2;
logic right2;
logic put2;
logic [2:0] lrp2;
logic [2:0] lrp3;

// Installation
get_inputs #(
  .N(3)
) test_input1 (
  .clk(clk),
  .rst(rst),
  .left(left1),
  .right(right1),
  .put(put1),
  .lrp_self(lrp1),
  .left_data(lrp2[2]),
  .right_data(lrp2[1]),
  .receive_data(lrp2[0]),
  .lrp_opponent(lrp3)
);

get_inputs #(
  .N(3)
) test_input2 (
  .clk(clk),
  .rst(rst),
  .left(left2),
  .right(right2),
  .put(put2),
  .lrp_self(lrp2),
  .left_data(),
  .right_data(),
  .receive_data(),
  .lrp_opponent()
);


// 50MHz Clock
always begin
	clk = 1;
	#10ns;
	clk = 0;
	#10ns;
end

// Test case
  initial begin
  $timeformat(-9, 0, " ns", 6);
  rst = 1;
  left1 = 1;
  right1 = 1;
  put1 = 1;
  left2 = 1;
  right2 = 1;
  put2 = 1;
  repeat(2) @(posedge clk);
  rst = 0;
  repeat(2) @(posedge clk);
  rst = 1;
  repeat(4) @(posedge clk);
  $display("~~~~~~~~ START ~~~~~~~~\n");
  left2 = 0;
  left1 = 0;
  repeat(10) @(posedge clk);
  left2 = 1;
  left1 = 1;
  repeat(10) @(posedge clk);
  right2 = 0;
  put2 = 0;
  right1 = 0;
  put1 = 0;
  repeat(10) @(posedge clk);
  right2 = 1;
  right1 = 1;
  repeat(10) @(posedge clk);
  put2 = 1;
  put1 = 1;
  repeat(10) @(posedge clk);
  left2 = 0;
  right2 = 0;
  left1 = 0;
  right1 = 0;
  repeat(10) @(posedge clk);
  left2 = 1;
  left1 = 1;
  repeat(10) @(posedge clk);
  right2 = 1;
  right1 = 1;
  repeat(20) @(posedge clk);
  $display("\n~~~~~~~~ END ~~~~~~~~");
  $finish;
end
endmodule