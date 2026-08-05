`timescale 1ns / 1ps

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
  
  logic [7:0] mem [15:0]; // 16 memory locations each 8 bits wide
  logic [$clog2(DEPTH)-1:0] write_ptr; //4 bits bc 16 slots in memory 0-15
  logic [$clog2(DEPTH)-1:0] read_ptr;  //4 bits bc 16 slots in memory 0-15
  logic [$clog2(DEPTH):0] count;  //5 bits bc 16 slots in memory

   
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      write_ptr <= 0;
      read_ptr <= 0;
      data_out <= 0;
      count <= 0;
      // We always start from rst.
    end 

    else begin 
      
      case ({write_en, read_en}) 
      
      2'b01: begin
        if (!empty) begin
          data_out <= mem[read_ptr];
          read_ptr <= read_ptr + 1;
          count <= count - 1;
        end 
      end 
      
      2'b10: begin
        if (!full) begin
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          count <= count + 1;
        end
      end
      
      2'b11: begin
        if (!full && !empty) begin
          data_out <= mem[read_ptr];
          read_ptr <= read_ptr + 1;
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          count <= count;
        end 
        
        else if (full && !empty) begin
          data_out <= mem[read_ptr];
          read_ptr <= read_ptr + 1;
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
        end 
        
        else if (empty && !full) begin 
          mem[write_ptr] <= din;
          write_ptr <= write_ptr + 1;
          count <= count + 1;
        end 
      end 
      
      endcase 
    end 
     
  end 
  
  assign full = (count == DEPTH);
  assign empty = (count == 0);
      
  endmodule
