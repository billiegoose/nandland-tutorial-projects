module CGA_to_RrrGggBbb (
  input [3:0] i_Color,
  output [8:0] o_RrrGggBbb
  );
  
  reg [8:0] r_RrrGggBbb;
  
  always @(i_Color) begin
    case (i_Color)
      4'h0: r_RrrGggBbb = 9'b000000000; // black 0%
      4'h1: r_RrrGggBbb = 9'b000000101; // navy
      4'h2: r_RrrGggBbb = 9'b000101000; // green
      4'h3: r_RrrGggBbb = 9'b000101101; // teal
      4'h4: r_RrrGggBbb = 9'b101000000; // maroon
      4'h5: r_RrrGggBbb = 9'b101000101; // purple
      4'h6: r_RrrGggBbb = 9'b101101000; // olive
      4'h7: r_RrrGggBbb = 9'b011011011; // silver 75%
      4'h8: r_RrrGggBbb = 9'b101101101; // gray 50%
      4'h9: r_RrrGggBbb = 9'b000000111; // blue
      4'hA: r_RrrGggBbb = 9'b000111000; // lime
      4'hB: r_RrrGggBbb = 9'b000111111; // aqua
      4'hC: r_RrrGggBbb = 9'b111000000; // red
      4'hD: r_RrrGggBbb = 9'b111000111; // fuchsia
      4'hE: r_RrrGggBbb = 9'b111111000; // yellow
      4'hF: r_RrrGggBbb = 9'b111111111; // white 100%
    endcase
  end
  
  assign o_RrrGggBbb = r_RrrGggBbb;
endmodule