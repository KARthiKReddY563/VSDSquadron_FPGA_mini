# VSDSquadron FM Research Internship 


# Task 1: Understanding and Implementing the Verilog Code on FM
## Objective: 
To Understand and document the provided Verilog code, creating the necessary PCF file, and integrating the design with the VSDSquadron FPGA Mini Board using the provided [datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)



<details>
<summary> Step 1: Analysis of the Verilog Implementation</summary>
<br>
  
The Verilog source code controlling  the RGB LED functionality is accessible via the following repository: [Task 1](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/tree/main/Task1).


**Architectural Overview**

The Verilog module controls the behavior of an RGB LED with an internal oscillator as a clock source and a frequency counter for modulation. The design provides stable timing control and LED signal generation.

**Module Interface**

- **Outputs:** 
  - `led_red`, `led_blue`, `led_green`: Control signals for the RGB LED.
  - `testwire`: A test output that shows the state of bit 5 from the counter frequency_counter_i for debugging purposes.



- **Inputs:** 
  - `hw_clk`: Primary clock input sourced from the onboard oscillator.

### Internal Design Elements

**1. Internal Oscillator (`SB_HFOSC`)**

- This embedded component supplies an oscilation of system clock that dispenses with an external oscillator requirement.
- The output frequency sets the performance of subsequent logic functions, so all LED timing conduct is regular and consistent.
  
`SB_HFOSC`:
This is a Verilog module that generates a high-frequency oscillator. It is commonly used in Lattice FPGAs (like the iCE40 series).
It has configurable parameters to control things like the division factor of the output frequency.

`CLKHF_DIV ("0b10")`:
`CLKHF_DIV` is a parameter that sets the clock divider for the oscillator. The value `"0b10"` corresponds to a divider setting of 4, which means the output frequency will be 12 MHz if the nominal oscillator frequency is 48 MHz.
Common settings for CLKHF_DIV:

- `"0b00"` for 48 MHz.

- `"0b01"` for 24 MHz.

- `"0b10"` for 12 MHz.

- `"0b11"` for 6 MHz.

*Control Signals*:

`CLKHFPU (1'b1)`:

`CLKHFPU` is the power-up signal for the high-frequency oscillator.
1'b1 means that the oscillator is powered up. If this signal were set to 1'b0, the oscillator would remain powered off.

`CLKHFEN (1'b1)`:
`CLKHFEN` is the enable signal for the oscillator.
1'b1 enables the oscillator. If this signal were 1'b0, the oscillator would not function, regardless of other settings.

`CLKHF (int_osc)`:
`CLKHF` is the high-frequency oscillator output, which generates the clock signal.
The output is connected to the int_osc wire, which is the internal clock signal used by other parts of the module.

**Frequency Counter Mechanism**

- Counter logic runs through the oscillator's frequency for commanding RGB LED states.
- The resulting frequency modulates the behavior of LED, creating a visible blinking effect.
- The counter counts up at every clock cycle and resets when it reaches a specified limit, generating a timed signal.

**RGB LED Driver Configuration**

- The driver controls current flow through the RGB LED to maintain proper function.
- Current levels and duty cycles can be manipulated to change LED brightness and color mixing.
- A pulse-width modulation (PWM) scheme is employed to provide smooth LED transitions and color control

- `RGBLEDEN(1'b1)`: Enables the RGB LED.
- `RGB0PWM (1'b0)`: Red LED minimum brightness (Red = OFF)
- `RGB1PWM (1'b0)`: Green LED minimum brightness (Green = OFF)
- `RGB2PWM (1'b1)`: Blue LED maximum brightness (Blue = ON)
- `CURREN (1'b1)`: Enables the current control.
- `RGB0`, `RGB1`, `RGB2`: Connects to actual hardware (led_red, led_green, led_blue).

*Current Settings (via def param)*:

- `RGB0_CURRENT = "0b000001"`: Sets the red LED current.
- `RGB1_CURRENT = "0b000001"`: Sets the green LED current.
- `RGB2_CURRENT = "0b000001"`: Sets the blue LED current.
  
**Purpose of the Module**

The purpose of this Verilog module, named `top`, is to control an RGB LED system using an internal oscillator and a counter. It encapsulates the logic necessary for managing the intensity and color of the LEDs.

**Description of Internal Logic and Oscillator**

 1. **Internal Logic:**
  - The module includes a counter `(frequency_counter_i)` that increments at every positive edge of the internal oscillator `(int_osc)`.
  - The counter's value is used to drive a test signal `(testwire)`, which is assigned the 6th bit of the counter.
