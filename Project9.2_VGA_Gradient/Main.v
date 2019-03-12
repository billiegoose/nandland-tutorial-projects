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
  
  always @ (posedge i_Clk) begin
    if (w_Reset === 1'b1) begin
      col <= 0;
      row <= 0;
    end else begin
      if (r_X < 80) col <= 0;
      else if (r_X < 80*2) col <= 1;
      else if (r_X < 80*3) col <= 2;
      else if (r_X < 80*4) col <= 3;
      else if (r_X < 80*5) col <= 4;
      else if (r_X < 80*6) col <= 5;
      else if (r_X < 80*7) col <= 6;
      else if (r_X < 80*8) col <= 7;
      else col <= 8;
      
      if (r_Y < 80) row <= 0;
      else if (r_Y < 80*2) row <= 1;
      else if (r_Y < 80*3) row <= 2;
      else if (r_Y < 80*4) row <= 3;
      else if (r_Y < 80*5) row <= 4;
      else if (r_Y < 80*6) row <= 5;
      else row <= 6;
    end
  end
  
  // Big purty color chart
  reg A_Red [2:0] = 3'b0;
  reg A_Grn [2:0] = 3'b0;
  reg A_Blu [2:0] = 3'b0;
  
  always @ ( * ) begin
    if (col === 7) begin
      A_Red = 7 - (r_Y / 60);
      A_Grn = 7 - (r_Y / 60);
      A_Blu = 7 - (r_Y / 60);
      // Optimization to avoid division:
      // 480 / 8 = 60 but that's not a power of 2
      // if we use 64 as the divisor, we can just bitshift right 6
      // we'll be off by half a block at the end, but all 8 colors are still visible.
      // A_Red = 7 - (r_Y >> 6);
      // A_Grn = 7 - (r_Y >> 6);
      // A_Blu = 7 - (r_Y >> 6);
    
    end else begin
  
      if (row === 0 || row === 1 || row == 5)
        A_Red = col + 1;
      else
        A_Red = 3'b0;
      
      if (0 < row && row < 4)
        A_Grn = col + 1;
      else
        A_Grn = 3'b0;
        
      if (2 < row && row < 6)
        A_Blu = col + 1;
      else
        A_Blu = 3'b0;
        
    end
      // A_Red[2] = ((1 << row) & 7'b0100011) && ((1 << col) & 8'b01111000) || (col == 7 && (1 << row) & 7'b000111); // || (col == 0 && (1 << row) & 7'b0111100);
      // A_Red[1] = ((1 << row) & 7'b0100011) && ((1 << col) & 8'b01100110) || (col == 7 && (1 << row) & 7'b001011); // || (col == 0 && (1 << row) & 7'b0110010);
      // A_Red[0] = ((1 << row) & 7'b0100011) && ((1 << col) & 8'b01010101) || (col == 7 && (1 << row) & 7'b010001); // || (col == 0 && (1 << row) & 7'b0101010);
      // A_Grn[2] = ((1 << row) & 7'b0001110) && ((1 << col) & 8'b01111000) || (col == 7 && (1 << row) & 7'b000111); // || (col == 0 && (1 << row) & 7'b0111100);
      // A_Grn[1] = ((1 << row) & 7'b0001110) && ((1 << col) & 8'b01100110) || (col == 7 && (1 << row) & 7'b001011); // || (col == 0 && (1 << row) & 7'b0110010);
      // A_Grn[0] = ((1 << row) & 7'b0001110) && ((1 << col) & 8'b01010101) || (col == 7 && (1 << row) & 7'b010001); // || (col == 0 && (1 << row) & 7'b0101010);
      // A_Blu[2] = ((1 << row) & 7'b0111000) && ((1 << col) & 8'b01111000) || (col == 7 && (1 << row) & 7'b000111); // || (col == 0 && (1 << row) & 7'b0111100);
      // A_Blu[1] = ((1 << row) & 7'b0111000) && ((1 << col) & 8'b01100110) || (col == 7 && (1 << row) & 7'b001011); // || (col == 0 && (1 << row) & 7'b0110010);
      // A_Blu[0] = ((1 << row) & 7'b0111000) && ((1 << col) & 8'b01010101) || (col == 7 && (1 << row) & 7'b010001); // || (col == 0 && (1 << row) & 7'b0101010);
  end

endmodule