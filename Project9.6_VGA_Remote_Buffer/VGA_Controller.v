module VGA_Controller (
  input i_Clk,
  input i_Reset,
  input [2:0] i_VGA_Red,
  input [2:0] i_VGA_Grn,
  input [2:0] i_VGA_Blu,
  // Useful outputs
  output [11:0] o_X,
  output [11:0] o_Y,
  output o_Active,
  // Boring outputs
  output o_VGA_HSync,
  output o_VGA_VSync,
  output o_VGA_Red_2,
  output o_VGA_Red_1,
  output o_VGA_Red_0,
  output o_VGA_Grn_2,
  output o_VGA_Grn_1,
  output o_VGA_Grn_0,
  output o_VGA_Blu_2,
  output o_VGA_Blu_1,
  output o_VGA_Blu_0,
  output o_HCounter,
  output o_VCounter
  );
  
  parameter LEAD_CYCLES = 12'd0;
  
  parameter H_TOTAL_WIDTH = 12'd800;
  parameter H_VISIBLE_WIDTH = 12'd640;
  parameter H_FRONT_PORCH = 12'd18;
  parameter H_BACK_PORCH = 12'd50;
  parameter H_START = H_VISIBLE_WIDTH + H_FRONT_PORCH;
  parameter H_FINISH = H_TOTAL_WIDTH - H_BACK_PORCH;
  
  parameter V_TOTAL_HEIGHT = 12'd525;
  parameter V_VISIBLE_HEIGHT = 12'd480;
  parameter V_FRONT_PORCH = 12'd10;
  parameter V_BACK_PORCH = 12'd33;
  parameter V_START = V_VISIBLE_HEIGHT + V_FRONT_PORCH;
  parameter V_FINISH = V_TOTAL_HEIGHT - V_BACK_PORCH;
  
  reg [2:0] r_VGA_Red;
  reg [2:0] r_VGA_Grn;
  reg [2:0] r_VGA_Blu;
  
  reg [11:0] r_HCounter = 12'b0;
  reg [11:0] r_VCounter = 12'b0;
  reg [11:0] r_X = LEAD_CYCLES;
  reg [11:0] r_Y = 12'b0;
  reg r_HSync = 1'b1;
  reg r_VSync = 1'b1;
  reg r_Active = 1'b0;
  
  always @ (posedge i_Clk) begin
    if (i_Reset === 1'b1) begin
      r_HCounter <= 12'b0;
      r_VCounter <= 12'b0;
      r_HSync <= 1'b0;
      r_VSync <= 1'b0;
      // r_X and r_Y are same as HCounter and VCounter, but have
      // a lead time of N clock cycles, so that the module user
      // can have time to set the color based on the X,Y "on deck"
      // so to speak.
      r_X <= LEAD_CYCLES;
      r_Y <= 12'b0;
    end else begin
      if (r_HCounter === H_TOTAL_WIDTH - 1) begin
        r_HCounter <= 12'b0;
        if (r_VCounter === V_TOTAL_HEIGHT - 1) begin
          r_VCounter <= 12'b0;
          r_X <= LEAD_CYCLES;
        end else begin
          r_VCounter <= r_VCounter + 1;
        end
      end else begin
        r_HCounter <= r_HCounter + 1;
      end
      // Exact same logic for r_X, r_Y.
      if (r_X === H_TOTAL_WIDTH - 1) begin
        r_X <= 12'b0;
        if (r_Y === V_TOTAL_HEIGHT - 1) begin
          r_Y <= 12'b0;
        end else begin
          r_Y <= r_Y + 1;
        end
      end else begin
        r_X <= r_X + 1;
      end
    end
    if (r_HCounter == H_START)
      r_HSync <= 1'b0;
    else if (r_HCounter == H_FINISH)
      r_HSync <= 1'b1;
    if (r_VCounter == V_START)
      r_VSync <= 1'b0;
    else if (r_VCounter == V_FINISH)
      r_VSync <= 1'b1;
    
    r_Active <= (r_HCounter < 12'd640) && (r_VCounter < 12'd480);
    r_VGA_Red <= i_VGA_Red;
    r_VGA_Grn <= i_VGA_Grn;
    r_VGA_Blu <= i_VGA_Blu;
  end
  
  // Outputs that might help the parent module decide
  // what color to output.
  assign o_X = r_X;
  assign o_Y = r_Y;
  
  // Current values
  assign o_Active = r_Active;
  assign o_HCounter = r_HCounter;
  assign o_VCounter = r_VCounter;
  
  // Boring output that's just for connecting to the VGA pins
  // so we don't have to worry about that in more than one place
  assign o_VGA_HSync = r_HSync;
  assign o_VGA_VSync = r_VSync;
  assign o_VGA_Red_2 = r_Active && r_VGA_Red[2];
  assign o_VGA_Red_1 = r_Active && r_VGA_Red[1];
  assign o_VGA_Red_0 = r_Active && r_VGA_Red[0];
  assign o_VGA_Grn_2 = r_Active && r_VGA_Grn[2];
  assign o_VGA_Grn_1 = r_Active && r_VGA_Grn[1];
  assign o_VGA_Grn_0 = r_Active && r_VGA_Grn[0];
  assign o_VGA_Blu_2 = r_Active && r_VGA_Blu[2];
  assign o_VGA_Blu_1 = r_Active && r_VGA_Blu[1];
  assign o_VGA_Blu_0 = r_Active && r_VGA_Blu[0];
  
endmodule