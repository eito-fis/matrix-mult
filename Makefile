IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VIVADO=vivado -mode batch -source
A=16
B=32
C=24

.PHONY: clean

FILES=hdl/*

generate_memories:
	python generate_memories.py -a ${A} -b ${B} -c ${C}

test_matmul: tests/test_matmul.sv $(FILES) generate_memories
	${IVERILOG} $^ -o test_matmul.bin && ${VVP} test_matmul.bin

clean:
	rm -f *.bin *.vcd vivado*.log vivado*.jou vivado*.str
