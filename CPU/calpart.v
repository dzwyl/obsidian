`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/15 16:36:09
// Design Name: 
// Module Name: calpart
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


module calpart#(
    parameter   REGISTER_LEN = 10
)
(
    input                           clock   ,
    input                           IE      ,
    input                           ZE      ,
    input                           OE      ,
    output reg                      Q =0    ,
    output reg  [REGISTER_LEN-1:0]  dataout ,
    input [REGISTER_LEN-1:0]        datain  ,
    input                           WE      ,
    input [1:0]                     WA      ,
    input                           RAE     ,
    input [1:0]                     RAA     ,
    input                           RBE     ,
    input [1:0]                     RBA     ,
    input [2:0]                     op      ,
    input [3:0]                    cal_value
    );

wire [REGISTER_LEN - 1:0] RFIN;
wire [REGISTER_LEN - 1:0] A;
wire [REGISTER_LEN - 1:0] B;
wire [REGISTER_LEN - 1:0] R;

assign RFIN = IE ? datain : R[REGISTER_LEN - 1:0];

    regfile regfile_inst(
        .clock(clock),
        .RFIN (RFIN),
        .WE   (WE),
        .WA   (WA),
        .RAE  (RAE),
        .RAA  (RAA),
        .RBE  (RBE),
        .RBA  (RBA),
        .A    (A),
        .B    (B)
    );

    ALU ALU_inst(
        .cal_value  (cal_value),
        .op         (op),      
        .A          (A),       
        .B          (B),        
        .R          (R)
    );  

always  @(posedge clock)
    begin
        if(ZE)
        Q   <=  R==0;
    end

always  @(*)
    begin
        if(OE)
        dataout <=  R;
    end


endmodule
