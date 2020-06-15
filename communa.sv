module communication
(
    input logic clk,
    input logic rst,
    input logic receive,
    input logic turn,
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
    endcase
  end
end
 



endmodule
 