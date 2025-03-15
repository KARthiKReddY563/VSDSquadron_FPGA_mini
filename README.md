# VSDSquadron FM Research Internship 


# Task 1: Understanding and Implementing the Verilog Code on FM
## Objective: 
To Understand and document the provided Verilog code, creating the necessary PCF file, and integrating the design with the VSDSquadron FPGA Mini Board using the provided [datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)



<details>
<summary> Step 1: Analysis of the Verilog Implementation</summary>

The Verilog source code controlling  the RGB LED functionality is accessible via the following repository: [VSDSquadron_FM Verilog Code](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/top.v)

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
`CLKHF_DIV` is a parameter that sets the clock divider for the oscillator. The value `"0b10"` corresponds to a divider setting of 4, which means the output frequency will be 12 MHz if the nominal oscillator frequency is 48 MHz15
Common settings for CLKHF_DIV:

`"0b00"` for 48 MHz

`"0b01"` for 24 MHz

`"0b10"` for 12 MHz

`"0b11"` for 6 MHz

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
- 
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
Step 2: Pin Constraint File (PCF) Definition**

<details>
  <summary>Step 2: Pin Constraint File (PCF) Definition</summary>
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

**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/Makefile)



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


  
</details>
# Task 2: Implementing a UART loopback mechanism
## Objective:
Implement a UART loopback mechanism where transmitted data is immediately received back, facilitating testing of UART functionality

<details>

The Verilog source code for the UART Loopback functionality is found in the following repository: [VSDSquadron_FM Verilog Code](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/top.v)


<summary> Step 1: Study the Existing Code
</summary>

### Port Analysis:
The module explains six ports:
- Three **RGB LED outputs** (led_red, led_blue, led_green)
- **UART transmit/receive pins** (uarttx, uartrx)
- **System clock input** (hw_clk)

### Internal Component Analysis
1. **Internal Oscilliator** (SB_HFOSC)
- Implements a high-frequency oscillator
- Uses CLKHF_DIV = "0b10" for frequency division
- Generates internal clock signal (int_osc)

2. **Frequency Counter**
- 28-bit counter (frequency_counter_i)
- Increments on every positive edge of internal oscillator
- Used for timing generation

3. **UART Loopback**
- Direct connection between transmit and receive pins
- Echoes back any received UART data immediately

4. **RGB LED Driver** (SB_RGBA_DRV)
- Controls three RGB channels
- Uses PWM (Pulse Width Modulation) for brightness control
- Current settings configured for each channel
- Maps UART input directly to LED intensity

### Operation Analysis
- The UART TX 8N1 module operates as a serial transmitter that converts parallel data into a serial bitstream following the 8N1 UART protocol. Let's analyze its operation in detail:

- The entire module operates on the positive edge of the clock signal (posedge clk). Each state transition and bit transmission occurs at a clock edge, meaning the transmission rate is directly tied to the clock frequency.

### Transmission Sequence

1. #### Idle State
  - During idle, the TX line is held high (logic 1), which is the standard UART idle state.
  - The module waits for the senddata signal to be asserted.
1. #### Start Bit Transmission
  - When senddata is asserted, the module captures the input byte into buf_tx.
  - It then transitions to STATE\_STARTTX where it pulls the TX line low (logic 0) for one clock cycle.
  - >This low signal serves as the start bit, signaling to the receiver that data transmission is beginning.
1. #### Data Bits Transmission
  - In STATE\_TXING, the module transmits 8 data bits sequentially.
  - It sends the least significant bit (LSB) first by outputting buf\_tx to the TX line.
  - After each bit transmission, it right-shifts buf\_tx to position the next bit.
  - The counter bits\_sent tracks how many bits have been transmitted.
1. #### Stop Bit and Completion
  - After all 8 data bits are sent, the TX line is pulled high again for the stop bit.
  - The module then transitions to STATE\_TXDONE where it asserts the txdone signal.
    - Finally, it returns to the idle state, ready for the next transmission.

### Timing Considerations

 Without a baud rate generator, each bit (start, data, and stop) is transmitted for exactly one clock cycle. This means:

- If the clock is running at 9600 Hz, the UART will transmit at 9600 baud.
- A complete 8N1 frame (1 start + 8 data + 1 stop) takes exactly 10 clock cycles.
- The txdone signal is asserted for one clock cycle after transmission completes.

### Data Flow 

The data path involves:

  -  Parallel data (txbyte) is loaded into buf_tx register.
- buf_tx is right-shifted during transmission, exposing each bit sequentially.
- The current bit is placed on the tx output through the txbit register.

This implementation uses a simple but effective approach for UART transmission.


</details>


<details>
<summary> Step 2: Design Documentation
</summary>
<details>
<summary>Block Diagram .</summary>

