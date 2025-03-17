`timescale 1ns/1ps
`include "top.v"

module top_tb();

    reg hw_clk = 0;
    reg echo = 0;
    wire uarttx;
    wire trig;
    wire led_red, led_blue, led_green;
    
    // Instantiate top module
    top uut (
        .led_red(led_red),
        .led_blue(led_blue),
        .led_green(led_green),
        .uarttx(uarttx),
        .echo(echo),
        .trig(trig),
        .hw_clk(hw_clk)
    );

    // Generate 12 MHz clock (83.33 ns period)
    always #41.67 hw_clk = ~hw_clk;
    
    // Echo response generation
    initial begin
        // Initialize inputs
        echo = 0;
        
        // ===== First Measurement: 234 cm =====
        // Wait for initial trigger pulse
        @(posedge trig);
        $display("\n[%0t] Trigger 1 Received - Starting 234 cm measurement", $time);
        
        // Simulate 234 cm distance (162,864 cycles = 234 cm * 696 cycles/cm)
        #10000;       // Short delay before echo response
        echo = 1;
        repeat(162864) @(posedge hw_clk);  // 234 cm pulse
        echo = 0;
        
        // Wait for processing and display
        #500000;
        $display("[%0t] Measured Distance 1: %0d cm (Expected: 234)", 
                $time, uut.distance_cm);
        
        // ===== Second Measurement: 400 cm =====
        // Wait 15ms between measurements
        #100000;
        
        // Reset ultrasonic FSM
       
        // Wait for second trigger
        @(posedge trig);
        $display("\n[%0t] Trigger 2 Received - Starting 400 cm measurement", $time);
        
        // Simulate 400 cm distance (278,400 cycles = 400 cm * 696 cycles/cm)
        #10000;
        echo = 1;
        repeat(278400) @(posedge hw_clk);  // 400 cm pulse
        echo = 0;
        
        // Final processing and display
        #500000;
        $display("[%0t] Measured Distance 2: %0d cm (Expected: 400)", 
                $time, uut.distance_cm);
    end
    
    // Simulation control and monitoring
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        
        // UART transmission monitor
        $monitor("[%0t] UART_TX: %b | State: %d ",
                $time, uarttx, uut.uart_state);
        
        // Total simulation time (adjust based on needs)
        #80000000;  // 80ms simulation time
        $display("\nSimulation Complete");
        $finish;
    end

endmodule