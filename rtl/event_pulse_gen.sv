module event_pulse_gen (
  input logic clk,
  input logic rst,
  input logic event_detected_i,
  
  output logic event_pulse_o
);
  
  logic event_detected_prev; 
  
  // Generate a single clock-cycle pulse when event_detected_i goes high.
  always_ff @ (posedge clk or posedge rst) begin 
    if (rst) begin
      event_pulse_o <= 0;
      event_detected_prev <= 0;
    end 
    
    else begin
      event_detected_prev <= event_detected_i;

      if (event_detected_prev != event_detected_i && event_detected_i)
          event_pulse_o <= 1;
      else
          event_pulse_o <= 0;
    end 
  end 
   
endmodule 