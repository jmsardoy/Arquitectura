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



while True:
    u_result = bin(ord(ser.read(1)))
    print u_result

