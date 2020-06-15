module PanelDisplay (
  input  logic clk,
  input  logic rst,
  
  input logic[5:0][6:0][1:0] panel,
  input logic[6:0] play,
  input logic player,
  input logic[1:0] winner,

  output logic hsync,
  output logic vsync,
  output logic [3:0] red,
  output logic [3:0] green,
  output logic [3:0] blue  
);

//Pixel clock
logic enable;
always_ff@(posedge clk ,negedge rst)
begin
  if(!rst)
    enable <= '0;
  else
    enable <= !enable;
end

// Horizontal (pixel) counter
logic [9:0] h_counter;
logic h_limit; // 799
assign h_limit = &h_counter[4:0] & &h_counter[9:8]; 
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    h_counter <= '0;
  end else begin
    if (enable) begin
      if (h_limit) begin
          h_counter <= '0;
      end else begin
          h_counter <= h_counter + 1'b1;
      end
    end
  end
end

// Vertical (line) counter
logic [9:0] v_counter;
logic v_limit; // 526
assign v_limit = &v_counter[3:1] & v_counter[9]; 
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    v_counter <= '0;
  end else begin
    if (enable & h_limit) begin
      if (v_limit) begin
          v_counter <= '0;
      end else begin
          v_counter <= v_counter + 1'b1;
      end
    end
  end
end

//hsync & vsync
assign hsync = (h_counter >= 656 && h_counter <= 751)? '0 : '1;
assign vsync = (v_counter >= 491 && v_counter <= 492)? '0 : '1;

// Color mapping
logic[2:0] rgb;
assign red = {4{rgb[2]}};
assign green = {4{rgb[1]}};
assign blue = {4{rgb[0]}};

// Sprites
logic[12:0] t_addr;
logic t_data;
token_sprite token(
  .addr   (t_addr),
  .data   (t_data)
);
logic[12:0] w_addr;
logic w_data;
winner_sprite win(
  .addr   (w_addr),
  .data   (w_data)
);


//coloring
localparam offset = 60;
int v_start;
int h_start;

always_comb begin
  w_addr = ((v_counter-20)*90)+(h_counter-530);
  // Borders & background - check
  if (v_counter>=440 || h_counter>=630 || v_counter<10 || h_counter<10) begin
    rgb = 3'b000;
  end else if (h_counter>=510 && h_counter<520) begin
    rgb = 3'b000;
  end else if (h_counter>=530 && h_counter<620 && v_counter>=20 && v_counter<74) begin //SCOREBOARD    
    if (w_data) begin
      case(winner)
        2'b01: begin
          rgb = 3'b010;
        end
        2'b10: begin
          rgb = 3'b100;
        end
        default: begin 
          rgb = 3'b110;
        end
      endcase
    end else begin //ADDED ELSE BLOCK
      rgb = 3'b001;
    end
  end else begin
    rgb = 3'b001;    
  end
  
  // Game panel 
  t_addr = 0;
  for (int i=0; i<=5; i++) begin
    v_start = 20+(70*i);
    if(v_counter>=v_start && v_counter<v_start+offset) begin
      for (int j=0; j<=6; j++) begin
        h_start = 20+(70*j);
        if(h_counter>=h_start && h_counter<h_start+offset) begin  
          t_addr = ((v_counter-v_start)*60)+(h_counter-h_start);         
          if (~t_data) begin
            rgb = {panel[5-i][j],1'b0};
          end
        end
      end
    end else begin 
     h_start = 0;
   end
  end
  
  // Player position - check
  if(v_counter>=(450) && v_counter<(470)) begin
    for (int j=0; j<=6; j++) begin
      if(h_counter>=(20+(70*j)) && h_counter<(20+(70*j)+offset)) begin
        if (play[j]==1'b1 && player==1'b0) begin
          rgb = 3'b010;
        end else if (play[j]==1'b1 && player==1'b1) begin
          rgb = 3'b100;
        end
      end
    end
  end
end

endmodule