`include "Debounce_Switch.v"
`include "Byte_To_Seven_Segment_Display.v"
`include "UART_Decoder.v"
`include "UART_Encoder.v"
module UART_Echo_Typing (
  input i_Clk,
  input i_UART_RX,
  input i_Switch_2,
  output o_Segment1_A,
  output o_Segment1_B,
  output o_Segment1_C,
  output o_Segment1_D,
  output o_Segment1_E,
  output o_Segment1_F,
  output o_Segment1_G,
  output o_Segment2_A,
  output o_Segment2_B,
  output o_Segment2_C,
  output o_Segment2_D,
  output o_Segment2_E,
  output o_Segment2_F,
  output o_Segment2_G,
  output o_UART_TX,
  output io_PMOD_1,
  output io_PMOD_2,
  output io_PMOD_3,
  output io_PMOD_4,
  output io_PMOD_7,
  output io_PMOD_8,
  output io_PMOD_9,
  output io_PMOD_10,
  output o_LED_1,
  output o_LED_2,
  output o_LED_3,
  output o_LED_4
  );

  reg [19:0] r_CLKS_PER_BIT; // Divide clock speed (25_000_000) by baud rate (115_200)
  reg [7:0] r_Byte;
  wire [7:0] w_Byte;
  reg r_Fresh_Byte = 0;
  reg r_Release_Byte = 0;
  reg r_Write_Enable = 0;
  
  reg r_UART_RX = 1'b1;
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  wire [2:0] r_Decoder_State;
  reg r_Sample = 1'b0;
    
  UART_Decoder UART_Decoder_1 (
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_UART_RX(i_UART_RX),
    .i_release(r_Release_Byte),
    .o_Byte(w_Byte),
    .o_ready(r_Byte_Ready),
    .o_Sample(io_PMOD_2),
    .o_Decoder_State(r_Decoder_State)
    );
    
  UART_Encoder UART_Encoder_1 (
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_Byte(w_Byte),
    .i_write_enable(r_Write_Enable),
    .o_UART_TX(o_UART_TX),
    .o_busy(r_Write_Busy)
    );
  
  // I'm thinking... make an edge detector module (to simplify the 1-clock-pulse codes)
  // And maybe even a low-pass filter for smoothing signals (2-5 clock pulses).
  
  always @(posedge i_Clk) begin
  
    r_Any_Switch <= w_Any_Switch;
    // Weird edge case on startup
    if (r_CLKS_PER_BIT == 20'b0) begin
      r_CLKS_PER_BIT <= 2604;
    end
    
    if (r_Byte_Ready == 1) begin
      // Move byte from Read register to Holding register
      r_Byte <= w_Byte;
      r_Release_Byte <= 1;
      r_Fresh_Byte <= 1;
    end
    // Make sure r_Release_Byte is just a 1 clock pulse
    if (r_Release_Byte == 1) begin
      r_Release_Byte <= 0;
    end
    
    if (r_Fresh_Byte == 1 && r_Write_Busy == 0) begin
      // Move byte from Holding register to Write register
      r_Write_Enable <= 1;
      r_Fresh_Byte <= 0;
    end
    // Make sure r_Write_Enable is just a 1 clock pulse
    if (r_Write_Enable == 1) begin
      r_Write_Enable <= 0;
    end
    
  end
  
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_a
    (.i_Byte(r_Byte),
     .o_Segment1_A(o_Segment1_A),
     .o_Segment1_B(o_Segment1_B),
     .o_Segment1_C(o_Segment1_C),
     .o_Segment1_D(o_Segment1_D),
     .o_Segment1_E(o_Segment1_E),
     .o_Segment1_F(o_Segment1_F),
     .o_Segment1_G(o_Segment1_G),
     .o_Segment2_A(o_Segment2_A),
     .o_Segment2_B(o_Segment2_B),
     .o_Segment2_C(o_Segment2_C),
     .o_Segment2_D(o_Segment2_D),
     .o_Segment2_E(o_Segment2_E),
     .o_Segment2_F(o_Segment2_F),
     .o_Segment2_G(o_Segment2_G)
    );
    
  assign io_PMOD_1 = i_UART_RX;
  //assign io_PMOD_2 = o_UART_TX;
  //
  assign io_PMOD_3 = r_Decoder_State[0];
  assign io_PMOD_4 = r_Decoder_State[1];
  assign io_PMOD_7 = r_Decoder_State[2];
  // assign io_PMOD_3 = 0;
  // assign io_PMOD_4 = 0;
  // assign io_PMOD_7 = 0;
  assign io_PMOD_8 = 0;
  assign io_PMOD_9 = 0;
  assign io_PMOD_10 = 0;
  
endmodule // UART