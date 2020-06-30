// testbench for lab2 -- alarm clock
`include "display_tb.sv"
module lab2_tb #(parameter NS = 60, NH = 24);
  logic Reset = 1,
        Clk = 0,
        Timeset = 0,
        Alarmset = 0,
		Minadv = 0,
		Hrsadv = 0,
                Dayadv = 0,
		Alarmon = 1,
		Pulse = 0;
  wire[6:0] S1disp, S0disp,
            M1disp, M0disp;
  wire[6:0] H1disp, H0disp;
  wire[6:0] D1disp, D0disp;
  wire Buzz;

  struct_diag sd(.*);
  initial begin
	#  2ns  Reset    = 0;
    display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
	#  1ns  Timeset  = 1;
	        Minadv   = 1;
	# 30ns  Minadv   = 0;
	        Hrsadv   = 1;
        # 7ns   Hrsadv   = 0;
                Dayadv   = 1;
        # 4ns   Timeset  = 0;
    display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
	#  1ns  Alarmset = 1;
                Hrsadv   = 1;
	#  8ns  Hrsadv   = 0;
	#  1ns  Minadv   = 1;
	#  1ns  Minadv   = 0;
	#  1ns  Alarmset = 0;
    display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
        # 1860ns display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
        # 84540ns display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
    for(int i=0; i<2; i++) begin
        # 1860ns display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
	# 84540ns  display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
    end
        # 1860ns display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
        # 1740ns display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .Buzz(Buzz));
  	#1500ns  $stop;
  end 
  always begin
    #500ps Pulse = 1;
    #500ps Pulse = 0;
  end

endmodule