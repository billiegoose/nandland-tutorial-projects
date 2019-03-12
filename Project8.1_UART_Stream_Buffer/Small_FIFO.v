module Small_FIFO (
  input i_Rst,
  input i_Clk,
  input i_Append_Now,
  input i_Shift_Now,
  input [7:0] i_Byte,
  output [7:0] o_Byte,
  output o_Ready_To_Read,
  output o_Ready_To_Write,
  output [2:0] o_Free_Space
  );
  parameter BUFFER_SIZE = 8;
  reg [7:0] r_Memory [BUFFER_SIZE-1:0];
  reg [3:0] r_Free_Space = BUFFER_SIZE;
  
  always @(posedge i_Clk) begin
    if (i_Rst == 1'b1) begin
      r_Memory[7] = 8'b0;
      r_Memory[6] = 8'b0;
      r_Memory[5] = 8'b0;
      r_Memory[4] = 8'b0;
      r_Memory[3] = 8'b0;
      r_Memory[2] = 8'b0;
      r_Memory[1] = 8'b0;
      r_Memory[0] = 8'b0;
      r_Free_Space = BUFFER_SIZE;
    end else begin
      if (i_Append_Now == 1'b1 && r_Free_Space > 0) begin
        r_Memory[r_Free_Space-1] = i_Byte;
        r_Free_Space = r_Free_Space - 1;
      end
      if (i_Shift_Now == 1'b1) begin
        if (r_Free_Space < BUFFER_SIZE)
          r_Free_Space = r_Free_Space + 1;
        r_Memory[7] = r_Memory[6];
        r_Memory[6] = r_Memory[5];
        r_Memory[5] = r_Memory[4];
        r_Memory[4] = r_Memory[3];
        r_Memory[3] = r_Memory[2];
        r_Memory[2] = r_Memory[1];
        r_Memory[1] = r_Memory[0];
      end
    end
  end
  
  assign o_Byte = r_Memory[BUFFER_SIZE-1];
  assign o_Free_Space = r_Free_Space;
  assign o_Ready_To_Read = r_Free_Space < BUFFER_SIZE;
  assign o_Ready_To_Write = r_Free_Space > 0;
endmodule
