#!/usr/bin/python3

import sys
import os

from masm import Masm

BINARY_MODE = "binary"
TEST_MODE = "test"

MODES = {
    "binary": "wb",
    "test": "w"
}

def print_help():
    print(os.path.basename(__file__) + " <mode> </path/to/asm/file> </out/file/path>")
    print("Where mode: \n\t* test\n\t* binary")

def main(argv=sys.argv):
    mode = argv[1]
    asm_file_path = argv[2]
    out_file_path = argv[3]

    with open(asm_file_path, 'r') as asm_file:
        with open(out_file_path, MODES[mode]) as out_file:
            assembler = Masm(asm_file)


if __name__ == "__main__":

    main()
