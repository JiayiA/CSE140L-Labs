 // CSE140L -- lab 5
// applies done flag when cycle_ct = 255
module top_level5(
  input        clk, init, 
  output logic done);
  logic[15:0] cycle_ct = 0;
  logic[5:0] LFSR[64];               // LFSR states
  logic[5:0] LFSR_ptrn[6];           // the 6 possible maximal length LFSR patterns
  logic[5:0] taps;                   //    one of these 6 tap patterns
  logic[7:0] prel;                   // preamble length
  logic[5:0] lfsr_trial[6][7];       // 6 possible LFSR match trials, each 7 cycles deep
  int        km;                     // number of ASCII _ in front of decoded message
  assign LFSR_ptrn[0] = 6'h21;
  assign LFSR_ptrn[1] = 6'h2D;
  assign LFSR_ptrn[2] = 6'h30;
  assign LFSR_ptrn[3] = 6'h33;
  assign LFSR_ptrn[4] = 6'h36;
  assign LFSR_ptrn[5] = 6'h39;
  logic[7:0]  foundit;               // got a match for LFSR
  //Added logic below
  logic       entered;
  logic       write_en, km_en, entered_en;
  logic[7:0]  raddr,
              waddr;
  logic[5:0]  start;                 // LFSR feedback pattern temp register
  logic[7:0]  data_in;
  wire [7:0]  data_out;
  logic       LFSR_en, load_LFSR, load_Final;
  wire [5:0]  LFSR1, LFSR2, LFSR3, LFSR4, LFSR5, LFSR6, LFSRFinal; 

  dat_mem dm1(.clk,.write_en,.raddr,.waddr, .data_in, .data_out);               // instantiate data memory

  lfsr6 l1(.clk, .en(LFSR_en), .init(load_LFSR), .taps(LFSR_ptrn[0]), .start(lfsr_trial[0][0]), .state(LFSR1));
  lfsr6 l2(.clk, .en(LFSR_en), .init(load_LFSR), .taps(LFSR_ptrn[1]), .start(lfsr_trial[1][0]), .state(LFSR2));
  lfsr6 l3(.clk, .en(LFSR_en), .init(load_LFSR), .taps(LFSR_ptrn[2]), .start(lfsr_trial[2][0]), .state(LFSR3));
  lfsr6 l4(.clk, .en(LFSR_en), .init(load_LFSR), .taps(LFSR_ptrn[3]), .start(lfsr_trial[3][0]), .state(LFSR4));
  lfsr6 l5(.clk, .en(LFSR_en), .init(load_LFSR), .taps(LFSR_ptrn[4]), .start(lfsr_trial[4][0]), .state(LFSR5));
  lfsr6 l6(.clk, .en(LFSR_en), .init(load_LFSR), .taps(LFSR_ptrn[5]), .start(lfsr_trial[5][0]), .state(LFSR6));
  
  lfsr6 lfinal(.clk, .en(LFSR_en), .init(load_Final), .taps, .start, .state(LFSRFinal));
  
  always @(posedge clk) begin
    if(!init) cycle_ct <= cycle_ct + 1;	
	 else      cycle_ct <= 0; 
  end 
  
  
  always_comb begin
    //Default condition
	 taps       = 'b0;
	 start      = 'b0;
	 prel       = 'b0;
    km_en      = 'b0;
	 entered_en = 'b0;
	 write_en   = 'b0;
	 raddr      = 'b0;
	 waddr      = 'b0;
	 data_in    = 'b0;
	 LFSR_en    = 'b0;
	 load_LFSR  = 'b0;
	 load_Final = 'b0;
	 foundit    = 'b0;
	 
	 if(cycle_ct>=0 && cycle_ct<7) begin
	   raddr          = 64+cycle_ct;
	   LFSR[cycle_ct] = data_out[5:0]^6'h1f;
	 end
	 
	 else if(cycle_ct == 7) begin
	 	raddr    = 64;
      lfsr_trial[0][0] = data_out[5:0]^6'h1f;
      lfsr_trial[1][0] = data_out[5:0]^6'h1f;
      lfsr_trial[2][0] = data_out[5:0]^6'h1f;
      lfsr_trial[3][0] = data_out[5:0]^6'h1f;
      lfsr_trial[4][0] = data_out[5:0]^6'h1f;
      lfsr_trial[5][0] = data_out[5:0]^6'h1f; 
		load_LFSR        = 'b1;
	 end
	 
	 else if(cycle_ct>=8 && cycle_ct<15) begin
	   LFSR_en = 'b1;
      lfsr_trial[0][cycle_ct-8] = LFSR1;   
      lfsr_trial[1][cycle_ct-8] = LFSR2;   
      lfsr_trial[2][cycle_ct-8] = LFSR3;   
      lfsr_trial[3][cycle_ct-8] = LFSR4;   
      lfsr_trial[4][cycle_ct-8] = LFSR5;
      lfsr_trial[5][cycle_ct-8] = LFSR6;		  
	 end
	 
	 else if(cycle_ct == 15) begin
		for(int mm=0;mm<6;mm++) begin :ureka_loop
        $display("mm = %d  lfsr_trial[mm] = %h, LFSR[6] = %h",
			  mm, lfsr_trial[mm][6], LFSR[6]); 
		  if(lfsr_trial[mm][6] == LFSR[6]) begin
			 foundit = mm;
			 $display("foundit = %d LFSR[6] = %h",foundit,LFSR[6]);
			 taps       = LFSR_ptrn[foundit];
		    start      = lfsr_trial[foundit][0];
		    $display("foundit fer sure = %d",foundit);
		    load_Final = 'b1;
        end
		end :ureka_loop 
		$display("foundit for sure = %d",foundit);
    end
		  
    else if(cycle_ct>=16 && cycle_ct<77) begin
		  LFSR_en    = 'b1;
		  LFSR[cycle_ct-16] = LFSRFinal; 
	 end
		
	 else if(cycle_ct >= 78 && cycle_ct < 139) begin
		raddr    = cycle_ct-7;
		waddr    = cycle_ct-78;
		write_en = 'b1;
		data_in  = data_out^LFSR[cycle_ct-71];
	 end
	 
	 else if(cycle_ct >= 139 && cycle_ct < 200) begin
	     raddr = cycle_ct-139;
		  if(data_out == 8'h5f) km_en = 'b1;
	 end
	   
			 
    else if(cycle_ct >= 200 && cycle_ct < 261) begin
		  raddr    = cycle_ct-200+km;
		  waddr    = cycle_ct-200;
		  write_en = 'b1;
		  data_in  = data_out;
		  //$display("%dth core = %h",cycle_ct-131,data_in);
    end
			 
  end

  always @(posedge clk)
    if(km_en) begin
	   if(raddr <= km) km = km+1;
	 end

  //Generate the done flag
  always_comb
    done = (cycle_ct == 261);   // holds for two clocks

endmodule