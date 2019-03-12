module VGA_Output (
  input [8:0] RrrGggBbb,
  input i_VGA_HSync,
  input i_VGA_VSync,
  output o_VGA_Red_0,
  output o_VGA_Red_1,
  output o_VGA_Red_2,
  output o_VGA_Grn_0,
  output o_VGA_Grn_1,
  output o_VGA_Grn_2,
  output o_VGA_Blu_0,
  output o_VGA_Blu_1,
  output o_VGA_Blu_2
  );
  
  wire active = (i_VGA_HSync && i_VGA_VSync);
  // This just makes black darker
  assign o_VGA_Red_0 = active && RrrGggBbb[8];
  assign o_VGA_Red_1 = active && RrrGggBbb[7];
  assign o_VGA_Red_2 = active && RrrGggBbb[6];
  assign o_VGA_Grn_0 = active && RrrGggBbb[5];
  assign o_VGA_Grn_1 = active && RrrGggBbb[4];
  assign o_VGA_Grn_2 = active && RrrGggBbb[3];
  assign o_VGA_Blu_0 = active && RrrGggBbb[2];
  assign o_VGA_Blu_1 = active && RrrGggBbb[1];
  assign o_VGA_Blu_2 = active && RrrGggBbb[0];
endmodule