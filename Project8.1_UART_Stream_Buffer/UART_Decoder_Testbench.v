// https://www.edaplayground.com/x/4cj4
module UART_Decoder_Testbench ();
  reg i_Clk = 1;
  always #1 i_Clk = !i_Clk;
  
  reg [19:0] r_CLKS_PER_BIT = 2;
  reg rx = 1'b1;
  reg r_clear_signal = 1'b0;
  wire [7:0] r_Byte;
  wire w_ready;
    
  UART_Decoder UART_Decoder_1 (
    .i_Clk(i_Clk),
    .i_Period(r_CLKS_PER_BIT),
    .i_UART_RX(rx),
    .i_release(r_clear_signal),
    .o_Byte(r_Byte),
    .o_ready(w_ready)
    );
  
  `include "serial_write_task.v"
  
  initial begin
    fork
      begin
        $monitor($time, " rx=%d, r_Byte=%h", rx, r_Byte);
        #4
        serial_write(20'hAA);
    	serial_write(20'h55);
      end
      begin
        r_clear_signal = 0;
        #44
        r_clear_signal = 1;
        #2
        r_clear_signal = 0;
      end
    join
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule