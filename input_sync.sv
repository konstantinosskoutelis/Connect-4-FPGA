// Synchronizer for signals from
//      different clock domains
// Enable signal is used for a
//      slower input data rate

module input_sync
#(
  parameter inv = 1
)
(
  input logic clk,
  input logic rst,
  input logic enable,

  input logic signal_in,
  output logic signal_out
);

// Bit synchronizer & edge detector
logic[1:0] sync;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    sync <= '0;
  end else begin
    if (enable) begin
      if (inv) begin
        sync[1] <= ~signal_in;
      end else begin
        sync[1] <= signal_in;
      end
      sync[0] <= sync[1];
    end
  end
end

// Output signal
assign signal_out = sync[0];

endmodule