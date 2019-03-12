module Virtual_RAM (
  input i_Clk,
  input i_Perform_Write,
  input [addr_width-1:0] i_Write_Address,
  input [data_width-1:0] i_Write_Data,
  input i_Perform_Read,
  input [addr_width-1:0] i_Read_Address,
  output [addr_width-1:0] o_Read_Address,
  output reg [data_width-1:0] o_Read_Data,
  output reg o_Ready_Write,
  output reg o_Ready_Read
  );
  parameter addr_width = 12;
  parameter data_width = 8;
  
  reg [addr_width-1:0] r_Write_Address;
  reg [addr_width-1:0] r_Read_Address;
  reg [data_width-1:0] r_Write_Data;
  reg [data_width-1:0] r_Read_Data;
  
  // Turn "Perform" signals into pulses if they aren't already.
  module Rising_Edge_Detector (
    input i_Clk,
    input i_Perform_Write,
    output w_Perform_Write_Now
    );
  module Rising_Edge_Detector (
    input i_Clk,
    input i_Perform_Read,
    output w_Perform_Read_Now
    );
  
  always @(posedge i_Clk) begin
    if (w_Perform_Write_Now == 1'b1) begin
      r_Write_Address <= i_Write_Address;
      r_Write_Data <= i_Write_Data;
    end
    if (w_Perform_Read_Now == 1'b1) begin
      r_Read_Address <= i_Read_Address;
      r_Read_Data <= i_Read_Data;
    end
    
    if (i_Write_Enable && i_Write_Address < 2400)
      mem[i_Write_Address] <= i_Data_In; // Using write address bus.
  
    if (i_Read_Address < 2400)
      o_Data_Out <= mem[i_Read_Address];  // Using read address bus.
    else
      o_Data_Out <= 0;

endmodule