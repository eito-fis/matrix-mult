IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VIVADO=vivado -mode batch -source

.PHONY: clean

FILES=hdl/*

test_matmul: tests/test_matmul.sv $(FILES)
	${IVERILOG} $^ -o test_matmul.bin && ${VVP} test_matmul.bin

clean:
	rm -f *.bin *.vcd vivado*.log vivado*.jou vivado*.str