![Image](https://github.com/user-attachments/assets/b110bef8-ae00-4a04-9219-bad1290bb2e1)
</details>

<details>
<summary> Circuit Diagram showing Connections between the FPGA and any Peripheral Devices used.</summary>

![Image](https://github.com/user-attachments/assets/e46e9fde-0a17-4ef5-8079-75c2011de1ad)
</details>

</details>
<details>
<summary>Step 3: FPGA Board Integration and Deploymen
</summary>


    
**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/Makefile)



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



    
 1. For the testing purpose we will use docklight software which is a simulation tool for serial communication protocols. It allows us to monitor the communication between two serial devices.It can be downladed from [here](https://docklight.de/downloads/).

    
2. After installation, open Docklight and select "Start with a blank project / blank script" to begin.

 - Configure the correct communication port:

  - Go to Tools > Project Settings

 - In the Communication tab, select your COM port (COM7 in your case)

- Verify the speed is set to 9600 bps (not the default 115200)

- Ensure other settings are correct: 8 data bits, 1 stop bit, no parity, and no flow control


    
![Image](https://github.com/user-attachments/assets/f6e605fb-d9e6-4b33-a143-d8fd8fa73177)

3. To create a new send sequence:

- Double-click on the last empty line in the Send Sequences table (the small blue box you mentioned)

- The "Edit Send Sequence" dialog will appear

4. In the dialog:

- Enter a unique name for your sequence in the "Name" field

- Select your preferred format (ASCII, HEX, Decimal, or Binary) using the "Edit Mode" radio buttons
- Type your message in the "Sequence" field.Click "OK" to add the sequence to your list

5.  To send the sequence:

- Click the arrow button next to the sequence name in the Send Sequences list

- Docklight will transmit your sequence through the configured COM port

- The sent data will appear in the communication window with a [TX] prefix.


6. In our case, we've created a loopback configuration by connecting the TX (transmit) pin directly to the RX (receive) pin. This means that any data we send out through the TX pin will be immediately received back on the RX pin, allowing us to verify that our transmission is working correctly by confirming we receive the exact same message that we sent.We can verify it in below image.
![Image](https://github.com/user-attachments/assets/19f37337-557c-4a8c-9649-b1112d7adaf0)

</details>

# Task 3: Developing a UART Transmitter Module
## Objective: 
Develop a UART transmitter module capable of sending serial data from the FPGA to an external device.

<details>

<summary> Step 1: Study the Existing Code</summary>

The Verilog source code for the UART Transmitter module can be found  via the following repository: [VSDSquadron_FM Verilog Code](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/top.v)


### Module Overview

- The UART TX 8N1 module operates as a serial transmitter that converts parallel data into a serial bitstream following the 8N1 UART protocol. Let's analyze its operation in detail:

- The entire module operates on the positive edge of the clock signal (posedge clk). Each state transition and bit transmission occurs at a clock edge, meaning the transmission rate is directly tied to the clock frequency.

### Transmission Sequence

1. #### Idle State
  - During idle, the TX line is held high (logic 1), which is the standard UART idle state.
  - The module waits for the senddata signal to be asserted.
2. #### Start Bit Transmission
  - When senddata is asserted, the module captures the input byte into buf_tx.
  - It then transitions to STATE\_STARTTX where it pulls the TX line low (logic 0) for one clock cycle.
  - >This low signal serves as the start bit, signaling to the receiver that data transmission is beginning.
3. #### Data Bits Transmission
  - In STATE\_TXING, the module transmits 8 data bits sequentially.
  - It sends the least significant bit (LSB) first by outputting buf\_tx to the TX line.
  - After each bit transmission, it right-shifts buf\_tx to position the next bit.
  - The counter bits\_sent tracks how many bits have been transmitted.
4. #### Stop Bit and Completion
  - After all 8 data bits are sent, the TX line is pulled high again for the stop bit.
  - The module then transitions to STATE\_TXDONE where it asserts the txdone signal.
  - Finally, it returns to the idle state, ready for the next transmission.

### Timing Considerations

 Without a baud rate generator, each bit (start, data, and stop) is transmitted for exactly one clock cycle. This means:

- If the clock is running at 9600 Hz, the UART will transmit at 9600 baud.
- A complete 8N1 frame (1 start + 8 data + 1 stop) takes exactly 10 clock cycles.
- The txdone signal is asserted for one clock cycle after transmission completes.

### Data Flow 

The data path involves:

  -  Parallel data (txbyte) is loaded into buf_tx register.
- buf_tx is right-shifted during transmission, exposing each bit sequentially.
- The current bit is placed on the tx output through the txbit register.

This implementation uses a simple but effective approach for UART transmission.
</details>

<details>
 <summary>Step 2: Design Documentation
</summary>


<details>
  <summary> Block diagram detailing the UART transmitter module
</summary>
![Image](https://github.com/user-attachments/assets/5197a3fd-8bc5-4751-b6ff-52e2ebbbb8c7)
![Image](https://github.com/user-attachments/assets/aaf19a22-3e30-430e-a8f4-eb0c393673be)
</details>

<details>
  <summary>Circuit diagram illustrating the FPGA's UART TX pin connection to the receiving device
</summary>
 
 ![Image](https://github.com/user-attachments/assets/71ff7fa7-2c8d-49ef-af34-d36e5d2a8529)
</details>


</details>


<details>

<summary>Step 3: Implementation
</summary>


    
**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/Makefile)



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

1. Install, and then open PuTTy.
2. 2. Select the serial option and verify if the Speed(baud rate) is 9600.
3. Verify that the correct port is connected through serial communication (COM 9 in my case)
4. Then, check that a series of "K"s are generated and the RGB LED is blinking (switching between red, green and blue) .


Task 3 is succesfully completed.
</details>






# Task 4: Implementing a UART Transmitter that Sends Data Based on Sensor Inputs
## Objective:
Implement a UART transmitter that sends data based on sensor inputs, enabling the FPGA to communicate real-time sensor data to an external device.



<details>
<summary> Step 1: Study the Existing Code</summary>
  
The Verilog source code for the Task 4 can be found  via the following repository: [VSDSquadron_FM Verilog Code](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/top.v)
Overview of the Block Diagram

The diagram illustrates a complete sensor data acquisition and UART transmission system with the following components:

1. **Sensor Data Path**:
   1. Sensor → Sensor Interface → Data Processing → Data Buffer
   2. This path handles the acquisition and initial processing of sensor data
2. **FPGA Processing Path**:
   1. FPGA → Baud Rate Generator
   2. Provides timing control for UART transmission
3. **Transmission Path**:
   1. Data Buffer (Stores Sensor Data) → TX Shift Register → UART TX Logic → UART Output
   2. Handles the actual UART transmission process
4. **Control Logic** 
   1. State Machine (connected to UART TX Logic)
   2. Manages the transmission sequence

Code Analysis: uart_tx_8n1 Module

The provided uart_tx_8n1 module implements a basic 8N1 UART transmitter (8 data bits, No parity, 1 stop bit).

**Key Components:**

1. **Interface Signals**:
   1. clk: Input clock (9600 Hz in the top module)
   2. txbyte: 8-bit data to transmit
   3. senddata: Trigger to start transmission
   4. txdone: Output signal indicating transmission completion
   5. tx: Serial UART output line
2. **State Machine**:
   1. STATE\_IDLE: Waiting for transmission request
   2. STATE\_STARTTX: Sending start bit (logic low)
   3. STATE\_TXING: Transmitting 8 data bits
   4. STATE\_TXDONE: Sending stop bit and signaling completion
3. **Internal Registers**:
   1. state: Current state of the FSM
   2. buf\_tx: Buffer holding the byte being transmitted
   3. bits\_sent: Counter for transmitted bits
   4. txbit: Current bit being transmitted
   5. txdone: Transmission completion flag

**Operation Flow:**

1. **Idle State**:
   1. TX line is held high
   2. Waits for senddata signal
2. **Start Bit**:
   1. When senddata is asserted, transitions to STATE\_STARTTX
   2. Outputs logic low (start bit)
3. **Data Bits**:
   1. Shifts out 8 data bits from buf\_tx LSB first
   2. Increments bits\_sent counter
4. **Stop Bit**:
   1. After 8 bits, outputs logic high (stop bit)
   2. Transitions to STATE\_TXDONE
5. **Completion**:
  1. Asserts txdone signal
  2. Returns to STATE\_IDLE

Top Module Analysis

The top module integrates the UART transmitter with:

1. **Clock Generation**:
   1. Uses internal high-frequency oscillator (SB\_HFOSC)
   2. Divides down to generate 9600 Hz clock for UART
2. **UART Implementation**:
   1. Instantiates uart\_tx\_8n1 module
   2. Configured to repeatedly transmit ASCII character 'D'
   1. Transmission triggered by bit 24 of a counter (creates periodic transmission)
3. **LED Control**:
   1. Uses SB\_RGBA\_DRV primitive for RGB LED control
   2. LED states tied to UART RX input (visual feedback)


</details>
<details>
<summary> Step 2: Design Documentation</summary>

<details>
<summary>Block diagram depicting the integration of the sensor module with the UART transmitter.</summary>



![Image](https://github.com/user-attachments/assets/8ff5da4d-a1c4-454d-bd20-cdc99ebab02a)

</details>
<details>
<summary> Circuit diagram showing connections between the FPGA, sensor, and the receiving device.</summary>



![Image](https://github.com/user-attachments/assets/b0bfe8d6-d3c3-46b8-a4b9-f34df53333e5)

</details>
</details>

<details>

<summary>Step 3: Implementation
</summary>


    
**Hardware Setup**

- Refer to the [VSDSquadron FPGA Mini Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)
 for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Ensure proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/Makefile)



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

1. Install, and then open PuTTy.
2. Select the serial option and verify if the Speed(baud rate) is 9600.
3. Verify that the correct port is connected through serial communication (COM 9 in my case)/
4. Then, check that a series of "F"s are generated .


Task 4 is succesfully completed.
</details>






