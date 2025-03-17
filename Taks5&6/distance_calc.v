module distance_calc #(
    parameter CLK_PER_CM = 348        // Calibration constant: 348 clock cycles per centimeter
// This value is derived from the physics of sound propagation:

//Sound travels at approximately 343 m/s (34,300 cm/s) at room temperature

// For ultrasonic distance measurement, we measure the round-trip time (sound travels to object and back)

// The time for sound to travel 1 cm and back is:

//1 cm ÷ 34,300 cm/s × 2 = ~58.3 microseconds

//At a 6MHz clock frequency, each clock cycle is:

//1 ÷ 6,000,000 = 0.1667 microseconds

//herefore, the number of clock cycles for sound to travel 1 cm and back is:

//58.3 μs ÷ 0.1667 μs/cycle = ~348 clock cycles
)(
    input clk,                        // System clock input
    input [23:0] echo_cycles,         // Echo pulse width in clock cycles from ultrasonic module
    output reg [15:0] distance_cm = 0 // Calculated distance in centimeters, initialized to 0
);

always @(posedge clk) begin           // Synchronous process, executes on rising edge of clock
    distance_cm <= echo_cycles / CLK_PER_CM;  // Simple division to convert time to distance
                                              // Sound travels at ~343 m/s, so round-trip is ~58µs/cm
end
endmodule
