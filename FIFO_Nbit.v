`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 20:17:28
// Design Name: 
// Module Name: FIFO_Nbit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO_Nbit #(parameter DEPTH=8,WIDTH=32)(input clk,cs,reset,we,re,input [WIDTH-1:0]din,output reg [WIDTH-1:0]dout,output full,empty);
localparam fifo_depth=$clog2(DEPTH);

reg [fifo_depth:0]write_p;
reg [fifo_depth:0]read_p;

reg [WIDTH-1:0] fifo [0:DEPTH-1];

always @(posedge clk)
begin
if(reset) begin
dout<=0;
write_p<=0;
end
else if(we && !full && cs)
begin
fifo[write_p[fifo_depth-1:0]]<=din;
write_p=write_p+1;
end
end

always @(posedge clk)
begin
if(reset) begin
dout<=0;
read_p<=0;
end
else if(re && !empty && cs)
begin
dout<=fifo[read_p[fifo_depth-1:0]];
read_p=read_p+1;
end
end

assign empty =(read_p==write_p);
assign full = (read_p==({~write_p[fifo_depth],write_p[fifo_depth-1:0]}));

endmodule
