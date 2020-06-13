module PanelDisplay (
	input  logic clk,
	input  logic rst,
	
	input logic[5:0][6:0][1:0] panel,
	input logic[6:0] play,
	input logic player,
	input logic[1:0] winner,
);

logic[5:0][6:0][2:0] test;

always_comb begin
    test = 0;
    // Horizontal - 3 tokens
    for (int i=0;i<=5;i++) begin
      for (int j=0;j<=4;j++) begin
        test[i][j][0] = panel[i][j][0]&panel[i][j+1][0]&panel[i][j+2][0];
      end
    end
    // Vertical - 3 tokens
    for (int i=0;i<=3;i++) begin
      for (int j=0;j<=6;j++) begin
        test[i][j][1] = panel[i][j][0]&panel[i+1][j][0]&panel[i+2][j][0];
      end
    end
    // Diagonal
    for (int i=0;i<=2;i++) begin
      for (int j=3;j>=0;j--) begin
        test[i][j][2] = panel[i][j][0]&panel[i+1][j+1][0]&panel[i+2][j+2][0]&panel[i+3][j+3][0];
      end
    end
    for (int i=3;i<=5;i++) begin
      for (int j=0;j<=3;j++) begin
        test[i][j][2] = panel[i][j][0]&panel[i-1][j+1][0]&panel[i-2][j+2][0]&panel[i-3][j+3][0];
      end
    end
  end
  