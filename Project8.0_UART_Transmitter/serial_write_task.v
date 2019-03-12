task serial_write;
  input [7:0] data;
  begin
    #4
    rx = 0; // start bit
    #4
    rx = data[0]; // bit 1
    #4
    rx = data[1]; // bit 2
    #4
    rx = data[2]; // bit 3
    #4
    rx = data[3]; // bit 4
    #4
    rx = data[4]; // bit 5
    #4
    rx = data[5]; // bit 6
    #4
    rx = data[6]; // bit 7
    #4
    rx = data[7]; // bit 8
    #4
    rx = 1; // stop bit
    #4;
  end
endtask