// https://www.edaplayground.com/x/4cj4
`include "UART_Encoder.v"
module UART_Encoder_Testbench ();
  reg i_Clk = 1;
  always #1 i_Clk = !i_Clk;
  
  reg [19:0] r_CLKS_PER_BIT = 2;
  reg rx = 1'b1;
  reg write_enable = 0;
  reg [7:0] r_Byte;
  wire tx;
  wire writing;
    
  UART_Encoder UART_Encoder_1 (
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_Byte(r_Byte),
    .i_write_enable(write_enable),
    .o_UART_TX(tx),
    .o_busy(writing)
    );
  
  `include "serial_write_task.v"
  
  initial begin
    
    r_Byte = 8'b10001010;
    $monitor($time, " rx=%d, r_Byte=%h, o_writing=%d, tx=%d", rx, r_Byte, writing, tx);
    fork
      begin
        #4
        write_enable = 1;
        #2
        write_enable = 0;
      end
      begin
        serial_write(r_Byte);
        #20;
      end
    join
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule