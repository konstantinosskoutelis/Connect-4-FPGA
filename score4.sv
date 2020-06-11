module score4 (
	input  logic clk,
	input  logic rst,

	input  logic left,
	input  logic right,
	input  logic put,
	
	output logic player,
	output logic invalid_move,
	output logic win_a,
	output logic win_b,
	output logic full_panel,

	output logic hsync,
	output logic vsync,
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue	
);
//TODO 
// 1. Sprites - 1bit
// 2. Winner change color 
// 3. VGA columns correction

// Pulse Inputs
logic left_pulse, right_pulse, put_pulse;

inputs_debounced inputs(
	.clk         (clk),
	.rst   		    (rst),
	.left  		    (left),
	.right 		    (right),
	.put   		    (put),
	.left_pulse  (left_pulse),
	.right_pulse (right_pulse),
	.put_pulse   (put_pulse)
);


// Game State
//logic[10:0][12:0][1:0] panel;//tha to allakso
logic[5:0][6:0][1:0] panel;
logic[6:0][2:0] position;
logic[6:0] play;
logic turn;
assign player = turn;

// Play & Turn Update
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    play <= 7'b0000001;
    turn <= 0;
  end else begin
		//Circular rotation of active column ( OUT OF BORDERS Scenario ) 
    play <= (left_pulse&~play[0])?   play>>1:
            (left_pulse&play[0])?   7'b1000000:
            (right_pulse&~play[6])?  play<<1:
            (right_pulse&play[6])?  7'b0000001:
            play;
    turn <= (put_pulse|invalid_move)? ~turn:
            turn;
  end
end

logic[5:0][6:0][2:0] test_a;
logic[5:0][6:0][2:0] test_b;

// Panel & Position Update
// Using our 6x7x2 flip-flops Grid to store information about the tokens' placement for both players
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    panel <= 0;
    position <= 0;
    invalid_move <= 0;
	 win_a <= 0;
    win_b <= 0;
  end else begin
    invalid_move <= 0;
    if(put_pulse) begin
      case(play)
        7'b0000001: begin
          if (position[0]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[0]][0][turn] <= 1'b1;
            position[0] <= position[0] + 1'b1;
          end
        end
        7'b0000010: begin
          if (position[1]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[1]][1][turn] <= 1'b1;
            position[1] <= position[1] + 1'b1;
          end
        end
        7'b0000100: begin
          if (position[2]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[2]][2][turn] <= 1'b1;
            position[2] <= position[2] + 1'b1;
          end
        end
        7'b0001000: begin
          if (position[3]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[3]][3][turn] <= 1'b1;
            position[3] <= position[3] + 1'b1;
          end
        end
        7'b0010000: begin
          if (position[4]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[4]][4][turn] <= 1'b1;
            position[4] <= position[4] + 1'b1;
          end
        end
        7'b0100000: begin
          if (position[5]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[5]][5][turn] <= 1'b1;
            position[5] <= position[5] + 1'b1;
          end
     	  end
     	  7'b1000000: begin
     	    if (position[6]==6) begin
            invalid_move <= 1;
          end else begin
            panel[position[6]][6][turn] <= 1'b1;
            position[6] <= position[6] + 1'b1;
          end
   	    end
 	    endcase
 	  end
	  //add other always ff
	  if (~win_a && ~win_b) begin
		win_a <= |test_a;
		win_b <= |test_b;
		//if i kai j
		  //Horizontal coloring
		for (int i=0;i<=5;i++) begin
			for (int j=0;j<=3;j++) begin
				if(test_a[i][j][0] || test_b[i][j][0]) begin
					panel[i][j]   <= 2'b11;
					panel[i][j+1] <= 2'b11;
					panel[i][j+2] <= 2'b11;
					panel[i][j+3] <= 2'b11;
				end				
			end
		end
		
		//Vertical coloring			
		for (int i=0;i<=2;i++) begin
		  for (int j=0;j<=6;j++) begin
			 if(test_a[i][j][1] || test_b[i][j][1]) begin
				panel[i][j]   <= 2'b11;
				panel[i+1][j] <= 2'b11;
				panel[i+2][j] <= 2'b11;
				panel[i+3][j] <= 2'b11;
			 end			 
		  end
		end
		
		//Diagonal
		for (int i=0;i<=2;i++) begin
		  for (int j=3;j>=0;j--) begin
			 if(test_a[i][j][2] || test_b[i][j][2]) begin
				if(i<=2) begin 
				  panel[i][j]     <= 2'b11;
				  panel[i+1][j+1] <= 2'b11;
				  panel[i+2][j+2] <= 2'b11;
				  panel[i+3][j+3] <= 2'b11;
				end   
			 end
		  end
		end
		
		for (int i=3;i<=5;i++) begin
			for (int j=0;j<=3;j++) begin
			  if(test_a[i][j][2] || test_b[i][j][2]) begin
				 if(i>2) begin 
					panel[i][j]     <= 2'b11;
					panel[i-1][j+1] <= 2'b11;
					panel[i-2][j+2] <= 2'b11;
					panel[i-3][j+3] <= 2'b11;
				 end 				
			  end
			end
		end	      
	 end
  end
end

// Full Panel
logic[6:0] full_col;
always_comb begin
  for(int i=0;i<=6;i=i+1)
    full_col[i] = (position[i]==6)? 1'b1: 1'b0;
end
assign full_panel = &full_col;

always_comb begin
  test_a = '0;
  test_b = '0;
  // Horizontal
  for (int i=0;i<=5;i++) begin
    for (int j=0;j<=3;j++) begin
      test_a[i][j][0] = (panel[i][j][0]&panel[i][j+1][0]&panel[i][j+2][0]&panel[i][j+3][0]);
      test_b[i][j][0] = (panel[i][j][1]&panel[i][j+1][1]&panel[i][j+2][1]&panel[i][j+3][1]);
    end
  end
  // Vertical
  for (int i=0;i<=2;i++) begin
    for (int j=0;j<=6;j++) begin
      test_a[i][j][1] = panel[i][j][0]&panel[i+1][j][0]&panel[i+2][j][0]&panel[i+3][j][0];
      test_b[i][j][1] = panel[i][j][1]&panel[i+1][j][1]&panel[i+2][j][1]&panel[i+3][j][1];
    end
  end
  // Diagonal
  for (int i=0;i<=2;i++) begin
    for (int j=3;j>=0;j--) begin
      test_a[i][j][2] = panel[i][j][0]&panel[i+1][j+1][0]&panel[i+2][j+2][0]&panel[i+3][j+3][0];
      test_b[i][j][2] = panel[i][j][1]&panel[i+1][j+1][1]&panel[i+2][j+2][1]&panel[i+3][j+3][1];
    end
  end
  for (int i=3;i<=5;i++) begin
    for (int j=0;j<=3;j++) begin
      test_a[i][j][2] = panel[i][j][0]&panel[i-1][j+1][0]&panel[i-2][j+2][0]&panel[i-3][j+3][0];
      test_b[i][j][2] = panel[i][j][1]&panel[i-1][j+1][1]&panel[i-2][j+2][1]&panel[i-3][j+3][1];
    end
  end
end




// VGA Driver
logic[1:0] winner;
assign winner = {win_b, win_a};

PanelDisplay VGA(
	.clk         (clk),
	.rst   		    (rst),
	.panel       (panel),
	.play        (play),
	.player      (player),
	.winner      (winner),
	.hsync 		    (hsync),
	.vsync 		    (vsync),
	.red   		    (red),
	.green 		    (green),
	.blue  		    (blue)
);

endmodule