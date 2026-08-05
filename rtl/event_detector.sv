module event_detector (
  input logic [7:0] sensor_value,
  input logic [7:0] threshold,
  input logic [1:0] arm_mode,
  
  output logic event_detected_o
);
  
  // Combinational event logic based on armed mode and sensor thresholds.
  always_comb begin
    event_detected_o = 0;
    
    case (arm_mode) 
      2'd00: begin // DISARM
        event_detected_o = 0;
      end 
      
      2'd01: begin // ARMED
        if (sensor_value >= threshold)
          event_detected_o = 1;
      end 
      
      2'd02: begin // TEST MODE
        if (sensor_value >= 10)
          event_detected_o = 1;
      end
      
      2'd03: begin  // RESERVED MODE
        event_detected_o = 0;
      end 
    endcase
    
  end 
  
endmodule
