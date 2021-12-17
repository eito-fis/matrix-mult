import argparse
import numpy as np

def generate_fibonacci_rom(fn="memories/fibonacci.memh"):
    print(f"Writing fibonacci sequence to {fn}.")
    with open(fn, 'w') as f:
        for i in range(48):
            f.write("%08x\n" % fibonacci(i))
    print(f"Wrote 48 bytes to {fn}.")


def write_matrix(m, file_name, bits=8):
    is_iter = True
    try:
        iter(m[0])
    except TypeError:
        is_iter = False
    with open(file_name, 'w') as f:
        for row in m:
            if is_iter:
                f.write("".join([f"{v:0{bits//4}x}" for v in row]) + "\n")
            else:
                f.write(f"{row:0{bits//4}x}" + "\n")
    print(f"Wrote {m.shape} matrix to {file_name}")
    return m

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--a', type=int, default=16)
    parser.add_argument('--b', type=int, default=32)
    parser.add_argument('--c', type=int, default=24)
    args = parser.parse_args()

    a = np.random.randint(0, 255, size=(args.a, args.b), dtype=np.uint8)
    b = np.random.randint(0, 255, size=(args.b, args.c), dtype=np.uint8)
    c = np.matmul(a, b, dtype=np.uint32)
    write_matrix(a, "memories/a.memh")
    write_matrix(np.transpose(b), "memories/b.memh")
    write_matrix(c.flatten(), "memories/c.memh", bits=32)

if __name__ == "__main__":
    main()
