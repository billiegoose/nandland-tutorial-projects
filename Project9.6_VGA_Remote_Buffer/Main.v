`include "Debounce_Switch.v"
`include "Rising_Edge_Detector.v"
`include "VGA_Controller.v"
`include "Seven_Segment_Display.v"
`include "Byte_To_Seven_Segment_Display.v"
`include "Virtual_RAM.v"
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
  input io_PMOD_1,    output io_PMOD_2,    output io_PMOD_3,    output io_PMOD_4,
  output io_PMOD_7,    output io_PMOD_8,    output io_PMOD_9,    output io_PMOD_10
  );
  
  parameter CLKS_PER_BIT = 2604;
  parameter FONT_HEIGHT = 16;
  parameter FONT_WIDTH = 8;
  
  wire [7:0] w_Serial_Byte;
  reg [7:0] r_RAM_Data_In;
  wire [7:0] w_RAM_Data_Out;
  reg [11:0] cursor = 12'd0;
  wire w_Serial_Byte_Ready;
  reg r_Prev_Serial_Byte_Ready = 1'b0;
  reg r_Release_Byte = 0;
  reg r_Write_Enable = 0;
  
  wire w_Any_Switch;
  wire w_Any_Switch_Rising_Edge;
  wire w_Button_1 = i_Switch_1 && w_Any_Switch_Rising_Edge;
  wire w_Button_2 = i_Switch_2 && w_Any_Switch_Rising_Edge;
  wire w_Button_3 = i_Switch_3 && w_Any_Switch_Rising_Edge;
  wire w_Button_4 = i_Switch_4 && w_Any_Switch_Rising_Edge;
  wire w_Reset = w_Button_1;
  wire w_Cursor_Down = w_Button_3;
  wire w_Cursor_Left = w_Button_2;
  wire w_Cursor_Right = w_Button_4;
  
  wire [11:0] r_X;
  wire [11:0] r_Y;
  
  reg [3:0] r_Step = 4'b0;
  
  wire [2:0] w_Red;
  wire [2:0] w_Grn;
  wire [2:0] w_Blu;
  wire [8:0] w_Foreground;
  wire [8:0] w_Background;
  
  wire [7:0] w_TextByte;
  wire [11:0] w_Cell_Index;
  reg [11:0] r_Cell_Index_1;
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch (
    .i_Clk(i_Clk),
    .i_Switch(i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4),
    .o_Switch(w_Any_Switch)
    );
  
  Rising_Edge_Detector Rising_Edge_Detector_1 (
    .i_Clk(i_Clk),
    .i_Signal(w_Any_Switch),
    .o_Pulse(w_Any_Switch_Rising_Edge)
    );
  
  // TODO: Turn RAM module into a stream sink,
  // so that UART_Decoder can be hooked directly to
  // RAM. and UART_Encoder can be hooked directly from RAM.
  Virtual_RAM Virtual_RAM_1 (
    .i_Write_Clock(i_Clk),
    .i_Data_In(r_RAM_Data_In),
    .i_Write_Address(cursor),
    .i_Read_Clock(i_Clk),
    .i_Write_Enable(r_Write_Enable),
    .i_Read_Address(w_Cell_Index),
    .o_Data_Out(w_RAM_Data_Out)
    );
  
  UART_Decoder UART_Decoder_1 (
    .i_Clk(i_Clk),
    .i_Period(CLKS_PER_BIT),
    .i_UART_RX(i_UART_RX),
    .i_release(r_Release_Byte),
    .o_Byte(w_Serial_Byte),
    .o_ready(w_Serial_Byte_Ready)
    );
    
  UART_Encoder UART_Encoder_1 (
    .i_Clk(i_Clk),
    .i_Period(CLKS_PER_BIT),
    .i_Byte(r_Byte),
    .i_write_enable(write_enable),
    .o_UART_TX(io_PMOD_1),
    .o_busy(writing)
    );
    
  UART_Decoder UART_Decoder_2 (
    .i_Clk(i_Clk),
    .i_Period(CLKS_PER_BIT),
    .i_UART_RX(io_PMOD_2),
    .i_release(r_Release_Byte),
    .o_Byte(w_Serial_Byte),
    .o_ready(w_Serial_Byte_Ready)
    );
    
  Byte_To_Seven_Segment_Display Byte_To_Seven_Segment_Display_1 (
    .i_Byte(cursor),
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
  
  Font_Perfect_DOS_VGA_437 Font_Perfect_DOS_VGA_437_1 (
    .index(w_RAM_Data_Out[7:0] -8'b1),
    .line(r_Y[3:0]),
    .data(w_TextByte)
    );
  
  // Read data from keyboard into the Text Buffer
  // TODO: I don't like how the VT_100 implements
  // stuff like arrow keys. I suggest implementing
  // the Unicode symbols from the U+2300-U+23FE
  // which are really quite useful and using them
  // as control characters.
  // Note that this would also mean ASCII control
  // "characters" like newline \n or backspace \b
  // might be better represented as ⎋⏎ (U+238B, U+23CE) and
  // ⎋⌫ (U+238B, U+232B)
  // Along with eliminating non-printable control
  // characters, I would also propose eliminating
  // the classic ESC character sequences.
  // In their place, I suggest every control / action
  // have both an ACTIVE semantic and a LITERAL glyph.
  // Literal glyphs (icons) represent Actions in toolbars,
  // menus, documentation, on keyboards, etc.
  // Most of the time, whether the character is
  // meant to be interpreted as an ACTION or a LITERAL
  // is obvious and application specific, and mandating
  // the use of extra escape symbols increases file size
  // and bandwidth requirements for no gain. However,
  // I recommend having two Universally recognized
  // symbols for ACTION and LITERAL that can be used
  // to precede icons where which semantic is meant
  // is ambiguous. These icons would always be ACTION
  // characters (except when immediately following a Book).
  // My initial suggestion, after a few hours research,
  // is these characters:
  //  🕭 U+1F56D Ringing Bell ‭0001 11110101 01101101‬
  //  🕮 U+1F56E Book ‭0001 11110101 01101110‬
  // The bell is an indicator that the application
  // should interpret the following characters as an action.
  // It has a long historical precident as a control
  // character in its own right (0x07 or \a) in which
  // typing the BEL character in the terminal resulted
  // not in a character being displayed, but an audible bell.
  // Here I've chosen a graphical bell rather than the
  // original ASCII control character so that we can
  // have a shared standard visual representation of the ACTION character.
  // The book is the literal character. By preceding any
  // character with the Book, it is asking the application
  // to interpret the following as literal words on
  // a page, not as instructions to be acted out.
  //
  // In this framework, only two characters ever NEED to be
  // escaped, the book and the bell. To print a book,
  // one would use 🕮🕮 and to print a bell one uses
  // 🕮🕭.
  //
  // Advantages over having a single ESC character.
  // 1. Simplified literal quoting function: unlike with \
  // escaping, you can simply alternate every character with
  // Book.
  // 2. 99% of the time, you needn't escape anything.
  // 3. All terminal control sequences have a printed visible equivalent
  // without resorting to hexadecimal or \a \t \b
  // encoding schemes.
  //   
  // Other symbols considered: 🖮 🖳 🗈 🖥 🖶 🗣 🖺 🖎  🔔🔕 🗲 ⌁ ⍞ ↯
  always @ (posedge i_Clk) begin
    r_Prev_Serial_Byte_Ready <= w_Serial_Byte_Ready;
    r_Cell_Index_1 <= w_Cell_Index;
    
    case (r_Step)
      4'd0: begin
        if (r_Prev_Serial_Byte_Ready == 1'b0 && w_Serial_Byte_Ready == 1'b1) begin
          r_Step <= 4'd1;
        end
      end
      4'd1: begin
        // If a control code, skip the "copy value to ram" step
        if (w_Serial_Byte == 8'd8 || w_Serial_Byte == 8'd13) begin
          r_Step <= 4'd3;
        end else
          r_Step <= 4'd2;
      end
      4'd2: begin
        r_RAM_Data_In <= w_Serial_Byte;
        r_Write_Enable <= 1'b1;
        r_Step <= 4'd3;
      end
      4'd3: begin
        r_Write_Enable <= 1'b0;
        if (w_Serial_Byte == 8'd8 /*backspace*/)
          cursor <= (cursor == 0) ? 2399 : cursor - 1;
        else if (w_Serial_Byte == 8'd13 /*return*/) begin
          cursor <= cursor + 80;
          if (cursor > 2399) cursor <= cursor - 2400;
        end else if (cursor == 2399)
          cursor <= 0;
        else
          cursor <= cursor + 1;
        r_Release_Byte <= 1'b1;
        r_Step <= 4'd4;
      end
      4'd4: begin
        r_Release_Byte <= 1'b0;
        r_Step <= 0;
      end
    endcase
    
    
    if (w_Reset === 1'b1)
      cursor <= 0;
    else if (w_Cursor_Left === 1'b1)
      cursor <= (cursor == 0) ? 2399 : cursor - 1;
    else if (w_Cursor_Right === 1'b1)
      cursor <= (cursor == 2399) ? 0 : cursor + 1;
    else if (w_Cursor_Down === 1'b1)
      cursor <= cursor + 80;
      if (cursor > 2399) cursor <= cursor - 2400;
  end
  
  assign w_Cell_Index = 80 * (r_Y >> 4) + (r_X >> 3);
  assign w_Foreground = (r_Cell_Index_1 == cursor) ? 9'd0 : 9'b111111111;
  assign w_Background = (r_Cell_Index_1 == cursor) ? 9'b111111000 : 9'd0;
  assign w_Red = (w_TextByte[-r_X[2:0]] == 1'b1) ? w_Foreground[2:0] : w_Background[2:0];
  assign w_Grn = (w_TextByte[-r_X[2:0]] == 1'b1) ? w_Foreground[5:3] : w_Background[5:3];
  assign w_Blu = (w_TextByte[-r_X[2:0]] == 1'b1) ? w_Foreground[8:6] : w_Background[8:6];

endmodule










