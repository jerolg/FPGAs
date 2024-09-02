#include <HardwareSerial.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>

#define RX_PIN 16
#define TX_PIN 17
#define DAC_CH1 25 // DAC CHANNEL 1

HardwareSerial SerialPort(2);  // UART channel#2

// Buffer Circular
#define BUFFER_SIZE 128
uint8_t buffer[BUFFER_SIZE];
volatile int writeIndex = 0;
volatile int readIndex = 0;

TaskHandle_t dacTaskHandle;
TaskHandle_t serialPrintTaskHandle;

void setup() {
  Serial.begin(115200);
  SerialPort.begin(115200, SERIAL_8N2, RX_PIN, TX_PIN); // Configuración de UART channel#2

  // Crear tareas
  xTaskCreatePinnedToCore(readSerialTask, "ReadSerialTask", 2048, NULL, 1, &dacTaskHandle, 0);
  xTaskCreatePinnedToCore(printSerialTask, "PrintSerialTask", 2048, NULL, 1, &serialPrintTaskHandle, 1);
}

void loop() {
  // Las tareas se ejecutan de forma independiente
}

void readSerialTask(void *parameter) {
  while (true) {
    while (SerialPort.available() > 0) {
      uint8_t rxdata = SerialPort.read();

      // Agregar dato al buffer circular
      int nextWriteIndex = (writeIndex + 1) % BUFFER_SIZE;
      if (nextWriteIndex != readIndex) { // Buffer no lleno
        buffer[writeIndex] = rxdata;
        writeIndex = nextWriteIndex;
      } else {
        // Buffer lleno: manejar pérdida de datos (puedes implementar un contador o log)
      }

      // Escribir en el DAC
      dacWrite(DAC_CH1, rxdata);
    }
    vTaskDelay(10 / portTICK_PERIOD_MS); // Delay para no sobrecargar el CPU
  }
}

void printSerialTask(void *parameter) {
  while (true) {
    if (readIndex != writeIndex) {
      uint8_t dataToPrint = buffer[readIndex];
      readIndex = (readIndex + 1) % BUFFER_SIZE;
      Serial.println(dataToPrint);
    }
    vTaskDelay(10 / portTICK_PERIOD_MS); // Delay para no sobrecargar el CPU
  }
}
