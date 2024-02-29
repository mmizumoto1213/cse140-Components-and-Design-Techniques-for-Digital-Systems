// micro-program counter, asynchronous reset
// Active high load
// Active low increment
module upcreg(
  input              clk,
  input              reset,
  input              load_incr,
  input [4:0]        upc_next,
  output logic [4:0] upc);

  always_ff @ (posedge clk, posedge reset) begin
// fill in guts
//   if(...) upc <= ...; else if(...) upc <= ...; else ... 
//   reset    load_incr	    upc
//     1		1			 0
//	1		0            0
//	   0		1		   upc_next
//	   0	    0          upc+1

    //$display("upcreg");

if (reset) begin
    upc <= 0;
end
else if (load_incr) begin
    upc <= upc_next;
end
else if (!load_incr) begin
    upc <= upc+1;
end
  end
endmodule    