`include "Debounce_Switch.v"
`include "VGA_Controller.v"
`include "CGA_to_RrrGggBbb.v"
`include "VGA_Output.v"
`include "Stateless_Seven_Segment_Display.v"
`include "Byte_To_Seven_Segment_Display.v"
module Main (
  input i_Clk,
  input i_Switch_1,
  input i_Switch_2,
  input i_Switch_3,
  input i_Switch_4,
  output o_LED_1,
  output o_LED_2,
  output o_LED_3,
  output o_LED_4,
  output o_Segment1_A,
  output o_Segment1_B,
  output o_Segment1_C,
  output o_Segment1_D,
  output o_Segment1_E,
  output o_Segment1_F,
  output o_Segment1_G,
  output o_Segment2_A,
  output o_Segment2_B,
  output o_Segment2_C,
  output o_Segment2_D,
  output o_Segment2_E,
  output o_Segment2_F,
  output o_Segment2_G,
  output o_VGA_HSync,
  output o_VGA_VSync,
  output o_VGA_Red_0,
  output o_VGA_Red_1,
  output o_VGA_Red_2,
  output o_VGA_Grn_0,
  output o_VGA_Grn_1,
  output o_VGA_Grn_2,
  output o_VGA_Blu_0,
  output o_VGA_Blu_1,
  output o_VGA_Blu_2,
  output io_PMOD_1,
  output io_PMOD_2,
  output io_PMOD_3,
  output io_PMOD_4,
  output io_PMOD_7,
  output io_PMOD_8,
  output io_PMOD_9,
  output io_PMOD_10
  );
  
  reg [3:0] r_Color = 0;
  wire [8:0] RrrGggBbb;
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
     .o_Switch(w_Any_Switch));
  
  always @ (posedge i_Clk) begin
    r_Any_Switch <= w_Any_Switch;
    if (r_Any_Switch == 1'b0 && w_Any_Switch == 1'b1) begin
      if (i_Switch_4 == 1'b1) begin
        if (r_Color === 15) begin
          r_Color <= 0;
        end else begin
          r_Color <= r_Color + 4'b1;
        end
      end
    end
  end
  
  // assign io_PMOD_1 = r_H_Sync;
  // assign io_PMOD_2 = r_V_Sync;
  assign o_LED_1 = 0;
  assign o_LED_2 = 0;
  assign o_LED_3 = 0;
  assign o_LED_4 = 0;
  
  CGA_to_RrrGggBbb CGA_to_RrrGggBbb_1 (
    .i_Color(r_Color),
    .o_RrrGggBbb(RrrGggBbb)
    );
    
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_a
    (.i_Byte(RrrGggBbb[7:0]),
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
  
  VGA_Output VGA_Output_1 (
    .RrrGggBbb(RrrGggBbb),
    .i_VGA_HSync(o_VGA_HSync),
    .i_VGA_VSync(o_VGA_VSync),
    .o_VGA_Red_0(o_VGA_Red_0),
    .o_VGA_Red_1(o_VGA_Red_1),
    .o_VGA_Red_2(o_VGA_Red_2),
    .o_VGA_Grn_0(o_VGA_Grn_0),
    .o_VGA_Grn_1(o_VGA_Grn_1),
    .o_VGA_Grn_2(o_VGA_Grn_2),
    .o_VGA_Blu_0(o_VGA_Blu_0),
    .o_VGA_Blu_1(o_VGA_Blu_1),
    .o_VGA_Blu_2(o_VGA_Blu_2)
    );

  wire [11:0] r_HCounter;
  wire [11:0] r_VCounter;

  VGA_Controller VGA_Controller_1 (
    .i_Clk(i_Clk),
    .i_Reset(i_Switch_1 && w_Any_Switch),
    .o_VGA_HSync(o_VGA_HSync),
    .o_VGA_VSync(o_VGA_VSync),
    .o_X(r_HCounter),
    .o_Y(r_VCounter)
    );
endmodule