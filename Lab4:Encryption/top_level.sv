// dummy shell for Lab 4
// CSE140L
module top_level #(parameter DW=8, AW=8, byte_count=2**AW)(
  input        clk, 
                en,
              init,
  output logic done);

// dat_mem interface
// you will need this to talk to the data memory
logic         write_en;        // data memory write enable        
logic[AW-1:0] raddr,           // read address pointer
              waddr;           // write address pointer
logic[DW-1:0] data_in;         // to dat_mem
wire [DW-1:0] data_out;        // from dat_mem
// LFSR control input and data output
logic         LFSR_en;         // 1: advance LFSR; 0: hold		
logic[   5:0] taps,            // LFSR feedback pattern temp register
              start;           // LFSR initial state temp register
logic         taps_en,         // 1: load taps register; 0: hold
              start_en,        //   same for start temp register
				  prelen_en;
logic         load_LFSR;       // copy taps and start into LFSR
wire [   5:0] LFSR;            // LFSR current value            
logic[   7:0] pre_len;         // preamble (_____) length           
logic[   7:0] scram;           // encrypted message
logic[   7:0] ct_inc;          // prog count step (default = +1) 
// instantiate the data memory 
dat_mem dm1(.clk, .write_en, .raddr, .waddr,
            .data_in, .data_out);
// instantiate the LFSR
lfsr6 l6(.clk, .en(LFSR_en), .init(load_LFSR),
         .taps, .start, .state(LFSR));

logic[7:0] ct;
// first tasks to be done: 
// 1) raddr = 62
//    taps <= data_out
// 2) raddr = 63
//    start <= data_out

// this can act as a program counter
always @(posedge clk) begin
  if(init)
    ct <= 0;
  else
	 ct <= ct + ct_inc;
end

// control decode logic (does work of instr. mem and control decode)
always_comb begin
// list defaults here; case needs list only exceptions
  write_en  = 'b0;         // data memory write enable        
  raddr     = 'b0;         // memory read address pointer
  waddr     = 'b0;         // memory write address pointer
  data_in   = 'b0;         // to dat_mem for store operations
  LFSR_en   = 'b0;         // 1: advance LFSR; 0: hold		
  taps_en   = 'b0;         // 1: load taps register; 0: hold
  start_en  = 'b0;         //   same for start temp register
  load_LFSR = 'b0;         // copy taps and start into LFSR
  prelen_en = 'b0;         // 1: load pre_len temp register; 0: hold
  ct_inc    = 'b1;         // PC normally advances by 1
  case(ct)
    0,1: begin   end       // no op to wait for things to settle from init
	 2:   begin             // load pre_len temp register
           raddr      = 'd61;
           prelen_en  = 'b1;
         end
    3:   begin             // load taps temp reg
           raddr     = 'd62;   
           taps_en   = 'b1;
         end               // load LFSR start temp reg
    4:   begin
           raddr     = 'd63;
           start_en  = 'b1;
         end
    5:   begin             // copy taps and start temps into LFSR
           load_LFSR = 'b1; 
         end    
  endcase
  /* What happens next?
   1)  for pre_len cycles, bitwise XOR ASCII _ = 0x5f with current
     LFSR state; prepend LFSR state with 2'b00 to pad to 8 bits
     write each successive result into dat_mem[64], dat_mem[65], etc.
     advance LFSR to next state while writing result  
   2) after pre_len operations, start reading data from dat_mem[0], [1], ...
     bitwise XOR each value w/ current LFLSR state
     store successively in dat_mem[64+pre_len+j], where j = 0, 1, ..., 49
     advance LFSR to next state while writing each result
     
You may want some sort of memory address counter or an adder that creates
an offset from the prog_counter.

Watch how the testbench performs Prog. 4. You will be doing the same 
operation, but at a more detailed, hardware level, instead of at the 
higher level the testbench uses.       
*/
  if(ct>=6 && ct<(6+pre_len)) begin
     waddr    = ct+58;
	  write_en = 'b1;
	  data_in  = LFSR^8'h5F; 
	  LFSR_en  = 'b1;
  end
  else if(ct>=(6+pre_len) && ct < (67+pre_len)) begin
      raddr     = ct-(6+pre_len);
		waddr     = 64+pre_len+(ct-(6+pre_len));
		write_en  = 'b1;
		data_in   = data_out^LFSR;
		LFSR_en   = 'b1;
  end 
end 


// load control registers from dat_mem 
always @(posedge clk)
  if(prelen_en) begin
    if(data_out <= 7) pre_len = 'd7;
	 else if(data_out >7) pre_len = data_out;  
  end                         // copy from data_mem[61] to pre_len reg.
  else if(taps_en)
    taps    <= data_out;      // copy from data_mem[62] to taps reg.
  else if(start_en)
    start   <= data_out;      // copy from data_mem[63] to start reg.


// my done flag goes high once every 64 clock cycles
// yours should at the completion of your encryption operation
//   may be more or fewer clock cycles than mine -- all OK 
// test bench waits for a done flag, so generate one somehow
assign done = (ct == 68+pre_len);

endmodule



						   