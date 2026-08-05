`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// UART transmitter. Starts sending a byte when trigger_i pulses high.
// It sends a start bit, eight data bits LSB-first, then a stop bit.
//////////////////////////////////////////////////////////////////////////////////

module UART_TX (
  input clk,
  input rst, 
  input wire baud_tick,
  input trigger_i,
  input [7:0] data_in,
  output reg bitout,
  output wire busy
);
  
  reg [3:0] bit_count;
  reg [1:0] state, nextstate;
  reg [7:0] shift_reg;
  reg trigger_prev;
  wire trigger_pulse;
  
  localparam IDLE = 2'b00;
  localparam START = 2'b01;
  localparam DATA = 2'b10;
  localparam STOP = 2'b11;
  
  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      shift_reg <= 8'b0;
      bit_count <= 4'b0;
      state <= IDLE;
      trigger_prev <= 1'b0;
    end 
  
    else begin
      trigger_prev <= trigger_i; // Track previous sample for edge detection
      state <= nextstate;
      if (state == IDLE && trigger_pulse) begin
            shift_reg <= data_in; // Load new byte to transmit
            bit_count <= 4'b0;
        end
        else if (state == DATA && baud_tick) begin
            shift_reg <= shift_reg >> 1; // Shift out LSB first each baud tick
            bit_count <= bit_count + 1;
        end
    end 
  end 
  
  always @(*) begin
    nextstate = state;
    bitout = 1'b1; // Idle line is high
    case (state)
      IDLE: begin 
        bitout = 1'b1;
        if (trigger_pulse) begin
          nextstate = START; // Begin frame on a trigger edge
        end
        else 
          nextstate = IDLE;
      end 
      
      START: begin
        bitout = 1'b0; // Drive start bit low
        if (baud_tick)
          nextstate = DATA;
        else
          nextstate = START;
      end 
      
      DATA: begin   
        bitout = shift_reg[0]; // Output current LSB of the shift register
        if (baud_tick) begin
          if (bit_count == 7)
            nextstate = STOP; // All eight bits sent
          else 
            nextstate = DATA;
        end
        else 
          nextstate = DATA;
      end 
      
      STOP: begin
        bitout = 1'b1; // Stop bit is high
        if (baud_tick)
          nextstate = IDLE;
        else 
          nextstate = STOP;
      end 
      
    endcase
      
  end
  
  assign busy = (state == START || state == DATA || state == STOP);
  assign trigger_pulse = trigger_i && !trigger_prev; // Detect rising edge of trigger

  endmodule 

