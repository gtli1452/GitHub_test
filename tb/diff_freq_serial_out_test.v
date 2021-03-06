/* Filename   : diff_freq_serial_out_test.v
 * Simulator  : ModelSim - Intel FPGA Edition vsim 2020.1
 * Complier   : Quartus Prime - Standard Edition 20.1.1
 * Description: Top module of uart for Quartus Prime.
 */

`include "parameter.v"

module diff_freq_serial_out_test (
  input  clk_i,          // PIN_P9
  input  rst_ni,         // PIN_G13
  output serial_out0_o,  // PIN_B6
  output serial_out1_o,  // PIN_B7
  output serial_out2_o,  // PIN_B8
  output serial_out3_o,  // PIN_B10
  output serial_out4_o,  // PIN_C10
  output serial_out5_o,  // PIN_A12
  output serial_out6_o,  // PIN_A13
  output serial_out7_o,  // PIN_A14
  output serial_out8_o,  // PIN_B15
  output serial_out9_o,  // PIN_C15
  output serial_out10_o, // PIN_D14
  output serial_out11_o, // PIN_D13
  output serial_out12_o, // PIN_E15
  output serial_out13_o, // PIN_G16
  output serial_out14_o, // PIN_H16
  output serial_out15_o, // PIN_J16
  // UART
  input  rx_i,           // PIN_J1
  output tx_o,           // PIN_J2
  // PLL
  output pll_locked_o    // PIN_R16
);

// Signal declaration
reg         rst_n_reg, rst_n_next; // synchronous reset
wire        clk_pll;
wire [7:0]  rx_received_data;
wire        rx_done_tick, tx_done_tick;
wire [15:0] serial_out;

assign serial_out0_o  = serial_out[0];
assign serial_out1_o  = serial_out[1];
assign serial_out2_o  = serial_out[2];
assign serial_out3_o  = serial_out[3];
assign serial_out4_o  = serial_out[4];
assign serial_out5_o  = serial_out[5];
assign serial_out6_o  = serial_out[6];
assign serial_out7_o  = serial_out[7];
assign serial_out8_o  = serial_out[8];
assign serial_out9_o  = serial_out[9];
assign serial_out10_o = serial_out[10];
assign serial_out11_o = serial_out[11];
assign serial_out12_o = serial_out[12];
assign serial_out13_o = serial_out[13];
assign serial_out14_o = serial_out[14];
assign serial_out15_o = serial_out[15];

// Data register
always @(posedge clk_i) begin
  rst_n_reg <= rst_n_next;
end

// Next-state logic
always @(*) begin
  rst_n_next = rst_ni;
end

// PLL IP
pll pll_100M (
  .refclk  (clk_i),
  .rst     (~rst_n_reg), // positive-edge reset
  .outclk_0(clk_pll),
  .locked  (pll_locked_o)
);

diff_freq_serial_out #(
  .DATA_BIT      (`DATA_BIT),
  .PACK_NUM      (`PACK_NUM),
  .OUTPUT_NUM    (`OUTPUT_NUM),
  .SLOW_PERIOD   (`DEFAULT_SLOW_PERIOD),
  .FAST_PERIOD   (`DEFAULT_FAST_PERIOD)
) DUT (
  .clk_i         (clk_pll),
  .rst_ni        (rst_n_reg),
  .data_i        (rx_received_data),
  .rx_done_tick_i(rx_done_tick),
  .serial_out_o  (serial_out)
);

UART #(
  .SYS_CLK       (`SYS_CLK),
  .BAUD_RATE     (`BAUD_RATE),
  .DATA_BITS     (`UART_DATA_BIT),
  .STOP_BIT      (`UART_STOP_BIT)
) DUT_uart (
  .clk_i         (clk_pll),
  .rst_ni        (rst_n_reg),
  //rx interface
  .rx_i          (rx_i),
  .rx_done_tick_o(rx_done_tick),
  .rx_data_o     (rx_received_data),
  //tx interface
  .tx_start_i    (rx_done_tick),
  .tx_data_i     (rx_received_data),
  .tx_o          (tx_o),
  .tx_done_tick_o(tx_done_tick)
);

endmodule
