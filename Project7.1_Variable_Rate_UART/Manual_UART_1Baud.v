module Manual_UART_1Baud (
  input i_Clk,
  input i_Switch_2,
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
  output o_LED_3,
  output o_LED_4
  );
  
  parameter CLKS_PER_BIT = 25000000; // 217; // Divide clock speed by baud rate

  reg [0:7] r_Byte = 0;
  reg [31:0] c_SampleClock = 32'b0;
  reg [3:0] r_DigitsToCapture = 4'b0;
  reg r_Switch_2 = 1'b0;
  reg r_Switch_4 = 1'b0;
  reg r_Any_Switch = 1'b0;
  reg r_LED_3 = 1'b0;
  reg r_LED_4 = 1'b0;
  
  // Clever trick: share debounce filter
  wire w_Any_Switch;
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_2 || i_Switch_4),
     .o_Switch(w_Any_Switch));
     
  always @(posedge i_Clk) begin
    r_Switch_2 <= i_Switch_2; // 1
    r_Switch_4 <= i_Switch_4; // 0
    r_Any_Switch <= w_Any_Switch;
    // Button pushed
    if (r_Any_Switch == 0 && w_Any_Switch == 1) begin
      if (i_Switch_4 == 1) begin
        r_Byte <= 0;
        r_DigitsToCapture <= 8;
      end
    end
    // Capturing state
    if (r_DigitsToCapture > 0) begin
      if (c_SampleClock == CLKS_PER_BIT) begin
        r_LED_3 <= ~r_LED_3;
        // Shift bits + sample
        r_Byte <= r_Byte * 2 + i_Switch_2;
        // Reset sampling counter timer
        c_SampleClock <= 0;
        // One less digit to grab
        r_DigitsToCapture <= r_DigitsToCapture - 1;
      end
      else begin
        c_SampleClock <= c_SampleClock + 1;
      end
    end
  end
  
  assign o_LED_3 = r_LED_3;
  assign o_LED_4 = (r_DigitsToCapture > 0);
  
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
  
endmodule // Manual_UART_1Baud