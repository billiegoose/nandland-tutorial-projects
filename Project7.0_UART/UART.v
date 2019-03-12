module UART (
  input i_Clk,
  input i_UART_RX,
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
  
  parameter CLKS_PER_BIT = 217; //25000000; // Divide clock speed by baud rate
  parameter CLKS_PER_BIT_OVER_TWO = 108;

  reg [0:1] r_State = 2'b0; // 0 = nothing, 1 = wait for drop, 2 = capturing
  reg [0:7] r_Byte = 0;
  wire [0:7] r_Reverse_Byte;
  reg [31:0] c_SampleClock = 32'b0;
  reg [2:0] r_DigitIndex = 4'b0;
  reg r_LED_3 = 1'b0;
  reg r_LED_4 = 1'b0;
  reg r_UART_RX = 1'b1;
     
  always @(posedge i_Clk) begin
    r_UART_RX <= i_UART_RX;
    // Begin watching for byte
    if (r_State == 0) begin
      if (r_UART_RX == 1 && i_UART_RX == 0) begin
        r_State <= 1;
        r_Byte <= 0;
        c_SampleClock <= 0;
        r_DigitIndex <= 0;
      end
    end
    // Wait a half-period and make sure still low
    else if (r_State == 1) begin
      if (c_SampleClock == CLKS_PER_BIT_OVER_TWO) begin
        if (i_UART_RX == 0) begin
          r_State <= 2;
          c_SampleClock <= 0;
        end
        else begin
          r_State <= 0;
        end
      end
      else begin
        c_SampleClock <= c_SampleClock + 1;
      end
    end
    // Capturing state
    else if (r_State == 2) begin
      if (c_SampleClock == CLKS_PER_BIT) begin
        r_LED_3 <= ~r_LED_3;
        // Shift bits + sample
        r_Byte <= r_Byte * 2 + i_UART_RX;
        // Reset sampling counter timer
        c_SampleClock <= 0;
        // One less digit to grab
        r_DigitIndex <= r_DigitIndex + 1;
        // NOTE: DESPITE THE LINE ABOVE, r_DigitIndex is STILL its old value in the comparison below. GET USED TO THINKING IN REGISTERS.
        if (r_DigitIndex == 7) begin
          r_State <= 0;
        end
      end
      else begin
        c_SampleClock <= c_SampleClock + 1;
      end
    end
  end
  
  
  assign o_LED_1 = (r_State == 0);
  assign o_LED_2 = (r_State == 1);
  assign o_LED_3 = (r_State == 2);
  assign o_LED_4 = ~i_UART_RX;
  
  assign r_Reverse_Byte[0] = r_Byte[7];
  assign r_Reverse_Byte[1] = r_Byte[6];
  assign r_Reverse_Byte[2] = r_Byte[5];
  assign r_Reverse_Byte[3] = r_Byte[4];
  assign r_Reverse_Byte[4] = r_Byte[3];
  assign r_Reverse_Byte[5] = r_Byte[2];
  assign r_Reverse_Byte[6] = r_Byte[1];
  assign r_Reverse_Byte[7] = r_Byte[0];
  
  
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_a
    (.i_Byte(r_Reverse_Byte),
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