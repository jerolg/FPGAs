<h1>Random Pulses Generation with FPGA and ESP32 DAC using PYNQ</h1>
The generation of random pulses is approached in two ways: using discrete representation through the Z-transform and using precompiled data. The Z-transform enables the implementation of transfer functions and filters designed and implemented in hardware, utilizing Hardware Description Languages (HDL). Both methodologies converge in generating digitized signals within the FPGA, which are transmitted via the UART (Universal Asynchronous Receiver-Transmitter) communication protocol to a DAC (Digital-to-Analog Converter). In this case, the DAC implemented on the ESP32 development board is used, which has two channels with a maximum resolution of 8 bits each. Once converted to analog values, these signals are sent to the FPGA using the ADC (Analog-to-Digital Converter) incorporated into the board, which in this case has a resolution of 12 bits and a maximum sampling frequency of 1 MHz for a base clock frecuency of 104 Mhz.

<h2>PYNQ Z1 & ARTY Z7 specifications</h2>
Both boards are based on the ZYNQ 7000 APSoC (All Programmable System on Chip), which integrates software programmability with an ARM-based processor and hardware programmability with an FPGA. This combination provides superior performance compared to systems that rely solely on software programming, such as widely known development boards like Arduino, Espressif, and Raspberry Pi.

The specifications for these boards can be found on the developer's website, Digilent:
- [PYNQ-Z1](https://digilent.com/reference/programmable-logic/pynq-z1/start)
- [Arty Z7](https://digilent.com/reference/programmable-logic/arty-z7/start)

<h2>Workflow</h2>

<h3>Hardware Design and Simulations for Data Transmission via the UART Protocol</h3>

<h3>Software Design for Receiving Serialized Data and Analog Data Output via the DAC</h3>

<h3>Hardware Design for Analog Reception</h3>

<h3>Design of a Random Pulse Generator</h3>

<h3>Evaluation of Sending Different Signals by Stages</h3>








