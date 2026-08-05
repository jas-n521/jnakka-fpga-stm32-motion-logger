`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ============================================================
// top.sv - WORK IN PROGRESS
// Currently used for integration testing / debug.
// Not representative of final top-level structure.
// ============================================================
module top(
    input logic clk,
    input logic uart_rx,
    input logic rst,
    output logic [7:0] led,
    output uart_tx,
    output logic interrupt_o //assign this to FPGA pin, and connect to STM32 GPIO/EXTI pin. When interrupt happens, STM32 hardware will know immediately.
);

logic baud_tick;

logic [7:0] rx_data;
logic rx_done_o;
logic rx_busy;

logic [7:0] CMD_out;
logic [7:0] DATA_out;
logic packet_valid_o;

logic [7:0] pwm_duty;
logic pwm_out;

logic [7:0] threshold; 
logic [1:0] arm_mode;
logic status_request_o;
logic command_error_o;
logic [7:0] sensor_value;

logic event_detected_o;
logic event_pulse_o;

logic write_en;
logic [7:0] din;
logic [7:0] data_out;
logic full;
logic empty;
logic read_en;

assign uart_tx = 1'b1; // idle high for now

BAUD_GEN bg(
    .clk(clk),
    .rst(rst),
    .baud_choice(2'b00),
    .baud_tick(baud_tick)
);

UART_RX rxer(
    .clk(clk),
    .rst(rst),
    .rx(uart_rx),
    .baud_choice(2'b00),
    .shift_reg(rx_data),
    .busy(rx_busy),
    .rx_done_o(rx_done_o)
);

parser PARSE (
    .clk(clk),
    .rst(rst),
    .RX_byte(rx_data),
    .rx_done_o(rx_done_o),
    .CMD_out(CMD_out),
    .DATA_out(DATA_out),
    .packet_valid_o(packet_valid_o)
);


command_decoder cmd_d (
    .clk(clk),
    .rst(rst),
    .CMD_out(CMD_out),
    .DATA_out(DATA_out),
    .packet_valid_o(packet_valid_o),
    .pwm_duty(pwm_duty),
    .threshold(threshold),
    .arm_mode(arm_mode),
    .read_en(read_en),
    .status_request_o(status_request_o),
    .sensor_value(sensor_value),
    .command_error_o(command_error_o)
);

PWM_GEN pwm_gen (
    .pwm_duty(pwm_duty), 
    .pwm_out(pwm_out),
    .clk(clk),
    .rst(rst)
);

event_detector ed (
    .sensor_value(sensor_value),
    .threshold(threshold),
    .arm_mode(arm_mode),
    .event_detected_o(event_detected_o)
);
  
event_pulse_gen epg (
    .clk(clk),
    .rst(rst),
    .event_detected_i(event_detected_o),
    .event_pulse_o(event_pulse_o)
);

FIFO fifo_run (
    .clk(clk),
    .rst(rst),
    .read_en(read_en),
    .write_en(write_en),
    .din(din),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);


logic [26:0] delay_counter;
logic seen_pulse;
logic interrupt_latched;
logic seen_write;
logic system_configured;

always_ff @ (posedge clk or posedge rst) begin
    if (rst) 
        system_configured <= 0;
    else if (packet_valid_o && CMD_out == 8'h03) //means we send threshold and then arm mode
        system_configured <= 1;
end 


always_ff @ (posedge clk or posedge rst) begin
    if (rst)
        interrupt_latched <= 1'b0;
    else if (event_pulse_o) 
        interrupt_latched <= 1;
    else if (read_en) 
        interrupt_latched <= 1;
end 

always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    seen_pulse <= 0;
    seen_write <= 0;
  end
  else begin 
    if (event_pulse_o)
    seen_pulse <= 1;
    if (write_en)
    seen_write <= 1; 
    end
end


/* always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        delay_counter <= 0;
        sensor_value <= 8'd5; // below threshold
    end 
    else if (system_configured) begin
        delay_counter <= delay_counter + 1;
    
    if (delay_counter == 27'd12_000_000)
        sensor_value <= 8'd20; // cross threshold later
    
    if (delay_counter == 27'd25_000_000)
        sensor_value <= 8'd7; // cross threshold later
    
    if (delay_counter == 27'd50_000_000)
        sensor_value <= 8'd50; // cross threshold later

    end
end
*/

assign din = sensor_value;
assign write_en = event_pulse_o && system_configured; // this lets us remove the WR_EVENT task.

//assign read_en = read_next_cycle; //tasks are not synthesizable RTL. Use READ_CURRENT_EVENT Command with command parser.
                           //next round turn of read_en completely to see interrupt signal.
assign interrupt_o = event_pulse_o && system_configured;

// assign led[7:0] = data_out;

assign led[7:0] = sensor_value; 

endmodule

