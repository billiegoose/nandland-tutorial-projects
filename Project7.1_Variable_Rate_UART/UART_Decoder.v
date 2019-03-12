module UART_Decoder (
  input i_Clk,
  input [19:0] i_Period,
  input i_UART_RX,
  output [7:0] o_Byte
  );
  
  wire [19:0] w_HalfPeriod;
  assign w_HalfPeriod = i_Period >> 1;
  
  reg r_UART_RX = 1'b1;
  reg [1:0] r_State = 2'b0; // State machine
  reg [7:0] r_Byte = 0;
  reg [19:0] c_SampleClock = 20'b0;
  reg [2:0] r_DigitIndex = 3'b0;
  
  always @(posedge i_Clk) begin
    r_UART_RX <= i_UART_RX;
    // Begin watching for byte
    if (r_State == 0) begin
      if (r_UART_RX == 1 && i_UART_RX == 0) begin
        r_State <= 1;
        r_Byte <= 0;
        c_SampleClock <= 1;
        r_DigitIndex <= 0;
      end
    end
    // Wait a half-period and make sure still low
    else if (r_State == 1) begin
      if (c_SampleClock == w_HalfPeriod) begin
        if (i_UART_RX == 0) begin
          r_State <= 2;
          c_SampleClock <= 1;
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
      if (c_SampleClock == i_Period) begin
        // Shift bits + sample
        r_Byte <= r_Byte | (i_UART_RX << r_DigitIndex);
        // Reset sampling counter timer
        c_SampleClock <= 1;
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
  
  assign o_Byte = r_Byte;
  
endmodule
