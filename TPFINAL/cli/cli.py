import serial
from time import sleep
import pprint

LOAD = 1
RUN  = 2
STEP = 3


DATA_READ_LEN = 1220

def parse_32_bits(data):
    data = map(ord, reversed(data))
    value = 0
    for i, d in enumerate(data):
        value += d*(256**i)
    return value


def make_unsigned(data):
    if data < 0:
        return (1<<32) + data
    return data

def make_signed(data):
    if data > (1<<31):
        return data - (1<<32)
    return data

def latch_data_2_dict(data, nbits):
    data = int(data, 2)
    data_dict = {}
    data_dict['signed_int'] = data
    data_dict['unsigned_int'] = make_unsigned(data)
    data_dict['binary'] = format(data, '0%sb'%nbits)
    return data_dict

def parse_latchs_data(data):
    data = ''.join(map(lambda x: format(ord(x), '08b'), data))
    id_ex_start = 64
    ex_mem_start = id_ex_start + 196
    mem_wb_start = ex_mem_start + 142
    finish = mem_wb_start + 104
    if_id_data = data[0 : id_ex_start]
    id_ex_data = data[id_ex_start : ex_mem_start]
    ex_mem_data = data[ex_mem_start : mem_wb_start]
    mem_wb_data = data[mem_wb_start : finish]

    latch_data = {}

    latch_data['IF_ID'] = {}
    latch_data['ID_EX'] = {}
    latch_data['EX_MEM'] = {}
    latch_data['MEM_WB'] = {}

    #IF_ID
    pcnext = if_id_data[0:32]
    instruction = if_id_data[31:]
    latch_data['IF_ID']['pcnext'] = latch_data_2_dict(pcnext, 32)
    latch_data['IF_ID']['instruction'] = latch_data_2_dict(instruction, 32)

    #ID_EX
    pcnext = id_ex_data[0:32]
    opcode = id_ex_data[32:38]
    read_data_1 = id_ex_data[38:70]
    read_data_2 = id_ex_data[70:102]
    immediate_data_ext = id_ex_data[102:134]
    jump_address = id_ex_data[134:166]
    rs = id_ex_data[166:171]
    rt = id_ex_data[171:176]
    rd = id_ex_data[176:181]
    reg_dst = id_ex_data[181]
    reg_write = id_ex_data[182]
    mem_read = id_ex_data[183]
    mem_write = id_ex_data[184]
    mem_to_reg = id_ex_data[185]
    alu_op = id_ex_data[186:190]
    alu_src = id_ex_data[190]
    shamt = id_ex_data[191]
    ls_filter_op = id_ex_data[192:195]
    branch_enable = id_ex_data[195]

    latch_data['ID_EX']['pcnext'] = latch_data_2_dict(pcnext, 32)
    latch_data['ID_EX']['opcode'] = latch_data_2_dict(opcode, 6)
    latch_data['ID_EX']['read_data_1'] = latch_data_2_dict(read_data_1, 32)
    latch_data['ID_EX']['read_data_2'] = latch_data_2_dict(read_data_2, 32)
    latch_data['ID_EX']['immediate_data_ext'] = latch_data_2_dict(immediate_data_ext, 32)
    latch_data['ID_EX']['jump_address'] = latch_data_2_dict(jump_address, 32)
    latch_data['ID_EX']['rs'] = latch_data_2_dict(rs, 5)
    latch_data['ID_EX']['rt'] = latch_data_2_dict(rt, 5)
    latch_data['ID_EX']['rd'] = latch_data_2_dict(rd, 5)
    latch_data['ID_EX']['RegDst'] = latch_data_2_dict(reg_dst, 1)
    latch_data['ID_EX']['RegWrite'] = latch_data_2_dict(reg_write, 1)
    latch_data['ID_EX']['MemRead'] = latch_data_2_dict(mem_read, 1)
    latch_data['ID_EX']['MemWrite'] = latch_data_2_dict(mem_write, 1)
    latch_data['ID_EX']['MemtoReg'] = latch_data_2_dict(mem_to_reg, 1)
    latch_data['ID_EX']['ALUOp'] = latch_data_2_dict(alu_op, 4)
    latch_data['ID_EX']['ALUSrc'] = latch_data_2_dict(alu_src, 1)
    latch_data['ID_EX']['Shamt'] = latch_data_2_dict(shamt, 1)
    latch_data['ID_EX']['ls_filter_op'] = latch_data_2_dict(ls_filter_op, 3)
    latch_data['ID_EX']['branch_enable'] = latch_data_2_dict(branch_enable, 1)

    #EX_MEM
    alu_result = ex_mem_data[0:32]
    rt_data = ex_mem_data[32:64]
    rd = ex_mem_data[64:69]
    reg_write = ex_mem_data[69]
    mem_read = ex_mem_data[70]
    mem_write = ex_mem_data[71]
    mem_to_reg = ex_mem_data[72]
    ls_filter_op = ex_mem_data[73:76]
    taken = ex_mem_data[76]
    pc_to_reg = ex_mem_data[77]
    jump_address = ex_mem_data[78:110]
    pc_return = ex_mem_data[110:142]

    latch_data['EX_MEM']['alu_result'] = latch_data_2_dict(alu_result, 32)
    latch_data['EX_MEM']['rt_data'] = latch_data_2_dict(rt_data, 32)
    latch_data['EX_MEM']['rd'] = latch_data_2_dict(rd, 5)
    latch_data['EX_MEM']['RegWrite'] = latch_data_2_dict(reg_write, 1)
    latch_data['EX_MEM']['MemRead'] = latch_data_2_dict(mem_read, 1)
    latch_data['EX_MEM']['MemWrite'] = latch_data_2_dict(mem_write, 1)
    latch_data['EX_MEM']['MemtoReg'] = latch_data_2_dict(mem_to_reg, 1)
    latch_data['EX_MEM']['ls_filter_op'] = latch_data_2_dict(ls_filter_op, 3)
    latch_data['EX_MEM']['taken'] = latch_data_2_dict(taken, 1)
    latch_data['EX_MEM']['pc_to_reg'] = latch_data_2_dict(pc_to_reg, 1)
    latch_data['EX_MEM']['jump_address'] = latch_data_2_dict(jump_address, 32)
    latch_data['EX_MEM']['pc_return'] = latch_data_2_dict(pc_return, 32)

    #MEM_WB
    alu_result = mem_wb_data[0:32]
    mem_data = mem_wb_data[32:64]
    rd = mem_wb_data[64:69]
    pc_to_reg = mem_wb_data[69]
    pc_return = mem_wb_data[70:102]
    reg_write = mem_wb_data[102]
    mem_to_reg = mem_wb_data[103]

    latch_data['MEM_WB']['alu_result'] = latch_data_2_dict(alu_result, 32)
    latch_data['MEM_WB']['mem_data'] = latch_data_2_dict(mem_data, 32)
    latch_data['MEM_WB']['rd'] = latch_data_2_dict(rd, 5)
    latch_data['MEM_WB']['pc_to_reg'] = latch_data_2_dict(pc_to_reg, 1)
    latch_data['MEM_WB']['pc_return'] = latch_data_2_dict(pc_return, 32)
    latch_data['MEM_WB']['RegWrite'] = latch_data_2_dict(reg_write, 1)
    latch_data['MEM_WB']['MemtoReg'] = latch_data_2_dict(mem_to_reg, 1)

    return latch_data


