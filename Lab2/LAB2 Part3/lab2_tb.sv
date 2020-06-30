// testbench for lab2 -- alarm clock
`include "display_tb.sv"
module lab2_tb #(parameter NS = 60, NH = 24);
  logic Reset = 1,
        Clk = 0,
        Timeset = 0,
        Alarmset = 0,
                Secadv = 0,
		Minadv = 0,
		Hrsadv = 0,
                Dayadv = 0,
                Yearadv = 0,
		Alarmon = 1,
		Pulse = 0;
  wire[6:0] S1disp, S0disp,
            M1disp, M0disp;
  wire[6:0] H1disp, H0disp;
  wire[6:0] D1disp, D0disp;
  wire[6:0] Date1disp, Date0disp;
  wire[6:0] Month1disp, Month0disp;
  wire Buzz;

  struct_diag sd(.*);
  initial begin
	#  2ns  Reset    = 0;
    #2ns
    display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .seg_l(Date1disp),
    .seg_m(Date0disp), .seg_n(Month1disp),
    .seg_o(Month0disp), .Buzz(Buzz));
	#  2ns  Timeset  = 1;
                Yearadv  = 1;
        # 119ns Yearadv  = 0;
                Timeset  = 0;
                Secadv   = 1;
    #2ns
    display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .seg_l(Date1disp),
    .seg_m(Date0disp), .seg_n(Month1disp),
    .seg_o(Month0disp), .Buzz(Buzz));
    # 30ns
    for(int i=0; i<2; i++) 
	# 86400ns  display_tb (.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .seg_j(D1disp),
    .seg_k(D0disp), .seg_l(Date1disp),
    .seg_m(Date0disp), .seg_n(Month1disp),
    .seg_o(Month0disp), .Buzz(Buzz));
  	#1500ns  $stop;
  end 
  always begin
    #500ps Pulse = 1;
    #500ps Pulse = 0;
  end

endmodule