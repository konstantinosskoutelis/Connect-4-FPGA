module inputs_debounced //SKOUTELIS
#(
  parameter delay = 15
)
(
  input logic clk,
  input logic rst,
  input logic receive,
  input logic turn,  
  input logic left, 
  input logic right,
  input logic put,  
  output logic send,
  inout left_data,right_data,	
  output logic left_pulse,
  output logic right_pulse,
  output logic put_pulse

);

communa cmn(
  .clk(clk),
  .rst(rst),
  .send(send),
  .receive(receive),
  .button(turn),
  .left(left),
  .right(right),
  .left_data(left_data),
  .right_data(right_data)
);

// Synchronizer & Falling Edge Detector for each of the player's moves (Left - Right - Put)
logic left_out;
inputs left_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (left),
  .pulse_out   (left_out),
  .constant_out() 
);

logic right_out;
inputs right_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (right),
  .pulse_out   (right_out),
  .constant_out() 
);

logic put_out;
inputs put_b(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (put),
  .pulse_out   (put_out),
  .constant_out() 
);
//communicated values
logic left_out2;
inputs left_b2(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (left),
  .pulse_out   (left_out2),
  .constant_out() 
);

logic right_out2;
inputs right_b2(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (right),
  .pulse_out   (right_out2),
  .constant_out() 
);

logic put_out2;
inputs put_b2(
  .clk          (clk),
  .rst          (rst),
  .signal_in    (put),
  .pulse_out   (put_out2),
  .constant_out() 
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
assign left_pulse = send ? ((|counter)? 1'b0 : left_out ) :  left_out2;
assign right_pulse =  send ? ((|counter | left_pulse)? 1'b0 : right_out ) : right_out2;
assign put_pulse = send ? ((|counter | left_pulse | right_pulse)? 1'b0 : put_out ) : put_out2;

endmodule
