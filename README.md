# VSDSquadron FM Research Internship by Ojasvi Shah


# Task 1: Understanding and Implementing the Verilog Code on FM
## Objective: 
To Understand and document the provided Verilog code, creating the necessary PCF file, and integrating the design with the VSDSquadron FPGA Mini Board using the provided [datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)


**Step 1: Analysis of the Verilog Implementation**

**Accessing the Source Code**

The Verilog source code controlling  the RGB LED functionality is accessible via the following repository: [VSDSquadron_FM Verilog Code](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/top.v)

**Architectural Overview**

The Verilog module controls the behavior of an RGB LED with an internal oscillator as a clock source and a frequency counter for modulation. The design provides stable timing control and LED signal generation.

**Module Interface**

- **Outputs:** 
  - led\_red, led\_blue, led\_green: Control signals for the RGB LED.
  - testwire: A test signal for verification purposes.
- **Inputs:** 
  - hw\_clk: Primary clock input sourced from the onboard oscillator.

**Internal Design Elements**

***Internal Oscillator (SB\_HFOSC)***

- This embedded component supplies an oscilation of system clock that dispenses with an external oscillator requirement.
- The output frequency sets the performance of subsequent logic functions, so all LED timing conduct is regular and consistent.
- The oscillator frequency is at a pre-configured rate that has an impact on all subsequent dependent digital logic contained within the module

**Frequency Counter Mechanism**

- Counter logic runs through the oscillator's frequency for commanding RGB LED states.
- The resulting frequency modulates the behavior of LED, creating a visible blinking effect.
- The counter counts up at every clock cycle and resets when it reaches a specified limit, generating a timed signal.

**RGB LED Driver Configuration**

- The driver controls current flow through the RGB LED to maintain proper function.
- Current levels and duty cycles can be manipulated to change LED brightness and color mixing.
- A pulse-width modulation (PWM) scheme is employed to provide smooth LED transitions and color control

**Step 2: Pin Constraint File (PCF) Definition**

**Accessing the PCF File**

The pin constraint file, which describes FPGA-to-board pin mappings, is here: [VSDSquadronFM.pcf](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/VSDSquadronFM.pcf)


**Pin Mapping and Hardware Correlation**

|**Signal**|**FPGA Pin**|
| :- | :- |
|led\_red|39|
|led\_blue|40|
|led\_green|41|
|hw\_clk|20|
|testwire|17|

**Verification with the VSDSquadron FPGA Mini Datasheet**

- Cross-check every signal-to-pin mapping with the hardware datasheet.
- Make sure that physical pin locations are consistent with anticipated connections within the Verilog implementation.
- Verify the electrical specifications of every assigned pin to avoid conflicts or misconfigurations.


**Step 3: FPGA Board Integration and Deployment**

**Hardware Setup**

- Refer to the **VSDSquadron FPGA Mini Datasheet** for board details and pinout specifications.
- Connect a USB-C interface between the board and the host computer.
- Check FTDI connection in order to facilitate FPGA programming and debugging.
- Proper power supply and stable connections to avoid communication errors during flashing.

**Compilation and Flashing Workflow**

A Makefile is used for compilation and flashing of the Verilog design. The repository link is: [Makefile](https://github.com/thesourcerer8/VSDSquadron_FM/blob/main/led_blue/Makefile)

**Execution Sequence**

make clean # Clear out old compilation artifacts

make build # Compile the Verilog design

sudo make flash # Upload the synthesized bitstream to the FPGA

**Expected Functional Behavior**

- The FPGA should be able to correctly program the LED control logic.
- The RGB LED must display a given blinking pattern, verifying correct operational behavior.
- The system should be able to respond to changes in the internal oscillator, to maintain synchronization with the counter logic.
- The use of debugging aids, i.e., test points or simulation waveforms, can be applied to ensure correct module operation.

**Step 4: Final Documentation and Repository Organization**

**Functional Summary of the Verilog Implementation**

- The solution utilizes an oscillator-driven frequency counter to control RGB LED behavior.
- The flashing sequence is established from the frequency output modulation.
- The onboard clocking architecture avoids the use of external timing components, leading to higher integration efficiency.
- The testwire output is an aid for diagnosing, used for external timing monitoring of the system.

**Pin Mapping Verification**

- Finalized FPGA pin constraints are cross-checked with respect to the specifications of the VSDSquadron FPGA Mini.
- An accurate pin mapping guarantees signal integrity and correct circuit behavior.
- Correctly allocated pins avoid unwanted electrical problems or misrouting during PCB design.






