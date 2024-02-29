// CSE140L  
// What does this do? 
// When does "z" go high? 
module ct_mod_D #()(
  input             clk, 
                    rst, 
                    en,
		    twelve,
		    t_one,
		    t_zero,
  output logic[6:0] N,
  output logic[6:0] ct_out,
  output logic      z);

  logic [6:0] next_ct;
/*  always_ff @(posedge clk)
    if(rst)
	  ct_out <= 0;
	else if(en)
	  ct_out <= (ct_out+1)%N;	  // modulo operator
    else 						  // optional
	  ct_out <= ct_out; 
*/

   always_ff @(posedge clk)     // sequential
     ct_out <= next_ct;    

   always_comb 	                // combo
     if(twelve)
	   N=12;
     	 else if(t_one)
	   N=31;
	 else if(t_zero)
	   N=30;
	 else
	   N=28;
   always_comb
     if(rst) 
	   next_ct = 0;
	 else if(en)
	   next_ct = (ct_out + 1)%N;
	 else 
	   next_ct = ct_out; 


/*
    else if(en)
	  if(ct_out==N-1)
	    ct_out <= 0;
	  else
	    ct_out <= ct_out+1

    always_ff @(posedge clk) a <= a+1;

     posedge clk arrives:   tempa = a+1;
	    complete all temps before moving on
	 a = tempa

	 in --> a --> b	--> c --> out
	 1	    1     0     0      0
	 0      1     1     0      0
	 0      0     1     1 

     c++    c=c+1   c<=c+1  
     
      if(c==d) ...	   if c.eq.d
      if(c<=d) ... 	   if c.le.d
        
	  assign c=c+1;    always_comb c = c+1; 

      always_comb begin
		#10ns c = c+1; 
      end


*/

  always_comb z = ct_out==(N-1);   // always @(*)   // always @(ct_out)

endmodule