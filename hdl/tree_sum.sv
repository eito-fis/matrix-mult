`default_nettype none 

module tree_sum(in_vals, out);
  parameter N = 32;
  parameter BITS = 32;

	input wire [N*BITS-1:0] in_vals;
	output logic [BITS-1:0] out; 

	always_comb begin
		out =
			in_vals[0 +: BITS] + 
			in_vals[32 +: BITS] + 
			in_vals[64 +: BITS] + 
			in_vals[96 +: BITS] + 
			in_vals[128 +: BITS] + 
			in_vals[160 +: BITS] + 
			in_vals[192 +: BITS] + 
			in_vals[224 +: BITS] + 
			in_vals[256 +: BITS] + 
			in_vals[288 +: BITS] + 
			in_vals[320 +: BITS] + 
			in_vals[352 +: BITS] + 
			in_vals[384 +: BITS] + 
			in_vals[416 +: BITS] + 
			in_vals[448 +: BITS] + 
			in_vals[480 +: BITS] + 
			in_vals[512 +: BITS] + 
			in_vals[544 +: BITS] + 
			in_vals[576 +: BITS] + 
			in_vals[608 +: BITS] + 
			in_vals[640 +: BITS] + 
			in_vals[672 +: BITS] + 
			in_vals[704 +: BITS] + 
			in_vals[736 +: BITS] + 
			in_vals[768 +: BITS] + 
			in_vals[800 +: BITS] + 
			in_vals[832 +: BITS] + 
			in_vals[864 +: BITS] + 
			in_vals[896 +: BITS] + 
			in_vals[928 +: BITS] + 
			in_vals[960 +: BITS] + 
			in_vals[992 +: BITS];
	end
endmodule

`default_nettype wire 
                      
