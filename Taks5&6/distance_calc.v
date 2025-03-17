module distance_calc #(
    parameter CLK_PER_CM = 348
)(
    input clk,
    input [23:0] echo_cycles,
    output reg [15:0] distance_cm =0
);

always @(posedge clk) begin
    distance_cm <= echo_cycles / CLK_PER_CM;
end
endmodule