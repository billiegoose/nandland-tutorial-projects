// https://www.edaplayground.com/x/2w_D
module Small_FIFO_Testbench ();
  // Setup fake clock
  reg i_Clk = 1;
  always #1 i_Clk = !i_Clk;
  
  // Local vars
  reg ri_Rst = 1'b1;
  reg [7:0] ri_Byte = 8'b0;
  reg ri_Append_Now = 0;
  reg ri_Shift_Now = 0;
  wire [7:0] wo_Byte;
  wire [2:0] wo_Free_Space;
  
  // Instantiate unit to test
  Small_FIFO Small_FIFO (
    .i_Rst(ri_Rst),
    .i_Clk(i_Clk),
    .i_Byte(ri_Byte),
    .i_Append_Now(ri_Append_Now),
    .i_Shift_Now(ri_Shift_Now),
    .o_Byte(wo_Byte),
    .o_Free_Space(wo_Free_Space)
  );
  
  // Test code
  initial begin
    #2
    ri_Rst = 1'b0;
    #4
    ri_Byte = 8'b00101010;
    ri_Append_Now = 1'b1;
    #2
    ri_Byte = ~ri_Byte;
    #2
    ri_Shift_Now = 1'b1;
    ri_Byte = ~ri_Byte;
    #2
    ri_Shift_Now = 1'b0;
    ri_Byte = ~ri_Byte;
    #2
    ri_Shift_Now = 1'b1;
    ri_Byte = ~ri_Byte;
    #2
    ri_Byte = ~ri_Byte;
    #2
    ri_Byte = ~ri_Byte;
    #2
    ri_Append_Now = 1'b0;
    #16
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule