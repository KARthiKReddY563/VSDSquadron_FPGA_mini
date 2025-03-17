module bcd_converter (
    input clk,
    input [15:0] binary_in ,
    output reg [3:0] hundreds =0,
    output reg [3:0] tens =0,
    output reg [3:0] units =0 
);

always @(posedge clk) begin
    hundreds <= binary_in / 100;
    tens <= (binary_in % 100) / 10;
    units <= binary_in % 10;
end
endmodule
