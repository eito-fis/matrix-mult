`default_nettype none 

module matmul_n(
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
  
	// Iterate over all row / col combinations
	logic incr_ena;
	logic [$clog2(M1_L)-1:0] row;
	logic [$clog2(M2_L)-1:0] col;
  always_ff @(posedge clk) begin : row_col_incr 
    if (rst) begin
    	row <= 0;
			col <= 0;
			valid <= 0;
    end else if (~valid & incr_ena) begin
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

	// Process one element of the dot product at a time
	logic [$clog2(B):0] chunk;
	logic [BITS-1:0] m1_cell, m2_cell;
	logic [OUT_BITS-1:0] prod, accum;
	always_comb begin
		m1_cell = m1_data[chunk * BITS +: BITS];
		m2_cell = m2_data[chunk * BITS +: BITS];
		prod = m1_cell * m2_cell;
	end
	always_comb m3_wr_data = accum;

	// FSM to control when to increment and write vs accumilate
	enum logic {ACCUM, INCR} state;

	always_comb begin: FSM_COMB
		case (state)
			ACCUM: begin
				m3_wr_ena = 0;
				incr_ena = 0;
			end
			INCR: begin
				m3_wr_ena = 1;
				incr_ena = 1;
			end
			default: begin end
		endcase
	end

  always_ff @(posedge clk) begin : FSM
    if (rst) begin
			state <= ACCUM;
			chunk <= 0;
			accum <= 0;
    end else if (~valid) begin
			case (state)
				ACCUM: begin
					accum <= accum + prod;
					if (chunk == B - 1) begin
						chunk <= 0;
						state <= INCR;
					end else begin
						chunk <= chunk + 1;
					end
				end
				INCR: begin
					state <= ACCUM;
					accum <= 0;
				end
				default: begin end
			endcase
    end
  end  

endmodule

`default_nettype wire 
                      
