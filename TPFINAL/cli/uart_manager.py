import serial
from time import sleep


class UartManager:
    
    def __init__(self, port, baudrate, wait_time=0.1):
        """ 
        Initializes the uart interface.

        Args:
            port (str): Port used for uart communication.
            baudrate (int): Baudrate used in uart communication.
            wait_time (float): Time to wait after data was written in uart.
        """
        self._ser = serial.Serial(port=port,
                                 baudrate=baudrate,
                                 parity=serial.PARITY_NONE,
                                 stopbits=serial.STOPBITS_ONE,
                                 bytesize=serial.EIGHTBITS)
        self._ser.isOpen()
        self._ser.flushInput()
        self._ser.flushOutput()
        self._ser.timeout=None
        self._wait_time = wait_time

    
    def _send(self, data):
        """
        Writes data to uart and waits _wait_time for its completion

        Args:
            data (char): Data to be send.
        """
        self._ser.write(data)
        sleep(self._wait_time)


    def send_byte(self, data):
        """
        Sends byte through uart.

        Args:
            data (int): Data to be send. 
        Raises: 
            TypeError: if data is not a int
        """
        try:
            data = chr(data)
        except:
            raise TypeError("An integer is required")
        self._send(data)


    def send_array(self, data):
        """
        Sends array of data through uart

        Args:
            data (list of int): Data to be send.
        Raises: 
            TypeError: if data is not a list of ints
        """
        try:
            data = map(chr, data)
        except:
            raise TypeError("A list of ints is requires")
        for d in data:
            self._send(d)


    def read(self, read_len):
        """
        Reads `read_len` bytes from uart. It blocks itself until all bytes
        arrive.
        
        Args:
            read_len (int): Number of bytes to be read.
        """
        return self._ser.read(read_len)
        
