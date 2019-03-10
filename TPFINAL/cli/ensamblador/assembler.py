#!/usr/bin/python3

import sys
import os

from masm import Masm

def main(argv=sys.argv):
    asm_file_path = argv[1]
    out_file_path = argv[2]

    with open(asm_file_path, 'r') as asm_file:
        bin_lines = Masm.assembly(asm_file.readlines())
    with open(out_file_path, 'w') as out_file:
        bin_lines = map(lambda x: x + '\n', bin_lines)
        out_file.writelines(bin_lines)


if __name__ == "__main__":
    main()
