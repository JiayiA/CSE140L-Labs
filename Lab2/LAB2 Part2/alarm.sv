// CSE140 lab 1  Summer 2018
// drives buzzer if alarm setting matches current time
module alarm #(parameter NH=24, NS=60)(
  input[6:0] tmin,
                        amin,
  input[6:0] thrs,
  			               ahrs,
  input[6:0] tday,
  output logic          buzz
);

  always_comb
    buzz = tmin==amin && thrs==ahrs && tday != 5 && tday != 6;

endmodule