`timescale 1ns/1ps                  // Defines simulation time unit (1ns) and precision (1ps)
`include "top.v"                    // Includes the top-level design module

module top_tb();                    // Testbench module declaration (no ports)

    reg hw_clk = 0;                 // Hardware clock signal, initialized to 0
    reg echo = 0;                   // Echo signal from ultrasonic sensor, initialized to 0
    wire uarttx;                    // UART transmit line output
    wire trig;                      // Trigger signal to ultrasonic sensor
    wire led_red, led_blue, led_green; // RGB LED outputs
    
    // Instantiate top module (device under test)
    top uut (                       // Unit Under Test (UUT) instantiation
        .led_red(led_red),          // Connect LED outputs
        .led_blue(led_blue),
        .led_green(led_green),
        .uarttx(uarttx),            // Connect UART transmit line
        .echo(echo),                // Connect echo input
        .trig(trig),                // Connect trigger output
        .hw_clk(hw_clk)             // Connect hardware clock
    );

    // Generate 12 MHz clock (83.33 ns period)
    always #41.67 hw_clk = ~hw_clk; // Toggle clock every 41.67ns (half of 83.33ns period)
    
    // Echo response generation
    initial begin                   // Initial block for test sequence
        // Initialize inputs
        echo = 0;                   // Ensure echo starts at 0
        
        // ===== First Measurement: 234 cm =====
        // Wait for initial trigger pulse
        @(posedge trig);            // Wait for rising edge on trigger signal
        $display("\n[%0t] Trigger 1 Received - Starting 234 cm measurement", $time);
        
        // Simulate 234 cm distance (162,864 cycles = 234 cm * 696 cycles/cm)
        #10000;                     // 10µs delay before echo response
        echo = 1;                   // Set echo high
        repeat(162864) @(posedge hw_clk);  // Hold echo high for 234cm equivalent time
        echo = 0;                   // Set echo low
        
        // Wait for processing and display
        #500000;                    // 500µs delay for processing
        $display("[%0t] Measured Distance 1: %0d cm (Expected: 234)", 
                $time, uut.distance_cm);  // Display measured distance
        
        // ===== Second Measurement: 400 cm =====
        // Wait 15ms between measurements
        #100000;                    // 100µs additional delay
        
        // Reset ultrasonic FSM (commented out in the code)
       
        // Wait for second trigger
        @(posedge trig);            // Wait for next rising edge on trigger
        $display("\n[%0t] Trigger 2 Received - Starting 400 cm measurement", $time);
        
        // Simulate 400 cm distance (278,400 cycles = 400 cm * 696 cycles/cm)
        #10000;                     // 10µs delay before echo response
        echo = 1;                   // Set echo high
        repeat(278400) @(posedge hw_clk);  // Hold echo high for 400cm equivalent time
        echo = 0;                   // Set echo low
        
        // Final processing and display
        #500000;                    // 500µs delay for processing
        $display("[%0t] Measured Distance 2: %0d cm (Expected: 400)", 
                $time, uut.distance_cm);  // Display measured distance
    end
    
    // Simulation control and monitoring
    initial begin                   // Second initial block for simulation control
        $dumpfile("top_tb.vcd");    // Specify VCD file for waveform dumping
        $dumpvars(0, top_tb);       // Dump all variables in the testbench
        
        // UART transmission monitor
        $monitor("[%0t] UART_TX: %b | State: %d ",  // Continuous monitoring format
                $time, uarttx, uut.uart_state);     // Monitor time, UART TX, and state
        
        // Total simulation time (adjust based on needs)
        #80000000;                  // Run simulation for 80ms
        $display("\nSimulation Complete");  // Display completion message
        $finish;                    // End simulation
    end

endmodule
