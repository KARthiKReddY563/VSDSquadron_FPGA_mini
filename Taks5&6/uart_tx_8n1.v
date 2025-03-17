// 8N1 UART Module, transmit only
module uart_tx_8n1 (
    input clk,         // Main clock (must be baud rate × oversampling factor)
    input [7:0] txbyte,// Data to transmit
    input senddata,    // Trigger transmission (pulse high)
    output reg txdone, // Transmission complete
    output tx,
    output reg [3:0] bits_sent         // Serial output
);

parameter STATE_IDLE   = 8'd0;
parameter STATE_STARTTX= 8'd1;
parameter STATE_TXING  = 8'd2;
parameter STATE_TXDONE = 8'd3;

reg [7:0] state = STATE_IDLE;
reg [7:0] buf_tx = 8'b0;  // Reduced from 8 bits
reg txbit = 1'b1;

assign tx = txbit;

always @(posedge clk) begin
    case(state)
        STATE_IDLE: begin
            txbit <= 1'b1;
            txdone <= 1'b0;
            if(senddata) begin
                state <= STATE_STARTTX;
                buf_tx <= txbyte;
                bits_sent <= 0;
            end
        end
        
        STATE_STARTTX: begin
            txbit <= 1'b0;       // Start bit
            state <= STATE_TXING;
        end
        
        STATE_TXING: begin
            txbit <= buf_tx[0];  // LSB first
            buf_tx <= buf_tx >> 1;
            bits_sent <= bits_sent + 1;
            
            if(bits_sent == 3'd7) // After 8 bits transmitted
                state <= STATE_TXDONE;
        end
        
        STATE_TXDONE: begin
            txbit <= 1'b1;       // Stop bit
            txdone <= 1'b1;
            bits_sent <=0;
            state <= STATE_IDLE;
        end
    endcase
end
endmodule