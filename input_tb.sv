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
