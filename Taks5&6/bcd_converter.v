module bcd_converter (
    input clk,                    // Clock input for synchronous operation
    input [15:0] binary_in,       // 16-bit binary input value to convert (0-65535)
    output reg [3:0] hundreds , // Hundreds digit (0-9) in BCD format
    output reg [3:0] tens ,     // Tens digit (0-9) in BCD format
    output reg [3:0] units     // Units/ones digit (0-9) in BCD format
);

always @(posedge clk) begin       // Synchronous process, executes on rising edge of clock
    hundreds <= binary_in / 100;  // Integer division by 100 to extract hundreds digit
                                  // Example: 234/100 = 2
    
    tens <= (binary_in % 100) / 10; // Modulo by 100 to get remainder, then divide by 10
                                    // Example: (234%100)/10 = 34/10 = 3
    
    units <= binary_in % 10;      // Modulo by 10 to extract units digit
                                  // Example: 234%10 = 4
end
endmodule