2. **Oscillator:**
  - The internal oscillator is implemented using the `SB_HFOSC` module, which generates a high-frequency clock.
- The oscillator is enabled and powered up (`CLKHFPU = 1'b1`, `CLKHFEN = 1'b1`).

**Functionality of the RGB LED Driver and Its Relationship to the Outputs**

1. **RGB LED Driver:**
- The RGB LED driver is implemented using the `SB_RGBA_DRV` module.
- It controls the RGB LEDs by setting their PWM signals (`RGB0PWM`, `RGB1PWM`, `RGB2PWM`) and current settings (`RGB0_CURRENT`, `RGB1_CURRENT`, `RGB2_CURRENT`).
2. **Relationship to the Outputs:**
- The outputs of the module are the actual RGB LED connections (`led_red`, `led_green`, `led_blue`).
- The RGB LEDs are enabled (`RGBLEDEN = 1'b1`), and their PWM signals are set to predefined values (`RGB0PWM = 1'b0`, `RGB1PWM = 1'b0`, `RGB2PWM = 1'b1`).

</details>


<details>
  <summary>Step 2: Pin Constraint File (PCF) Definition</summary>

  <br>
  
  **Accessing the PCF File**

The pin constraint file, which describes FPGA-to-board pin mappings, is here: [VSDSquadronFM.pcf](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/VSDSquadronFM.pcf)

**Pin Mapping and Hardware Correlation**

|**Signal**|**FPGA Pin**|**Function**|
| :- | :- | :-|
|led\_red|39|Drives the red channel of the RGB LED via PWM signal, controlling its intensity.|
|led\_blue|40|Drives the blue channel of the RGB LED via PWM signal, controlling its intensity.|
|led\_green|41|Drives the green channel of the RGB LED via PWM signal, controlling its intensity.|
|hw\_clk|20|Receives the hardware clock signal, serving as the primary timing reference for the FPGA's internal logic and operations.|
|testwire|17|Configured for testing purposes.|
</details>



<details>
  <summary>Step 3: FPGA Board Integration and Deployment</summary>
<br>
  
**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task1/Makefile).



**Execution Sequence**
```
lsusb # To check if Fpga is connected

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA

```
**Expected Functional Behavior**

- The FPGA should be able to correctly program the LED control logic.
- The RGB LED must display a given blinking pattern, verifying correct operational behavior.
- The system should be able to respond to changes in the internal oscillator, to maintain synchronization with the counter logic.

</details>

<details>
<summary>Step 4: Final Documentation and Repository Organization</summary>
<br>
  
**Functional Summary of the Verilog Implementation**

- The code is designed to manage RGB LEDs using PWM signals for color control.The internal oscillator drives the counter, which can be used to dynamically adjust the PWM signals for more complex color patterns.The testwire provides a means to observe the internal oscillator's frequency indirectly.



**Pin Mapping Verification**

|**Signal**|**FPGA Pin**|
| :- | :- |
|led\_red|39|
|led\_blue|40|
|led\_green|41|
|hw\_clk|20|
|testwire|17|

- Finalized FPGA pin constraints are cross-checked with respect to the specifications of the VSDSquadron FPGA Mini.
- An accurate pin mapping guarantees signal integrity and correct circuit behavior.

 
<details>
  <summary> Video demonstrating Task 1 (using 48MHz clock ) </summary>
  
https://github.com/user-attachments/assets/95510870-3ad2-4bbc-b6f8-2143b636e00c
</details>
<details>
  <summary> Video demonstrating Task 1 (using 24MHz clock ) </summary>
  
https://github.com/user-attachments/assets/c42ad4e5-1598-4da6-9159-4bd9a65f42af
</details>
<details>
  <summary> Video demonstrating Task 1 (using 12MHz clock ) </summary>

https://github.com/user-attachments/assets/deaffc83-271a-4d2d-99e6-365eed995d21
</details>
<details>
  <summary> Video demonstrating 1 (using 6MHz clock ) </summary>
  
https://github.com/user-attachments/assets/195c507b-8f67-46b6-905c-bef2a5c8d349
</details>


Task 1 is succesfully completed.
</details>

# Task 2: Implementing a UART loopback mechanism

## Objective:
Implement a UART loopback mechanism where transmitted data is immediately received back, facilitating testing of UART functionality

<details>



<summary> Step 1: Study the Existing Code
</summary>

<br>

 The Verilog source code for the UART Loopback functionality is found in the following repository: [Task 2](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task2/top.v).

