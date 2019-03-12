// https://www.edaplayground.com/x/4cj4
module UART_Decoder_Testbench ();
  reg i_Clk = 1;
  always #1 i_Clk = !i_Clk;
  
  reg [19:0] r_CLKS_PER_BIT = 2;
  reg rx = 1'b1;
  wire [7:0] r_Byte;
    
  UART_Decoder UART_Decoder_1 (
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_UART_RX(rx),
    .o_Byte(r_Byte)
    );
  
  `include "serial_write_task.v"
  
  initial begin
    $monitor($time, " rx=%d, r_Byte=%h", rx, r_Byte);
    serial_write(20'hAA);
    #4
    serial_write(20'h55);
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule