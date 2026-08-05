// Command decoder: interprets packet commands and generates control outputs.
module command_decoder (
  
  input logic clk,
  input logic rst,
  input logic [7:0] CMD_out,
  input logic [7:0] DATA_out,
  input logic packet_valid_o,
  
  output logic [7:0] pwm_duty,
  output logic [7:0] threshold,
  output logic [1:0] arm_mode,
  output logic read_en,
  output logic status_request_o,
  output logic command_error_o,
  output logic [7:0] sensor_value
  
);
  
  always_ff @ (posedge clk or posedge rst) begin
    if (rst) begin
      pwm_duty <= 0;
      threshold <= 0;
      arm_mode <= 0;
      status_request_o <= 0;
      command_error_o <= 0;
      read_en <= 0;
      sensor_value <= 0;
    end 
    
    else begin
      status_request_o <= 0; // one-cycle request pulses
      command_error_o <= 0;
      read_en <= 0;

      if (packet_valid_o) begin 
        case (CMD_out)
          8'h01: begin // SET_PWM
  		  	if (DATA_out <= 8'd100)
            	pwm_duty <= DATA_out;
            else 
                command_error_o <= 1;
		  end

		  8'h02: begin // SET_THRESHOLD
          	if (DATA_out <= 8'd255)
            	threshold <= DATA_out;
            else 
            	command_error_o <= 1;
          end

	      8'h03: begin // SET_ARM_MODE
         	if (DATA_out <= 8'd3)
            	arm_mode <= DATA_out[1:0];
            else 
                command_error_o <= 1;
		  end
		  
		  8'h04: begin // READ_NEXT_EVENT
		    //DATA byte is ignored
		     read_en <= 1;
		  end
          
          8'h05: begin //STATUS_REQ
            //DATA byte is ignored
            status_request_o <= 1;
          end 
          
          8'h06: begin //Update sensor value
            sensor_value <= DATA_out; 
          end 
            
          default: begin
  			command_error_o <= 1;
		  end
       endcase 
      end 
    end 
  end 
    
endmodule