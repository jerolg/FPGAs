#include <HardwareSerial.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>

#define RX_pin 16
#define TX_pin 17

#define DAC_CH1 25 // DAC CHANNEL 1
#define OUTPUT_PIN 2 // Pin de salida para el pulso
#define RANDOM_PIN 39 // Pin analógico para la semilla

HardwareSerial SerialPort(2);  // UART channel#2

// Buffer Circular
#define BUFFER_SIZE 128
uint8_t buffer[BUFFER_SIZE];
volatile int writeIndex = 0;
volatile int readIndex = 0;

TaskHandle_t dataAcquisitionTaskHandle;
TaskHandle_t dataProcessingTaskHandle;
TaskHandle_t pulseGenerationTaskHandle;

void setup() {
  Serial.begin(115200);
  pinMode(OUTPUT_PIN, OUTPUT); // Configuración del pin de salida
  pinMode(RANDOM_PIN, INPUT); // Configuración del pin analógico

  SerialPort.begin(9600, SERIAL_8N2, RX_pin, TX_pin); // Configuración de UART channel#2

  // Inicializar la semilla aleatoria
  randomSeed(analogRead(RANDOM_PIN));

  // Crear las tareas para adquisición, procesamiento de datos y generación de pulsos
  xTaskCreatePinnedToCore(dataAcquisitionTask, "Data Acquisition", 2048, NULL, 2, &dataAcquisitionTaskHandle, 0);
  xTaskCreatePinnedToCore(dataProcessingTask, "Data Processing", 2048, NULL, 2, &dataProcessingTaskHandle, 1);
  xTaskCreatePinnedToCore(pulseGenerationTask, "Pulse Generation", 2048, NULL, 2, &pulseGenerationTaskHandle, 1);
}

void loop() {
  // Nada en el loop principal, todo se maneja por tareas
}

// Tarea 1: Adquisición de datos desde UART
void dataAcquisitionTask(void *parameter) {
  uint8_t rxdata;

  while (true) {
    // Adquisición de datos
    while (SerialPort.available() > 0) {
      rxdata = SerialPort.read();

      // Agregar dato al buffer circular
      int nextWriteIndex = (writeIndex + 1) % BUFFER_SIZE;
      if (nextWriteIndex != readIndex) { // Buffer no lleno
        buffer[writeIndex] = rxdata;
        writeIndex = nextWriteIndex;
      } else {
        // Buffer lleno: manejar pérdida de datos (puedes implementar un contador o log)
      }
    }
    vTaskDelay(1 / portTICK_PERIOD_MS); // Delay mínimo para evitar bloqueo de CPU
  }
}

// Tarea 2: Procesamiento de datos y envío al DAC
void dataProcessingTask(void *parameter) {
  while (true) {
    // Procesar datos del buffer si hay disponibles
    while (readIndex != writeIndex) {
      uint8_t dataToProcess = buffer[readIndex];
      readIndex = (readIndex + 1) % BUFFER_SIZE;

      dacWrite(DAC_CH1, dataToProcess);
      //Serial.print("Data Processed: ");
      //Serial.println(dataToProcess);
    }
    vTaskDelay(1 / portTICK_PERIOD_MS); // Delay mínimo para evitar bloqueo de CPU
  }
}

// Tarea 3: Generación de pulsos aleatorios
void pulseGenerationTask(void *parameter) {
  int umbral = 30;

  while (true) {
    int RANDOM_VAL = random(0, 1000);
    int pulso = (RANDOM_VAL < umbral) ? 1 : 0;
    digitalWrite(OUTPUT_PIN, pulso);

    // Delay no bloqueante de 50ms
    vTaskDelay(50 / portTICK_PERIOD_MS);
  }
}
