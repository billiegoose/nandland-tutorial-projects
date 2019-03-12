module Byte_To_Seven_Segment_Display (
  input [7:0] i_Byte,
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
  output o_Segment2_G
  );
  
  Stateless_Seven_Segment_Display Seven_Segment_Display_1
    (.i_Nibble(i_Byte[7:4]),
     .o_Segment_A(o_Segment1_A),
     .o_Segment_B(o_Segment1_B),
     .o_Segment_C(o_Segment1_C),
     .o_Segment_D(o_Segment1_D),
     .o_Segment_E(o_Segment1_E),
     .o_Segment_F(o_Segment1_F),
     .o_Segment_G(o_Segment1_G)
    );
  Stateless_Seven_Segment_Display Seven_Segment_Display_2
    (.i_Nibble(i_Byte[3:0]),
     .o_Segment_A(o_Segment2_A),
     .o_Segment_B(o_Segment2_B),
     .o_Segment_C(o_Segment2_C),
     .o_Segment_D(o_Segment2_D),
     .o_Segment_E(o_Segment2_E),
     .o_Segment_F(o_Segment2_F),
     .o_Segment_G(o_Segment2_G)
    );
    
endmodule