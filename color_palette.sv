module color_palette(
  input logic[2:0] rgb,
  
  output logic[3:0] red,
  output logic[3:0] green,
  output logic[3:0] blue
);

//Since we are only using absolute values of RGB, as well as their combinations, we translate the 12bit information of a pixel's colour into a 3 bit one
  
assign red = {4{rgb[2]}};
assign green = {4{rgb[1]}};
assign blue = {4{rgb[0]}};
  
endmodule
