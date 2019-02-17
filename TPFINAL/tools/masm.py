from tables import INSTRUCTIONS, REGISTERS, ARG_REG, ARG_IMM

def format_bin32(i):
    return format(i, '#034b')

class Masm():
    def __init__(self, asm_file):
        self._parse(asm_file)

    def _parse(self, asm_file):
        for line in asm_file:
            bytecodeline = int()
            print(len(bytecodeline))
            sline = line.split()
            mnemonic = sline[0].lower()
            if mnemonic in INSTRUCTIONS:
                ins_data = INSTRUCTIONS[mnemonic]
                for index, arg in enumerate(ins_data["args"]):
                    if arg == ARG_REG:
                        reg = sline[index+1].strip(',')
                        if reg in REGISTERS:
                            print(reg)
                            bytecodeline = bytecodeline | ins_data["op"]
                        else:
                            raise Exception("Invalid register: " + reg)
                    elif arg == ARG_IMM:
                        imm = sline[index+1].strip(',')
                        print(imm)
            else:
                raise Exception("Invalid instruction: " + mnemonic)

            print(format_bin32(bytecodeline))
