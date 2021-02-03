/*
Filename    : diff_freq_serial_out_tb.v
Compiler    : ModelSim 10.2c, Debussy 5.4 v9
Description : ModelSim with debussy
Author      : Tim.Li
Release     : 12/16/2020 v1.0
*/

module diff_freq_serial_out_test (
  input  clk,           // PIN_P9
  input  rst_n,         // PIN_G13
  output o_serial_out0, // PIN_T7
  output o_serial_out1, // PIN_P8
  output o_serial_out2, // PIN_R9
  output o_bit_tick,    // PIN_R10
  output o_done_tick,   // PIN_T8
  // UART
  input  i_rx,          // PIN_K12
  output o_tx,          // PIN_M12
  // PLL
  output o_pll_locked   // PIN_R16
);

// Serial output parameter 
localparam DATA_BIT       = 32;
localparam PACK_NUM       = (DATA_BIT/8)*2+1; // byte_num of a pack = output_pattern (32-bit) + freq_pattern (32-bit) + control_byte

// Uart parameter
localparam SYS_CLK        = 100_000_000; // 100Mhz
localparam BAUD_RATE      = 19200;
localparam UART_CLK_DIV   = SYS_CLK/(16*BAUD_RATE); // SYS_CLK/(16*BAUD_RATE), i.e. 10M/(16*19200)
localparam UART_DIV_BIT   = $clog2(UART_CLK_DIV);        // bits for TICK_DIVIDE, it must be >= log2(TICK_DIVIDE)
localparam UART_DATA_BIT  = 8;                      // 8-bit data
localparam UART_STOP_TICK = 16;                     // 1-bit stop (16 ticks/bit)

// Signal declaration
reg        rst_n_reg, rst_n_next; // synchronous reset
wire       clk_pll;
wire [7:0] rx_received_data;
wire       o_rx_done_tick, o_tx_done_tick;

// Data register
always @(posedge clk) begin
  rst_n_reg <= rst_n_next;
end

// Next-state logic
always @(*) begin
  rst_n_next = rst_n;
end

// PLL IP
pll pll_100M (
  .refclk   (clk),
  .rst      (~rst_n_reg), // positive-edge reset
  .outclk_0 (clk_pll),
  .locked   (o_pll_locked)
);

diff_freq_serial_out #(
  .DATA_BIT       (DATA_BIT),
  .PACK_NUM       (PACK_NUM)
) DUT (
  .clk            (clk_pll),
  .rst_n          (rst_n_reg),
  .i_data         (rx_received_data),
  .i_rx_done_tick (o_rx_done_tick),
  .o_serial_out0  (o_serial_out0),
  .o_serial_out1  (o_serial_out1),
  .o_serial_out2  (o_serial_out2),
  .o_bit_tick     (o_bit_tick),
  .o_done_tick    (o_done_tick)
);

UART #(
  .SYS_CLK       (SYS_CLK),
  .BAUD_RATE     (BAUD_RATE),
  .DATA_BITS     (UART_DATA_BIT),
  .STOP_TICK     (UART_STOP_TICK),
  .CLK_DIV       (UART_CLK_DIV),
  .DIV_BIT       (UART_DIV_BIT)
) DUT_uart (
  .clk            (clk_pll),
  .rst_n          (rst_n_reg),
  //rx interface
  .i_rx           (i_rx),
  .o_rx_done_tick (o_rx_done_tick),
  .o_rx_data      (rx_received_data),
  
  //tx interface
  .i_tx_start     (o_rx_done_tick),
  .i_tx_data      (rx_received_data),
  .o_tx           (o_tx),
  .o_tx_done_tick (o_tx_done_tick)
);

endmodule
