module UART_Decoder (
  input i_Clk,
  input [19:0] i_Period,
  input i_UART_RX,
  input i_release,
  output [7:0] o_Byte,
  output o_ready,
  output o_Sample,
  output [2:0] o_Decoder_State
  );
  
  wire [19:0] w_HalfPeriod;
  assign w_HalfPeriod = i_Period >> 1;
  
  reg [2:0] r_State = 3'b0; // State machine
  reg [7:0] r_ByteInProgress = 8'b0;
  reg [7:0] r_FinishedByte = 8'b0;
  reg [19:0] c_SampleClock = 20'b0;
  reg [2:0] r_DigitIndex = 3'b0;
  reg r_Sample = 1'b0;
  
  always @(posedge i_Clk) begin
    c_SampleClock <= c_SampleClock + 1; // default behavior
    // Begin watching for byte
    if (r_State === 3'd0) begin
      r_Sample <= 1;
      if (i_UART_RX === 0) begin
        r_State <= 1;
        r_ByteInProgress <= 8'b0;
        c_SampleClock <= 0;
        r_DigitIndex <= 0;
      end
    end
    // Make sure it stays low for at least a half-period
    else if (r_State === 3'd1) begin
      if (c_SampleClock === w_HalfPeriod) begin
        if (i_UART_RX === 0) begin
          r_State <= 2;
        end else begin
          r_State <= 0;
        end
        c_SampleClock <= 0;
      end
    end
    // Capturing state
    else if (r_State === 3'd2) begin
      if (c_SampleClock === i_Period) begin
        // Shift bits + sample
        r_ByteInProgress <= r_ByteInProgress | (i_UART_RX << r_DigitIndex);
        // Reset sampling counter timer
        c_SampleClock <= 0;
        // One less digit to grab
        r_DigitIndex <= r_DigitIndex + 1;
        // NOTE: DESPITE THE LINE ABOVE, r_DigitIndex is STILL its old value in the comparison below. GET USED TO THINKING IN REGISTERS.
        if (r_DigitIndex === 7) begin
          r_State <= 3;
        end
      end
    end
    // Verify stop bit
    else if (r_State === 3'd3) begin
      if (c_SampleClock === i_Period) begin
        if (i_UART_RX === 1) begin
          r_State <= 4;
          r_FinishedByte <= r_ByteInProgress;
          r_ByteInProgress <= 8'b0;
        end else begin
          r_ByteInProgress <= 8'b0;
          r_State <= 0;
        end
      end
    end
    else if (r_State === 3'd4) begin
      if (i_release) begin
        r_State <= 0;
      end
    end
    if (c_SampleClock === 1) begin
      r_Sample <= !r_Sample;
    end
  end
  
  assign o_Byte = r_FinishedByte;
  assign o_ready = r_State === 4;
  assign o_Sample = r_Sample;
  assign o_Decoder_State = r_State;
endmodule
