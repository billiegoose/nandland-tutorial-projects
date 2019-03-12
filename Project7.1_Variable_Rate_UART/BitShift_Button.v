module BitShift_Button (
  // input i_Clk,
  input i_Switch_2,
  input i_Switch_4,
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
  
  reg [0:7] r_Byte = 0;
  // reg r_Switch_2 = 1;
  // reg r_Switch_4 = 1;
  // reg r_Any_Switch = 1;
  
  // // Clever trick: share debounce filter
  wire w_Any_Switch;
  assign w_Any_Switch = i_Switch_2 || i_Switch_4;
  // 
  // // Debounce Filter
  // Debounce_Switch Debounce_Switch
  //   (.i_Clk(i_Clk),
  //    .i_Switch(i_Switch_2 || i_Switch_4),
  //    .o_Switch(w_Any_Switch));
     
  always @(posedge w_Any_Switch) begin
    // r_Switch_2 <= i_Switch_2; // 1
    // r_Switch_4 <= i_Switch_4; // 0
    // r_Any_Switch <= w_Any_Switch;
    // if (r_Any_Switch == 0 && w_Any_Switch == 1) begin
      if (i_Switch_4 == 1) begin
        r_Byte <= r_Byte * 2;
      end
      else if (i_Switch_2 == 1) begin
        r_Byte <= r_Byte * 2 + 1;
      end
    // end
  end
  
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_a
    (.i_Byte(r_Byte),
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
  
endmodule // BitShift_Button