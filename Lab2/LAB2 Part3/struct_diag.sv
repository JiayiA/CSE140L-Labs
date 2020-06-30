// CSE140L  Fall 2019
// see Structural Diagram in Lab2.pdf
module struct_diag(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Secadv,
		Minadv,
		Hrsadv,
		Dayadv,
		Yearadv,
		Alarmon,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 
    M1disp, M0disp, H1disp, H0disp, D1disp, D0disp, Date1disp, Date0disp, Month1disp, Month0disp,
  output logic Buzz);	  // alarm sounds
  logic[6:0] TSec, TMin, THrs, TDay, AMin, AHrs, dateY, monthY;
  logic[6:0] Min, Hrs, Day, Date, Month;
  logic[8:0] TYear;
  logic Szero, Mzero, Hzero, Dzero, Yzero, TSen, TMen, THen, TDen, TYen, AMen, AHen, BuzzAND; 

// free-running seconds counter
  ct_mod60 Sct(
    .clk(Pulse), .rst(Reset), .en(TSen), .ct_out(TSec), .z(Szero)
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
// date counter -- runs at 1/24 hours
  ct_mod365 Yct(
   .clk(Pulse), .rst(Reset), .en(TYen), .datyear(TYear), .z(Yzero), .date(dateY), .month(monthY)
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
	
	lcd_int Datedisp(
	 .bin_in (Date),
	.Segment1 (Date1disp),
	.Segment0 (Date0disp)
	);
	
	lcd_int Monthdisp(
	 .bin_in (Month),
	.Segment1 (Month1disp),
	.Segment0 (Month0disp)
	);

// buzz off :)
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tday(TDay), .buzz(BuzzAND)
	);
	
	assign Buzz = Alarmon & BuzzAND;
	
	assign AHen = Hrsadv & Alarmset;
	
	assign AMen = Alarmset & Minadv; 
	
	always_comb begin
	  if(Secadv == 1)
	    TSen = 1;
	  else
	    TSen = 0;
   end
	

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
	  if((Timeset & Yearadv) == 1)
	    TYen = 1;
	  else
	    TYen = Hzero;
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
	 
	//Logic for display ?
	always_comb begin
	  if((Alarmset) == 1) begin
	    Date = 0;
		 Month = 0;
	  end
	  else begin
	    Date = dateY;
		 Month = monthY; 
	  end
	end
	

endmodule