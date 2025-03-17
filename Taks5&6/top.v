`include "uart_tx_8n1.v"
`include "ultrasonic.v"
`include "distance_calc.v"
`include "bcd_converter.v"

module top (
    output wire led_red,
    output wire led_blue,
    output wire led_green,
    output wire uarttx,
    input wire uartrx,
    input  wire echo,
    output wire trig, 
    input  wire hw_clk

  
);

// Clock generation
wire int_osc;

// Measurement system
wire [23:0] echo_cycles;
wire [15:0] distance_cm;
wire [3:0] hundreds, tens, units;

// UART control
reg [7:0] tx_data;
reg send_uart;
wire tx_done;
reg [2:0] uart_state = 0;

// Timing registers
reg clk_9600 = 0;
reg [31:0] cntr_9600 = 0;
parameter period_9600 = 312;
reg [23:0] timer = 0;  // Added timer declaration

ultrasonic usonic_inst (
    .clk(int_osc),
    .echo(echo),
    .trig(trig),        // Now connects to wire
    .pulse_width(echo_cycles)
   
);

distance_calc calc_inst (
    .clk(int_osc),
    .echo_cycles(echo_cycles),
    .distance_cm(distance_cm)
);

bcd_converter bcd_inst (
    .clk(int_osc),
    .binary_in(distance_cm),
    .hundreds(hundreds),
    .tens(tens),
    .units(units)
);





always @(posedge int_osc) begin
    cntr_9600 <= cntr_9600 + 1;
    if (cntr_9600 == period_9600) begin
        clk_9600 <= ~clk_9600;
        cntr_9600 <= 0;
    end
end

uart_tx_8n1 uart_inst (
    .clk(clk_9600),
    .txbyte(tx_data),
    .senddata(send_uart),
    .txdone(tx_done),
    .tx(uarttx)
);

/// Transmission FSM
// Pipeline registers
always @(posedge clk_9600) begin
    case(uart_state)
        0: begin  // Wait 1 second
            send_uart <= 0;
            if(timer == 9600) begin
                timer <= 0;
                uart_state <= 1;
            end
            else timer <= timer + 1;
        end
        1: begin  // Send hundreds
            tx_data <= 8'd48 + hundreds;
            send_uart <= 1;
            uart_state <= tx_done ? 2 : 1;
        end
       2: begin  // Send tens
            tx_data <= 8'd48 + tens;
            send_uart <= 1;
            uart_state <= tx_done ? 3 : 2;
        end
        3: begin  // Send units
            tx_data <= 8'd48 + units;
            send_uart <= 1;
            uart_state <= tx_done ? 4 : 3;
        end
        4: begin  // Send newline
            tx_data <= 8'h0A;
            send_uart <= 1;
            uart_state <= tx_done ? 0 : 4;
        end
        
    endcase

end
// LED control
// Add your LED control logic here

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillator                                --
//                                                                          --
//----------------------------------------------------------------------------
  SB_HFOSC #(.CLKHF_DIV ("0b11")) u_SB_HFOSC ( .CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));


//----------------------------------------------------------------------------
//                                                                          --
//                       Counter                                            --
//                                                                          --
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//                                                                          --
//                       Instantiate RGB primitive                          --
//                                                                          --
//----------------------------------------------------------------------------
  SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1                                            ),
    .RGB0PWM ((distance_cm <= 50) ? 1'b1 : 1'b0),
    .RGB1PWM ( (distance_cm > 50 && distance_cm <= 100) ? 1'b1 : 1'b0),
    .RGB2PWM ((distance_cm > 100) ? 1'b1 : 1'b0),
    .CURREN  (1'b1                                            ),
    .RGB0    (led_green                                       ), //Actual Hardware connection
    .RGB1    (led_blue                                        ),
    .RGB2    (led_red                                         )
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule