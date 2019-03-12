module VGA_Text_Buffer (
  din,
  write_en,
  waddr,
  wclk,
  raddr,
  rclk,
  dout
  ); //2400x8
  parameter addr_width = 12;
  parameter data_width = 8;
  input [data_width-1:0] din;
  input [addr_width-1:0] waddr, raddr;
  input write_en, wclk, rclk;
  output reg [data_width-1:0] dout;
  
  reg [data_width-1:0] mem [2399:0];
  
  always @(posedge wclk) // Write memory.
    if (write_en)
      mem[waddr] <= din; // Using write address bus.
  
  always @(posedge rclk) // Read memory.
    dout <= mem[raddr];  // Using read address bus.

endmodule