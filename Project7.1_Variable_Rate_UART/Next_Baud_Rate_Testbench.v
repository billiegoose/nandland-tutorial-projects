// https://www.edaplayground.com/x/2crq
module Next_Baud_Rate_Testbench ();
  
  reg [19:0] i_CurrentPeriod;
  reg [19:0] o_NextPeriod;
  
  Next_Baud_Rate #(25000000) Next_Baud_Rate_1 (
    .i_CurrentPeriod(i_CurrentPeriod),
    .o_NextPeriod(o_NextPeriod)
  );
  
  always begin
    #1
    i_CurrentPeriod = o_NextPeriod;
  end
  
  initial begin
    i_CurrentPeriod = 227272;
    $monitor($time, " Current=%d, Next=%d", 25000000/i_CurrentPeriod, o_NextPeriod);
    #14
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule