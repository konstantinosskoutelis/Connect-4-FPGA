module inputs_debounced //SKOUTELIS
#(
  parameter delay = 15
)
(
  input logic clk,
  input logic rst,
  
  input logic left,
  input logic right,
  input logic put,
  
  output logic left_pulse,
  output logic right_pulse,
  output logic put_pulse
);

// Synchronizer & Falling Edge Detector for each of the player's moves (Left - Right - Put)
logic left_out;
pulse_input left_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (left),
  .signal_out   (left_out)
);

logic right_out;
pulse_input right_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (right),
  .signal_out   (right_out)
);

logic put_out;
pulse_input put_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (put),
  .signal_out   (put_out)
);
// Debounce counter
logic[delay-1:0] counter;
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    counter <= '0;
  end else begin
    case (counter)
      0: begin
        if (left_out | right_out | put_out) begin
          counter[0] <= 1'b1;
        end
      end
      default: begin
        counter <= counter<<1;
      end
    endcase
  end
end

// Debouncing Output Signals
assign left_pulse = (|counter)? 1'b0 : left_out;
assign right_pulse = (|counter | left_pulse)? 1'b0 : right_out;
assign put_pulse = (|counter | left_pulse | right_pulse)? 1'b0 : put_out;

endmodule
