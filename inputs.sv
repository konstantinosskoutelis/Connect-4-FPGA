module inputs
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

//Creating 1 bit signals,  which will act as input to our Connect 4 Game - thus replacing the keyboard
//We will implement a Rising Edge Detector for each one of the players' available moves (Left - Right - Put )
logic left_out;
debouncing left_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (left),
  .signal_out   (left_out)
);

logic right_out;
debouncing          right_b(
  .clk					(clk),
  .rst					(rst),
  .signal_in		(right),
  .signal_out 	(right_out)
);

logic           put_out;
debouncing          put_b(
  .clk					(clk),
  .rst					(rst),
  .signal_in		(put),
  .signal_out 	(put_out)
);

// Debouncing
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
// Output Signal
assign left_pulse = (|counter)? 1'b0 : left_out;
assign right_pulse = (|counter)? 1'b0 : right_out;
assign put_pulse = (|counter)? 1'b0 : put_out;

endmodule