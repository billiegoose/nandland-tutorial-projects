`include "Seven_Segment_Display.v"
`include "Byte_To_Seven_Segment_Display.v"
`include "Rising_Edge_Detector.v"
`include "UART_Decoder.v"
`include "UART_Encoder.v"
`include "Small_FIFO.v"
module Main (
  input i_Clk,
  input i_Switch_2,
  input i_UART_RX,
  output o_UART_TX,
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
  output o_LED_1,
  output o_LED_2,
  output o_LED_3,
  output o_LED_4
  );

  reg [19:0] r_CLKS_PER_BIT = 20'd2604; // Divide clock speed (25_000_000) by baud rate (115_200)
  
  // Goal: hook Decoder -> FIFO -> Encoder
  
  wire w_Decoder_Ready_To_Read;
  wire w_FIFO_Ready_To_Read;
  wire w_Encoder_Ready_To_Write;
  wire w_FIFO_Ready_To_Write;
  wire w_Ready_To_Read_Pulse;
  wire w_Ready_To_Write_Pulse;
  wire [7:0] w_Incoming;
  wire [7:0] w_Outgoing;
  wire [2:0] w_Free_Space;
  
  UART_Decoder UART_Decoder_1 (
    .i_Rst(i_Switch_2),
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_UART_RX(i_UART_RX),
    .i_Release_Now(w_Decoder_Ready_To_Read && w_FIFO_Ready_To_Write),
    .o_Byte(w_Incoming),
    .o_Ready_To_Read(w_Decoder_Ready_To_Read)
    );
  
  // Rising_Edge_Detector Rising_Edge_Detector_1 (
  //   .i_Clk(i_Clk),
  //   .i_Signal(w_Decoder_Ready_To_Read),
  //   .o_Pulse(w_Decoder_Ready_To_Read_Pulse)
  //   );
  
  Small_FIFO Small_FIFO_1 (
    .i_Rst(i_Switch_2),
    .i_Clk(i_Clk),
    .i_Byte(w_Incoming),
    .i_Append_Now(w_Decoder_Ready_To_Read && w_FIFO_Ready_To_Write),
    .o_Byte(w_Outgoing),
    .i_Shift_Now(w_FIFO_Ready_To_Read && w_Encoder_Ready_To_Write),
    .o_Free_Space(w_Free_Space),
    .o_Ready_To_Read(w_FIFO_Ready_To_Read),
    .o_Ready_To_Write(w_FIFO_Ready_To_Write)
    );
    
  // Rising_Edge_Detector Rising_Edge_Detector_2 (
  //   .i_Clk(i_Clk),
  //   .i_Signal(w_FIFO_Ready_To_Read),
  //   .o_Pulse(w_FIFO_Ready_To_Read_Pulse)
  //   );
    
  UART_Encoder UART_Encoder_1 (
    .i_Rst(i_Switch_2),
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_Byte(w_Outgoing),
    .i_Write_Now(w_FIFO_Ready_To_Read && w_Encoder_Ready_To_Write),
    .o_Ready_To_Write(w_Encoder_Ready_To_Write),
    .o_UART_TX(o_UART_TX)
    );
  
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_1 (
    .i_Byte(w_Outgoing),
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
    
endmodule
