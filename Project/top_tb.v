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
        // Initialize echo to 0
        echo = 0;
        
        // Wait for first trigger pulse
        @(posedge trig);
        $display("Time=%0t: First trigger detected", $time);
        
        // Wait a bit before responding (simulate sound travel time)
        #10000;       
        
        // Generate echo pulse for ~42cm distance
        echo = 1;
        repeat(162864) @(posedge hw_clk); // ~42cm (2.44ms at 12MHz)
        echo = 0;
        
        // Wait and display the calculated distance
        #500000;
        $display("Time=%0t: First Distance = %0d cm", $time, uut.distance_cm);
        
        // Wait 15ms before second measurement
        #15000000;
        
        // Force the ultrasonic state machine to IDLE to ensure new trigger
        force uut.ultrasonic_state = 2'd0;
        #100;
        release uut.ultrasonic_state;
        
        // Wait for second trigger pulse
        @(posedge trig);
        $display("Time=%0t: Second trigger detected", $time);
        
        // Wait a bit before responding
        #10000;
        
        // Generate echo pulse for 400cm
        echo = 1;
        repeat(278400) @(posedge hw_clk); // 400cm (23.2ms at 12MHz)
        echo = 0;
        
        // Wait and display the calculated distance
        #500000;
        $display("Time=%0t: Second Distance = %0d cm", $time, uut.distance_cm);
    end
      
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Monitor UART transmission
        $monitor("Time=%0t | UART TX = %b | send_uart = %b | bits_sent = %b | Distance = %d", 
                 $time, uarttx, uut.send_uart, uut.bits_sent, uut.distance_cm);

        
        

    
   
       
        

        // Monitor UART transmission
       

        #80000000; // Allow sufficient simulation time for UART transmission

        $finish;
    end

endmodule
