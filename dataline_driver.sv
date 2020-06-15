module dataline_driver
(
  input logic send,
  input logic receive,
  input logic [1:0] lr_in,
  output logic [1:0] lr_out
);

assign lr_out = (send & ~receive) ? lr_in : 'z;

endmodule