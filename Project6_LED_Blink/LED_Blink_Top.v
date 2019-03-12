module LED_Blink_Top
  (input i_Clk,
   output o_LED_1,
   output o_LED_2,
   output o_LED_3,
   output o_LED_4);
   
  LED_Blink Instance
    (.i_Clk(i_Clk),
     .o_LED_1(o_LED_1),
     .o_LED_2(o_LED_2),
     .o_LED_3(o_LED_3),
     .o_LED_4(o_LED_4));
endmodule