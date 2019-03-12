`include "Debounce_Switch.v"
`include "VGA_Controller.v"
`include "Stateless_Seven_Segment_Display.v"
`include "Byte_To_Seven_Segment_Display.v"
`include "VGA_Text_Buffer.v"
`include "UART_Decoder.v"
module Main (
  input i_Clk,
  input i_Switch_1,    input i_Switch_2,    input i_Switch_3,    input i_Switch_4,
  input i_UART_RX,     output o_UART_TX,
  output o_LED_1,      output o_LED_2,      output o_LED_3,      output o_LED_4,
  output o_Segment1_A, output o_Segment1_B, output o_Segment1_C, output o_Segment1_D, output o_Segment1_E, output o_Segment1_F, output o_Segment1_G,
  output o_Segment2_A, output o_Segment2_B, output o_Segment2_C, output o_Segment2_D, output o_Segment2_E, output o_Segment2_F, output o_Segment2_G,
  output o_VGA_Red_0,  output o_VGA_Red_1,  output o_VGA_Red_2,
  output o_VGA_Grn_0,  output o_VGA_Grn_1,  output o_VGA_Grn_2,
  output o_VGA_Blu_0,  output o_VGA_Blu_1,  output o_VGA_Blu_2,
  output o_VGA_HSync,  output o_VGA_VSync,
  output io_PMOD_1,    output io_PMOD_2,    output io_PMOD_3,    output io_PMOD_4,
  output io_PMOD_7,    output io_PMOD_8,    output io_PMOD_9,    output io_PMOD_10
  );
  
  parameter CLKS_PER_BIT = 2604;
  
  reg [7:0] r_Print_Byte = 8'b0;
  wire [7:0] w_Serial_Byte;
  reg [7:0] r_RAM_Data_In;
  wire [7:0] w_RAM_Data_Out;
  reg [11:0] r_RAM_Addr_Out;
  wire [11:0] w_RAM_Addr_Out;
  reg [11:0] r_RAM_Addr_In;
  reg [11:0] cursor = 12'd0;
  wire w_Serial_Byte_Ready;
  reg r_Prev_Serial_Byte_Ready = 1'b0;
  reg r_Prev_Write_Pulse = 1'b0;
  reg w_Write_Pulse;
  reg r_Release_Byte = 0;
  reg r_Write_Enable = 0;
  
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  wire w_Reset = i_Switch_1 && w_Any_Switch;
  wire w_Button_2 = i_Switch_2 && w_Any_Switch;
  
  reg [11:0] col = 12'b0;
  reg [11:0] row = 12'b0;
  
  wire [11:0] r_X;
  wire [11:0] r_Y;
  
  reg [3:0] r_Step = 4'b0;
  
  reg [2:0] r_Red = 3'b0;
  reg [2:0] r_Grn = 3'b0;
  reg [2:0] r_Blu = 3'b0;
  wire [2:0] w_Red;
  wire [2:0] w_Grn;
  wire [2:0] w_Blu;
  
  // TODO: Turn RAM module into a stream sink,
  // so that UART_Decoder can be hooked directly to
  // RAM. and UART_Encoder can be hooked directly from RAM.
  VGA_Text_Buffer VGA_Text_Buffer_1 (
    .din(r_RAM_Data_In),
    .waddr(cursor),
    .write_en(r_Write_Enable),
    .wclk(i_Clk),
    .rclk(i_Clk),
    .raddr(w_RAM_Addr_Out),
    .dout(w_RAM_Data_Out)
    );
  
  UART_Decoder UART_Decoder_1 (
    .i_Clk(i_Clk),
    .i_Period(CLKS_PER_BIT),
    .i_UART_RX(i_UART_RX),
    .i_release(r_Release_Byte),
    .o_Byte(w_Serial_Byte),
    .o_ready(w_Serial_Byte_Ready)
    );
  
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
     .o_Switch(w_Any_Switch));

  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_a
    (.i_Byte(r_Print_Byte),
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
  
  VGA_Controller VGA_Controller_1 (
    .i_Clk(i_Clk),
    .i_Reset(w_Reset),
    .i_VGA_Red(w_Red),
    .i_VGA_Grn(w_Grn),
    .i_VGA_Blu(w_Blu),
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
    
  // Print contents of ram to the screen
  always @ (posedge i_Clk) begin
    r_Prev_Serial_Byte_Ready <= w_Serial_Byte_Ready;
    r_Prev_Write_Pulse <= w_Write_Pulse;
        
    if (w_Reset === 1'b1) begin
      col <= 0;
      row <= 0;
      cursor <= 0;
    end else begin
      col <= (r_X >> 3);
      row <= (r_Y >> 4);
    end
    if (r_X < 12'd640) begin
      r_RAM_Addr_Out <= row * 12'd80 + col + 1;
      if (row[7:0] > r_Print_Byte[7:0])
        r_Print_Byte <= row;
    end
    
    case (r_Step)
      4'd0:
        if (r_Prev_Serial_Byte_Ready == 1'b0 && w_Serial_Byte_Ready == 1'b1) begin
          r_Step <= 4'd1;
        end
      4'd1: begin
        r_RAM_Data_In <= w_Serial_Byte;
        r_Write_Enable <= 1'b1;
        r_Step <= 4'd2;
        end
      4'd2: begin
        r_Write_Enable <= 1'b0;
        r_Step <= 4'd3;
        end
      4'd3: begin
        r_Release_Byte <= 1'b1;
        cursor <= cursor + 1;
        r_Step <= 4'd4;
        end
      4'd4: begin
        r_Release_Byte <= 1'b0;
        r_Step <= 0;
        end
    endcase
    
    // r_Red <= (r_X == 799) ? 7 : 0;
    // r_Blu <= (r_X == 639) ? 7 : 0;
    // r_Grn <= (r_X == 0) ? 7 : 0;
    
    // if (r_X == 0 && r_Y == 0) begin
    //   A_Red <= 7;
    //   A_Grn <= 0;
    //   A_Blu <= 0;
    // end else if (r_X == 319 && r_Y == 239) begin
    //   A_Red <= 7;
    //   A_Grn <= 0;
    //   A_Blu <= 0;
    // end else if (r_X == 320 && r_Y == 239) begin
    //   A_Red <= 7;
    //   A_Grn <= 0;
    //   A_Blu <= 0;
    // end else if (r_X == 319 && r_Y == 240) begin
    //   A_Red <= 7;
    //   A_Grn <= 0;
    //   A_Blu <= 0;
    // end else if (r_X == 320 && r_Y == 240) begin
    //   A_Red <= 7;
    //   A_Grn <= 0;
    //   A_Blu <= 0;
    // end else if (3*r_X == 4*r_Y) begin
    //   A_Red <= 7;
    //   A_Grn <= 7;
    //   A_Blu <= 7;
    // end else if (r_X == 639 && r_Y == 0) begin
    //   A_Red <= 0;
    //   A_Grn <= 7;
    //   A_Blu <= 0;
    // end else if ((639 - r_X)*3 == 4*r_Y) begin
    //   A_Red <= 5;
    //   A_Grn <= 5;
    //   A_Blu <= 5;
    // end else begin
    //   A_Red <= 0;
    //   A_Blu <= 0;
    //   A_Grn <= 0;
    // end
    
    if (r_X < 640 && r_Y < 480) begin
      r_Red <= w_RAM_Data_Out[2:0];
      r_Grn <= w_RAM_Data_Out[5:3];
      r_Blu <= w_RAM_Data_Out[7:5];
    end else begin
      r_Red <= 0;
      r_Blu <= 0;
      r_Grn <= 0;
    end
  end
  
  assign w_RAM_Addr_Out = row * 12'd80 + col + 1;
  assign w_Red = w_RAM_Data_Out[2:0];
  assign w_Grn = w_RAM_Data_Out[5:3];
  assign w_Blu = w_RAM_Data_Out[7:5];

endmodule










