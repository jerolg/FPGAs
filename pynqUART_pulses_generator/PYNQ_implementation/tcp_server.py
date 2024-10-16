# Servidor TCP en la placa
import socket
import json

def procesar_datos(data):
    # Multiplicar cada elemento del arreglo por 2
    arreglo = json.loads(data)
    resultado = [x * 2 for x in arreglo]
    return json.dumps(resultado)

# Configuración del socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('0.0.0.0', 12345)) # Escuchar en todas las interfaces
server_socket.listen(1)

print("Esperando una conexión...")

# Espera y acepta la conexión,knklnn

connection, address = server_socket.accept()
print(f"Conexión establecida con {address}")

try:
    # Recibir datos
    data = connection.recv(1024).decode()
    print(f"Datos recibidos: {data}")

    # Procesar y enviar la respuesta
    respuesta = procesar_datos(data)
    connection.sendall(respuesta.encode())
    print(f"Respuesta enviada: {respuesta}")

finally:
    # Cerrar la conexión
    connection.close()
    server_socket.close()



