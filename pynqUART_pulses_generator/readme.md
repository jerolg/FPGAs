<h1>Random Pulses Generation with FPGA and ESP32 DAC using PYNQ</h1>
The generation of random pulses is approached in two ways: using discrete representation through the Z-transform and using precompiled data. The Z-transform enables the implementation of transfer functions and filters designed and implemented in hardware, utilizing Hardware Description Languages (HDL). Both methodologies converge in generating digitized signals within the FPGA, which are transmitted via the UART (Universal Asynchronous Receiver-Transmitter) communication protocol to a DAC (Digital-to-Analog Converter). In this case, the DAC implemented on the ESP32 development board is used, which has two channels with a maximum resolution of 8 bits each. Once converted to analog values, these signals are sent to the FPGA using the ADC (Analog-to-Digital Converter) incorporated into the board, which in this case has a resolution of 12 bits and a maximum sampling frequency of 1 MHz for a base clock frecuency of 104 Mhz.

<h2>PYNQ Z1 & ARTY Z7 specifications</h2>
Both boards are based on the ZYNQ 7000 APSoC (All Programmable System on Chip), which integrates software programmability with an ARM-based processor and hardware programmability with an FPGA. This combination provides superior performance compared to systems that rely solely on software programming, such as widely known development boards like Arduino, Espressif, Raspberry and others.

The specifications for these boards can be found on the developer's website, Digilent:
- [PYNQ-Z1](https://digilent.com/reference/programmable-logic/pynq-z1/start)
- [Arty Z7](https://digilent.com/reference/programmable-logic/arty-z7/start)

<h2>Workflow</h2>

Vivado es una suite de herramientas de diseño y síntesis de Xilinx para el desarrollo de sistemas basados en FPGAs que ofrece una variedad de funcionalidades para diseñar, simular y depurar sistemas digitales. Es necesario conocer cómo utilizar este conjunto de herramientas, por lo cual se recomienda consultar y revisar diferentes guías y tutoriales que proporcionan instrucciones detalladas sobre el uso de Vivado. Estos recursos pueden incluir documentación oficial, cursos en línea, foros de discusión y videos educativos, los cuales ayudarán a comprender mejor el entorno de desarrollo y las técnicas de diseño. **Nota Aclaratoria**: La versión de Vivado Design Suite usada es la 2022.2 [Download Vivado<sup>TM</sup>](https://www.xilinx.com/support/download.html)

**Apertura de un nuevo proyecto en Vivado y reconstrucción del diseño**

**1.** Inicialmente vamos a crear un nuevo proyecto RTL en Vivado sin especificar las fuentes HDL

![RTL new design](https://raw.githubusercontent.com/jerolg/FPGAs/refs/heads/main/pynqUART_pulses_generator/resources/RTL_new_proj.png "RTL new design")

**2.** Después de haber creado el diseño y estar ubicados dentro de la interfaz del proyecto, en la esquina izquierda seleccionamos la opción ***add sources>add or create design sources*** e importamos todas las fuentes de diseño que se encuentran en la carpeta [**src**](https://github.com/jerolg/FPGAs/edit/main/pynqUART_pulses_generator/hardware_design/src/) 

**3.** Ahora en la TCL console escribir `pwd` para ubicar la pocision actual donde la terminal se encuentra y verificar que el directorio sea la carpeta ***./bd/*** en caso contrario introducir `cd /ruta/al/directorio/donde/se/encuetra/el/proyecto/pynqUART_pulses_generator/bd/` y seguidamente volver a verificar por medio de `pwd` la ruta actual donde se encuentra.

**4.** Dentro de la TCL console ejecutar la siguiente instrucción **`source design_use_ZYNQ.tcl`** y presionar enter para realizar el autoruteo y reconexión del block design del proyecto usando las sources importadas y los diferentes IP-Cores dentro de la biblioteca de Vivado. Con lo cuál el proyecto estaria conectado como se puede ver en la siguiente imagen: 

![Block Design](https://raw.githubusercontent.com/jerolg/FPGAs/refs/heads/main/pynqUART_pulses_generator/resources/block_design.png "Block Design")



<h3>Arduino Sketch for Receiving and Transmission of Serialized Data</h3>

<h3> XADC initialization & Hardware Design for Analog Reception</h3>

<h3>Design of a Random Pulse Generator</h3>

<h3>Evaluation of Sending Different Signals by Stages</h3>








