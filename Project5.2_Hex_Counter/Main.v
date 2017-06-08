`include "Debounce_Switch.v"
`include "Seven_Segment_Display.v"
`include "Byte_To_Seven_Segment_Display.v"
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
  
  parameter KEY_REPEAT       = 1000000;
  parameter KEY_REPEAT_DELAY = 5000000;
  
  reg [19:0] r_Key_Repeat_Counter = 0;
  reg [22:0] r_Key_Repeat_Delay_Counter = 0;
  reg r_Any_Switch = 1'b0;
  reg [0:7] r_State = 0;
  
  // Clever trick: share debounce filter
  wire w_Any_Switch;
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch (
    .i_Clk(i_Clk),
    .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
    .o_Switch(w_Any_Switch)
    );
  
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_1 (
    .i_Byte(r_State),
    .o_Segment1_A(o_Segment1_A),
    .o_Segment1_B(o_Segment1_B),
    .o_Segment1_C(o_Segment1_C),
    .o_Segment1_D(o_Segment1_D),
    .o_Segment1_E(o_Segment1_E),
    .o_Segment1_F(o_Segment1_F),
    .o_Segment1_G(o_Segment1_G),
    .o_Segment2_A(o_Segment2_A),
    .o_Segment2_B(o_Segment2_B),
    .o_Segment2_C(o_Segment2_C),
    .o_Segment2_D(o_Segment2_D),
    .o_Segment2_E(o_Segment2_E),
    .o_Segment2_F(o_Segment2_F),
    .o_Segment2_G(o_Segment2_G)
    );
  
  always @ (posedge i_Clk) begin
    r_Any_Switch <= w_Any_Switch;
    // Held down state
    if (r_Any_Switch == 1'b1 && w_Any_Switch == 1'b1) begin
      if (i_Switch_3 == 1'b1) begin
        if (r_Key_Repeat_Delay_Counter < KEY_REPEAT_DELAY) begin
          r_Key_Repeat_Delay_Counter <= r_Key_Repeat_Delay_Counter + 1;
        end else if (r_Key_Repeat_Counter == KEY_REPEAT) begin
          r_Key_Repeat_Counter <= 0;
          r_State <= r_State + 1;
        end else begin
          r_Key_Repeat_Counter <= r_Key_Repeat_Counter + 1;
        end
      end
    // Just released state
    end else if (r_Any_Switch == 1'b1 && w_Any_Switch == 1'b0) begin
      r_Key_Repeat_Counter <= 0;
      r_Key_Repeat_Delay_Counter <= 0;
    // Just pressed state
    end else if (r_Any_Switch == 1'b0 && w_Any_Switch == 1'b1) begin
      if (i_Switch_3 == 1'b1) begin
        r_State <= r_State + 1;
      end else if (i_Switch_4 == 1'b1) begin
        r_State <= 0;
      end
    end
  end
  
endmodule