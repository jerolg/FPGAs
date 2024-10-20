import pickle
from pynq import PL, Overlay, allocate
import socket
import json
import numpy as np


class GPIOS_conf:
    @staticmethod
    def configure(params, overlay):

        GPIO = overlay.GPIO_CTRL
        xgpio_pretrig_wind = GPIO.PRETRIG_AND_WINDOW_CTRL
        xgpio_decim_signal_sel = GPIO.DECIM_AND_SIGNAL_SEL
        xgpio_thresh = GPIO.THRESHOLD_CTRL

        # Configuración de registros
        xgpio_pretrig_wind.write(0, params[0])  # Total de muestras en ventana
        xgpio_pretrig_wind.write(8, params[1])  # Muestras pretrigger
        xgpio_decim_signal_sel.write(0, params[2])  # Factor de decimación
        xgpio_decim_signal_sel.write(8, params[3])  # Selección de señal
        xgpio_thresh.write(0, params[4])  # Nivel de umbral
        xgpio_thresh.write(8, params[5])  # Selección de borde

        # Llamada al método g_print para mostrar los parámetros configurados

    @staticmethod
    def g_print(params):
           return str(f"Configured GPIOS:\n"
            f"Window_samples: {params[0]}\n"
            f"Pretrig_samples: {params[1]}\n"
            f"Decim. Factor: {params[2]}\n"
            f"Signal_select: {params[3]}\n"
            f"Threshold: {params[4]}\n"
            f"Edge_sel: {params[5]}")
 

def servidor():
    host = '10.6.17.209'  # Localhost
    puerto = 65432  # Puerto que se utilizará

    # Crear un socket TCP/IP
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as servidor_socket:
        servidor_socket.bind((host, puerto))
        servidor_socket.listen()

        print(f"Servidor escuchando en {host}:{puerto}...")

        conn, addr = servidor_socket.accept()
        with conn:
            print(f"Conexión establecida desde {addr}")

            # Paso 1: Recibir lista de 5 enteros
            data = conn.recv(1024)
            
            PL.reset()
            overlay = Overlay('./xadc_uart1msps.bit')
            print("Accesibles IP-Cores:")
            print(overlay.ip_dict.keys())
    
            GPIOS_params = pickle.loads(data)
            
            GPIOS_conf.configure(GPIOS_params, overlay)
            
            dma = overlay.axi_dma_0

            # Enviar mensaje de confirmación al cliente
            message = f"Accesibles IP-Cores\n{overlay.ip_dict.keys()}\n\n{GPIOS_conf.g_print(GPIOS_params)}"
            conn.sendall(message.encode())

            # Paso 2 y 3: Bucle de espera para recibir '1' o '0'
            while True:
                data = conn.recv(1024).decode()
                print(f'DMA READ: {data}')

                if data == '1':
                    # Enviar respuesta al cliente
                    
                    buffer_size = 1040
                    input_buffer = allocate(shape=(buffer_size,))
                    dma.recvchannel.transfer(input_buffer)
                    dma.recvchannel.wait()
                    dma_out = list(np.array(input_buffer).flatten().astype(np.float64))
                    
                    conn.sendall(json.dumps(dma_out).encode())
                    print(f"Respuesta enviada:")
                    
                elif data == '0':
                    print("Conexión cerrada por el cliente.")
                    break

if __name__ == "__main__":
    servidor()


