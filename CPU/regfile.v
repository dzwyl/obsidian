`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/15 15:32:54
// Design Name: 
// Module Name: regfile
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


module regfile #(
    parameter REGISTER_LEN =   10
)
(
    input                       clock,
    input   [REGISTER_LEN-1:0] RFIN,
    input                       WE,
    input   [1:0]               WA,
    input                       RAE,
    input   [1:0]               RAA,
    input                       RBE,
    input   [1:0]               RBA,

    output reg [REGISTER_LEN-1:0]  A,
    output reg [REGISTER_LEN-1:0]  B

    );

reg [REGISTER_LEN-1:0] register    [3:0];

always @(posedge clock) begin
    if(RAE)
    A   <=  register[RAA];
end

always @(posedge clock) begin
    if(RBE)
    B   <=  register[RBA];
end

always @(posedge clock) begin
    if(WE)
    register[WA]   <=  RFIN;
end

endmodule
