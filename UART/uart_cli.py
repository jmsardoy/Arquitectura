from time import sleep
import serial

#ser = serial.serial_for_url('loop://', timeout=1)

ser = serial.Serial(
     port     = '/dev/ttyUSB1',	#Configurar con el puerto
     baudrate = 19200,
     parity   = serial.PARITY_NONE,
     stopbits = serial.STOPBITS_ONE,
     bytesize = serial.EIGHTBITS
 )

ser.isOpen()
ser.timeout=None
ser.flushInput()
ser.flushOutput()


op_menu = '0 - ADD\n'\
         +'1 - SUB\n'\
         +'2 - AND\n'\
         +'3 - OR\n'\
         +'4 - XOR\n'\
         +'5 - NOR\n'\
         +'6 - SRA\n'\
         +'7 - SRL\n'\
         +'ingrese la operacion: '

opcodes_dict = {'0': 0x20, 
                '1': 0x22, 
                '2': 0x24,
                '3': 0x25,
                '4': 0x26,
                '5': 0x27,
                '6': 0x03,
                '7': 0x02}

while True:
    u_a = int(raw_input('ingrese primer argumento: '))
    if u_a<0: a = 256+u_a
    else: a = u_a
    ser.write(chr(a))
    b = int(raw_input('ingrese segundo argumento: '))
    if u_b<0: b = 256+u_b
    ser.write(chr(b))
    op = raw_input(op_menu)
    opcode = opcodes_dict[op]
    ser.write(chr(opcode))
    u_result = ord(ser.read(1))
    if u_result > 127: result = u_result-256
    else: result = u_result

    print 'a:       %3i,  %10s'%(a, format(a, '#010b'))
    print 'b:       %3i,  %10s'%(b, format(b, '#010b'))
    print 'result:  %3i,  %10s'%(result, format(u_result, '#010b'))

