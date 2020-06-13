module communa(
     input clk,
     input rst,
     output send,
     input receive,
     input button,//button => PUT 
     input left,right,     
     inout left_data,right_data	
 );
 
 
 logic receive_p;
 inputs receive_pulse(
   .clk          (clk),
   .rst          (rst),
   .signal_in    (receive),
   .pulse_out   (),
   .constant_out(receive_p) 
 );

 logic [9:0] counter;
 logic active;
 assign send = (active & ~receive_p);
 always_ff@(posedge clk, negedge rst) begin
   if (!rst) begin
     active <= '1;
   end else if(counter[5:3] == 0) begin
     case ({active,receive_p})
         2'b00: active <= 1;
         2'b11: active <= 0;
     endcase
    if(button & active)
      active <= ~active;
   end
 end
 
 always_ff@(posedge clk, negedge rst) begin
   if (!rst) begin
         counter[5:3] <= '0;
     end else begin
         counter[5:3] <= counter[5:3] +1;
         if(counter[5:3] == 6)begin 
             counter[5:3]<=0;
         end
     end	
 end
 
 always_comb begin 
     if(send) begin
         left_data = left;
         right_data = right;
     end else begin
         left_data = 'z;
         right_data = 'z;
     end
 end
 
 
 assign counter[1] = receive_p;
 assign counter[2] = active;
 
 assign counter[7] = right_data;
 assign counter[8] = send;
 assign counter[9] = left_data;
 
 endmodule
 