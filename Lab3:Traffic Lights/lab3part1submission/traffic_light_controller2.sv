// shell for advanced traffic light controller (stretch goal)
// CSE140L   Summer II  2019
// semi-independent operation of east and west straight and left signals
//  see assignment writeup

module traffic_light_controller(
  input clk,
        reset,
        ew_left_sensor,
        ew_str_sensor,		
        ns_sensor,
  output logic[1:0] ew_left_light,     
  		            ew_str_light,	   	
			        ns_light);	

  logic[3:0] present_state, next_state;
  logic[3:0] ctr;  //mod 10 counter
  logic[2:0] ctr5; //5-second special counter
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
      if(ctr_reset)    ctr <= 'b0;
      else if(ctr_adv) ctr <= ctr + 1;
		
		if(ctr5_reset)   ctr5 <= 'b0;
		else if(ctr5_adv) ctr5 <= ctr5 + 1;
    end 
 
  //Combination part of the state machine 
  always_comb begin
    next_state = 'b0000;
    ctr_reset  = 'b1;
	 ctr5_reset = 'b1;
    ctr_adv    = 'b0;
	 ctr5_adv   = 'b1;
    case(present_state)
      //all red state
      'b0000: if(ew_str_sensor==1) next_state = 'b0001;
              else if(ew_left_sensor==1) next_state = 'b0011;
              else if(ns_sensor==1) next_state = 'b0101;
      //green light for e/w str
      'b0001: begin
		       ctr_reset = 'b0;
             ctr_adv   = 'b1;
             if((ew_str_sensor==0 && ew_left_sensor==0 && ns_sensor==0) || (ew_str_sensor==0 && ctr<9)) begin
				   ctr5_reset = 'b0;
               ctr5_adv   = 'b1;
               if(ctr5<4) next_state = 'b0001; 
               else begin
					     next_state = 'b0010;
						  ctr5_reset = 'b1;
						  ctr_reset  = 'b1;
					end 
             end
             else if(ew_left_sensor==1 || ns_sensor == 1) begin
               if(ctr<9) next_state = 'b0001;
               else begin 
					     next_state = 'b0010;
						  ctr_reset = 'b1;
					end
             end 
             else next_state = 'b0001;
             end  
      //yellow light for e/w str
      'b0010: begin
		       if(ew_left_sensor==0 && ns_sensor == 0) begin
               ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0010;
               else begin 
				        next_state = 'b0000;
						  ctr_reset = 'b1;
				   end
				 end
				 else if(ew_left_sensor == 1 && ns_sensor == 0) begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0010;
               else begin 
				        next_state = 'b0111;
						  ctr_reset = 'b1;
				   end
				 end
				 else if(ns_sensor == 1 && ew_left_sensor == 0) begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0010;
               else begin 
				        next_state = 'b1000;
						  ctr_reset = 'b1;
				   end
				 end
				 else if(ns_sensor == 1 && ew_left_sensor == 1) begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0010;
               else begin 
				        next_state = 'b1001;
						  ctr_reset = 'b1;
				   end
			    end
             end 
      //green light for e/w left 
      'b0011: begin
		       ctr_reset = 'b0;
             ctr_adv   = 'b1;
             if((ew_str_sensor==0 && ew_left_sensor==0 && ns_sensor==0) || (ew_left_sensor==0 && ctr<9)) begin
				   ctr5_reset = 'b0;
               ctr5_adv   = 'b1;
               if(ctr5<4) next_state = 'b0011; 
               else begin 
					     next_state = 'b0100;
						  ctr5_reset = 'b1;
				        ctr_reset  = 'b1;
				   end 
             end
             else if(ew_str_sensor==1 || ns_sensor == 1) begin
               if(ctr<9) next_state = 'b0011;
               else begin 
					     next_state = 'b0100;
						  ctr_reset = 'b1;
					end 
             end 
             else next_state = 'b0011;
             end  
      //yellow light for e/w left 
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
				 else if(ns_sensor == 1 && ew_str_sensor == 1) begin
				   ctr_reset = 'b0;
					ctr_adv = 'b1;
					if(ctr<1) next_state = 'b0100;
					else begin
					   next_state = 'b1010;
						ctr_reset  = 'b1;
					end 
				 end 
				 else if(ns_sensor == 1 && ew_str_sensor == 0) begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0100;
               else begin 
				      next_state = 'b1000;
						ctr_reset  = 'b1;
               end
				 end
				 else if(ns_sensor == 0 && ew_str_sensor == 1) begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0100;
               else begin 
				      next_state = 'b0000;
						ctr_reset  = 'b1;
               end
				 end
				 end 
      //green light for ns (5-10 cycles)
      'b0101: begin
		       ctr_reset = 'b0;
             ctr_adv   = 'b1;
             if((ew_str_sensor==0 && ew_left_sensor==0 && ns_sensor==0) || (ns_sensor==0 && ctr<9)) begin
				   ctr5_reset = 'b0;
               ctr5_adv   = 'b1;
               if(ctr5<4) next_state = 'b0101; 
               else begin 
					     next_state = 'b0110;
						  ctr5_reset = 'b1;
						  ctr_reset  = 'b1;
					end
             end
             else if(ew_left_sensor==1 || ew_str_sensor == 1) begin
               if(ctr<9) next_state = 'b0101;
               else begin
					     next_state = 'b0110;
						  ctr_reset  = 'b1;
					end
             end 
             else next_state = 'b0101;
             end  
      //yellow light for ns (2 cycles) 
      'b0110: begin
             if(ew_left_sensor == 0)begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0110;
               else begin 
				        next_state = 'b0000;
						  ctr_reset  = 'b1;
				   end
				 end
				 else if(ew_left_sensor == 1 && ew_str_sensor == 1) begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0110;
               else begin 
				        next_state = 'b0000;
						  ctr_reset  = 'b1;
				   end
			    end
				 else if(ew_left_sensor == 1 && ew_str_sensor == 0)begin
				   ctr_reset = 'b0;
               ctr_adv   = 'b1;
               if(ctr<1) next_state = 'b0110;
               else begin 
				        next_state = 'b0111;
						  ctr_reset  = 'b1;
				   end
				 end
				 else if(ew_str_sensor == 1 && ew_left_sensor == 0)begin
				   ctr_reset = 'b0;
					ctr_adv   = 'b1;
					if(ctr<1) next_state = 'b100;
					else begin
					     next_state = 'b0000;
						  ctr_reset  = 'b1;
					end 
				 end
             end
		//Special case when there's traffic in left too 
		'b0111: next_state = 'b0011;
		//Special case when there's traffic in ns 
		'b1000: next_state = 'b0101;
		//Special case when there traffic in three direction going to left next
		'b1001: next_state = 'b0011;
		//Special case when there are traffic in three direction going to ns next
		'b1010: next_state = 'b0101;
    endcase
  end 

  //Combination output driver 
  //green = 10, yellow = 01, red = 00
  always_comb case(present_state)
    'b0000: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
    'b0001: {ew_str_light, ew_left_light, ns_light} = 6'b10_00_00;
    'b0010: {ew_str_light, ew_left_light, ns_light} = 6'b01_00_00;
    'b0011: {ew_str_light, ew_left_light, ns_light} = 6'b00_10_00;
    'b0100: {ew_str_light, ew_left_light, ns_light} = 6'b00_01_00;
    'b0101: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_10;
    'b0110: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_01;
	 //extra state to go to e/w left light
	 'b0111: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
	 'b1000: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
	 //extra state handling the ns light
	 'b1001: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
	 'b1010: {ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
  endcase  
	

endmodule 