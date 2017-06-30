import socket, threading
import pynmea2
import BMP280 as BMP280
import smbus

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 7997))
s.listen(1)

# initialize message list
flarm_messages = []
lock = threading.Lock()
welcome_message = 'Welcome \n'
 
def play_sound():
    #sound the horn
    return
 
def open_window():
    # open a window
    return
 
class daemon(threading.Thread):
 
    def __init__(self, (socket,address)):
        threading.Thread.__init__(self)
        self.socket = socket
        self.address = address
 
    def run(self):
 
        # display welcome message
        self.socket.send(welcome_message)
 
        while(True):
            inches,temperature,pressure,altitude = BMP280.readBME280All()
            temp = str(temperature)
            press = str(pressure)
            alt = str(altitude)
            inches = str(inches)
            wattemp = ''
            watc = ''
            relh = ''
            absh = ''
            dew = ''
            dewc = ''
            windt = ''
            windm = ''
            windskn = ''
            windkn = ''
            windsm = ''
            windm = ''

            wind_message_mda = pynmea2.ProprietarySentence('I', ['MDA',inches,'I',press,'B',temp,'C',wattemp,watc,relh,absh,dew,dewc,windt,windt,windm,windm,windskn,windkn,windsm,windm])
            flarm_messages.append(str(wind_message_mda))
            #print ('MDA:'),str(wind_message_mda)
            self.socket.send(str(wind_message_mda)+"\r\n")
            
        # close connection
        self.socket.close()
 
while True:
    daemon(s.accept()).start()
