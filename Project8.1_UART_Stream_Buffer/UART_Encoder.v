module UART_Encoder (
  input i_Rst,
  input i_Clk,
  input [19:0] i_Period,
  input [7:0] i_Byte,
  input i_Write_Now,
  output o_UART_TX,
  output o_Ready_To_Write
  );
  
  reg [2:0] r_State = 3'b0; // State machine
  reg [7:0] r_Byte = 0;
  reg [19:0] c_SampleClock = 20'b0;
  reg [2:0] r_DigitIndex;
  reg r_Ready_To_Write = 1;
  reg r_UART_TX = 1;
  
  assign o_UART_TX = r_UART_TX;
  assign o_Ready_To_Write = r_Ready_To_Write;
  
  always @(posedge i_Clk) begin
    if (i_Rst == 1'b1) begin
      r_State <= 3'b0;
      r_Byte <= 8'b0;
      c_SampleClock <= 20'b0;
      r_DigitIndex <= 0;
      r_Ready_To_Write <= 1'b1;
      r_UART_TX <= 1'b1;
    end
    else if (r_State == 0) begin
      r_DigitIndex <= 0;
      c_SampleClock <= 2;
      // Start
      if (i_Write_Now) begin
        // Snapshot of byte
        r_Byte <= i_Byte;
        r_State <= 1;
        r_Ready_To_Write <= 0;
      end else begin
        r_Byte <= 0;
        r_State <= 0;
        r_Ready_To_Write <= 1;
      end
    end
    // Writing start bit
    else if (r_State == 1) begin
      r_UART_TX <= 0;
      r_Ready_To_Write <= 1;
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
      r_Ready_To_Write <= 0;
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
      r_Ready_To_Write <= 0;
      if (c_SampleClock >= i_Period) begin
        r_State <= 0;
        c_SampleClock <= 1;
      end else begin
        r_State <= 3;
        c_SampleClock <= c_SampleClock + 1;
      end
    end
    else begin
      r_Ready_To_Write <= 1;
      r_UART_TX <= 1;
    end
  end
  
endmodule