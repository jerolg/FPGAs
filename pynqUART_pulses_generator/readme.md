<h1>Random Pulses Generation with FPGA and ESP32 DAC using PYNQ</h1>
The generation of random pulses is approached in two ways: using discrete representation through the Z-transform and using precompiled data. The Z-transform enables the implementation of transfer functions and filters designed and implemented in hardware, utilizing Hardware Description Languages (HDL). Both methodologies converge in generating digitized signals within the FPGA, which are transmitted via the UART (Universal Asynchronous Receiver-Transmitter) communication protocol to a DAC (Digital-to-Analog Converter). In this case, the DAC implemented on the ESP32 development board is used, which has two channels with a maximum resolution of 8 bits each. Once converted to analog values, these signals are sent to the FPGA using the ADC (Analog-to-Digital Converter) incorporated into the board, which in this case has a resolution of 12 bits and a maximum sampling frequency of 1 MHz for a base clock frecuency of 104 Mhz.

<h2>PYNQ Z1 & ARTY Z7 specifications</h2>
Both boards are based on the ZYNQ 7000 APSoC (All Programmable System on Chip), which integrates software programmability with an ARM-based processor and hardware programmability with an FPGA. This combination provides superior performance compared to systems that rely solely on software programming, such as widely known development boards like Arduino, Espressif, Raspberry and others.

