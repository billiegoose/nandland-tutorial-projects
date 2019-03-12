// TODO: Learn how to make a function
module Next_Baud_Rate #(
  parameter CLOCK_SPEED=25000000
  ) (
  input [19:0] i_CurrentPeriod,
  output [19:0] o_NextPeriod,
  output [4:0] o_NextIndex
  );
// Will cycle through 13 speeds:
// 300Hz, 600Hz, 1200Hz, 2400Hz, 4800Hz, 9600Hz, 19200Hz, 38400Hz,
// 57600Hz, 115200Hz, 230400Hz, 460800Hz, 921600Hz
// Thoughts on auto-detecting baud rate:
// From the initial down up:
// ___  Δt  ___
//    |____|
//
// We learn the following constraints on the period P:
// Fastest BAUD rate (smallest P), Δt = P * 9;
// Slowest BAUD rate (largest P), Δt = P;
// Δt / 9 <= P <= Δt
// Δt / 16 <= Δt / 9 <= P <= Δt
// Δt / 2^4 <= P <= Δt
// (Δt >> 4) <= P <= Δt
//
// Actually, we learn this for EVERY down up. So in fact if we store
// Δt_max, Δt_min
// Then we know
// P >= Δt_max >> 4
// P <= Δt_min
//
// We also have a constraint from the high signal.
// P >= Δth_min

  parameter [19:0] TICKS_PER_300_HZ = CLOCK_SPEED / 300;
  parameter [19:0] TICKS_PER_38400_HZ = CLOCK_SPEED / 38400;
  parameter [19:0] TICKS_PER_57600_HZ = CLOCK_SPEED / 57600;
  parameter [19:0] TICKS_PER_921600_HZ = CLOCK_SPEED / 921600;
  
  reg [19:0] r_Next;
  reg [4:0] r_Index = 5'b0;
  always @ ( * ) begin
    // Edge case
    if (i_CurrentPeriod == 0) begin
      r_Next <= TICKS_PER_300_HZ;
      r_Index <= 0;
    end
    // Normal cases
    else if (i_CurrentPeriod == TICKS_PER_38400_HZ) begin
      r_Next <= TICKS_PER_57600_HZ;
      r_Index <= r_Index + 1;
    end
    else if (i_CurrentPeriod === TICKS_PER_921600_HZ) begin
      r_Next <= TICKS_PER_300_HZ;
      r_Index <= 0;
    end
    else begin
      r_Next <= i_CurrentPeriod >> 1;
      r_Index <= r_Index + 1;
    end
  end
  
  assign o_NextPeriod = r_Next;
  assign o_NextIndex = r_Index;
  
endmodule // Next_Baud_Rate
