module Rising_Edge_Detector (
  input i_Clk,
  input i_Signal,
  output o_Pulse
  );
  
  reg r_Signal_1 = 1'b0;
  reg r_Output = 1'b0;
  
  always @(posedge i_Clk)
    r_Signal_1 <= i_Signal;
  
  assign o_Pulse = (i_Signal == 1'b1 && r_Signal_1 == 1'b0);
  
endmodule
