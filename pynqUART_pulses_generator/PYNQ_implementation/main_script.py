#When updating the imported Vivado files (.bit, .hwh, .tcl), it is necessary to restart the PL.
from pynq import PL
PL.reset()

# TCP Server
import socket
import json

#Libraries and Overlay upload
from pynq import Overlay, Clocks, allocate
from pynq import allocate
import numpy as np
import time

overlay = Overlay('./xadc.bit')
print("Accesible IP-Cores:")
overlay.ip_dict.keys()

#DMA initialization
dma = overlay.axi_dma_0   
dma_recv = dma.recvchannel

GPIO = overlay.GPIO_CTRL
#--------------------------------------------------------------------
#GPIO control of pretrigger samples and total samples in window
xgpio_pretrig_wind = GPIO.PRETRIG_AND_WINDOW_CTRL

#--------------------------------------------------------------------
#GPIO control of decimation factor and reference signal selection
xgpio_decim_signal_sel = GPIO.DECIM_AND_SIGNAL_SEL

#--------------------------------------------------------------------
#GPIO control of threshold_control
xgpio_thresh = GPIO.THRESHOLD_CTRL

##-------------------------------------------------------------------------------
##-------------------------------------------------------------------------------

# Socket Configuration
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('0.0.0.0', 12345)) # Escuchar en todas las interfaces
server_socket.listen(1)
print("Waiting connection...")

# Accept the connection
connection, address = server_socket.accept()
print(f"Connected to: {address}")


def GPIO_map(params):
    GPIO_params = list(map(int, params.split(',')))
    return GPIO_params


def server_recv():
    recv_data = connection.recv(1024).decode()
    print(f"Datos recibidos: {recv_data}")
    return recv_data

def server_response(data_send):
    response = json.dumps(data_send)
    connection.sendall(response.encode())
    print(f"Respuesta enviada")

try:

    recv_GPIO = server_recv()
    GPIO = GPIO_map(recv_GPIO)

    xgpio_pretrig_wind.write(0,GPIO[0]) #Total window samples
    xgpio_pretrig_wind.write(8,GPIO[1])  #Pretrigger samples
    xgpio_decim_signal_sel.write(0, GPIO[2]) #Decimation factor (1 for decimation off)
    
    #Predefined reference signal selection
    #0x0 DC CONSTANT 0.5v monopolar mode
    #0x1 FILTERED SIGNAL
    #0x2 NOISY SIGNAL
    #0x3 EXPONENTIAL
    xgpio_decim_signal_sel.write(8, GPIO[3]) #signal selection

    xgpio_thresh.write(0, GPIO[4])  #Threshold Level
    xgpio_thresh.write(8, GPIO[5])  #Edge sel

    #-----------------------------------------------------------------------------
    #-----------------------------------------------------------------------------
    #DMA buffer size assignment
    buffer_size = 1040
    #Input buffer declaration
    input_buffer = allocate(shape=(buffer_size,)) #, dtype=np.uint16)

    dma.recvchannel.transfer(input_buffer)
    dma.recvchannel.wait()
    dma_out = np.array(input_buffer).flatten()

    server_response(dma_out)
    
finally:
    # Cerrar la conexión
    connection.close()
    server_socket.close()

