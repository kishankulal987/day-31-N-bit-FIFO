`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2025 09:06:14 PM
// Design Name: FIFO Testbench
// Module Name: FIFO_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple testbench to verify FIFO functionality (write, read, full, empty)
// 
// Dependencies: FIFO_Nbit module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIFO_tb();
  parameter DEPTH = 8;
  parameter WIDTH = 32;
  
  // Inputs
  reg clk, cs, reset, we, re;
  reg [WIDTH-1:0] din;
  
  // Outputs
  wire [WIDTH-1:0] dout;
  wire full, empty;
  
  // Instantiate the FIFO module
  FIFO_Nbit #(DEPTH, WIDTH) DUT (
    .clk(clk),
    .cs(cs),
    .reset(reset),
    .we(we),
    .re(re),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
  );
  
  // Clock generation: 10ns period (5ns high, 5ns low)
  initial clk = 0;
  always #5 clk = ~clk;
  
  // Test stimulus
  initial begin
    // Initialize signals
    reset = 1;
    cs = 1;
    we = 0;
    re = 0;
    din = 0;
    
    // Reset the FIFO
    #10 reset = 0;
    
    // Test 1: Write until FIFO is full
    write_data(32'h00000001);
    write_data(32'h00000002);
    write_data(32'h00000003);
    write_data(32'h00000004);
    write_data(32'h00000005);
    write_data(32'h00000006);
    write_data(32'h00000007);
    write_data(32'h00000008); // Should make FIFO full
    #10;
    if (full) $display("Test 1 Passed: FIFO is full after 8 writes");
    else $display("Test 1 Failed: FIFO not full");
    
    // Test 2: Attempt to write when full
    write_data(32'h00000009); // Should not write (FIFO full)
    #10;
    
    // Test 3: Read until FIFO is empty
    read_data();
    read_data();
    read_data();
    read_data();
    read_data();
    read_data();
    read_data();
    read_data(); // Should make FIFO empty
    #10;
    if (empty) $display("Test 3 Passed: FIFO is empty after 8 reads");
    else $display("Test 3 Failed: FIFO not empty");
    
    // Test 4: Attempt to read when empty
    read_data(); // Should not read (FIFO empty)
    #10;
    
    // Test 5: Write and read alternately
    write_data(32'hA5A5A5A5);
    read_data();
    write_data(32'h5A5A5A5A);
    read_data();
    #10;
    
    // End simulation
    $display("Simulation completed");
    $finish;
  end
  
  // Task to write data to FIFO
  task write_data(input [31:0] data);
  begin
    we = 1;
    din = data;
    #10;
    we = 0;
    $display("Write: %h, Full: %b, Empty: %b", data, full, empty);
  end
  endtask
  
  // Task to read data from FIFO
  task read_data();
  begin
    re = 1;
    #10;
    re = 0;
    $display("Read: %h, Full: %b, Empty: %b", dout, full, empty);
  end
  endtask

endmodule