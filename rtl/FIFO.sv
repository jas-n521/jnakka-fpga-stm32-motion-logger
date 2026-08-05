`timescale 1ns / 1ps

// Simple FIFO queue with independent read and write enable signals.
// The FIFO holds up to DEPTH bytes and provides full/empty status.
module FIFO (
  input logic clk,
  input logic rst,
  input logic read_en,
  input logic write_en,
  input logic [7:0] din,
  
  output logic [7:0] data_out,
  output logic full,
  output logic empty
);

  parameter int DEPTH = 16;
  
  logic [7:0] mem [15:0]; // Storage array: 16 entries of 8 bits
  logic [$clog2(DEPTH)-1:0] write_ptr; // Write address pointer
  logic [$clog2(DEPTH)-1:0] read_ptr;  // Read address pointer
  logic [$clog2(DEPTH):0] count;  // Occupancy count, one bit wider than pointer

   
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      write_ptr <= 0;
      read_ptr <= 0;
      data_out <= 0;
      count <= 0;
      // FIFO is empty after reset.
    end 

    else begin 
      case ({write_en, read_en}) 
      
      2'b01: begin // Read only
        if (!empty) begin
          data_out <= mem[read_ptr];
          read_ptr <= read_ptr + 1;
          count <= count - 1;
        end 
      end 
      
      2'b10: begin // Write only
        if (!full) begin
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          count <= count + 1;
        end
      end
      
      2'b11: begin // Simultaneous write and read
        if (!full && !empty) begin
          data_out <= mem[read_ptr];
          read_ptr <= read_ptr + 1;
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          count <= count; // occupancy stays constant
        end 
        
        else if (full && !empty) begin
          data_out <= mem[read_ptr];
          read_ptr <= read_ptr + 1;
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          // If FIFO was full, a read + write keeps it full.
        end 
        
        else if (empty && !full) begin 
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          count <= count + 1;
          // If FIFO was empty, only a write occurs.
        end 
      end 
      
      default: begin
        // No operation when both enables are inactive.
      end
      endcase 
    end 
     
  end 
  
  assign full = (count == DEPTH);
  assign empty = (count == 0);
       
endmodule