The specifications for these boards can be found on the developer's website, Digilent:
- [PYNQ-Z1](https://digilent.com/reference/programmable-logic/pynq-z1/start)
- [Arty Z7](https://digilent.com/reference/programmable-logic/arty-z7/start)

<h2>Workflow</h2>

Vivado es una suite de herramientas de diseño y síntesis de Xilinx para el desarrollo de sistemas basados en FPGAs que ofrece una variedad de funcionalidades para diseñar, simular y depurar sistemas digitales. Es necesario conocer cómo utilizar este conjunto de herramientas, por lo cual se recomienda consultar y revisar diferentes guías y tutoriales que proporcionan instrucciones detalladas sobre el uso de Vivado. Estos recursos pueden incluir documentación oficial, cursos en línea, foros de discusión y videos educativos, los cuales ayudarán a comprender mejor el entorno de desarrollo y las técnicas de diseño. **Nota Aclaratoria**: La versión de Vivado Design Suite usada es la 2022.2 [Download Vivado<sup>TM</sup>](https://www.xilinx.com/support/download.html)

**Instalación de PYNQ**

**Nota:** Si aún no has instalado PYNQ dentro de tu tarjeta que permita esta carácteristica, puedes hacerlo siguiendo estos pasos:

*Primer Paso:* La tarjeta viene con una ranura para Tarjeta microSD, en la cuál se quemará el Sistema Operativo (PYNQ). Descarga la imagen de la versión de PYNQ compatible con tu board en el siguiente enlace [PYNQ Boards SD card Images](https://www.pynq.io/boards.html).

*Segundo Paso:* Déspues con el uso de alguna herramienta de software para flashear unidades de almacenamiento **(Se recomienda el uso de Balena Etcher)** se carga la imagen del SO y ya con esto PYNQ estaría instalado y funcional dentro de la microSD que debes ahora instalar en la ranura de la tarjeta a utilizar.

**Apertura de un nuevo proyecto en Vivado y reconstrucción del diseño**

**1.** Inicialmente vamos a crear un nuevo proyecto RTL en Vivado sin especificar las fuentes HDL

**1.1.** En la sección para seleccionar la plataforma de Hardware utilizada, debe seleccionarse la referente a la que actualmente se esta utilizando.

**¡Importante! : Este proyecto esta diseñado en particular para plataformas que incorporan SoC's de la familia ZYNQ 7000.**



![RTL new design](https://raw.githubusercontent.com/jerolg/FPGAs/refs/heads/main/pynqUART_pulses_generator/resources/RTL_new_proj.png "RTL new design")

**2.** Después de haber creado el diseño y estar ubicados dentro de la interfaz del proyecto, en la esquina izquierda seleccionamos la opción ***add sources>add or create design sources*** e importamos todas las fuentes de diseño que se encuentran en la carpeta [**src**](https://github.com/jerolg/FPGAs/edit/main/pynqUART_pulses_generator/hardware_design/src/) 

**3.** Ahora en la TCL console escribir `pwd` para ubicar la pocision actual donde la terminal se encuentra y verificar que el directorio sea la carpeta ***./bd/*** en caso contrario introducir `cd /ruta/al/directorio/donde/se/encuetra/el/proyecto/pynqUART_pulses_generator/bd/` y seguidamente volver a verificar por medio de `pwd` la ruta actual donde se encuentra.

**4.** Dentro de la TCL console ejecutar la siguiente instrucción **`source design_use_ZYNQ.tcl`** y presionar enter para realizar el autoruteo y reconexión del block design del proyecto usando las sources importadas y los diferentes IP-Cores dentro de las biblioteca por defecto de Vivado. Con lo cuál el proyecto estaria conectado como se puede ver en la siguiente imagen:

![Block Design](https://raw.githubusercontent.com/jerolg/FPGAs/refs/heads/main/pynqUART_pulses_generator/resources/block_design.png "Block Design")

**Verificación de Constraints, Síntesis, Implementación y Programación de la Plataforma de Hardware**

**5.** Después de verificar la correcta conexión de cada uno de los componentes y bloques de diseño, es importante verificar la compatibilidad de los constraints con la plataforma de hardware utilizada. **¿Qué son los *constraints*?:** Son archivos con la extensión **`.xdc`** que almacenan cada una de las asignaciones a los pines físicos específicos de la plataforma de Hardware utilizada, donde este se manipula para conectar los puertos de entrada y salida dentro del diseño lógico a cada uno de los pine físicos determinados. Esto es crítico para garantizar que las señales correctas se conecten a los pines correspondientes del dispositivo. Adicionalmente este archivo tambien puede almacenar restricciones de temporización y parámetros de alimentación que son recibidos por la FPGA.

**5.1.** En la sección **``Sources>./Constraints/** abrir el archivo **`.xdc`** y en este es donde se modifican los constraints del proyecto, los cuales para cada una de las plataformas deben ser buscados previamente en repositorios dedicados para ello o la documentación de fabricante. En este repositorio se anexan los constraints correspondientes a las plataformas ART Z7 Y PYNQ Z1, las cuáles son muy similares. [PYNQ_Z1_C.xdc](https://www.xilinx.com/support/download.html), [ARTY_Z7_C.xdc](https://www.xilinx.com/support/download.html)

**6.** Ya con todo lo anterior verificado, abre el bloque de diseño del proyecto y de manera opcional preconfigura los parámetros de funcionamiento del mismo, sin embargo no se recomienda sin tener los conocimientos del funcionamiento de los IP-cores que lo integran. El diseño a implementar ya trae los parámetros de funcionamiento por defecto.

**7.** **Generación del Bitstream  y programación**: En la esquina izquierda ubicados en la sección **`Flow Navigator`** dirigirse a la parte inferior en **`PROGRAM AND DEBUG`** y seleccionar **`Generate Bitstream`** y el programa empezará a ejecutar una serie de procesos (**`SYNTHESIS`**, **`IMPLEMENTATION`** & **`PROGRAM AND DEBUG`**) que pueden ser mas detallados dentro de la documentación de Vivado, para el entendimiento de las tareas dentro de cada etapa.

**7.1.** **Generación del Bitstream  y programación:** Este proceso convierte el diseño lógico, que ha sido sintetizado e implementado, en una serie de instrucciones binarias que configuran los elementos programables del FPGA (LUTs, flip-flops, interconexiones y pines de entrada/salida). El bitstream es el archivo final que contiene la información necesaria para configurar la FPGA. Una vez generado el archivo bitstream, se transfiere al FPGA mediante una interfaz de programación donde el caso mas común es através de JTAG.

A partir de aquí se tomará la metodología de trabajo con PYNQ (Productivity for ZYNQ) que es una plataforma basada en el uso de Python para interactuar con la FPGA y facilitar al usuario el control de la misma, basado en un diseño de hardware previamente construido que establece el funcionamiento del PL (Programable Logic) y a partir de aquí todo es controlado por medio de terminal o Notebooks de Jupyter que permiten al PS (Processor System) interactuar con la lógica incorporada dentro del FPGA. Para conocer más sobre PYNQ puedes visitar [PYNQ | Python Productivity to AMD adaptative Compute Platforms](https://www.pynq.io/) y [PYNQ ReadTheDocs](https://pynq.readthedocs.io/en/latest/).

**Uso de PYNQ**

**8.** Déspues de tener conectada la tarjeta a la alimentación y a la red local por conexión cableada mediante el conector RJ45 que viene en la placa, ingresa al navegador y accede a la dirección IP que fue asignada a tu tarjeta dentro de la red local. El usuario predeterminado es **xilinx** y la contraseña es **xilinx** y como se puede ver, ya se esta en el sistema de archivos de la tarjeta usando PYNQ.

**9.** Crea una carpeta para el proyecto y abre un nuevo Notebook de Jupyter.

**10.** Busca en el directorio local donde tienes alojado los archivos del proyecto de Vivado, 3 archivos, los cuales serán necesarios para cargarlos al sistema de archivos de PYNQ. 

- Archivo asociado al Bitstream generado, con el nombre del bloque de diseño y extensión **`.bit`**
  
- Archivo asociado al ruteo de hardware, los puertos I/O, registros y direcciones de memoria asignadas, con el nombre del bloque de diseño y extensión **`.hwh`**

- Archivo asociado al script que describe los pasos necesarios para recrear el diseño o automatizar su configuración, con el nombre del bloque de diseño y extensión **`.tcl`**

Estos archivos pueden buscarse a partir de la barra de busqueda solo utilizando su extensión (**`*.extension`**) ubicandose en la carpeta inicial del proyecto. Se cargan en PYNQ en el mismo directorio con el mismo nombre entre ellos, sugeriblemente en la carpeta que esta ubicado el notebook a utilizar. Se veria así:

![Entorno PYNQ](IMAGEN PYNQ ENTORNO CARPETA)

**11.** El Notebook ejemplo esta dentro del presente repositorio debidamente comentado y evaluado garantizando su funcionamiento y compatibilidad con el diseño de Hardware (**verificar la coincidencia del nombre de los archivos importados con el invocado en la linea de código **`overlay = Overlay("bitstream_file.bit")`**.







