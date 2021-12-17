`default_nettype none 

module dot_product(v1, v2, out);
  parameter N = 32;
  parameter BITS = 8;
  parameter OUT_BITS = BITS * 4;

	input wire [N*BITS-1:0] v1, v2;
	output logic [N*OUT_BITS-1:0] out;  // 8 bit input produces 32 bit outputs

	generate
		genvar i;
		for (i = 0; i < N; i = i + 1) begin
			always_comb begin
				// Multiply over all values in the input arrays
				// [31:0], [63:32] ... = [7:0] * [7:0], [15:8] * [15:8] ...
				out[(OUT_BITS*(i+1))-1:OUT_BITS*i] =
					v1[(BITS*(i+1))-1:BITS*i] * v2[(BITS*(i+1))-1:BITS*i];
			end
		end
	endgenerate
endmodule

`default_nettype wire 
                      
