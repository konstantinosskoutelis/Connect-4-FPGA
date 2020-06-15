module communication
(
    input logic clk,
    input logic rst,
    input logic receive,
    input logic player,
    output logic send,
    output logic restart
 );


// Handshake principle ({send, receive}):
//    01 or 10: connection established
//          00: initial state
//          11: connection lost
always_ff@(posedge clk, negedge rst) begin
  if (!rst) begin
    send <= '0;
    restart <= '1;
  end else begin
    case ({send, receive})
      2'b11: begin
        send <= '0;
        restart <= '1;
      end
      2'b00: begin
        send <= turn;
      end
      default: begin
        send <= turn;
        restart <= 0;
      end
      end
    endcase
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
 


assign counter[1] = receive_p;
assign counter[2] = active;

assign counter[7] = right_data;
assign counter[8] = send;
assign counter[9] = left_data;

endmodule
 