import os, sys, inspect
from subprocess import call

current_dir = os.path.dirname(
                os.path.abspath(inspect.getfile(inspect.currentframe()))
              )
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0, parent_dir)

from mips_cli import MipsCLI
from ensamblador.masm import Masm


port = '/dev/ttyUSB1'
cli = MipsCLI(port)

def load_program(file_in):
    file_out = file_in.replace('.asm', '.mem')
    exit_code = call("../ensamblador/assembler.py %s %s"%(file_in, file_out),
                     shell=True)
    if exit_code == 0:
        with open(file_out) as fp:
            instructions = fp.readlines()
            instructions = map(lambda x: x.replace('\n', ''), instructions)
        cli.load_instructions(instructions)
        os.remove(file_out)

def make_signed(num, nbits):
    if num >= (1 << (nbits-1)):
        return num - (1 << nbits)
    else:
        return num

def make_unsigned(num, nbits):
    if num < 0:
        return (1 << nbits) + num
    else:
        return num



def test_stores():
    program_file = 'test_stores.asm'
    load_program(program_file)
    mips_info = cli.run()
    byte = 5
    hexa = (1<<8) + byte
    word = (1<<16) + hexa
    assert mips_info['memory_data'][0]['unsigned_int'] == word
    assert mips_info['memory_data'][1]['unsigned_int'] == hexa
    assert mips_info['memory_data'][2]['unsigned_int'] == byte


def test_loads():
    program_file = 'test_loads.asm'
    load_program(program_file)
    mips_info = cli.run()
    u_byte = 133
    byte = make_signed(u_byte, 8)
    u_hexa = (129<<8) + u_byte
    hexa = make_signed(u_hexa, 16)
    u_word = (1<<16) + u_hexa
    assert mips_info['register_file'][2]['signed_int'] == u_byte
    assert mips_info['register_file'][3]['signed_int'] == u_hexa
    assert mips_info['register_file'][4]['signed_int'] == u_word
    assert mips_info['register_file'][5]['signed_int'] == byte
    assert mips_info['register_file'][6]['signed_int'] == hexa


def test_r_type():
    program_file = 'test_r_type.asm'
    load_program(program_file)
    mips_info = cli.run()
    reg1 = 5
    reg2 = -7
    reg3 = 2
    u_reg1 = make_unsigned(reg1, 32)
    u_reg2 = make_unsigned(reg2, 32)

    def srl(val, n):
        return make_unsigned(val>>2, 32-n)

    assert mips_info['register_file'][4]['signed_int'] == (reg1 + reg2)
    assert mips_info['register_file'][5]['signed_int'] == (reg1 + reg2)
    assert mips_info['register_file'][6]['signed_int'] == (reg1 - reg2)
    assert mips_info['register_file'][7]['signed_int'] == (reg1 - reg2)
    assert mips_info['register_file'][8]['signed_int'] == (reg1 & reg2)
    assert mips_info['register_file'][9]['signed_int'] == (reg1 | reg2)
    assert mips_info['register_file'][10]['signed_int'] == (reg1 ^ reg2)
    assert mips_info['register_file'][11]['signed_int'] == ~(reg1 | reg2)
    assert mips_info['register_file'][12]['signed_int'] == int(reg1 < reg2)
    assert mips_info['register_file'][13]['signed_int'] == int(reg2 < reg1)
    assert mips_info['register_file'][14]['signed_int'] == (reg1 << 6)
    assert mips_info['register_file'][15]['signed_int'] == srl(reg1, 2)
    assert mips_info['register_file'][16]['signed_int'] == srl(reg2, 2)
    assert mips_info['register_file'][17]['signed_int'] == (reg1 >> 2)
    assert mips_info['register_file'][18]['signed_int'] == (reg2 >> 2)
    assert mips_info['register_file'][19]['signed_int'] == (reg1 << reg3)
    assert mips_info['register_file'][20]['signed_int'] == srl(reg1, reg3)
    assert mips_info['register_file'][21]['signed_int'] == srl(reg2, reg3)
    assert mips_info['register_file'][22]['signed_int'] == (reg1 >> reg3)
    assert mips_info['register_file'][23]['signed_int'] == (reg2 >> reg3)

    
def test_immed_type():
    program_file = 'test_immed_type.asm'
    load_program(program_file)
    mips_info = cli.run()

    reg1 = 156

    assert mips_info['register_file'][2]['signed_int'] == reg1 + (-9)
    assert mips_info['register_file'][3]['signed_int'] == reg1 & (-751)
    assert mips_info['register_file'][4]['signed_int'] == reg1 | 126
    assert mips_info['register_file'][5]['signed_int'] == reg1 ^ 85
    assert mips_info['register_file'][6]['signed_int'] == (942 << 16)
    assert mips_info['register_file'][7]['signed_int'] == 0
    assert mips_info['register_file'][8]['signed_int'] == 1


def test_branchs():
    program_file = 'test_branchs.asm'
    load_program(program_file)
    mips_info = cli.run()

    assert mips_info['register_file'][2]['signed_int'] == 0
    assert mips_info['register_file'][3]['signed_int'] != 0


def test_hazards():
    program_file = 'test_hazards.asm'
    load_program(program_file)
    mips_info = cli.run()

    assert mips_info['register_file'][2]['signed_int'] == 1
    assert mips_info['register_file'][3]['signed_int'] == 1
    assert mips_info['register_file'][4]['signed_int'] == 5
    assert mips_info['register_file'][5]['signed_int'] == 5
    assert mips_info['register_file'][7]['signed_int'] == 6

