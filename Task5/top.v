module top (
    output wire led_red,
    output wire led_blue,
    output wire led_green,
    output wire uarttx,
    input  wire echo,
    output reg  trig,
    input  wire hw_clk
);

// Parameters
parameter CLK_FREQ     = 12_000_000;  // 12 MHz clock
parameter BAUD_RATE    = 9600;
parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; 

// Ultrasonic Parameters
parameter TRIGGER_CYCLES = 120;       // 10µs trigger (12MHz: 120 cycles)
parameter CM_DIVISOR     = 696;       // 12MHz scaling factor

// UART Control
reg [7:0] tx_data = 0;
reg [3:0] bit_index = 0;
reg [10:0] clk_count = 0;
reg       tx_active = 0;
reg       tx_done = 0;
reg       tx_start = 0;

// Ultrasonic Measurement
reg [15:0] distance_cm = 0;
reg [7:0]  trigger_counter = 0;
reg [31:0] echo_counter = 0;
reg [1:0]  ultrasonic_state = 0;

// Data Processing
reg [15:0] latched_distance;
reg [3:0]  hundreds = 0, tens = 0, units = 0;

// Timing Generation
reg [23:0] send_counter = 0;
reg        send_uart = 0;
reg        baud_tick;

// Synchronization registers
reg [1:0] echo_sync = 0;

// UART Transmitter
reg tx = 1'b1;
reg [7:0] tx_buffer;

// Division pipeline registers
reg [31:0] echo_counter_latched = 0;
reg        division_in_progress = 0;
reg [1:0]  division_state = 0;

// UART state machine
reg [2:0] uart_state = 0;
reg       prev_tx_done = 0;

// Declare int_osc as wire
wire int_osc;

// Baud rate generation
always @(posedge int_osc) begin
    // Generate baud tick (9600 baud)
    if(clk_count == CLKS_PER_BIT-1) begin
        baud_tick <= 1'b1;
        clk_count <= 0;
    end else begin
        baud_tick <= 1'b0;
        clk_count <= clk_count + 1;
    end
end

// Echo synchronization
always @(posedge int_osc) begin
    // Synchronize echo input
    echo_sync <= {echo_sync[0], echo};
end
reg [3:0] bits_sent;
// UART Transmitter Logic - Completely redesigned
always @(posedge int_osc) begin
    prev_tx_done <= tx_done;  // For edge detection
    
    if (tx_start && !tx_active) begin
        // Start a new transmission
        tx_active <= 1'b1;
        tx_buffer <= tx_data;  // Latch the data
        bit_index <= 0;
        tx_done <= 1'b0;
        tx <= 1'b1;  // Ensure we're idle before starting
    end
    
    if (tx_active && baud_tick) begin
        case (bit_index)
            4'd0: begin  // Start bit
                tx <= 1'b0;
                bit_index <= bit_index + 1;
                bits_sent <= 0;
            end
            
            4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8: begin  // Data bits
                tx <= tx_buffer[0];
                tx_buffer <= {1'b0, tx_buffer[7:1]};  // Right shift
                bit_index <= bit_index + 1;
                bits_sent <= bits_sent +1 ;
            end
            
            4'd9: begin  // Stop bit
                tx <= 1'b1;
                bit_index <= 0;
                tx_active <= 1'b0;
                tx_done <= 1'b1;
                bits_sent <= 0;  // Signal transmission complete
            end
            
            default: begin
                bit_index <= 0;
            end
        endcase
    end
    
    // Clear tx_done after one cycle
    if (tx_done && !tx_active && !baud_tick) begin
        tx_done <= 1'b0;
    end
end
reg [23:0] cooldown_counter = 0;

// Ultrasonic State Machine
always @(posedge int_osc) begin
    case (ultrasonic_state)
        2'd0: begin  // IDLE
            trig <= 0;
            trigger_counter <= 0;
            echo_counter <= 0;
            ultrasonic_state <= 2'd1;
            division_in_progress <= 0;
        end
        
        2'd1: begin  // TRIGGER
            trig <= 1;
            if (trigger_counter >= TRIGGER_CYCLES-1) begin
                trig <= 0;
                ultrasonic_state <= 2'd2;
            end
            trigger_counter <= trigger_counter + 1;
        end
        
        2'd2: begin  // WAIT ECHO
            if (echo_sync[1]) begin
                echo_counter <= echo_counter + 1;
            end else if (echo_counter > 0) begin
                // Latch the counter value for division
                echo_counter_latched <= echo_counter;
                division_in_progress <= 1;
                division_state <= 0;
                ultrasonic_state <= 2'd3;
            end
        end
        
        2'd3: begin  // COOLDOWN
    cooldown_counter <= cooldown_counter + 1;
    // 10ms at 12MHz = 120,000 clock cycles
    if (cooldown_counter >= 120000) begin
        cooldown_counter <= 0;
        ultrasonic_state <= 2'd0;
    end
end
    endcase
end

// Pipelined division for distance calculation
always @(posedge int_osc) begin
    if (division_in_progress) begin
        distance_cm <= echo_counter_latched / CM_DIVISOR;
        division_in_progress <= 0;
    end
end 

// 1-second Measurement Interval
always @(posedge int_osc) begin
    if (send_counter == 12_000_000) begin
        send_counter <= 0;
        send_uart <= 1;
        latched_distance <= distance_cm;  // Latch stable value
        
        // Calculate BCD values immediately
        hundreds <= distance_cm / 100;
        tens <= (distance_cm % 100) / 10;
        units <= distance_cm % 10;
    end else begin
        send_counter <= send_counter + 1;
        send_uart <= 0;
    end
end

// UART state machine - completely redesigned
always @(posedge int_osc) begin
    // Default state for tx_start
    tx_start <= 1'b0;
    
    // Detect rising edge of tx_done
    if (tx_done && !prev_tx_done) begin
        case (uart_state)
            3'd1: begin  // Hundreds digit sent
                tx_data <= 8'd48 + tens;  // ASCII for tens digit
                uart_state <= 3'd2;
                tx_start <= 1'b1;
            end
            
            3'd2: begin  // Tens digit sent
                tx_data <= 8'd48 + units;  // ASCII for units digit
                uart_state <= 3'd3;
                tx_start <= 1'b1;
            end
            
            3'd3: begin  // Units digit sent
                tx_data <= 8'h0A;  // Newline
                uart_state <= 3'd4;
                tx_start <= 1'b1;
            end
            
            3'd4: begin  // Newline sent
                uart_state <= 3'd0;  // Return to idle
            end
        endcase
    end
    
    // Start a new transmission sequence
    if (send_uart && uart_state == 3'd0) begin
        tx_data <= 8'd48 + hundreds;  // ASCII for hundreds digit
        uart_state <= 3'd1;
        tx_start <= 1'b1;
    end
end

assign uarttx = tx;

// Assign values to LEDs

  SB_HFOSC #(.CLKHF_DIV("0b10")) u_SB_HFOSC (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(int_osc)
  );

 

 SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1                                            ),
    .RGB0PWM ((latched_distance <= 50) ? 1'b1 : 1'b0 ),
    .RGB1PWM ( (latched_distance > 50 && latched_distance <= 100) ? 1'b1 : 1'b0),
    .RGB2PWM ((latched_distance > 100) ? 1'b1 : 1'b0),
    .CURREN  (1'b1                                            ),
    .RGB0    (led_green                                       ), //Actual Hardware connection
    .RGB1    (led_blue                                        ),
    .RGB2    (led_red                                         )
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

// Internal oscillator instantiation


endmodule
