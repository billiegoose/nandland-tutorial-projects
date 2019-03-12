`include "Debounce_Switch.v"
`include "VGA_Controller.v"
`include "Stateless_Seven_Segment_Display.v"
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
  
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  // Debounce Filter
  Debounce_Switch Debounce_Switch
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
     .o_Switch(w_Any_Switch));
  
  reg [2:0] r_Red = 3'b0;
  reg [2:0] r_Grn = 3'b0;
  reg [2:0] r_Blu = 3'b0;
  reg [3:0] r_Button = 4'b0;
  reg [3:0] r_Buffer = 4'b0;
  
  always @ (posedge i_Clk) begin
    r_Any_Switch <= w_Any_Switch;
    if (r_Any_Switch === 1'b0 && w_Any_Switch === 1'b1) begin
      case ({i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4})
        4'b1000: r_Button = 4'd1;
        4'b0100: r_Button = 4'd2;
        4'b0010: r_Button = 4'd3;
        4'b0001: r_Button = 4'd4;
        default: r_Button = 4'd0;
      endcase
      
      if (i_Switch_2) begin
        r_Red <= (r_Red + 1) % 8;
        r_Buffer[2:0] <= (r_Red + 1) % 8;
      end
      if (i_Switch_3) begin
        r_Grn <= (r_Grn + 1) % 8;
        r_Buffer[2:0] <= (r_Grn + 1) % 8;
      end
      if (i_Switch_4) begin
        r_Blu <= (r_Blu + 1) % 8;
        r_Buffer[2:0] <= (r_Blu + 1) % 8;
      end
    end
  end
  
  Stateless_Seven_Segment_Display Seven_Segment_Display_1
    (.i_Nibble(r_Buffer),
     .o_Segment_A(o_Segment1_A),
     .o_Segment_B(o_Segment1_B),
     .o_Segment_C(o_Segment1_C),
     .o_Segment_D(o_Segment1_D),
     .o_Segment_E(o_Segment1_E),
     .o_Segment_F(o_Segment1_F),
     .o_Segment_G(o_Segment1_G)
    );
  
  // assign io_PMOD_1 = r_H_Sync;
  // assign io_PMOD_2 = r_V_Sync;
  assign o_LED_1 = 0;
  assign o_LED_2 = 0;
  assign o_LED_3 = 0;
  assign o_LED_4 = 0;
  assign o_VGA_Red_0 = 1'b1 && r_Red[0] && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Red_1 = 1'b1 && r_Red[1] && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Red_2 = 1'b0 && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Grn_0 = 1'b1 && r_Grn[0] && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Grn_1 = 1'b1 && r_Grn[1] && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Grn_2 = 1'b0 && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Blu_0 = 1'b1 && r_Blu[0] && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Blu_1 = 1'b1 && r_Blu[1] && o_VGA_HSync && o_VGA_VSync;
  assign o_VGA_Blu_2 = 1'b0 && o_VGA_HSync && o_VGA_VSync;

endmodule