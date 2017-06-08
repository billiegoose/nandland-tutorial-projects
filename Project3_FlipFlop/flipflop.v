module flipflop (
  input i_Clk,
  input i_Switch_1,
  output o_LED_1
  );
  
  reg r_Switch_1 = 1'b0;
  reg r_LED_1 = 1'b0;
  
  always @ (posedge i_Clk) begin
    r_Switch_1 <= i_Switch_1;
    // Note: changes when button is released
    if (i_Switch_1 == 1'b0 && r_Switch_1 == 1'b1) begin
      r_LED_1 <= ~r_LED_1;
    end
  end
  
  assign o_LED_1 = r_LED_1;
  
endmodule