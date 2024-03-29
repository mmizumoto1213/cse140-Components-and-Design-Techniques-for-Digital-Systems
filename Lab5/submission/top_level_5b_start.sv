// ECE260C -- lab 5 alternative DUT
// applies done flag when cycle_ct = 255
module top_level_5b(
  input          clk, init, 
  output logic   done);

// memory interface
  logic          wr_en;
  logic    [7:0] raddr, 
                 waddr,
                 data_in;
  logic    [7:0] data_out;             

// program counter
  logic[15:0] cycle_ct = 0;

// LFSR interface
  logic load_LFSR,
        LFSR_en;
  logic[5:0] LFSR_ptrn[6];           // the 6 possible maximal length LFSR patterns
  assign LFSR_ptrn[0] = 6'h21;
  assign LFSR_ptrn[1] = 6'h2D;
  assign LFSR_ptrn[2] = 6'h30;
  assign LFSR_ptrn[3] = 6'h33;
  assign LFSR_ptrn[4] = 6'h36;
  assign LFSR_ptrn[5] = 6'h39;
  logic[5:0] start;                  // LFSR starting state
  logic[5:0] LFSR_state[6];
  logic[5:0] match;					 // got a match for LFSR (one hot)
  logic[2:0] foundit;                // binary index equiv. of match
  logic[4:0] prelen;
  logic[15:0] t;
  logic added;
  int i;

// instantiate submodules
// data memory -- fill in the connections
  dat_mem dm1(.clk(clk),.write_en(wr_en),.raddr,.waddr(waddr),
       .data_in(data_in),.data_out(data_out));                   // instantiate data memory

