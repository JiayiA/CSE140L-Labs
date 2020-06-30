// CSE140L  Fall 2019
module ct_mod7(
  input clk, rst, en,
  output logic[6:0] ct_out,
  output logic      z);
  //logic[6:0] ctq;

  always_ff @(posedge clk)
    if(rst)
	  ct_out <= 0;
	else if(en)
	  ct_out <= (ct_out+1)%(7'd7);	  // modulo operator
	  
  //always_ff @(posedge clk)
    //if(rst)
	   //ctq <= 0;
	 //else
	   //ctq <= ct_out;
	  
  assign z = ct_out == 6;	  // always @(*)   // always @(ct_out)

endmodule