### Port Analysis:
The module explains six ports:
- Three **RGB LED outputs** ( `led_red`, `led_blue`, `led_green`)
- **UART transmit/receive pins** (`uarttx`, `uartrx`)
- **System clock input** (`hw_clk`)

### Internal Component Analysis
1. **Internal Oscilliator** (`SB_HFOSC`)
- Implements a high-frequency oscillator
- Uses CLKHF_DIV = "0b10" for frequency division
- Generates internal clock signal (`int_osc`)

2. **Frequency Counter**
- 28-bit counter (`frequency_counter_i`)
- Increments on every positive edge of internal oscillator
- Used for timing generation

3. **UART Loopback**
- Direct connection between transmit and receive pins
- Echoes back any received UART data immediately

4. **RGB LED Driver** (`SB_RGBA_DRV`)
- Controls three RGB channels
- Uses PWM (Pulse Width Modulation) for brightness control
- Current settings configured for each channel
- Maps UART input directly to LED intensity

### Operation Analysis
- The `uart_tx_8n1` module operates as a serial transmitter that converts parallel data into a serial bitstream following the 8N1 UART protocol. Let's analyze its operation in detail:

- The entire module operates on the positive edge of the clock signal (posedge clk). Each state transition and bit transmission occurs at a clock edge, meaning the transmission rate is directly tied to the clock frequency.

### Transmission Sequence

1. #### Idle State
  - During idle, the `TX` line is held high (logic 1), which is the standard UART idle state.
  - The module waits for the `senddata` signal to be asserted.
2. #### Start Bit Transmission
  - When `senddata` is asserted, the module captures the input byte into `buf_tx`.
  - It then transitions to  `STATE_STARTTX` where it pulls the `TX` line low (logic 0) for one clock cycle.
  - This low signal serves as the start bit, signaling to the receiver that data transmission is beginning.
3. #### Data Bits Transmission
  - In `STATE_TXING`, the module transmits 8 data bits sequentially.
  - It sends the least significant bit (LSB) first by outputting `buf_tx` to the `TX` line.
  - After each bit transmission, it right-shifts `buf_tx` to position the next bit.
  - The counter `bits_sent` tracks how many bits have been transmitted.
4. #### Stop Bit and Completion
  - After all 8 data bits are sent, the `TX` line is pulled high again for the stop bit.
  - The module then transitions to `STATE_TXDONE` where it asserts the `txdone` signal.
  - Finally, it returns to the idle state, ready for the next transmission.

### Timing Considerations

 Without a baud rate generator, each bit (start, data, and stop) is transmitted for exactly one clock cycle. This means:

- If the clock is running at 9600 Hz, the UART will transmit at 9600 baud.
- A complete 8N1 frame (1 start + 8 data + 1 stop) takes exactly 10 clock cycles.
- The txdone signal is asserted for one clock cycle after transmission completes.

### Data Flow 

The data path involves:

-  Parallel data (txbyte) is loaded into `buf_tx` register.
- `buf_tx` is right-shifted during transmission, exposing each bit sequentially.
- The current bit is placed on the `tx` output through the txbit register.

This implementation uses a simple but effective approach for UART transmission.


</details>


<details>
<summary> Step 2: Design Documentation
</summary>
  <br>
  
<details>
<summary>Block Diagram .</summary>

