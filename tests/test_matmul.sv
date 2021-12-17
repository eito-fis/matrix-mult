`timescale 1ns/1ps
`default_nettype none

module main;

localparam MAX_CYCLES = 384 * 2 + 1;

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

logic clk, rst;

wire [$clog2(M1_L)-1:0] m1_addr;
wire [M12_W-1:0] m1_data;

wire [$clog2(M2_L)-1:0] m2_addr;
wire [M12_W-1:0] m2_data;

logic [$clog2(M3_L)-1:0] m3_rd_addr;
wire [$clog2(M3_L)-1:0] m3_wr_addr;
wire [M3_W-1:0] m3_rd_data;
wire [M3_W-1:0] m3_wr_data;
wire m3_wr_ena;
wire valid;

// Input matricies
block_rom #(.L(M1_L), .W(M12_W), .INIT("memories/a.memh")) MAT_A(
	.addr(m1_addr), .data(m1_data)
);
block_rom #(.L(M2_L), .W(M12_W), .INIT("memories/b.memh")) MAT_B(
	.addr(m2_addr), .data(m2_data)
);

// Output matrix
block_ram #(.L(M3_L), .W(OUT_BITS)) MAT_C(
	.clk(clk), .rd_addr(m3_rd_addr), .rd_data(m3_rd_data),
	.wr_ena(m3_wr_ena), .wr_addr(m3_wr_addr), .wr_data(m3_wr_data)
);

// Validation matrix
logic [$clog2(M3_L)-1:0] mv_addr;
wire [M3_W-1:0] mv_data;
block_rom #(.L(M3_L), .W(OUT_BITS), .INIT("memories/c.memh")) MAT_V(
	.addr(mv_addr), .data(mv_data)
);

// Matmul!
matmul #(.A(A), .B(B), .C(C), .BITS(BITS)) MATMUL(
	.clk(clk), .rst(rst),
	.m1_addr(m1_addr), .m1_data(m1_data),
	.m2_addr(m2_addr), .m2_data(m2_data),
	.m3_wr_addr(m3_wr_addr), .m3_wr_data(m3_wr_data), .m3_wr_ena(m3_wr_ena),
	.valid(valid)
);

always #5 clk = ~clk;

int errors = 0;
initial begin
  $dumpfile("matmul.vcd");
  $dumpvars(0, main);

  clk = 0;
  rst = 1;
  repeat (2) @(negedge clk);
  rst = 0;
	@(negedge clk);

	while(~valid) begin
		// Change inputs at a negative edge to avoid setup issues.
		@(posedge clk);
		@(negedge clk);
	end

	for (int i = 0; i < M3_L; i = i + 1) begin
		m3_rd_addr = i;
		mv_addr = i;
		@(posedge clk);
		#5 assert(m3_rd_data === mv_data) else begin
			errors = errors + 1;
		end
		#5 $display("Calculated: %d | Correct: %d", m3_rd_data, mv_data);
		@(negedge clk);
	end

	if (errors !== 0) begin
		$display("---------------------------------------------------------------");
		$display("-- FAILURE                                                   --");
		$display("---------------------------------------------------------------");
		$display(" %d failures found!", errors);
	end else begin
		$display("---------------------------------------------------------------");
		$display("-- SUCCESS                                                   --");
		$display("---------------------------------------------------------------");
	end

  $finish;
end

endmodule
