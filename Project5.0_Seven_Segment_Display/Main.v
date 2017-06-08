`include "Debounce_Switch.v"
`include "Seven_Segment_Display.v"
module Main (
  input i_Clk,
  input i_Switch_3,
  input i_Switch_4,
  output o_Segment2_A,
  output o_Segment2_B,
  output o_Segment2_C,
  output o_Segment2_D,
  output o_Segment2_E,
  output o_Segment2_F,
  output o_Segment2_G
  );
  
  reg r_Switch_3 = 1'b0;
  wire w_Switch_3;
  reg r_Switch_4 = 1'b0;
  wire w_Switch_4;
  reg [3:0] r_State = 0;
  
  Debounce_Switch Debounce_Switch_3 (
    .i_Clk(i_Clk),
    .i_Switch(i_Switch_3),
    .o_Switch(w_Switch_3)
    );
  
  Debounce_Switch Debounce_Switch_4 (
    .i_Clk(i_Clk),
    .i_Switch(i_Switch_4),
    .o_Switch(w_Switch_4)
    );
  
  Seven_Segment_Display Seven_Segment_Display_2 (
    .i_Nibble(r_State),
    .o_Segment_A(o_Segment2_A),
    .o_Segment_B(o_Segment2_B),
    .o_Segment_C(o_Segment2_C),
    .o_Segment_D(o_Segment2_D),
    .o_Segment_E(o_Segment2_E),
    .o_Segment_F(o_Segment2_F),
    .o_Segment_G(o_Segment2_G)
    );
  
  always @ (posedge i_Clk) begin
    r_Switch_3 <= w_Switch_3;
    r_Switch_4 <= w_Switch_4;
    // Note: changes when button is depressed
    if (w_Switch_3 == 1'b1 && r_Switch_3 == 1'b0)
      if (r_State === 9)
        r_State <= 0;
      else
        r_State <= r_State + 4'b1;
    else if (w_Switch_4 == 1'b1 && r_Switch_4 == 1'b0)
      if (r_State == 0)
        r_State <= 9;
      else
        r_State <= r_State - 4'b1;
  end
  
endmodule