// CSE140L  Fall 2019
module ct_mod365(
  input clk, rst, en,
  output logic[8:0] datyear,
  output logic      z,
  output logic[6:0] month,
  output logic[6:0] date);
  //logic[8:0] ctq;

   always_ff @(posedge clk) begin
    if(rst)
	  datyear <= 0;
	 else if(en)
	  datyear <= (datyear+1)%(9'd365);	  // modulo operator
	end
	
	always_ff @(posedge clk) begin
	 if(datyear<31) begin
      month = 1;
	   date = datyear+1;
    end 
    else if(datyear<(31+28)) begin
      month = 2;
	   date = (datyear - 30);
    end
    else if(datyear<(31+28+31)) begin
      month = 3;
  	   date = (datyear - (30+28));
    end 
    else if(datyear<(31+28+31+30)) begin
      month = 4;
	   date = (datyear - (30+28+31));
    end 
    else if(datyear<(31+28+31+30+31)) begin
      month = 5;
	   date = (datyear - (30+28+31+30));
    end
    else if(datyear<(31+28+31+30+31+30)) begin
      month = 6;
	   date = (datyear - (30+28+31+30+31));
    end 
    else if(datyear<(31+28+31+30+31+30+31)) begin
      month = 7;
	   date = (datyear - (30+28+31+30+31+30));
    end
    else if(datyear<(31+28+31+30+31+30+31+31)) begin
      month = 8;
	   date = (datyear - (30+28+31+30+31+30+31));
    end
    else if(datyear<(31+28+31+30+31+30+31+31+30)) begin
      month = 9;
	   date = (datyear - (30+28+31+30+31+30+31+31));
    end
    else if(datyear<(31+28+31+30+31+30+31+31+30+31)) begin
      month = 10;
	   date = (datyear - (30+28+31+30+31+30+31+31+30));
    end
    else if(datyear<(31+28+31+30+31+30+31+31+30+31+30)) begin
      month = 11;
	   date = (datyear - (30+28+31+30+31+30+31+31+30+31));
    end
    else if(datyear<(31+28+31+30+31+30+31+31+30+31+30+31)) begin
      month = 12;
	   date = (datyear - (30+28+31+30+31+30+31+31+30+31+30));
    end
  end
	  
  //always_ff @(posedge clk)
    //if(rst)
	   //ctq <= 0;
	 //else
	   //ctq <= datyear;
	  
  assign z = datyear == 364;	  // always @(*)   // always @(ct_out)
	 

endmodule

