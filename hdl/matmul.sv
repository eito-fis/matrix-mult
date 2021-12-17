`default_nettype none 

module matmul(
	clk, rst,
	m1_addr, m1_data,
	m2_addr, m2_data,
	m3_wr_addr, m3_wr_data, m3_wr_ena,
	valid
);
  parameter A = 16;
  parameter B = 32;
  parameter C = 24;
  parameter BITS = 8;
	parameter OUT_BITS = BITS * 4;

	parameter M1_L = A;
	parameter M2_L = C;
	parameter M12_W = B * BITS;
	parameter M3_L = A * C;
	parameter M3_W = OUT_BITS;
  
  input wire clk, rst;
	output logic valid;

	output logic [$clog2(M1_L)-1:0] m1_addr;
	input wire [M12_W-1:0] m1_data;
	output logic [$clog2(M2_L)-1:0] m2_addr;
	input wire [M12_W-1:0] m2_data;

	output logic [$clog2(M3_L)-1:0] m3_wr_addr;
	output logic [M3_W-1:0] m3_wr_data;
	output logic m3_wr_ena;
	assign m3_wr_ena = 1; // Writing on every clock cycle
  
	// Iterate over all row / col combinations
	logic [$clog2(M1_L)-1:0] row;
	logic [$clog2(M2_L)-1:0] col;
  always_ff @(posedge clk) begin : row_col_incr 
    if (rst) begin
    	row <= 0;
			col <= 0;
			valid <= 0;
    end else if (~valid) begin
			row <= row + 1;
			if (row == M1_L-1) begin  // Iterated over all rows, next col
				if (col == M2_L-1) begin  // Iterated over all cols, finish
					valid <= 1;
				end else begin
					col <= col + 1;
					row <= 0;
				end
			end
    end
  end  
	always_comb begin
		m1_addr = row;
		m2_addr = col;
		// The final RAM is flat, so we must convert 2D coords to flat coords
		m3_wr_addr = (row * C) + col;
	end

	wire [B*OUT_BITS-1:0] dot_product_out;
	dot_product #(.N(B), .BITS(BITS)) DOT_PROD(
		.v1(m1_data), .v2(m2_data), .out(dot_product_out)
	);
	tree_sum #(.N(B), .BITS(OUT_BITS)) TREE_SUM(
		.in_vals(dot_product_out), .out(m3_wr_data)
	);

endmodule

`default_nettype wire 
                      
