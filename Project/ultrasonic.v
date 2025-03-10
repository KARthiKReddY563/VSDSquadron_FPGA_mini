module ultrasonic (
    input wire clk,   
    input wire rst,         
    input wire echo,        
    output reg trig,        
    output reg [15:0] distance_cm 
);


parameter IDLE      = 2'b00;
parameter TRIGGER   = 2'b01;
parameter WAIT_ECHO = 2'b10;
parameter CALCULATE = 2'b11;

reg [1:0] state;


localparam TRIGGER_DURATION = 120; 
reg [7:0] trigger_counter;
reg [31:0] echo_counter;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        trig <= 0;
        distance_cm <= 0;
        trigger_counter <= 0;
        echo_counter <= 0;
    end else begin
        case (state)
            IDLE: begin
                trig <= 0;
                trigger_counter <= 0;
                echo_counter <= 0;
                state <= TRIGGER;
            end

            TRIGGER: begin
                trig <= 1;
                if (trigger_counter < TRIGGER_DURATION) begin
                    trigger_counter <= trigger_counter + 1;
                end else begin
                    trig <= 0;
                    trigger_counter <= 0;
                    state <= WAIT_ECHO;
                end
            end

            WAIT_ECHO: begin
    if (echo) begin
        echo_counter <= echo_counter + 1;
    end else if (echo_counter > 0) begin
        state <= CALCULATE;
    end
end


            CALCULATE: begin
                 $display("Echo Counter: %d", echo_counter);
                distance_cm <= echo_counter  / 696;
                echo_counter <= 0;
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
