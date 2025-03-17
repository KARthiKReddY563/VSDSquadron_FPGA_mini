module ultrasonic #(
    parameter TRIGGER_CYCLES = 60,                // Duration of trigger pulse (60 clock cycles)
    parameter MAX_ECHO_CYCLES = 139800,           // Safety timeout (~23ms at 6MHz, prevents hanging if echo never returns)
    parameter COOLDOWN_CYCLES = 1500000           // Delay between measurements (250ms at 6MHz clock)
)(
    input clk,                                    // System clock input
    input echo,                                   // Echo signal from ultrasonic sensor
    output reg trig,                              // Trigger signal to ultrasonic sensor
    output reg [23:0] pulse_width = 0             // Measured echo pulse width (proportional to distance)
);
 reg [1:0] state = 0;                             // FSM state register (4 states: 0-3)
 reg [7:0] trig_counter = 0;                      // Counter for trigger pulse duration
 reg [23:0] echo_counter = 0;                     // Counter for measuring echo pulse width
 reg [23:0] cooldown_counter = 0;                 // Counter for cooldown period between measurements

always @(posedge clk) begin                       // Main state machine, runs on every clock edge
    case(state)
        0: begin  // Idle state - Initialize all counters
            trig <= 0;                            // Ensure trigger is low
            trig_counter <= 0;                    // Reset trigger counter
            echo_counter <= 0;                    // Reset echo counter
            cooldown_counter <= 0;                // Reset cooldown counter
            state <= 1;                           // Move to trigger generation state
        end
        
        1: begin  // Generate trigger pulse state
            trig <= 1;                            // Set trigger high
            trig_counter <= trig_counter + 1;     // Increment trigger duration counter
            if(trig_counter == TRIGGER_CYCLES-1) begin  // Check if trigger pulse is complete
                trig <= 0;                        // Set trigger low
                state <= 2;                       // Move to echo measurement state
            end
        end
        
        2: begin  // Measure echo pulse state
            if(echo) begin                        // If echo signal is high
                echo_counter <= echo_counter + 1; // Count echo pulse duration
                if(echo_counter >= MAX_ECHO_CYCLES) begin  // Safety timeout check
                    pulse_width <= MAX_ECHO_CYCLES;  // Cap the pulse width at maximum
                    state <= 3;                   // Move to cooldown state
                end
            end
            else if(echo_counter > 0) begin       // If echo has gone low after being high
                pulse_width <= echo_counter;      // Store the measured pulse width
                state <= 3;                       // Move to cooldown state
            end
        end
        
        3: begin  // Cooldown state - wait before next measurement
            cooldown_counter <= cooldown_counter + 1;  // Increment cooldown counter
            if (cooldown_counter >= COOLDOWN_CYCLES)   // Check if cooldown period is complete
                state <= 0;                       // Return to idle state for next measurement
        end
        
        default: state <= 0;                      // Safety default to return to idle state
    endcase
end
endmodule
