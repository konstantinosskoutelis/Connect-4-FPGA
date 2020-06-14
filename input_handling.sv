// Reduced input data rate by 2^N
// One hot encoding for player's input

module input_handling
#(
  parameter inv = 1,
  parameter N = 6
)
(
  input logic clk,
  input logic rst,

  input logic left,
  input logic right,
  input logic put,

  output logic [2:0] lrp,
  output logic l_64,
  output logic r_64
);

// Reduced data rate
logic[N-1:0] counter;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    counter <= '0;
  end else begin
    counter <= counter + 1'b1;
  end
end
logic enable;
assign enable = &counter;
logic enable2;
assign enable2 = ~(|counter);

// Input from player - Left/Right/Put
logic left_synced;
input_sync #(.inv(inv)) left_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable),
  .signal_in(left),
  .signal_out(left_synced)
);
logic right_synced;
input_sync #(.inv(inv)) right_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable),
  .signal_in(right),
  .signal_out(right_synced)
);
logic put_synced;
input_sync #(.inv(inv)) put_button
(
  .clk(clk),
  .rst(rst),
  .enable(enable),
  .signal_in(put),
  .signal_out(put_synced)
);

// Pulse output
logic left_reg, right_reg, put_reg;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    left_reg <= '0;
    right_reg <= '0;
    put_reg <= '0;
  end else begin
    left_reg <= left_synced;
    right_reg <= right_synced;
    put_reg <= put_synced;
  end
end
logic left_pulse, right_pulse, put_pulse;
assign left_pulse = left_synced & ~left_reg;
assign right_pulse = right_synced & ~right_reg;
assign put_pulse = put_synced & ~put_reg;

// One hot encoding
assign lrp[2] = left_pulse;
assign lrp[1] = right_pulse & ~left_pulse;
assign lrp[0] = put_pulse & ~right_pulse & ~left_pulse;

// One hot pulse extension
logic left_hold, right_hold;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    left_hold <= '0;
    right_hold <= '0;
  end else begin
    if (enable2) begin
      left_hold <= left_pulse;;
      right_hold <= right_pulse & ~left_pulse;;
    end
  end
end
// One hot output for communication
assign l_64 = left_hold;
assign r_64 = right_hold;

endmodule

module tb;

// SIGNALS
logic clk;
logic rst;
logic left;
logic right;
logic put;
logic [2:0] lrp;
logic l_64;
logic r_64;

// Installation
input_handling #(
  .inv(1),
  .N(2)
) test_input (
  .clk(clk),
  .rst(rst),
  .left(left),
  .right(right),
  .put(put),
  .lrp(lrp),
  .l_64(l_64),
  .r_64(r_64)
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
  rst = 0;
  left = 1;
  right = 1;
  put = 1;
  repeat(2) @(posedge clk);
  rst <= 1;
  repeat(2) @(posedge clk);
  $display("~~~~~~~~ START ~~~~~~~~\n");
  left = 0;
  repeat(10) @(posedge clk);
  left = 1;
  repeat(10) @(posedge clk);
  right = 0;
  put = 0;
  repeat(10) @(posedge clk);
  right = 1;
  repeat(10) @(posedge clk);
  put = 1;
  repeat(10) @(posedge clk);
  left = 0;
  right = 0;
  repeat(10) @(posedge clk);
  left = 1;
  repeat(10) @(posedge clk);
  right = 1;
  repeat(10) @(posedge clk);
  $display("\n~~~~~~~~ END ~~~~~~~~");
  $finish;
end
endmodule