![Image](https://github.com/user-attachments/assets/b110bef8-ae00-4a04-9219-bad1290bb2e1)
</details>
<br>
<details>
<summary> Circuit Diagram showing Connections between the FPGA and any Peripheral Devices used.</summary>

![Image](https://github.com/user-attachments/assets/e46e9fde-0a17-4ef5-8079-75c2011de1ad)
</details>

</details>


<details>
<summary>Step 3: Implementation
</summary>

  <br>
    
**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task2/Makefile)



**Execution Sequence**
```
lsusb # To check if Fpga is connected

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA

```


</details>
<details>
<summary>Step 4: Testing and Verification
</summary>

<br>
    
 1. For the testing purpose we will use docklight software which is a simulation tool for serial communication protocols. It allows us to monitor the communication between two serial devices.It can be downladed from [here](https://docklight.de/downloads/).

    
2. After installation, open Docklight and select "Start with a blank project / blank script" to begin.

 - Configure the correct communication port:

  - Go to Tools > Project Settings.

 - In the Communication tab, select your COM port (COM9 in my case).

- Verify the speed is set to 9600 bps (not the default 115200).

- Ensure other settings are correct: 8 data bits, 1 stop bit, no parity, and no flow control.


    
![Image](https://github.com/user-attachments/assets/f6e605fb-d9e6-4b33-a143-d8fd8fa73177)

3. To create a new send sequence:

- Double-click on the last empty line in the Send Sequences table.

- The "Edit Send Sequence" dialog will appear.

4. In the dialog:

- Enter a unique name for your sequence in the "Name" field.

- Select your preferred format (ASCII, HEX, Decimal, or Binary) using the "Edit Mode" radio buttons
- Type your message in the "Sequence" field.Click "OK" to add the sequence to your list.

5.  To send the sequence:

- Click the arrow button next to the sequence name in the Send Sequences list.

- Docklight will transmit your sequence through the configured COM port.

- The sent data will appear in the communication window with a [TX] prefix.


6. In our case, we've created a loopback configuration by connecting the TX (transmit) pin directly to the RX (receive) pin. This means that any data we send out through the TX pin will be immediately received back on the RX pin, allowing us to verify that our transmission is working correctly by confirming we receive the exact same message that we sent.We can verify it in below image.
   <br>
![Image](https://github.com/user-attachments/assets/19f37337-557c-4a8c-9649-b1112d7adaf0)

Task 2 is succesfully completed.
</details>

# Task 3: Developing a UART Transmitter Module
## Objective: 
Develop a UART transmitter module capable of sending serial data from the FPGA to an external device.

<details>

<summary> Step 1: Study the Existing Code</summary>

  <br>
  
The Verilog source code for the UART Transmitter module can be found  via the following repository: [Task 3](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task3/top.v).


### Module Overview

- The `uart_tx_8n1` module operates as a serial transmitter that converts parallel data into a serial bitstream following the 8N1 UART protocol. Let's analyze its operation in detail:

- The entire module operates on the positive edge of the clock signal (posedge clk). Each state transition and bit transmission occurs at a clock edge, meaning the transmission rate is directly tied to the clock frequency.

### Transmission Sequence

1. #### Idle State
  - During idle, the `TX` line is held high (logic 1), which is the standard UART idle state.
  - The module waits for the `senddata` signal to be asserted.
2. #### Start Bit Transmission
  - When `senddata` is asserted, the module captures the input byte into `buf_tx`.
  - It then transitions to  `STATE_STARTTX` where it pulls the `TX` line low (logic 0) for one clock cycle.
  - This low signal serves as the start bit, signaling to the receiver that data transmission is beginning.
3. #### Data Bits Transmission
  - In `STATE_TXING`, the module transmits 8 data bits sequentially.
  - It sends the least significant bit (LSB) first by outputting `buf_tx` to the `TX` line.
  - After each bit transmission, it right-shifts `buf_tx` to position the next bit.
  - The counter `bits_sent` tracks how many bits have been transmitted.
4. #### Stop Bit and Completion
  - After all 8 data bits are sent, the `TX` line is pulled high again for the stop bit.
  - The module then transitions to `STATE_TXDONE` where it asserts the `txdone` signal.
  - Finally, it returns to the idle state, ready for the next transmission.

### Timing Considerations

 Without a baud rate generator, each bit (start, data, and stop) is transmitted for exactly one clock cycle. This means:

- If the clock is running at 9600 Hz, the UART will transmit at 9600 baud.
- A complete 8N1 frame (1 start + 8 data + 1 stop) takes exactly 10 clock cycles.
- The txdone signal is asserted for one clock cycle after transmission completes.

### Data Flow 

The data path involves:

-  Parallel data (txbyte) is loaded into `buf_tx` register.
- `buf_tx` is right-shifted during transmission, exposing each bit sequentially.
- The current bit is placed on the `tx` output through the txbit register.

This implementation uses a simple but effective approach for UART transmission.


</details>

<details>
 <summary>Step 2: Design Documentation
</summary>
<br>

<details>
  <summary> Block diagram detailing the UART transmitter module
</summary>
  <br>
![Image](https://github.com/user-attachments/assets/5197a3fd-8bc5-4751-b6ff-52e2ebbbb8c7)

![Image](https://github.com/user-attachments/assets/aaf19a22-3e30-430e-a8f4-eb0c393673be)
</details>
<br>
<details>
  <summary>Circuit diagram illustrating the FPGA's UART TX pin connection to the receiving device
</summary>
 
 ![Image](https://github.com/user-attachments/assets/71ff7fa7-2c8d-49ef-af34-d36e5d2a8529)
</details>
<br>

</details>


<details>

<summary>Step 3: Implementation
</summary>

<br>

**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task3/Makefile).



**Execution Sequence**
```
lsusb # To check if Fpga is connected

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA

```


</details>



<details>
<summary>Step 4: Testing and Verification
</summary>
<br>
  
1. Install, and then open PuTTy.
2.  Select the serial option and verify if the Speed(baud rate) is 9600.
      
![Image](https://github.com/user-attachments/assets/8fa480d7-784c-4b57-9f7d-45a50e9067e8)

3. Verify that the correct port is connected through serial communication (COM 9 in my case).
4. Then, check that a series of "K"s are generated and the RGB LED is blinking (switching between red, green and blue) .

   <br>
   
<details>
  
  <summary> Video demonstrating Task 3 </summary>
  
 https://github.com/user-attachments/assets/60675e20-6911-40c9-9351-cba4d7d272a7
</details>

Task 3 is succesfully completed.
</details>


# Task 4: Implementing a UART Transmitter that Sends Data Based on Sensor Inputs
## Objective:
Implement a UART transmitter that sends data based on sensor inputs, enabling the FPGA to communicate real-time sensor data to an external device.



<details>
<summary> Step 1: Study the Existing Code</summary>
  
  <br>
  
The Verilog source code for the Task 4 can be found  via the following repository: [Task 4](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task4/top.v).


Overview of the Block Diagram

The diagram illustrates a complete sensor data acquisition and UART transmission system with the following components:

1. **Sensor Data Path**:
   1. Sensor → Sensor Interface → Data Processing → Data Buffer.
   2. This path handles the acquisition and initial processing of sensor data.
2. **FPGA Processing Path**:
   1. FPGA → Baud Rate Generator.
   2. Provides timing control for UART transmission.
3. **Transmission Path**:
   1. Data Buffer (Stores Sensor Data) → TX Shift Register → UART TX Logic → UART Output.
   2. Handles the actual UART transmission process.
4. **Control Logic** 
   1. State Machine (connected to UART TX Logic).
   2. Manages the transmission sequence.

Code Analysis: uart_tx_8n1 Module

The provided `uart_tx_8n1` module implements a basic 8N1 UART transmitter (8 data bits, No parity, 1 stop bit).

**Key Components:**

1. **Interface Signals**:
   1. `clk`: Input clock (9600 Hz in the top module).
   2. `txbyte`: 8-bit data to transmit.
   3. `senddata`: Trigger to start transmission.
   4. `txdone`: Output signal indicating transmission completion.
   5. `tx`: Serial UART output line.
2. **State Machine**:
   1. `STATE_IDLE`: Waiting for transmission request.
   2. `STATE_STARTTX`: Sending start bit (logic low).
   3. `STATE_TXING`: Transmitting 8 data bits.
   4. `STATE_TXDONE`: Sending stop bit and signaling completion.
3. **Internal Registers**:
   1. `state`: Current state of the FSM.
   2. `buf_tx`: Buffer holding the byte being transmitted.
   3. `bits_sent`: Counter for transmitted bits.
   4. `txbit`: Current bit being transmitted.
   5. `txdone`: Transmission completion flag.


**Operation Flow:**

1. **Idle State**:
   1. `TX` line is held high.
   2. Waits for senddata signal.
2. **Start Bit**:
   1. When senddata is asserted, transitions to `STATE_STARTTX`.
   2. Outputs logic low (start bit).
3. **Data Bits**:
   1. Shifts out 8 data bits from `buf_tx` LSB first.
   2. Increments `bits_sent` counter
4. **Stop Bit**:
   1. After 8 bits, outputs logic high (stop bit).
   2. Transitions to `STATE_TXDONE`.
5. **Completion**:
   1. Asserts txdone signal.
   2. Returns to `STATE_IDLE`.

Top Module Analysis

The `top` module integrates the UART transmitter with:

1. **Clock Generation**:
   1. Uses internal high-frequency oscillator (`SB_HFOSC`).
   2. Divides down to generate 9600 Hz clock for UART.
2. **UART Implementation**:
   1. Instantiates `uart_tx_8n1` module.
   2. Configured to repeatedly transmit ASCII character 'F'.
   1. Transmission triggered by bit 24 of a counter (creates periodic transmission).
3. **LED Control**:
   1. Uses `SB_RGBA_DRV` primitive for RGB LED control.
   2. LED states tied to UART RX input (visual feedback).


</details>
<details>
<summary> Step 2: Design Documentation</summary>
  
<br>
  
<details>
<summary>Block diagram depicting the integration of the sensor module with the UART transmitter.</summary>


![Image](https://github.com/user-attachments/assets/8ff5da4d-a1c4-454d-bd20-cdc99ebab02a)

</details>

<br>

<details>
<summary> Circuit diagram showing connections between the FPGA, sensor, and the receiving device.</summary>



![Image](https://github.com/user-attachments/assets/b0bfe8d6-d3c3-46b8-a4b9-f34df53333e5)

</details>

<br>
</details>

<details>

<summary>Step 3: Implementation
</summary>

<br>

**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Task4/Makefile).



**Execution Sequence**
```
lsusb # To check if Fpga is connected

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA

```


</details>



<details>
<summary>Step 4: Testing and Verification
</summary>
  
<br>

1. Install, and then open PuTTy.
2. Select the serial option and verify if the Speed(baud rate) is 9600.
   
![Image](https://github.com/user-attachments/assets/8fa480d7-784c-4b57-9f7d-45a50e9067e8)

3. Verify that the correct port is connected through serial communication (COM 9 in my case).
4. Then, check that a series of "F"s are generated .
   <br>
<details>
  <summary> Video demonstrating Task 4 </summary>
  
https://github.com/user-attachments/assets/ad5c3fd9-f7f4-490b-a9a6-5d1dbd1042aa
</details>
<br>
Task 4 is succesfully completed.
</details>

# Task 5  Real-Time Sensor Data Acquisition and Transmission System

## Objective

Real-Time Sensor Data Acquisition and Transmission System: This theme focuses on developing systems that interface with various sensors to collect data, process it using the FPGA, and transmit the information to external devices through communication protocols like UART.​



<details>
<summary>Step 1 : Project Description</summary>

<br>

This project implements an ultrasonic distance measurement system with UART output. It measures distance using an ultrasonic sensor (HC-SR04 or similar), converts the measurement to centimeters, and transmits the result to ESP8266(NodeMCU) via UART at 9600 baud. This project also provides visual feedback through RGB LEDs based on the measured distance.

</details>
<details>
  

<summary> Step 2: Define System Requirements</summary>

<br>

**Hardware Components:**

- VSDSquadron Fpga board.
- HC-SR04 ultrasonic sensor.
- ESP8266 (NodeMCU).
- USB cable.
- Connecting wires and breadboard.

**Software Tools:**

- Iverilog.
- Gtkwave.
- Visual Studio code.
- Arduino IDE for ESP8266 programming.
- Putty(Serial monitoring tool).

</details>
<details>
 <summary> Step 3: System Architecture</summary>
  <br>
<details>
 <summary> Block Diagram </summary>
![Image](https://github.com/user-attachments/assets/ac43e17e-b2a7-42bc-9c29-84b02d059f15) 
</details>
  <br>
  
The system consists of four primary functional blocks:

1. **Sensor Interface Module**
   1. Generates 10μs trigger pulses for the HC-SR04
   1. Measures echo pulse duration
   1. Implements 250ms cooldown period between measurements.
1. **Data Processing Module**
   1. Converts echo time to distance in centimeters
   1. Formats data for transmission
   1. Implements signal conditioning if necessary
1. **Communication Module**
   1. UART transmitter (9600 baud rate)
   1. Packet formation with start/stop bits.
   1. Serial data transmission to ESP8266
1. **Feedback and Display Module**
   1. RGB LED driver for visual distance indication
   1. Distance thresholds for color changes


**Data Flow**

1. HC-SR04 sensor receives trigger pulse from FPGA
1. Echo pulse duration is measured by FPGA
1. FPGA converts pulse duration to distance
1. Distance data is formatted and transmitted via UART
1. ESP8266 receives data for wireless transmission
1. RGB LED provides visual distance indication

</details>

<details>
<summary> Step 4: Project Implementation Plan</summary>

<br>

**Phase 1: System Setup and Component Testing**

- Configure FPGA development environment.
- Test HC-SR04 sensor functionality.
- Verify ESP8266 communication capabilities.
- Implement and test RGB LED driver.

**Phase 2: FPGA Module Development**

- Develop ultrasonic sensor interface module
  - Implement trigger pulse generation (10μs).
  - Create echo pulse measurement system.
  - Add 250ms cooldown period between measurements.

**Phase 3: Communication System Implementation**

- Develop UART transmitter module.
- Configure ESP8266 for data reception.
  

**Phase 4: Integration and Testing (2 weeks)**

- Combine all FPGA modules into complete system.
- Integrate ESP8266 with FPGA via UART.
- Implement RGB LED feedback based on distance thresholds.
- Conduct comprehensive system testing
  - Verify measurement accuracy at various distances.
  - Test communication reliability.
  - Validate visual feedback functionality.


Expected Outcomes

The completed system will provide:

- Real-time distance measurements using the HC-SR04 ultrasonic sensor.
- Reliable UART data transmission to the ESP8266.
- Visual feedback through RGB LEDs based on measured distance.


This project demonstrates the integration of sensor data acquisition with real-time processing and communication capabilities.

</details>

# Task 6 Implementation

## Objective

Execute the project plan by developing, testing, and validating the system.​




<details>
<summary>Step 1 : Developing FPGA Modules</summary>

<br>

The project is implemented using several interconnected Verilog modules, each handling specific functionality. Here's a detailed explanation of each module:

#### Ultrasonic Sensor Interface

The `ultrasonic` module manages the HC-SR04 ultrasonic distance sensor interface:

- **Parameters**:
  - `TRIGGER_CYCLES`: Controls the trigger pulse duration (set to 60 cycles).
  - `MAX_ECHO_CYCLES`: Prevents system hanging if echo never returns (24-bit max value). 
  - `COOLDOWN_CYCLES`: Ensures proper timing between measurements (12,000 cycles or 250ms at 12MHz).
- **Functionality**: Implements a 4-state FSM that:
  - Initializes counters in idle state.
  - Generates a trigger pulse to the sensor.
  - Measures the echo pulse width by counting clock cycles.
  - Enforces a cooldown period before starting the next measurement.

- The module outputs `pulse_width`, which represents the echo duration in clock cycles.

#### Distance Calculation

The `distance_calc` module converts echo pulse duration to distance:

- **Parameters**:
  - `CLK_PER_CM`: Calibration constant (348 clock cycles per centimeter).
- **Functionality**: Divides the echo pulse width by the calibration constant to calculate distance in centimeters.

#### BCD Converter

The `bcd_converter` module converts binary distance values to decimal digits:

- **Inputs**: 16-bit binary distance value.
- **Outputs**: Three 4-bit BCD values for hundreds, tens, and units digits,
- **Functionality**: Performs integer division and modulo operations to extract individual decimal digits from the binary distance value.

#### UART Transmission

The `uart_tx_8n1` module (included but not shown in detail) handles serial communication:

- **Functionality**: Transmits 8-bit data with no parity and 1 stop bit over UART protocol.

Top Module Integration

The `top` module integrates all components:

- **Clock Generation**: Uses the internal oscillator (SB\_HFOSC) configured to generate the system clock.
- **Measurement System**: Instantiates the ultrasonic sensor interface and distance calculation modules.
- **Data Processing**: Uses the BCD converter to prepare distance values for transmission.
- **UART Control**: Implements a 5-state FSM to transmit distance readings serially:
  - Waits for 1 second between transmissions.
  - Sends hundreds digit.
  - Sends tens digit.
  - Sends units digit.
  - Sends newline character.
- **LED Feedback**: Uses the RGB LED to provide visual distance feedback:
  - Red LED: Distance ≤ 50cm.
  - Green LED: Distance between 50cm and 100cm.
  - Blue LED: Distance > 100cm.

The system continuously measures distance, converts it to human-readable format, transmits it via UART, and provides visual feedback through the RGB LED.



</details>
<details>
  

<summary> Step 2: Simulation </summary>

<br>

I have used Icarus Verilog + Gtkwave to simulate the modules but if you have any other tools like Xilinx vivado/ISE, modelsim etc. you can use them.
Here is the installation for [Icarus verilog in windows.](https://www.youtube.com/watch?v=FqIhFxf9kFM)

```verilog
   always @(posedge clk_9600) begin
    case(uart_state)
        0: begin  // Wait 1 second
            send_uart <= 0;      // Ensure send signal is low
            if(timer == 12) begin   // 9600 cycles of 9600 Hz clock = 1 second
                timer <= 0;
                uart_state <= 1; // Move to sending hundreds digit
            end
            else timer <= timer + 1;
        end
         ....
    endcase
end
```
- For simulation purposes, I reduced the wait period in the UART transmission FSM by changing `timer == 9600` to `timer == 12`.
- This modification significantly decreases the memory requirements of the testbench while maintaining the same functional behavior.
- In the actual implementation, the timer would count to 9600 (representing a 1-second delay between transmissions), but for simulation purposes, the shorter count of 12 allows us to verify the system's operation without consuming excessive computational resources.



#### Simulation Results

- In the below image, the GTKWave simulation shows the UART transmission of distance data. 
- The distance_cm[15:0] signal shows a value of 0000, representing 0 centimeters. 
-  The system is transmitting this value over UART, where we can see tx_data[7:0] carrying the ASCII value "30" (hexadecimal representation of ASCII character '0'). 
- The UART transmission can be observed on the uarttx signal, which shows the serial bit pattern for transmitting the ASCII character '0' followed later by "0A" (the ASCII newline character).
-  The bits_sent[3:0] counter shows the progression of bits being transmitted for each character.

![Image](https://github.com/user-attachments/assets/f90a119d-a3a5-4deb-a575-b2c90256973a)

In the below  image :

- The distance_cm[15:0] value has changed to "00EA" (234 centimeters)
- The system is transmitting the digits sequentially:

    - "32" (ASCII for '2')

    - "33" (ASCII for '3')

    - "34" (ASCII for '4')

    - "0A" (newline)
- Beginning to transmit "32" again for the next cycle.
- The uarttx signal shows the serial transmission of each character.
- The bits_sent[3:0] counter cycles through 0-9 for each character transmitted.

![Image](https://github.com/user-attachments/assets/3d81bdd8-133e-4b2c-a298-34ba999ea98c)

- In the below image :

- The distance_cm[15:0] value has increased to "0190" (400 in decimal)
- The tx_data[7:0] signal shows the transmission sequence:

    - "34" (ASCII for '4')

    - "30" (ASCII for '0')

    - "0A" (newline)
- The uarttx signal continues to show the serial bit patterns
- The bits_sent[3:0] counter maintains its pattern of cycling through 0-9 for each character.

![Image](https://github.com/user-attachments/assets/9ac664f0-1cd9-48e9-be51-947b6191ff9e)

</details>

<details>

<br>

  
 <summary> Step 3: Testing with Hardware</summary>
<details>
  
  
<summary> Testing with Serial Termianl</summary>

<br>

1. **Hardware Setup**


- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.
- Connect TRIG (Pin 4) → HC-SR04 TRIG
- Connect ECHO (Pin 3)→ HC-SR04 ECHO.
- Connect 5 V to sensor VCC, common GND.
- Connect FPGA’s UARTTX (Pin 14) → USB–Serial RX.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Taks5%266/Makefile).

**Execution Sequence**
```
lsusb # To check if Fpga is connected

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA
```

2. **Terminal**:

   - Open putty and select serial option.
   - Verify the speed (baud rate) is 9600.
   - Verify that the correct port is connected through serial communication (COM 9 in my case).

3. **Measuring Distance**:

   - Place an object ~10 cm away from the sensor.
   - Terminal should display a reading around “0010” .
   - Move the object closer or farther to see changing values.

***

</details>

<details>
<summary> Testing with ESP8266</summary>
  
<br>
  
Change the `set_io uarttx` from  14 to  10 to send the signals via pin 10 in the [VSDSquadronFM.pcf](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Taks5%266/Makefile).

1. **Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.
- Connect TRIG (Pin 4) → HC-SR04 TRIG
- Connect ECHO (Pin 3)→ HC-SR04 ECHO.
- Connect 5 V to sensor VCC, common GND.
- Connect FPGA’s UARTTX (Pin 14) → USB–Serial RX.
  
**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Taks5%266/Makefile).

**Execution Sequence**
```
lsusb # To check if Fpga is connected

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA
```
- Upload the [esp9266_rx.c](https://github.com/KARthiKReddY563/VSDSquadron_FPGA_mini/blob/main/Taks5%266/esp8266_rx.c) to the ESP8266.
2. **Terminal**:

   - Open putty and select serial option.
   - Verify the speed (baud rate) is 9600.
   - Verify that the correct port is connected through serial communication (COM 10 in my case).
   - We can also check in the Serial Moniter window of Arduino ide.
   
3. **Measuring Distance**:

   - Place an object ~10 cm away from the sensor.

   - Terminal should display a reading around “Distance: 10 cm”.

   - Move the object closer or farther to see changing values.

***
</details>
</details>

<details>

<summary> Step 4: Verification 
</summary>
<br>

<details>
  

  
<summary> Video Demonstration (Termianl) 
</summary>
  
https://github.com/user-attachments/assets/1f4dcc04-079d-4188-898a-41927fe4b1a6
</details>
<details>

<br>

<summary> Video Demonstration (ESP8266)  
</summary>

https://github.com/user-attachments/assets/8b9ddb23-0b96-4498-a1b3-6e93c07f0cc5
</details>

<br>

</details>






