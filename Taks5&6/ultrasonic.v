module ultrasonic #(
    parameter TRIGGER_CYCLES = 60,
     parameter MAX_ECHO_CYCLES = 139800, // Maximum echo count to prevent hanging
    parameter COOLDOWN_CYCLES = 1500000    // 250 ms at 1 MHz clock
)(
    input clk,
    input echo,
    output reg trig,
    output reg [23:0] pulse_width =0
          // Initialize state to 0
);
 reg [1:0] state = 0;
reg [7:0] trig_counter = 0;
reg [23:0] echo_counter = 0;
reg [23:0] cooldown_counter = 0;    // Needs 22 bits to hold 3,000,000

always @(posedge clk) begin
    case(state)
        0: begin  // Idle
            trig <= 0;
            trig_counter <= 0;
            echo_counter <= 0;
            cooldown_counter <= 0;
            state <= 1;
        end
        
        1: begin  // Generate trigger
            trig <= 1;
            trig_counter <= trig_counter + 1;
            if(trig_counter == TRIGGER_CYCLES-1) begin
                trig <= 0;
                state <= 2;
            end
        end
        
        2: begin  // Measure echo
            if(echo) begin
                echo_counter <= echo_counter + 1;
                // Add timeout check
                if(echo_counter >= MAX_ECHO_CYCLES) begin
                    pulse_width <= MAX_ECHO_CYCLES;
                    state <= 3;
                end
            end
            else if(echo_counter > 0) begin
                pulse_width <= echo_counter;
                state <= 3;
            end
        end
        
        3: begin  // Cooldown - 250 ms at 12 MHz
            cooldown_counter <= cooldown_counter + 1;
            if (cooldown_counter >= COOLDOWN_CYCLES)
                state <= 0;
        end
        
        default: state <= 0;  // Safety default case
    endcase
end
endmodule
