`include "Debounce_Switch.v"
`include "Byte_To_Seven_Segment_Display.v"
`include "UART_Decoder.v"
`include "Next_Baud_Rate.v"
module UART_Variable_Four_Button (
  input i_Clk,
  input i_UART_RX,
  input i_Switch_1,
  input i_Switch_2,
  input i_Switch_3,
  input i_Switch_4,
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

  reg [19:0] r_CLKS_PER_BIT; // Divide clock speed (25_000_000) by baud rate (115_200)
  wire [19:0] w_NextPeriod;
  reg [7:0] r_Byte;
  wire [7:0] w_Byte;
  wire [7:0] r_Reverse_Byte;
  
  reg r_UART_RX = 1'b1;
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  
  assign o_LED_1 = r_CLKS_PER_BIT[8];
  assign o_LED_2 = r_CLKS_PER_BIT[9];
  assign o_LED_3 = r_CLKS_PER_BIT[10];
  assign o_LED_4 = r_CLKS_PER_BIT[11];
  
  Debounce_Switch dbounce1 (
    .i_Clk(i_Clk),
    .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
    .o_Switch(w_Any_Switch)
    );
    
  UART_Decoder UART_Decoder_1 (
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_UART_RX(i_UART_RX),
    .o_Byte(w_Byte)
    );
    
  Next_Baud_Rate #(25000000) Next_Baud_Rate_1 (
    .i_CurrentPeriod(r_CLKS_PER_BIT),
    .o_NextPeriod(w_NextPeriod)
    );
  
  always @(posedge i_Clk) begin
  
    r_Any_Switch <= w_Any_Switch;
    r_Byte <= w_Byte;
    // Weird edge case on startup
    if (r_CLKS_PER_BIT == 32'b0) begin
      r_CLKS_PER_BIT <= 217;
      r_Byte <= 3;
    end
    // Normal cases
    else if (r_Any_Switch == 1'b0 && w_Any_Switch == 1'b1) begin
      if (i_Switch_2 == 1'b1) begin
        r_CLKS_PER_BIT <= 217; // 115200 baud
      end
      else if (i_Switch_1 == 1'b1) begin
        r_CLKS_PER_BIT <= 2604; // 9600 baud
      end
      else if (i_Switch_3 == 1'b1) begin
        r_CLKS_PER_BIT <= r_CLKS_PER_BIT >> 1; // faster
      end
      else if (i_Switch_4 == 1'b1) begin
        r_CLKS_PER_BIT <= r_CLKS_PER_BIT << 1; // slower
      end
      else
        r_CLKS_PER_BIT <= 217;
    end
  end
  
  assign r_Reverse_Byte[0] = r_Byte[7];
  assign r_Reverse_Byte[1] = r_Byte[6];
  assign r_Reverse_Byte[2] = r_Byte[5];
  assign r_Reverse_Byte[3] = r_Byte[4];
  assign r_Reverse_Byte[4] = r_Byte[3];
  assign r_Reverse_Byte[5] = r_Byte[2];
  assign r_Reverse_Byte[6] = r_Byte[1];
  assign r_Reverse_Byte[7] = r_Byte[0];
  
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
  
endmodule // UART