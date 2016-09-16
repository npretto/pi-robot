import wiringpi as gpio
from SimpleWebSocketServer import SimpleWebSocketServer, WebSocket
import time

gpio.wiringPiSetupPhys()

left = 11;
right = 21;
sleep_time = 0.2;

gpio.pinMode(left,1);
gpio.pinMode(left+1,1);
gpio.pinMode(right,1);
gpio.pinMode(right+1,1);

gpio.digitalWrite(left,0);
gpio.digitalWrite(left+1,0);
gpio.digitalWrite(right,0);
gpio.digitalWrite(right+1,0);


def motor(side,status):
    if status > 0.1:
        gpio.digitalWrite(side,1)
        gpio.digitalWrite(side+1,0)
    elif status < -0.1:
        gpio.digitalWrite(side,0)
        gpio.digitalWrite(side+1,1)
    else:
        gpio.digitalWrite(left,0);
        gpio.digitalWrite(left+1,0);
        gpio.digitalWrite(right,0);
        gpio.digitalWrite(right+1,0);
    return

def both(v):
    motor(left,v)
    motor(right,v)

def forward():
    both(1)

def back():
    both(-1)

def stop():
    both(0)

def l():
    motor(left,-1)
    motor(right,1)
    time.sleep(sleep_time)
    stop()

def r():
    motor(left,1)
    motor(right,-1)
    time.sleep(sleep_time)
    stop()





class SimpleEcho(WebSocket):

    def handleMessage(self):
        try:
            # echo message back to client
            #print(self.data)
            splitted = self.data.split(":")
            if splitted[0] == "m":
                print('motors data incoming!')
                motors = splitted[1].split("|")
                lv = float(motors[0])
                rv = float(motors[1])
                print("("+str(lv)+","+str(rv)+")")
                motor(left, lv)
                motor(right, rv)
        except(error):
            print("ERROR???")
            print(error)



    def handleConnected(self):
        print(self.address, 'connected')

    def handleClose(self):
        print(self.address, 'closed')

server = SimpleWebSocketServer('', 8000, SimpleEcho)
server.serveforever()
