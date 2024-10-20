import socket
import pickle
import json
import matplotlib.pyplot as plt

def graph(data):
    plt.plot(data)
    plt.title('DMA read')
    plt.grid()
    plt.show()

def cliente():
    host = '10.6.17.209'  # Debe coincidir con el host del servidor
    puerto = 65432  # Debe coincidir con el puerto del servidor

    # Crear un socket TCP/IP
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as cliente_socket:
        cliente_socket.connect((host, puerto))

        # Paso 1: Enviar lista de 5 enteros al servidor
        GPIO_params = {
            'window_samples': 1024,
            'Pretrig Samples': 1100,
            'Decim. Factor': 1,
            'Signal Select': 1,
            'Threshold': 40000,
            'Edge_sel': 0,
        }

        lista = list(GPIO_params.values())  # Lista de ejemplo
        cliente_socket.sendall(pickle.dumps(lista))

        # Recibir y mostrar el mensaje de confirmación del servidor
        mensaje = cliente_socket.recv(1024).decode()
        print(f"Mensaje del servidor: {mensaje}")

        # Paso 2 y 3: Bucle de comandos
        while True:
            comando = input("Ingresa '1' para recibir datos, '0' para cerrar: ")
            cliente_socket.sendall(comando.encode())

            if comando == '1':
                # Recibir datos del servidor
                data = cliente_socket.recv(16384).decode()

                if not data:
                    print("No se recibieron datos del servidor.")
                    continue

                try:
                    respuesta = json.loads(data)  # Intentar decodificar JSON
                    print(f"Respuesta del servidor: {respuesta}")
                    graph(respuesta)
                    
                except json.JSONDecodeError as e:
                    print(f"Error al decodificar JSON: {e}")
                    print(f"Datos recibidos: {data}")
            elif comando == '0':
                print("Cerrando conexión...")
                break

if __name__ == "__main__":
    cliente()
