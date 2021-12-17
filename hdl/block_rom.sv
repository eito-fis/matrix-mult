module block_rom(addr, data);

parameter W = 8; // Width of each row of  the memory
parameter L = 32; // Length fo the memory
parameter INIT = "zeros.memh";

input [$clog2(L)-1:0] addr;
output logic [W-1:0] data;

logic [W-1:0] rom [0:L-1];
initial begin
  $display("Initializing block rom from file %s.", INIT);
  $readmemh(INIT, rom); // Initializes the ROM with the values in the init file.
end

always_comb data = rom[addr];

endmodule
