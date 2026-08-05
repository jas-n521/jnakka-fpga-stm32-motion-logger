`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Baud rate generator. Produces a single-cycle pulse at the selected baud rate.
//////////////////////////////////////////////////////////////////////////////////

module BAUD_GEN (
  input clk,
  input rst, 
  input [1:0] baud_choice,
  output reg baud_tick ); 
  
  reg [12:0] pulse_count;
  reg [12:0] LIMIT; 
 
  // Sequential counter that generates a pulse when the limit is reached.
  always @ (posedge clk or posedge rst) begin 
    if (rst) begin 
      pulse_count <= 0;
      baud_tick <= 0;
    end 
    else begin
      if (pulse_count == LIMIT ) begin
        pulse_count <= 0;
        baud_tick <= 1; // One cycle pulse to drive transmitter/receiver timing
      end
      else begin
        pulse_count <= pulse_count + 1;
        baud_tick <= 0;
      end
    end
  end 
    
  // Combinational limit selection based on baud choice.
  always @(*) begin
     if (baud_choice == 2'b00) 
       LIMIT = 10415; // 9600 baud
     else if (baud_choice == 2'b01) 
       LIMIT = 2603;  // 38400 baud
     else if (baud_choice == 2'b10) 
       LIMIT = 1301;  // 57600 baud
     else if (baud_choice == 2'b11) 
       LIMIT = 867;   // 115200 baud
   end  
  
endmodule
