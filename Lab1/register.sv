// load and store register
// sequential NOT combinational
module register # (parameter N = 8)
   (input                clk,   // implied input wire
    input                load,
    input                clear,
    input        [N-1:0] in,
    output logic [N-1:0] out
    );
	 
  always_ff @ (posedge clk, posedge clear)    begin
// fill in guts
//  if(...) out <= ... ;          // use <= nonblocking assignment!
//  else if(...) out <= ... ;
//   clear   load    out
//     1       0      0	   (clear output)
//     1       1      0
//     0       0     hold  (no change in output)
//     0       1      in   (update output)


    //$display("register");

	
// Aside: What would be the impact of leaving posedge clear out of 
//  the sensitivity list? 
// If clear is active, reset the entire register to 0
    if (clear) begin
      out[N-1:0] <= 0;
    end
    // If only loadl is active, load the low bits
    else if (!clear & !load) begin
    // Do nothing
    end
    // If only loadh is active, load the high bits
    else if (!clear & load) begin
      out[N-1:0] <= in;
    end
end	
		
endmodule

