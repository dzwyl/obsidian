`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/30 22:51:59
// Design Name: 
// Module Name: tb_cpu
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


module tb_cpu(

    );

reg clock;
always #10 clock = ~clock;

reg [9:0] datain = 10;
always #500 datain = datain + 3;

wire [9:0] dataout;

initial begin
    clock=0;
    dataout=0;
end

CPU inst(
    .clock(clock),
    .datain(datain),
    .dataout(dataout)
);


endmodule
