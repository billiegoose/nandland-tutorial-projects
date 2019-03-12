module Stateless_Seven_Segment_Display (
  input [3:0] i_Nibble,
  output o_Segment_A,
  output o_Segment_B,
  output o_Segment_C,
  output o_Segment_D,
  output o_Segment_E,
  output o_Segment_F,
  output o_Segment_G
  );
  
  integer w_Display;
  
  always @(i_Nibble)
    case (i_Nibble)
      0: w_Display = 7'h81;
      1: w_Display = 7'hCF;
      2: w_Display = 7'h92;
      3: w_Display = 7'h86;
      4: w_Display = 7'hCC;
      5: w_Display = 7'hA4;
      6: w_Display = 7'hA0;
      7: w_Display = 7'h8F;
      8: w_Display = 7'h80;
      9: w_Display = 7'h84;
      10: w_Display = 7'h88;
      11: w_Display = 7'hE0;
      12: w_Display = 7'hB1;
      13: w_Display = 7'hC2;
      14: w_Display = 7'hB0;
      15: w_Display = 7'hB8;
    endcase
    
  assign o_Segment_A = w_Display[6];
  assign o_Segment_B = w_Display[5];
  assign o_Segment_C = w_Display[4];
  assign o_Segment_D = w_Display[3];
  assign o_Segment_E = w_Display[2];
  assign o_Segment_F = w_Display[1];
  assign o_Segment_G = w_Display[0];
  
endmodule // Seven_Segment_Display