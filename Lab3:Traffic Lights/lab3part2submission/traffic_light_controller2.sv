// shell for advanced traffic light controller (stretch goal)
// CSE140L   Summer II  2019
// semi-independent operation of east and west straight and left signals
//  see assignment writeup
module traffic_light_controller(
  input clk,
        reset,
        e_left_sensor,
        w_left_sensor,
        e_str_sensor,	
        w_str_sensor,	
        ns_sensor,
  output logic[1:0] w_left_light,     
  		            w_str_light,	
			        e_left_light,     
			        e_str_light,	
			        ns_light);

  logic[5:0] present_state, next_state;
  logic[3:0] ctr;  //mod 10 counter
  logic[2:0] ctr5; //special 5 counter
  logic      ctr_reset, ctr_adv;
  logic      ctr5_reset, ctr5_adv;

  //Sequential part of the state machine
  always_ff @(posedge clk)
    if(reset) begin
      present_state <= 'b0;
      ctr           <= 'b0;
		ctr5          <= 'b0;
    end
    else begin
      present_state <= next_state;
      if(ctr_reset)     ctr <= 'b0;
      else if(ctr_adv)  ctr <= ctr + 1;
		if(ctr5_reset)    ctr5 <= 'b0;
		else if(ctr5_adv) ctr5 <= ctr5 + 1;
    end 
 
  //Combination part of the state machine 
  always_comb begin
    next_state = 'b0000;
    ctr_reset  = 'b1;
    ctr_adv    = 'b0;
	 ctr5_reset = 'b1;
	 ctr5_adv   = 'b0;
    case(present_state)
      //all red states
      'b0000: if((e_str_sensor == 1 && w_str_sensor == 1) || (e_str_sensor == 1 && e_left_sensor == 0) 
		          || (w_str_sensor == 1 && w_left_sensor == 0)) next_state = 'b0101;
              else if(e_left_sensor == 1 && w_left_sensor == 1) next_state = 'b0111;
				  else if(e_str_sensor == 1 || e_left_sensor == 1)  next_state = 'b0001;
              else if(w_str_sensor == 1 || w_left_sensor == 1)  next_state = 'b0011;
              else if(ns_sensor==1)                             next_state = 'b1001;
      //green light for e str/left (5-10 cycles)
      'b0001: begin
		        ctr_reset = 'b0;
              ctr_adv   = 'b1;
              if((e_str_sensor == 0 && e_left_sensor == 0 && w_str_sensor == 0 && w_left_sensor == 0 && ns_sensor == 0)
				      || (e_str_sensor==0 && e_left_sensor==0 && ctr<9)) begin
                 ctr5_reset = 'b0;
                 ctr5_adv   = 'b1;
                 if(ctr5<4) next_state = 'b0001;
                 else begin
					       next_state = 'b0010;
							 ctr5_reset = 'b1;
							 ctr_reset  = 'b1;
				     end
              end 
              else if(w_str_sensor == 1 || w_left_sensor == 1 || ns_sensor == 1) begin
                 if(ctr<9) next_state = 'b0001;
                 else begin
					       next_state = 'b0010;
							 ctr_reset  = 'b1;
				     end
              end
              else next_state = 'b0001;
              end     
      //yellow light for e str/left (2 cycles)
      'b0010: begin
		         if(ns_sensor == 0) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0010;
                 else begin
					       next_state = 'b0000;
						    ctr_reset  = 'b1;
					  end 
				   end 
				   else begin
					  ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0010;
                 else begin
					       next_state = 'b1110;
						    ctr_reset  = 'b1;
					  end 
				   end 
              end 
      //green light for w str/left (5-10 cycles)
      'b0011: begin 
		        ctr_reset = 'b0;
              ctr_adv   = 'b1;
              if((e_str_sensor == 0 && e_left_sensor == 0 && w_str_sensor == 0 && w_left_sensor == 0 && ns_sensor == 0)
				      || (w_str_sensor==0 && w_left_sensor==0 && ctr<9) || ctr5 > 0) begin
                 ctr5_reset = 'b0;
                 ctr5_adv   = 'b1;
                 if(ctr5<4) next_state = 'b0011;
                 else begin
					       next_state = 'b0100;
							 ctr_reset  = 'b1;
							 ctr5_reset = 'b1;
					  end
              end 
              else if(e_str_sensor == 1 || e_left_sensor == 1 || ns_sensor == 1) begin
                 if(ctr<9) next_state = 'b0011;
                 else begin
					       next_state = 'b0100;
							 ctr_reset  = 'b1;
					  end
              end
              else next_state = 'b0011;
              end
      //yellow light for w str/left (2 cycles) 
      'b0100: begin
		        if(ns_sensor == 0) begin
                ctr_reset = 'b0;
                ctr_adv   = 'b1;
                if(ctr<1) next_state = 'b0100;
                else begin 
				         next_state = 'b0000;
						   ctr_reset  = 'b1;
                end
				  end
				  else begin
				    ctr_reset = 'b0;
                ctr_adv   = 'b1;
                if(ctr<1) next_state = 'b0100;
                else begin 
				         next_state = 'b1110;
						   ctr_reset  = 'b1;
                end
				  end
				  end
      //green light for e/2 str
      'b0101: begin 
		        ctr_reset = 'b0;
              ctr_adv   = 'b1;
              if((e_str_sensor == 0 && e_left_sensor == 0 && w_str_sensor == 0 && w_left_sensor == 0 && ns_sensor == 0)
				      || (e_str_sensor==0 && w_str_sensor==0 && ctr<9) || ctr5 > 0)begin
                 ctr5_reset = 'b0;
                 ctr5_adv   = 'b1;
                 if(ctr5<4) next_state = 'b0101;
                 else begin
					       next_state = 'b0110;
							 ctr5_reset = 'b1;
							 ctr_reset  = 'b1;
					  end
              end 
              else if(e_left_sensor == 1 || w_left_sensor == 1 || ns_sensor == 1) begin
                 if(ctr<9) next_state = 'b0101;
                 else begin 
					       next_state = 'b0110;
							 ctr_reset  = 'b1;
					  end
              end
              else next_state = 'b0101;
              end
      //yellow light for e/w str
      'b0110: begin
              if(ns_sensor == 0 && e_left_sensor == 0 && w_left_sensor == 0) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0110;
                 else begin
					       next_state = 'b0000;
							 ctr_reset  = 'b1;
					  end
              end 
              else if(e_left_sensor == 1 && w_left_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0110;
                 else begin
					       next_state = 'b1011;
							 ctr_reset  = 'b1;
					  end
              end
              else if(e_str_sensor == 1 || e_left_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0110;
                 else begin
					       next_state = 'b1100;
							 ctr_reset  = 'b1;
					  end
              end
              else if(w_str_sensor == 1 || w_left_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0110;
                 else begin
					       next_state = 'b1101;
							 ctr_reset  = 'b1;
					  end
              end
				  else if(ns_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b0110;
                 else begin
					       next_state = 'b1110;
							 ctr_reset  = 'b1;
					  end
              end
              end 
      //green light for e/w left 
      'b0111: begin 
		        ctr_reset = 'b0;
              ctr_adv   = 'b1;
              if((e_str_sensor == 0 && e_left_sensor == 0 && w_str_sensor == 0 && w_left_sensor == 0 && ns_sensor == 0)
				      || (e_left_sensor==0 && w_left_sensor==0 && ctr<9) || ctr5 > 0)begin
                 ctr5_reset = 'b0;
                 ctr5_adv   = 'b1;
                 if(ctr5<4) next_state = 'b0111;
                 else begin
					       next_state = 'b1000;
							 ctr5_reset = 'b1;
							 ctr_reset  = 'b1;
					  end
              end 
              else if(e_str_sensor == 1 || w_str_sensor == 1 || ns_sensor == 1) begin
                 if(ctr<9) next_state = 'b0111;
                 else begin
					       next_state = 'b1000;
							 ctr_reset  = 'b1;
					  end
              end
              else next_state = 'b0111;
              end
      //yellow light for e/w left 
      'b1000: begin
              if(ns_sensor == 0 || ((e_str_sensor == 1 || w_str_sensor == 1) && ns_sensor == 0)) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b1000;
                 else begin
					       next_state = 'b0000;
							 ctr_reset  = 'b1;
					  end
              end 
				  else if(ns_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b1000;
                 else begin
					       next_state = 'b1110;
							 ctr_reset  = 'b1;
					  end
              end
              else if(e_str_sensor == 1 || e_left_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b1000;
                 else begin
					       next_state = 'b1100;
							 ctr_reset  = 'b1;
					  end
              end
              else if(w_str_sensor == 1 || w_left_sensor == 1) begin
                 ctr_reset = 'b0;
                 ctr_adv   = 'b1;
                 if(ctr<1) next_state = 'b1000;
                 else begin
					       next_state = 'b1101;
							 ctr_reset  = 'b1;
					  end
              end
              end 
      //green light for ns (5-10 cycles)
      'b1001: begin 
		        ctr_reset = 'b0;
              ctr_adv   = 'b1;
              if((e_str_sensor == 0 && e_left_sensor == 0 && w_str_sensor == 0 && w_left_sensor == 0 && ns_sensor == 0)
				      || (ns_sensor==0 && ctr<9) || ctr5 > 0)begin
                 ctr5_reset = 'b0;
                 ctr5_adv   = 'b1;
                 if(ctr5<4) next_state = 'b1001;
                 else begin 
					       next_state = 'b1010;
							 ctr5_reset = 'b1;
							 ctr_reset  = 'b1;
					  end
              end 
              else if(e_left_sensor == 1 || w_left_sensor == 1 || e_str_sensor == 1 || w_str_sensor == 1) begin
                 if(ctr<9) next_state = 'b1001;
                 else begin
					       next_state = 'b1010;
							 ctr_reset  = 'b1;
					  end
              end
              else next_state = 'b1001;
              end
      //yellow light for ns (2 cycles) 
      'b1010: begin 
              if((e_str_sensor == 1 || w_str_sensor == 1)) begin
                ctr_reset = 'b0;
                ctr_adv   = 'b1;
                if(ctr<1) next_state = 'b1010;
                else begin
					       next_state = 'b0000;
							 ctr_reset  = 'b1;
					  end
              end
              else if(e_left_sensor == 1 && w_left_sensor == 1) begin
                ctr_reset = 'b0;
                ctr_adv   = 'b1;
                if(ctr<1) next_state = 'b1010;
                else begin
					       next_state = 'b1011;
							 ctr_reset  = 'b1;
					  end
              end
              else if(e_str_sensor == 1 || e_left_sensor == 1) begin 
                ctr_reset = 'b0;
                ctr_adv   = 'b1;
                if(ctr<1) next_state = 'b1010;
                else begin
					       next_state = 'b1100;
							 ctr_reset  = 'b1;
					  end
              end
              else if(w_str_sensor == 1 || w_left_sensor == 1) begin 
                ctr_reset = 'b0;
                ctr_adv   = 'b1;
                if(ctr<1) next_state = 'b1010;
                else begin
					       next_state = 'b1101;
							 ctr_reset  = 'b1;
					  end
              end
              end
      //all red state leading to e/w left directly
      'b1011: next_state = 'b0111;
      //all red state leading to e left/str directly
      'b1100: next_state = 'b0001;
      //all red state leading to w left/str directly
      'b1101: next_state = 'b0011;
      //all red state leading to ns directly
      'b1110: next_state = 'b1001;

    endcase
  end 

  //Combination output driver 
  //green = 10, yellow = 01, red = 00
  always_comb case(present_state)
    'b0000: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_00;
    'b0001: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b10_10_00_00_00;
    'b0010: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b01_01_00_00_00;
    'b0011: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_10_10_00;
    'b0100: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_01_01_00;
    'b0101: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b10_00_10_00_00;
    'b0110: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b01_00_01_00_00;
    'b0111: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_10_00_10_00;
    'b1000: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_01_00_01_00;
    'b1001: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_10;
    'b1010: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_01;
    'b1011: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_00;
	 'b1100: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_00;
	 'b1101: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_00;
    'b1110: {e_str_light, e_left_light, w_str_light, w_left_light, ns_light} = 10'b00_00_00_00_00;
  endcase


endmodule 