module LED_Blink
  #(parameter g_COUNT_10HZ = 1250000,
    parameter g_COUNT_5HZ = 2500000,
    parameter g_COUNT_2HZ = 6250000,
    parameter g_COUNT_1HZ = 12500000)
  (input  i_Clk,
   output reg o_LED_1 = 1'b0,
   output reg o_LED_2 = 1'b0,
   output reg o_LED_3 = 1'b0,
   output reg o_LED_4 = 1'b0);

  // These signals will be the counters:
  reg [31:0] r_Count_10Hz = 0;
  reg [31:0] r_Count_5Hz  = 0;
  reg [31:0] r_Count_2Hz  = 0;
  reg [31:0] r_Count_1Hz  = 0;
  
  // All processes toggle a specific signal at a different frequency.
  // They all run continuously
  
  always @(posedge i_Clk)
  begin
    if (r_Count_10Hz == g_COUNT_10HZ)
    begin
      o_LED_1      <= ~o_LED_1;
      r_Count_10Hz <= 0;
    end
    else
      r_Count_10Hz <= r_Count_10Hz + 1;
  end

  always @(posedge i_Clk)
  begin
    if (r_Count_5Hz == g_COUNT_5HZ)
    begin
      o_LED_2     <= ~o_LED_2;
      r_Count_5Hz <= 0;
    end
    else
      r_Count_5Hz <= r_Count_5Hz + 1;
  end

  always @(posedge i_Clk)
  begin
    if (r_Count_2Hz == g_COUNT_2HZ)
    begin
      o_LED_3     <= ~o_LED_3;
      r_Count_2Hz <= 0;
    end
    else
      r_Count_2Hz <= r_Count_2Hz + 1;
  end

  always @(posedge i_Clk)
  begin
    if (r_Count_1Hz == g_COUNT_1HZ)
    begin
      o_LED_4     <= ~o_LED_4;
      r_Count_1Hz <= 0;
    end
    else
      r_Count_1Hz <= r_Count_1Hz + 1;
  end

endmodule