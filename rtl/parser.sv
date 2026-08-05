module parser (
	
  input logic [7:0] RX_byte,
  input logic rx_done_o,
  input logic clk,
  input logic rst,
  
  output logic [7:0] CMD_out,
  output logic [7:0] DATA_out,
  output logic packet_valid_o
  
);
  
  logic [7:0] CMD_save_reg;
  logic [7:0] DATA_save_reg;
  
  typedef enum logic [1:0] {
    IDLE,
    CMD,
    DATA,
    END
} state_t;
  
  state_t state, nextstate;
  
  always_ff @ (posedge clk or posedge rst) begin
    
    if (rst) begin
      state <= IDLE;
      CMD_out <= 0;
      DATA_out <= 0;
      CMD_save_reg <= 0;
      DATA_save_reg <= 0;
      packet_valid_o <= 0;

    end 
    
    else begin
      state <= nextstate;
      packet_valid_o <= 0;

      
      if (state == CMD) begin
        if(rx_done_o) 
          CMD_save_reg <= RX_byte;
        else CMD_save_reg <= CMD_save_reg;
      end 
      
      if (state == DATA) begin
        if(rx_done_o) 
          DATA_save_reg <= RX_byte;
        else DATA_save_reg <= DATA_save_reg;
      end 
      
      if (state == END && rx_done_o && RX_byte == 8'h55) begin
        CMD_out <= CMD_save_reg;
        DATA_out <= DATA_save_reg;
        packet_valid_o <= 1'b1;
      end

      
    end 
    
  end 
  
  always_comb begin
    
    nextstate = state; 
    
    case (state)
      IDLE: begin 
        
        if (rx_done_o) begin
          if (RX_byte == 8'hAA)
            nextstate = CMD;
          else 
            nextstate = IDLE;
        end 
        
        else nextstate = IDLE;
        
      end
      
      CMD: begin 
        
        if (rx_done_o) begin 
          nextstate = DATA;
        end 
        
        else nextstate = CMD;
        
      end 
      
      DATA: begin
        
        if (rx_done_o) begin
          nextstate = END;
        end 
        
        else nextstate = DATA;
        
      end 
      
      END: begin 
        
        if (rx_done_o) begin
          if (RX_byte == 8'h55) begin
            nextstate = IDLE;
          end 
          else begin 
            nextstate = IDLE;
          end   
        end 
        
        else nextstate = END;  
          
      end 
        
    endcase 
       
  end 
      
      
  endmodule 