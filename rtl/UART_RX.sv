`timescale 1ns / 1ps

module UART_RX (
  input logic rx,
  input logic clk,
  input logic rst, 
  input logic [1:0] baud_choice,
  
  output logic [7:0] shift_reg,
  output logic busy,
  output logic rx_done_o
);
  
  typedef enum logic [1:0] {
    IDLE,
    START,
    DATA,
    STOP
  } state_t;

  state_t state, nextstate;
  
  logic [2:0] bitcount;        
  logic [13:0] x;              
  logic [13:0] half_x;         
  logic [13:0] pulses_counted; 

  always_ff @ (posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      bitcount <= 7;          
      pulses_counted <= 0;
      shift_reg <= 0;
      rx_done_o <= 0;          
    end 
    
    else begin
      state <= nextstate; 
      rx_done_o <= 0;     
      
      if (state == IDLE) begin 
        bitcount <= 7;         
        pulses_counted <= 0;
      end 
      
      if (state == START) begin
        if (pulses_counted == half_x) begin
          // When transitioning to DATA, reset the counter to 0 so it starts 
          // counting a full bit length 'x' from the exact center of the start bit.
          pulses_counted <= 0; 
        end 
        else begin
          pulses_counted <= pulses_counted + 1;
        end
      end
      
      if (state == DATA) begin
        if (pulses_counted == x) begin 
          shift_reg <= {rx, shift_reg[7:1]}; // Shifts RIGHT (LSB first)
          bitcount <= bitcount - 1;          
          pulses_counted <= 0; // Reset counter for the next bit center
        end 
        else begin
          pulses_counted <= pulses_counted + 1;
        end
      end 
      
      if (state == STOP) begin
        if (pulses_counted == x) begin 
          pulses_counted <= 0;
          rx_done_o <= 1;      // One shot pulse when stop bit finishes
        end
        else begin
          pulses_counted <= pulses_counted + 1;
        end
      end 
      
    end 
  end 
  
  always_comb begin 
    nextstate = state;
   
    // Baud Rate Math Setup
    if (baud_choice == 2'b00) begin // 9600 Baud
       x = 10415;
       half_x = 5207;
    end
    else if (baud_choice == 2'b01) begin // 38400 Baud
       x = 2603;
       half_x = 1301;
    end
    else if (baud_choice == 2'b10) begin // 57600 Baud
       x = 1735; 
       half_x = 867;
    end
    else begin // 115200 Baud
       x = 867;  
       half_x = 433;
    end 
        
    case (state)
      IDLE: begin
        if (rx == 0) 
          nextstate = START;
      end 
      
      START: begin
        if (pulses_counted == half_x) begin
          if (rx == 0)  
            nextstate = DATA;
          else 
            nextstate = IDLE; // False start bit detected
        end
      end 
      
      DATA: begin
        // Move to STOP only after the 8th bit (bitcount == 0) has been fully sampled
        if (pulses_counted == x && bitcount == 3'd0)
          nextstate = STOP;
      end 
      
      STOP: begin
        if (pulses_counted == x) begin 
          nextstate = IDLE;
        end 
      end
      
      default: nextstate = IDLE;
    endcase 
  end 
  
  assign busy = (state == START || state == DATA || state == STOP);
  
endmodule