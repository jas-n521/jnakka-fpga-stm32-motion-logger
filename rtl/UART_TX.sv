`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

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
      trigger_prev <= trigger_i;
      state <= nextstate;
      if (state == IDLE && trigger_pulse) begin
            shift_reg <= data_in;
            bit_count <= 4'b0;
        end
        else if (state == DATA && baud_tick) begin
            shift_reg <= shift_reg >> 1;
            bit_count <= bit_count + 1;
        end
    end 
  end 
  
  always @(*) begin
    nextstate = state;
    bitout = 1'b1;
    case (state)
      IDLE: begin 
        bitout = 1'b1;
        if (trigger_pulse) begin
          nextstate = START;
        end
        else 
          nextstate = IDLE;
      end 
      
      START: begin
        bitout = 1'b0;
      if (baud_tick)
        nextstate = DATA;
      else
        nextstate = START;
      end 
      
      DATA: begin   
        bitout = shift_reg[0]; 
        // ^ this is the LSB (right) that gets pushed out. it's diff order of index in Verilog.
        if (baud_tick) begin
          if (bit_count == 7)
          	nextstate = STOP;
          else 
            nextstate = DATA;
        end
        else 
          nextstate = DATA;
      end 
      
      STOP: begin
        bitout = 1'b1;
        if (baud_tick)
          nextstate = IDLE;
        else 
          nextstate = STOP;
      end 
      
    endcase
      
  end
  
  assign busy = (state == START || state == DATA || state == STOP);
  assign trigger_pulse = trigger_i && !trigger_prev;
  
endmodule 

