module Debounce_Switch (
  input i_Clk,
  input i_Switch,
  output o_Switch
  );
  
  parameter c_DEBOUNCE_LIMIT = 250000;
  
  reg r_State = 1'b0;
  reg [17:0] r_Count = 0;
  
  
  always @(posedge i_Clk)
    begin
      if (i_Switch !== r_State && r_Count < c_DEBOUNCE_LIMIT)
        r_Count <= r_Count + 1;
      else if (r_Count == c_DEBOUNCE_LIMIT)
        begin
          r_Count <= 0;
          r_State <= i_Switch;
        end
      else
        r_Count <= 0;
    end
  
  assign o_Switch = r_State;
  
endmodule // Debounce_Switch