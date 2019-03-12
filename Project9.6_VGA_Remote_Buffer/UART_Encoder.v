module UART_Encoder (
  input i_Clk,
  input [19:0] i_Period,
  input [7:0] i_Byte,
  input i_write_enable,
  output o_UART_TX,
  output o_busy
  );
  
  reg [2:0] r_State = 3'b0; // State machine
  reg [7:0] r_Byte = 0;
  reg [19:0] c_SampleClock = 20'b0;
  reg [2:0] r_DigitIndex;
  reg r_busy = 0;
  reg r_UART_TX = 1;
  
  assign o_UART_TX = r_UART_TX;
  assign o_busy = r_busy;
  
  always @(posedge i_Clk) begin
    if (r_State == 0) begin
      r_DigitIndex <= 0;
      c_SampleClock <= 2;
      // Start
      if (i_write_enable) begin
        // Snapshot of byte
        r_Byte <= i_Byte;
        r_State <= 1;
        r_busy <= 1;
      end else begin
        r_Byte <= 0;
        r_State <= 0;
        r_busy <= 0;
      end
    end
    // Writing start bit
    else if (r_State == 1) begin
      r_UART_TX <= 0;
      r_busy <= 1;
      r_DigitIndex <= 0;
      if (c_SampleClock >= i_Period) begin
        r_State <= 2;
        c_SampleClock <= 1;
      end else begin
        r_State <= 1;
        c_SampleClock <= c_SampleClock + 1;
      end
    end
    // Write data bits
    else if (r_State == 2) begin
      r_busy <= 1;
      if (c_SampleClock >= i_Period) begin
        c_SampleClock <= 1;
        r_UART_TX <= r_Byte[r_DigitIndex];
        r_DigitIndex <= r_DigitIndex + 1;
        if (r_DigitIndex == 7) begin
          r_State <= 3;
        end
      end
      else begin
        r_UART_TX <= r_Byte[r_DigitIndex];
        c_SampleClock <= c_SampleClock + 1;
      end
    end
    // Writing stop bit
    else if (r_State == 3) begin
      r_UART_TX <= 1;
      r_busy <= 1;
      if (c_SampleClock >= i_Period) begin
        r_State <= 0;
        c_SampleClock <= 1;
      end else begin
        r_State <= 3;
        c_SampleClock <= c_SampleClock + 1;
      end
    end
    else begin
      r_busy <= 0;
      r_UART_TX <= 1;
    end
  end
  
endmodule