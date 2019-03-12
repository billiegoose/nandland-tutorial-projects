// This is a little wrapper that makes it convenient to assign
// actions to button clicks. It debounces and combines button data and
// turns them into 1-clock pulses.
module Switch_Board (
  input i_Clk,
  input i_Switch_1,
  input i_Switch_2,
  input i_Switch_3,
  input i_Switch_4,
  output [3:0] o_Buttons
  );
  reg [3:0] r_Buttons = 4'b0000;
  reg r_Any_Switch = 1'b0;
  wire w_Any_Switch;
  wire w_Any_Switch_Filtered;
  
  r_Any_Switch = i_Switch_1 || i_Switch_2 || i_Switch_3 || i_Switch_4;
  
  // Debounce Filter
  Debounce_Switch Debounce_Switch_1 (
    .i_Clk(i_Clk),
    .i_Switch(w_Any_Switch),
    .o_Switch(w_Any_Switch_Filtered)
    );
  
  always @ (posedge i_Clk) begin
    r_Any_Switch <= w_Any_Switch;
    // Only output on the positive edge of button press
    if (r_Any_Switch === 1'b0 && w_Any_Switch === 1'b1) begin
      r_Buttons <= {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4};
    end else begin
      r_Buttons <= 4'b0000;
    end
  end
  
  assign o_Buttons = r_Buttons;
  
endmodule // Debounce_Switch