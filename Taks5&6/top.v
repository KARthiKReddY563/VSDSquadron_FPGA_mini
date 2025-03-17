`include "uart_tx_8n1.v"        // Include UART transmitter module
`include "ultrasonic.v"         // Include ultrasonic sensor interface module
`include "distance_calc.v"      // Include distance calculation module
`include "bcd_converter.v"      // Include binary-to-BCD converter module

module top (
    output wire led_red,         // Red LED output
    output wire led_blue,        // Blue LED output
    output wire led_green,       // Green LED output
    output wire uarttx,          // UART transmit line
    input wire uartrx,           // UART receive line (unused in this design)
    input wire echo,             // Echo signal from ultrasonic sensor
    output wire trig,            // Trigger signal to ultrasonic sensor
    input wire hw_clk            // Hardware clock input (unused, using internal oscillator)
);

// Clock generation
wire int_osc;                    // Internal oscillator signal

// Measurement system
wire [23:0] echo_cycles;         // Echo pulse width in clock cycles
wire [15:0] distance_cm;         // Calculated distance in centimeters
wire [3:0] hundreds, tens, units; // BCD digits for distance value

// UART control
reg [7:0] tx_data;               // Data byte to transmit via UART
reg send_uart;                   // Signal to initiate UART transmission
wire tx_done;                    // Signal indicating UART transmission complete
reg [2:0] uart_state = 0;        // FSM state for UART transmission sequence

// Timing registers
reg clk_9600 = 0;                // 9600 Hz clock for UART
reg [31:0] cntr_9600 = 0;        // Counter for generating 9600 Hz clock
parameter period_9600 = 312;     // Divider value for 9600 Hz clock generation
reg [23:0] timer = 0;            // Timer for 1-second delay between transmissions

// Instantiate ultrasonic sensor interface
ultrasonic usonic_inst (
    .clk(int_osc),               // Connect to internal oscillator
    .echo(echo),                 // Connect to echo input pin
    .trig(trig),                 // Connect to trigger output pin
    .pulse_width(echo_cycles)    // Output echo pulse width
);

// Instantiate distance calculator
distance_calc calc_inst (
    .clk(int_osc),               // Connect to internal oscillator
    .echo_cycles(echo_cycles),   // Input echo pulse width
    .distance_cm(distance_cm)    // Output calculated distance
);

// Instantiate BCD converter
bcd_converter bcd_inst (
    .clk(int_osc),               // Connect to internal oscillator
    .binary_in(distance_cm),     // Input binary distance value
    .hundreds(hundreds),         // Output hundreds digit
    .tens(tens),                 // Output tens digit
    .units(units)                // Output units digit
);

// Clock divider for UART baud rate generation
always @(posedge int_osc) begin
    cntr_9600 <= cntr_9600 + 1;
    if (cntr_9600 == period_9600) begin
        clk_9600 <= ~clk_9600;   // Toggle 9600 Hz clock
        cntr_9600 <= 0;          // Reset counter
    end
end

// Instantiate UART transmitter
uart_tx_8n1 uart_inst (
    .clk(clk_9600),              // Connect to 9600 Hz clock
    .txbyte(tx_data),            // Input data byte to transmit
    .senddata(send_uart),        // Input signal to start transmission
    .txdone(tx_done),            // Output signal indicating transmission complete
    .tx(uarttx)                  // Connect to UART TX output pin
);

// UART transmission state machine
always @(posedge clk_9600) begin
    case(uart_state)
        0: begin  // Wait 1 second
            send_uart <= 0;      // Ensure send signal is low
            if(timer == 9600) begin  // 9600 cycles of 9600 Hz clock = 1 second
                timer <= 0;
                uart_state <= 1; // Move to sending hundreds digit
            end
            else timer <= timer + 1;
        end
        1: begin  // Send hundreds digit
            tx_data <= 8'd48 + hundreds;  // Convert to ASCII ('0' = 48)
            send_uart <= 1;               // Trigger UART transmission
            uart_state <= tx_done ? 2 : 1;  // Move to tens digit when done
        end
        2: begin  // Send tens digit
            tx_data <= 8'd48 + tens;      // Convert to ASCII
            send_uart <= 1;               // Trigger UART transmission
            uart_state <= tx_done ? 3 : 2;  // Move to units digit when done
        end
        3: begin  // Send units digit
            tx_data <= 8'd48 + units;     // Convert to ASCII
            send_uart <= 1;               // Trigger UART transmission
            uart_state <= tx_done ? 4 : 3;  // Move to newline when done
        end
        4: begin  // Send newline
            tx_data <= 8'h0A;             // ASCII newline character
            send_uart <= 1;               // Trigger UART transmission
            uart_state <= tx_done ? 0 : 4;  // Return to wait state when done
        end
    endcase
end

// Instantiate internal oscillator (6 MHz)
SB_HFOSC #(.CLKHF_DIV ("0b11")) u_SB_HFOSC (
    .CLKHFPU(1'b1),              // Power up high-frequency oscillator
    .CLKHFEN(1'b1),              // Enable high-frequency oscillator
    .CLKHF(int_osc)              // Output clock signal
);

// Instantiate RGB LED driver
SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1),                                           // Enable RGB LED
    .RGB0PWM ((distance_cm <= 50) ? 1'b1 : 1'b0),              // Green LED for distances ≤ 50cm
    .RGB1PWM ((distance_cm > 50 && distance_cm <= 100) ? 1'b1 : 1'b0), // Blue LED for 50cm < distance ≤ 100cm
    .RGB2PWM ((distance_cm > 100) ? 1'b1 : 1'b0),              // Red LED for distances > 100cm
    .CURREN  (1'b1),                                           // Enable current
    .RGB0    (led_green),                                      // Connect to green LED pin
    .RGB1    (led_blue),                                       // Connect to blue LED pin
    .RGB2    (led_red)                                         // Connect to red LED pin
);
// Set LED current parameters
defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";  // Set green LED current
defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";  // Set blue LED current
defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";  // Set red LED current

endmodule
