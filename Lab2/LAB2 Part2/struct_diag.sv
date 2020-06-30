// CSE140L  Fall 2019
// see Structural Diagram in Lab2.pdf
module struct_diag(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Dayadv,
		Alarmon,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 
    M1disp, M0disp, H1disp, H0disp, D1disp, D0disp,
  output logic Buzz);	  // alarm sounds
  logic[6:0] TSec, TMin, THrs, TDay, AMin, AHrs;
  logic[6:0] Min, Hrs, Day;
  logic Szero, Mzero, Hzero, Dzero, TMen, THen, TDen, AMen, AHen, BuzzAND; 

// free-running seconds counter
  ct_mod60 Sct(
    .clk(Pulse), .rst(Reset), .en(1'b1), .ct_out(TSec), .z(Szero)
    );
// minutes counter -- runs at either 1/sec or 1/60sec
  ct_mod60 Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mzero)
    );
// hours counter -- runs at either 1/sec or 1/60min
  ct_mod24 Hct(
	.clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hzero)
    );
// days counter -- runs at 1/24hours
  ct_mod7 Dct(
   .clk(Pulse), .rst(Reset), .en(TDen), .ct_out(TDay), .z(Dzero)
	 );
	 
// alarm set registers -- either hold or advance 1/sec
  ct_mod60 Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z()
    ); 

  ct_mod24 Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z()
    ); 

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(
    .bin_in (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in (Min) ,
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);
	
	lcd_int Ddisp(
	 .bin_in (Day),
	.Segment1 (D1disp), 
	.Segment0 (D0disp)
	);

// buzz off :)
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tday(TDay), .buzz(BuzzAND)
	);
	
	assign Buzz = Alarmon & BuzzAND;
	
	assign AHen = Hrsadv & Alarmset;
	
	assign AMen = Alarmset & Minadv; 
	

   always_comb begin
     if((Timeset & Minadv) == 1)
	    TMen = 1;
	  else
	    TMen = Szero;
   end
	
	always_comb begin
	  if((Timeset & Hrsadv) == 1)
	    THen = 1;
	  else
	    THen = Mzero;
	end 
	
	always_comb begin
	  if((Timeset & Dayadv) == 1)
	    TDen = 1;
	  else 
	    TDen = Hzero;
	end
	
	always_comb begin 
	  if((Alarmset) == 1)
	    Hrs = AHrs;
	  else
	    Hrs = THrs;
	end 
	
	always_comb begin 
	  if((Alarmset) == 1)
	    Min = AMin;
	  else 
	    Min = TMin; 
	end 
	
	always_comb begin
	  if((Alarmset) == 1)
	    Day = 0;
	  else
	    Day = TDay;
	end

endmodule