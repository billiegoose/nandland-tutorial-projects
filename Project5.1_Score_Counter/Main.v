`include "Debounce_Switch.v"
`include "Seven_Segment_Display.v"
module Main (
  input i_Clk,
  input i_Switch_1,
  input i_Switch_2,
  output o_Segment1_A,
  output o_Segment1_B,
  output o_Segment1_C,
  output o_Segment1_D,
  output o_Segment1_E,
  output o_Segment1_F,
  output o_Segment1_G,
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
  
  reg r_Any_Switch = 1'b0;
  reg [3:0] r_State_1 = 0;
  reg [3:0] r_State_2 = 0;
  
  // Clever trick: share debounce filter
  wire w_Any_Switch;
  
  Debounce_Switch Debounce_Switch (
    .i_Clk(i_Clk),
    .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
    .o_Switch(w_Any_Switch)
    );
  
  Seven_Segment_Display Seven_Segment_Display_1 (
    .i_Nibble(r_State_1),
    .o_Segment_A(o_Segment1_A),
    .o_Segment_B(o_Segment1_B),
    .o_Segment_C(o_Segment1_C),
    .o_Segment_D(o_Segment1_D),
    .o_Segment_E(o_Segment1_E),
    .o_Segment_F(o_Segment1_F),
    .o_Segment_G(o_Segment1_G)
    );
  Seven_Segment_Display Seven_Segment_Display_2 (
    .i_Nibble(r_State_2),
    .o_Segment_A(o_Segment2_A),
    .o_Segment_B(o_Segment2_B),
    .o_Segment_C(o_Segment2_C),
    .o_Segment_D(o_Segment2_D),
    .o_Segment_E(o_Segment2_E),
    .o_Segment_F(o_Segment2_F),
    .o_Segment_G(o_Segment2_G)
    );
  
  always @ (posedge i_Clk) begin
    r_Any_Switch <= w_Any_Switch;
    if (w_Any_Switch == 1'b1 && r_Any_Switch == 1'b0) begin
      if (i_Switch_1 == 1'b1) begin
        if (r_State_1 === 9)
          r_State_1 <= 0;
        else
          r_State_1 <= r_State_1 + 4'b1;
      end else if (i_Switch_2 == 1'b1)
        r_State_1 <= 0;
      else if (i_Switch_3 == 1'b1) begin
        if (r_State_2 === 9)
          r_State_2 <= 0;
        else
          r_State_2 <= r_State_2 + 4'b1;
      end else if (i_Switch_4 == 1'b1)
        r_State_2 <= 0;
    end
  end
  
endmodule // Score_Counter