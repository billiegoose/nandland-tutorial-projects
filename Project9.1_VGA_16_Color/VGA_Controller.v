module VGA_Controller (
  input i_Clk,
  input i_Reset,
  output o_VGA_HSync,
  output o_VGA_VSync,
  output [11:0] o_X,
  output [11:0] o_Y
  );
  
  parameter H_TOTAL_WIDTH = 12'd800;
  parameter H_VISIBLE_WIDTH = 12'd640;
  parameter H_FRONT_PORCH = 12'd18;
  parameter H_BACK_PORCH = 12'd50;
  parameter H_START = H_TOTAL_WIDTH - H_FRONT_PORCH;
  parameter H_FINISH = H_VISIBLE_WIDTH + H_BACK_PORCH;
  
  parameter V_TOTAL_HEIGHT = 12'd525;
  parameter V_VISIBLE_HEIGHT = 12'd480;
  parameter V_FRONT_PORCH = 12'd10;
  parameter V_BACK_PORCH = 12'd33;
  parameter V_START = V_TOTAL_HEIGHT - V_FRONT_PORCH;
  parameter V_FINISH = V_VISIBLE_HEIGHT + V_BACK_PORCH;
  
  reg [11:0] r_HCounter = 12'b1;
  reg [11:0] r_VCounter = 12'b1;
  reg r_HSync;
  reg r_VSync;
  
  always @ (posedge i_Clk) begin
    if (i_Reset === 1'b1) begin
      r_HCounter <= 12'b0;
      r_VCounter <= 12'b0;
    end else begin
      r_HCounter <= r_HCounter + 1;
      if (r_HCounter === H_TOTAL_WIDTH) begin
        r_HCounter <= 12'b1;
        r_VCounter <= r_VCounter + 1;
        if (r_VCounter === V_TOTAL_HEIGHT) begin
          r_VCounter <= 12'b1;
        end
      end
    end
    if (r_HCounter > H_FINISH && r_HCounter < H_START)
      r_HSync <= 0;
    else
      r_HSync <= 1;
    if (r_VCounter > V_FINISH && r_VCounter < V_START)
      r_VSync <= 0;
    else
      r_VSync <= 1;
  end
    
  // assign io_PMOD_1 = r_H_Sync;
  // assign io_PMOD_2 = r_V_Sync;
  assign o_X = r_HCounter;
  assign o_Y = r_VCounter;
  assign o_VGA_HSync = r_HSync;
  assign o_VGA_VSync = r_VSync;
endmodule