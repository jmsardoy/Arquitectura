
class Masm:
    
    opcodes = {
                'add' : 0b000000,
                'sub' : 0b000000,
                'and' : 0b000000,
                'or'  : 0b000000,
                'xor' : 0b000000,
                'nor' : 0b000000,
                'slt' : 0b000000,
                'sll' : 0b000000,
                'srl' : 0b000000,
                'sra' : 0b000000,
                'sllv': 0b000000,
                'srlv': 0b000000,
                'srav': 0b000000,
                'addu': 0b000000,
                'subu': 0b000000,

                'lb'  : 0b100000,
                'lh'  : 0b100001,
                'lw'  : 0b100011,
                'lbu' : 0b100100,
                'lhu' : 0b100101,
                'sb'  : 0b101000,
                'sh'  : 0b101001,
                'sw'  : 0b101011,
                'sw'  : 0b101011,

                'addi': 0b001000,
                'andi': 0b001100,
                'ori' : 0b001101,
                'xori': 0b001110,
                'lui' : 0b001111,
                'slti': 0b001010,

                'beq' : 0b000100,
                'bne' : 0b000101,

                'j'   : 0b000010,
                'jal' : 0b000011,

                'jr'  : 0b000000,
                'jalr': 0b000000
    }

    functions = {
                'add' : 0b100000,
                'sub' : 0b100010,
                'and' : 0b100100,
                'or'  : 0b100101,
                'xor' : 0b100110,
                'nor' : 0b100111,
                'slt' : 0b101010,
                'sll' : 0b000000,
                'srl' : 0b000010,
                'sra' : 0b000011,
                'sllv': 0b000100,
                'srlv': 0b000110,
                'srav': 0b000111,
                'addu': 0b100001,
                'subu': 0b100011,

                'jr'  : 0b001000,
                'jalr': 0b001001
    }

    inst_type = {
                    'add' : 'r_type',
                    'sub' : 'r_type',
                    'and' : 'r_type',
                    'or'  : 'r_type',
                    'xor' : 'r_type',
                    'nor' : 'r_type',
                    'slt' : 'r_type',
                    'sll' : 'shamt_type',
                    'srl' : 'shamt_type',
                    'sra' : 'shamt_type',
                    'sllv': 'r_type',
                    'srlv': 'r_type',
                    'srav': 'r_type',
                    'addu': 'r_type',
                    'subu': 'r_type',

                    'lb'  : 'ls_type',
                    'lh'  : 'ls_type',
                    'lw'  : 'ls_type',
                    'lbu' : 'ls_type',
                    'lhu' : 'ls_type',
                    'sb'  : 'ls_type',
                    'sh'  : 'ls_type',
                    'sw'  : 'ls_type',
                    'sw'  : 'ls_type',

                    'addi': 'immed_type',
                    'andi': 'immed_type',
                    'ori' : 'immed_type',
                    'xori': 'immed_type',
                    'lui' : 'lui_type',
                    'slti': 'immed_type',

                    'beq' : 'immed_type',
                    'bne' : 'immed_type',

                    'j'   : 'j_type',
                    'jal' : 'j_type',

                    'jr'  : 'jr_type',
                    'jalr': 'jalr_type'
    }


    @classmethod
    def assembly(cls, asm_lines):
        bin_lines = []
        for asm_line in asm_lines:
            bin_lines.append(cls._parse(cls, asm_line))
        return bin_lines


    def _parse(self, asm_line):
        asm_line = asm_line.lower()
        instruction = asm_line.split()[0]
        parser = getattr(self, '_parse_'+self.inst_type[instruction])
        return parser(self, asm_line)


    def _parse_r_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rs = format(int(asm_split[2].replace('$', '')), '05b')
        rt = format(int(asm_split[3].replace('$', '')), '05b')
        rd = format(int(asm_split[1].replace('$', '')), '05b')
        shamt = format(0, '05b')
        funct = format(self.functions[asm_split[0]], '06b')
        parsed_inst = opcode + rs + rt + rd + shamt + funct
        return parsed_inst
        
    
    def _parse_ls_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rt = format(int(asm_split[1].replace('$', '')), '05b')
        offset, rs = asm_split[2].replace(')','').split('(')
        rs = format(int(rs.replace('$', '')), '05b')
        immediate = format(int(offset), '016b')
        parsed_inst = opcode + rs + rt + immediate
        return parsed_inst
        
        

    def _parse_immed_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rs = format(int(asm_split[2].replace('$', '')), '05b')
        rt = format(int(asm_split[1].replace('$', '')), '05b')
        immediate = format(int(asm_split[3]), '016b')
        parsed_inst = opcode + rs + rt + immediate
        return parsed_inst

    
    def _parse_shamt_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rs = format(0, '05b')
        rt = format(int(asm_split[2].replace('$', '')), '05b')
        rd = format(int(asm_split[1].replace('$', '')), '05b')
        shamt = format(int(asm_split[3].replace('$', '')), '05b')
        funct = format(self.functions[asm_split[0]], '06b')
        parsed_inst = opcode + rs + rt + rd + shamt + funct
        return parsed_inst

 
    def _parse_lui_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rs = format(0, '05b')
        rt = format(int(asm_split[1].replace('$', '')), '05b')
        immediate = format(int(asm_split[2]), '016b')
        parsed_inst = opcode + rs + rt + immediate
        return parsed_inst
        

    def _parse_j_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        immediate = format(int(asm_split[1]), '026b')
        parsed_inst = opcode + immediate
        return parsed_inst

    def _parse_jr_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rs = format(int(asm_split[1].replace('$', '')), '05b')
        rt = format(0, '05b')
        rd = format(0, '05b')
        shamt = format(0, '05b')
        funct = format(self.functions[asm_split[0]], '06b')
        parsed_inst = opcode + rs + rt + rd + shamt + funct
        return parsed_inst

    def _parse_jalr_type(self, asm_line):
        asm_line = asm_line.replace(',', '')
        asm_split = asm_line.split()
        opcode = format(self.opcodes[asm_split[0]], '06b')
        rs = format(int(asm_split[2].replace('$', '')), '05b')
        rt = format(0, '05b')
        rd = format(int(asm_split[1].replace('$', '')), '05b')
        shamt = format(0, '05b')
        funct = format(self.functions[asm_split[0]], '06b')
        parsed_inst = opcode + rs + rt + rd + shamt + funct
        return parsed_inst
