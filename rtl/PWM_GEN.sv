// PWM generator: produces a pulse width modulated output with a 100-count period.
module PWM_GEN (
  input logic clk, 
  input logic rst, 
  input logic [7:0] pwm_duty, 
  
  output logic pwm_out
  
);
  
  logic [7:0] counter;
  
  always_ff @ (posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
    end 
    
    else begin
      if (counter == 8'd99) begin 
        counter <= 0;
      end 
      else counter <= counter + 1;
        
    end
        
  end 
  
  assign pwm_out = (counter < pwm_duty );

endmodule