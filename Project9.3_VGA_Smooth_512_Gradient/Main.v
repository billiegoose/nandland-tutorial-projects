`include "Debounce_Switch.v"
`include "VGA_Controller.v"
`include "Stateless_Seven_Segment_Display.v"
`include "Byte_To_Seven_Segment_Display.v"
module Main (
  input i_Clk,
  input i_Switch_1,    input i_Switch_2,    input i_Switch_3,    input i_Switch_4,
  output o_LED_1,      output o_LED_2,      output o_LED_3,      output o_LED_4,
  output io_PMOD_1,    output io_PMOD_2,    output io_PMOD_3,    output io_PMOD_4,
  output io_PMOD_7,    output io_PMOD_8,    output io_PMOD_9,    output io_PMOD_10,
  output o_Segment1_A, output o_Segment1_B, output o_Segment1_C, output o_Segment1_D, output o_Segment1_E, output o_Segment1_F, output o_Segment1_G,
  output o_Segment2_A, output o_Segment2_B, output o_Segment2_C, output o_Segment2_D, output o_Segment2_E, output o_Segment2_F, output o_Segment2_G,
  output o_VGA_Red_0,  output o_VGA_Red_1,  output o_VGA_Red_2,
  output o_VGA_Grn_0,  output o_VGA_Grn_1,  output o_VGA_Grn_2,
  output o_VGA_Blu_0,  output o_VGA_Blu_1,  output o_VGA_Blu_2,
  output o_VGA_HSync,  output o_VGA_VSync
  );
  
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  wire w_Reset = i_Switch_1 && w_Any_Switch;
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
     .o_Switch(w_Any_Switch));

  reg [7:0] col = 0;
  reg [7:0] row = 0;
  
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_a
    (.i_Byte({row, col}),
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
  
  wire [11:0] r_X;
  wire [11:0] r_Y;

  VGA_Controller VGA_Controller_1 (
    .i_Clk(i_Clk),
    .i_Reset(w_Reset),
    .i_VGA_Red(A_Red),
    .i_VGA_Grn(A_Grn),
    .i_VGA_Blu(A_Blu),
    .o_X(r_X),
    .o_Y(r_Y),
    .o_VGA_HSync(o_VGA_HSync),
    .o_VGA_VSync(o_VGA_VSync),
    .o_VGA_Red_2(o_VGA_Red_2),
    .o_VGA_Red_1(o_VGA_Red_1),
    .o_VGA_Red_0(o_VGA_Red_0),
    .o_VGA_Grn_2(o_VGA_Grn_2),
    .o_VGA_Grn_1(o_VGA_Grn_1),
    .o_VGA_Grn_0(o_VGA_Grn_0),
    .o_VGA_Blu_2(o_VGA_Blu_2),
    .o_VGA_Blu_1(o_VGA_Blu_1),
    .o_VGA_Blu_0(o_VGA_Blu_0)
    );
  
  // Big purty color chart
  reg A_Red [2:0] = 3'b0;
  reg A_Grn [2:0] = 3'b0;
  reg A_Blu [2:0] = 3'b0;
  
  always @ (posedge i_Clk) begin
    if (w_Reset === 1'b1) begin
      col <= 0;
      row <= 0;
    end else begin
      // 8 rows of lightness
      // 64 columns of hue
      row <= r_Y / 30;
      col <= r_X / 20;
    end
    if (row <= 7) begin
      if (0 <= col && col <= 7) begin
        A_Blu <= ~row;
        A_Grn <= col;
        A_Red <= 0;
      end else if (8 <= col && col <= 15) begin
        A_Red <= 0;
        A_Grn <= ~col;
        A_Blu <= row;
      end else if (16 <= col && col <= 23) begin
        A_Red <= 0;
        A_Grn <= row;
        A_Blu <= row;
      end else if (24 <= col && col <= 31) begin
        A_Red <= 0;
        A_Grn <= ~row;
        A_Blu <= ~col;
      end
    end else if (8 <= row && row <= 15) begin
      if (0 <= col && col <= 7) begin
        A_Blu <= 0;
        A_Red <= row;
        A_Grn <= col;
      end else if (8 <= col && col <= 15) begin
        A_Red <= row;
        A_Grn <= 7;
        A_Blu <= col;
      end else if (16 <= col && col <= 23) begin
        A_Red <= row;
        A_Grn <= ~col;
        A_Blu <= 7;
      end else if (24 <= col && col <= 31) begin
        A_Grn <= 0;
        A_Blu <= ~col;
        A_Red <= row;
      end
    end 
  end

endmodule