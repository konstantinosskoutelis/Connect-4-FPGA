module PanelDisplay (//OK Boomer
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

logic enable;
logic [9:0] count_horizontal;
logic [9:0] count_vertical;

//Pixel clock
always_ff@(posedge clk ,negedge rst)
begin
	if(!rst)
    enable <= 0;
	else
		enable <= !enable;
end

// Horizontal and Vertical pixel counters
always_ff @(posedge clk, negedge rst) begin
  if (!rst) begin
    count_horizontal <= 0;
    count_vertical <= 0;
  end else begin
    if (enable) begin
      case (count_horizontal)
        799: begin
          count_horizontal <= 0;
          case(count_vertical)
            523: begin
              count_vertical <= 0;
            end
            default begin
              count_vertical <= count_vertical + 1;
            end
          endcase
        end
        default begin
          count_horizontal <= count_horizontal + 1;
        end
      endcase
    end
  end
end

//hsync & vsync
always_comb begin
	if(count_horizontal >= 656 && count_horizontal <= 751)
		hsync=0;
	else
		hsync=1;
	if(count_vertical >= 491 && count_vertical <= 492)
		vsync=0;
	else
		vsync=1;
end

// Color mapping
logic[2:0] rgb;
color_palette CP(
  .rgb    (rgb),
  .red    (red),
  .green  (green),
  .blue   (blue)
  );

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
  w_addr = ((count_vertical-20)*90)+(count_horizontal-530);
  // Borders & background - check
  if (count_vertical>=440 || count_horizontal>=630 || count_vertical<10 || count_horizontal<10) begin
    rgb = 0;
  end else if (count_horizontal>=510 && count_horizontal<520) begin
    rgb = 0;
  end else if (count_horizontal>=530 && count_horizontal<620 && count_vertical>=20 && count_vertical<74) begin //SCOREBOARD        
    if (w_data) begin
      case(winner)
        2'b00: begin
          //rgb = {w_data,2'b10};
          rgb = 3'b110;
        end
        2'b01: begin
          rgb = 3'b010;
          //rgb = 3'b010;
        end
        2'b10: begin
          rgb = 3'b100;
          //rgb = 3'b100;
        end
      default: begin 
      rgb = {~w_data,2'b10};
      end
      endcase
    end else begin
      rgb = {w_data,2'b01};//Winner Sprite background Coloring  
    end
  end else begin
    rgb = 3'b001;		
  end
  
  // Game panel 
  t_addr = ((count_vertical-v_start)*60)+(count_horizontal-h_start);  
  for (int i=0; i<=5; i++) begin
    v_start = 20+(70*i);
    if(count_vertical>=v_start && count_vertical<v_start+offset) begin
      for (int j=0; j<=6; j++) begin
        h_start = 20+(70*j);
        if(count_horizontal>=h_start && count_horizontal<h_start+offset) begin          
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
  if(count_vertical>=(450) && count_vertical<(470)) begin
    for (int j=0; j<=6; j++) begin
      if(count_horizontal>=(20+(70*j)) && count_horizontal<(20+(70*j)+offset)) begin
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