from uart_manager import UartManager


class MipsCLI:
    

    LOAD = 1
    RUN  = 2
    START_STEP = 3
    SEND_STEP = 4
    STOP_STEP = 5
    DATA_READ_LEN = 1220

    def __init__(self, 
                 uart_port, 
                 uart_baudrate=19200, 
                 uart_wait_time=0.1):

        self._uart = UartManager(uart_port, 
                                 uart_baudrate, 
                                 wait_time = uart_wait_time)
        self.mips_data = {}


    def _make_signed(self, data):
        if data > (1<<31):
            return data - (1<<32)
        return data


    def _binarize(self, data):
        return ''.join(map(lambda x: format(ord(x), '08b'), data))
        

    def _data_to_dict(self, data, nbits=32):
        data = int(data, 2)
        data_dict = {}
        data_dict['signed_int'] = self._make_signed(data)
        data_dict['unsigned_int'] = data
        data_dict['binary'] = format(data, '0%sb'%nbits)
        return data_dict


    def _parse_latchs_data(self, data):
        data = self._binarize(data)
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
        instruction = if_id_data[32:]
        latch_data['IF_ID']['pcnext'] = self._data_to_dict(pcnext, 32)
        latch_data['IF_ID']['instruction'] = self._data_to_dict(instruction, 32)

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

        latch_data['ID_EX']['pcnext'] = self._data_to_dict(pcnext, 32)
        latch_data['ID_EX']['opcode'] = self._data_to_dict(opcode, 6)
        latch_data['ID_EX']['read_data_1'] = self._data_to_dict(read_data_1, 32)
        latch_data['ID_EX']['read_data_2'] = self._data_to_dict(read_data_2, 32)
        latch_data['ID_EX']['immediate_data_ext'] = self._data_to_dict(immediate_data_ext, 32)
        latch_data['ID_EX']['jump_address'] = self._data_to_dict(jump_address, 32)
        latch_data['ID_EX']['rs'] = self._data_to_dict(rs, 5)
        latch_data['ID_EX']['rt'] = self._data_to_dict(rt, 5)
        latch_data['ID_EX']['rd'] = self._data_to_dict(rd, 5)
        latch_data['ID_EX']['RegDst'] = self._data_to_dict(reg_dst, 1)
        latch_data['ID_EX']['RegWrite'] = self._data_to_dict(reg_write, 1)
        latch_data['ID_EX']['MemRead'] = self._data_to_dict(mem_read, 1)
        latch_data['ID_EX']['MemWrite'] = self._data_to_dict(mem_write, 1)
        latch_data['ID_EX']['MemtoReg'] = self._data_to_dict(mem_to_reg, 1)
        latch_data['ID_EX']['ALUOp'] = self._data_to_dict(alu_op, 4)
        latch_data['ID_EX']['ALUSrc'] = self._data_to_dict(alu_src, 1)
        latch_data['ID_EX']['Shamt'] = self._data_to_dict(shamt, 1)
        latch_data['ID_EX']['ls_filter_op'] = self._data_to_dict(ls_filter_op, 3)
        latch_data['ID_EX']['branch_enable'] = self._data_to_dict(branch_enable, 1)

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

        latch_data['EX_MEM']['alu_result'] = self._data_to_dict(alu_result, 32)
        latch_data['EX_MEM']['rt_data'] = self._data_to_dict(rt_data, 32)
        latch_data['EX_MEM']['rd'] = self._data_to_dict(rd, 5)
        latch_data['EX_MEM']['RegWrite'] = self._data_to_dict(reg_write, 1)
        latch_data['EX_MEM']['MemRead'] = self._data_to_dict(mem_read, 1)
        latch_data['EX_MEM']['MemWrite'] = self._data_to_dict(mem_write, 1)
        latch_data['EX_MEM']['MemtoReg'] = self._data_to_dict(mem_to_reg, 1)
        latch_data['EX_MEM']['ls_filter_op'] = self._data_to_dict(ls_filter_op, 3)
        latch_data['EX_MEM']['taken'] = self._data_to_dict(taken, 1)
        latch_data['EX_MEM']['pc_to_reg'] = self._data_to_dict(pc_to_reg, 1)
        latch_data['EX_MEM']['jump_address'] = self._data_to_dict(jump_address, 32)
        latch_data['EX_MEM']['pc_return'] = self._data_to_dict(pc_return, 32)

        #MEM_WB
        alu_result = mem_wb_data[0:32]
        mem_data = mem_wb_data[32:64]
        rd = mem_wb_data[64:69]
        pc_to_reg = mem_wb_data[69]
        pc_return = mem_wb_data[70:102]
        reg_write = mem_wb_data[102]
        mem_to_reg = mem_wb_data[103]

        latch_data['MEM_WB']['alu_result'] = self._data_to_dict(alu_result, 32)
        latch_data['MEM_WB']['mem_data'] = self._data_to_dict(mem_data, 32)
        latch_data['MEM_WB']['rd'] = self._data_to_dict(rd, 5)
        latch_data['MEM_WB']['pc_to_reg'] = self._data_to_dict(pc_to_reg, 1)
        latch_data['MEM_WB']['pc_return'] = self._data_to_dict(pc_return, 32)
        latch_data['MEM_WB']['RegWrite'] = self._data_to_dict(reg_write, 1)
        latch_data['MEM_WB']['MemtoReg'] = self._data_to_dict(mem_to_reg, 1)

        return latch_data


    def _parse_mips_data(self, data):
        mips_data = {}

        #clk count extraction
        clk_count_raw = self._binarize(data[0:4])
        mips_data['clk_count'] = self._data_to_dict(clk_count_raw, nbits=32)

        #register files data extraction
        rf_data_raw = data[4:132]
        rf_data = []
        for i in range(len(rf_data_raw)/4):
            rf_data.append(rf_data_raw[i*4:(i+1)*4])
        rf_data = map(lambda x: self._data_to_dict(self._binarize(x)), rf_data)
        rf_data_dict = {i : data for i, data in enumerate(reversed(rf_data))}
        mips_data['register_file'] = rf_data_dict

        #latchs data extraction
        latchs_data_raw = data[132:196]
        mips_data['latchs_data'] = self._parse_latchs_data(latchs_data_raw)

        #memory data extraction
        memory_data_raw = data[196:]
        memory_data = []
        for i in range(len(memory_data_raw)/4):
            memory_data.append(memory_data_raw[i*4:(i+1)*4])
        memory_data = map(lambda x: self._data_to_dict(self._binarize(x)),
                          memory_data)
        memory_data_dict = {i : data for i, data in enumerate(memory_data)}
        mips_data['memory_data'] = memory_data_dict

        return mips_data


    def load_instructions(self, instructions):
        instructions_count = len(instructions)
        indexs = [(0,7), (8,15), (16,23), (24,31)]
        instructions_bytes = [inst[s:e+1] for inst in instructions 
                                          for s,e in indexs]
        instructions_bytes = map(lambda x: int(x, 2), instructions_bytes)

        self._uart.send_byte(self.LOAD)
        self._uart.send_byte(instructions_count)
        self._uart.send_array(instructions_bytes)


    def run(self):
        self._uart.send_byte(self.RUN)
        mips_data_raw = self._uart.read(self.DATA_READ_LEN)
        mips_data = self._parse_mips_data(mips_data_raw)
        self.mips_data = mips_data
        return mips_data

    def start_step(self):
        self._uart.send_byte(self.START_STEP)
        mips_data_raw = self._uart.read(self.DATA_READ_LEN)
        mips_data = self._parse_mips_data(mips_data_raw)
        self.mips_data = mips_data
        return mips_data

    def send_step(self):
        self._uart.send_byte(self.SEND_STEP)
        mips_data_raw = self._uart.read(self.DATA_READ_LEN)
        mips_data = self._parse_mips_data(mips_data_raw)
        self.mips_data = mips_data
        return mips_data

    def stop_step(self):
        self._uart.send_byte(self.STOP_STEP)


"""
port = '/dev/ttyUSB1'
cli = MipsCLI(port)

mem_path = '../src/testasm.mem'
with open(mem_path) as fp:
    instructions = fp.readlines()
    instructions = map(lambda x: x.replace('\n', ''), instructions)

#cli.load_instructions(instructions)
cli.run()
"""