def parse_mips_data(data):
    clk_count = data[0:4]
    clk_count = parse_32_bits(clk_count)
    rf_data = data[4:132]
    rf_data_splitted = []
    for i in range(len(rf_data)/4):
        rf_data_splitted.append(rf_data[i*4:(i+1)*4])
    rf_data_int_uns = map(parse_32_bits, reversed(rf_data_splitted))
    rf_data_int = map(make_signed, rf_data_int_uns)
    latchs_data = data[132:196]
    latchs_data = parse_latchs_data(latchs_data)
    memory_data = data[196:]
    memory_data_splitted = []
    for i in range(len(memory_data)/4):
        memory_data_splitted.append(memory_data[i*4:(i+1)*4])
    memory_int_uns = map(parse_32_bits, memory_data_splitted)
    memory_int = map(make_signed, memory_int_uns)

    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(latchs_data)
    print memory_int
    print rf_data_int
    print clk_count

def run_mips(ser):
    ser.write(chr(RUN))
    print "reading data"
    mips_data = ser.read(DATA_READ_LEN)
    parse_mips_data(mips_data)
    

def load_memory(ser, mem_path):
    with open(mem_path) as fp:
        instructions = fp.readlines()
    instructions = map(lambda x: x.replace('\n', ''), instructions)
    instructions_count = len(instructions)
    indexs = [(0,7), (8,15), (16,23), (24,31)]
    instructions_bytes = [inst[s:e+1] for inst in instructions for s,e in indexs]
    instructions_bytes = map(lambda x: int(x, 2), instructions_bytes)

    ser.write(chr(LOAD)); sleep(0.2)
    ser.write(chr(instructions_count)); sleep(0.2)
    print "inst count: ", instructions_count
    for inst in instructions_bytes:
        import ipdb; ipdb.set_trace()
        ser.write(chr(inst))
        print inst, bin(inst)
        sleep(0.2)

def cli():
    
    port = '/dev/ttyUSB1'
    baudrate = 19200
    ser = serial.Serial(port=port,
                        baudrate=baudrate,
                        parity=serial.PARITY_NONE,
                        stopbits=serial.STOPBITS_ONE,
                        bytesize=serial.EIGHTBITS)
    ser.isOpen()
    ser.flushInput()
    ser.flushOutput()
    ser.timeout=None

    load_memory(ser, '../src/testasm.mem')
    run_mips(ser)


if __name__ == '__main__':
    cli()