// 6 parallel LFSRs -- fill in the missing connections
  lfsr6b l0(.clk(clk) , 
         .en   (LFSR_en)  ,            // 1: advance LFSR on rising clk
         .init (load_LFSR),	            // 1: initialize LFSR
         .taps (6'h21)     ,    // tap pattern 0
         .start(start) ,	            // starting state for LFSR
         .state(LFSR_state[0]));		   // LFSR state = LFSR output 

  lfsr6b l1(.clk(clk), .en(LFSR_en), .init(load_LFSR), .taps(6'h2D), .start(start), .state(LFSR_state[1]));
  lfsr6b l2(.clk(clk), .en(LFSR_en), .init(load_LFSR), .taps(6'h30), .start(start), .state(LFSR_state[2]));
  lfsr6b l3(.clk(clk), .en(LFSR_en), .init(load_LFSR), .taps(6'h33), .start(start), .state(LFSR_state[3]));
  lfsr6b l4(.clk(clk), .en(LFSR_en), .init(load_LFSR), .taps(6'h36), .start(start), .state(LFSR_state[4]));
  lfsr6b l5(.clk(clk), .en(LFSR_en), .init(load_LFSR), .taps(6'h39), .start(start), .state(LFSR_state[5]));
/* fill in the guts: continue with other 5 lfsr6b
*/


/* We need to advance the LFSR(s) once per clock cycle. 
Same with raddr, waddr, since we can physically do one memory read and/or write
per clock cycle. 
*/

// this block remaps a one-hot 6-bit code into a 3-bit binary count
// acts like a priority encoder from MSB to LSB 
/*
  always_comb case(match)
    6'b10_0000: foundit = 'd5;	    // because bit [5] was set
    // fill in the guts
    6'b01_0000: foundit = 'd4;
    6'b00_1000: foundit = 'd3;
    6'b00_0100: foundit = 'd2;
    6'b00_0010: foundit = 'd1;
    6'b00_0001: foundit = 'd0;
	default: foundit = 0;           // covers bit[0] match and no match cases
  endcase
*/

// program counter
// as in Lab 4, you can do the whole lab without any branches or jumps
  always @(posedge clk) begin  :clock_loop
    if(init) begin
      cycle_ct <= 'b0;
      match    <= 'b0;
	end
    else begin
	cycle_ct <= cycle_ct + 1;
	  if(cycle_ct== 9) begin			// last symbol of preamble
	    //raddr = 63 + cycle_ct;
	    //LFSR_state[6] = data_out[5:0] ^ 'b011111;
	    for(i=0; i<6; i++) begin
		if (start == LFSR_state[i]) begin
		  match[i] = 1;
		end			// which LFSR state conforms to our test bench LFSR? 
		// $display("The value of LFSR is %d", LFSR_state[i]);
	    end
          end
    end
  end  

  always_comb case(match)
    6'b10_0000: foundit = 'd5;	    // because bit [5] was set
    // fill in the guts
    6'b01_0000: foundit = 'd4;
    6'b00_1000: foundit = 'd3;
    6'b00_0100: foundit = 'd2;
    6'b00_0010: foundit = 'd1;
    6'b00_0001: foundit = 'd0;
	default: foundit = 0;           // covers bit[0] match and no match cases
  endcase

  always_comb begin 
//defaults
    load_LFSR = 'b0; 
    LFSR_en   = 'b0;   
    wr_en     = 'b0;
  if (added &&(t != cycle_ct)) begin 
	prelen = prelen + 1;
	//$display("The value of cycle is %d", cycle_ct);
  end
  case(cycle_ct)
	0: begin 
           raddr     = 'd64;   // starting address for encrypted data to be loaded into device
	   waddr     = 'd0;   // starting address for storing decrypted results into data mem
	     end		       // no op
	1: begin 
           load_LFSR = 'b1;	  // initialize the 6 LFSRs
           raddr     = 'd64;
	   start     = data_out[5:0] ^ 'b011111;
	     end		       // no op
	2  : begin				   
           LFSR_en   = 'b1;	   // advance the 6 LFSRs     
	   raddr     = 'd63 + cycle_ct;
	   data_in = data_out ^ LFSR_state[2];
	   // waddr     = 'd1;
         end
	3  : begin			       // training seq.	-- run LFSRs & advance raddr
	       //LFSR_en = 'b1;
		raddr     = 'd63 + cycle_ct;
	   	data_in = data_out ^ LFSR_state[2];
	       // waddr = 'd2;
		//prelen = 'b1;
		 end
	75  : begin
            done = 'b1;		// send acknowledge back to test bench to halt simulation; 
	     end
	default: begin	         // covers cycle_ct 4-71
	       LFSR_en = 'b1;
           //raddr = ; 
	   if (cycle_ct <= 8) begin
		raddr = 63 + cycle_ct - 1;
		start = data_out[5:0] ^ 'b011111;
		prelen = 9;
	   end
	   /* else if (prelen) begin
		raddr = cycle_ct + 63 - 2;
		data_in = data_out ^ LFSR_state[foundit];
		if (data_in != 95) begin
			prelen = 'b0;
			waddr cycle_ct - 8 - 2;
		end
		else begin
			prelen = cycle_ct;
		end
	   end */
           else begin   // turn on write enable
		wr_en = 'b1;
		raddr = cycle_ct + 63 - 2;
		data_in = data_out ^ LFSR_state[foundit];
		// raddr = cycle_ct - prelen - 1;
		if (data_in == 95) begin
			t = cycle_ct;
			added = 'b1;
		end
		else added = 'b0;
		// else waddr = cycle_ct - prelen;
		//$display("The value of cycle is %d The value of data_in is %d", cycle_ct, data_in);
		waddr = cycle_ct - prelen;
	    end
	end
//		   data_in = data_out^LFSR_state[foundit];
  endcase
		// else waddr = cycle_ct - prelen;
end

/*
    if(!init && initQ) begin :init_loop  // falling init
	  begin  :loop2			   
        for(int jl=0;jl<7;jl++)
	      LFSR[jl] =         dm1.core[64+jl][5:0]^6'h1f;
          lfsr_trial[0][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[1][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[2][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[3][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[4][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[5][0] = dm1.core[64][5:0]^6'h1f;
//          $display("trial 0 = %h",lfsr_trial[0][0]);
          for(int kl=0;kl<6;kl++) begin :trial_loop
            lfsr_trial[0][kl+1] = (lfsr_trial[0][kl]<<1)+(^(lfsr_trial[0][kl]&LFSR_ptrn[0]));   
            lfsr_trial[1][kl+1] = (lfsr_trial[1][kl]<<1)+(^(lfsr_trial[1][kl]&LFSR_ptrn[1]));   
            lfsr_trial[2][kl+1] = (lfsr_trial[2][kl]<<1)+(^(lfsr_trial[2][kl]&LFSR_ptrn[2]));   
            lfsr_trial[3][kl+1] = (lfsr_trial[3][kl]<<1)+(^(lfsr_trial[3][kl]&LFSR_ptrn[3]));   
            lfsr_trial[4][kl+1] = (lfsr_trial[4][kl]<<1)+(^(lfsr_trial[4][kl]&LFSR_ptrn[4]));   
            lfsr_trial[5][kl+1] = (lfsr_trial[5][kl]<<1)+(^(lfsr_trial[5][kl]&LFSR_ptrn[5]));   
            $display("trials %d %h %h %h %h %h %h    %h",  kl,
				 lfsr_trial[0][kl+1],
				 lfsr_trial[1][kl+1],
				 lfsr_trial[2][kl+1],
				 lfsr_trial[3][kl+1],
				 lfsr_trial[4][kl+1],
				 lfsr_trial[5][kl+1],
				 LFSR[kl+1]);			  
          end :trial_loop
		  for(int mm=0;mm<6;mm++) begin :ureka_loop
            $display("mm = %d  lfsr_trial[mm] = %h, LFSR[6] = %h",
			     mm, lfsr_trial[mm][6], LFSR[6]); 
		    if(lfsr_trial[mm][6] == LFSR[6]) begin
			  foundit = mm;
			  $display("foundit = %d LFSR[6] = %h",foundit,LFSR[6]);
            end
		  end :ureka_loop
		  $display("foundit fer sure = %d",foundit);								   
		  for(int jm=0;jm<63;jm++)
		    LFSR[jm+1] = (LFSR[jm]<<1)+(^(LFSR[jm]&LFSR_ptrn[foundit]));
          for(int mn=7;mn<64-7;mn++) begin  :first_core_write
		    dm1.core[mn-7] = dm1.core[64+mn-7]^{2'b0,LFSR[mn-7]};
			$display("%dth core = %h LFSR = %h",mn,dm1.core[64+mn-7],LFSR[mn-7]);
          end   :first_core_write
         #10ns;
         for(km=0; km<64; km++) begin
            if(dm1.core[km]==8'h5f) continue;
            else break;  
          end     
          $display("underscores to %d th",km);
          for(int kl=0; kl<64; kl++) begin
            dm1.core[kl] = dm1.core[kl+km];
		    $display("%dth core = %h",kl,dm1.core[kl]);
          end
	  end   :loop2
    end :init_loop
  end  :clock_loop

  always_comb
    done = &cycle_ct[6:0];   // holds for two clocks
*/
endmodule