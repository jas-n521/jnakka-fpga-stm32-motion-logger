`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module BAUD_GEN (
  input clk,
  input rst, 
  input [1:0] baud_choice,
  output reg baud_tick ); 
  
  reg [12:0] pulse_count;
  reg [12:0] LIMIT; 
 
  // Sequential parts
  always @ (posedge clk or posedge rst) begin 
    if (rst) begin 
      pulse_count <= 0;
      baud_tick <= 0;
    end 
    else begin
      if (pulse_count == LIMIT ) begin
        pulse_count <= 0;
        baud_tick <= 1;
      end
      else begin
        pulse_count <= pulse_count + 1;
        baud_tick <= 0;
      end
    end
  end 
    
  // Combinational parts
  always @(*) begin
     if (baud_choice == 2'b00) 
       LIMIT = 10415;
  
     else if (baud_choice == 2'b01) 
       LIMIT = 2603;
       
     else if (baud_choice == 2'b10) 
       LIMIT = 1301;
       
     else if (baud_choice == 2'b11) 
       LIMIT = 867;  
       
   end  
  
endmodule
