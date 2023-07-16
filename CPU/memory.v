`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/15 14:36:26
// Design Name: 
// Module Name: memory
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

module memory#(
    parameter ADDR_LEN = 4,
    parameter INSTRUCTION_LEN = 10
)
(
    input clock,
    input PCload,
    input reset,
    input IRload,
    input Jmux,

    output  reg [INSTRUCTION_LEN-1:0]  IR
    );

wire [INSTRUCTION_LEN-1:0]    instruction;
reg [ADDR_LEN-1:0]    PC=0;

wire    [ADDR_LEN-1:0]  PC_JMP;
wire    [ADDR_LEN-1:0]  PC_INC;
wire    [ADDR_LEN-1:0]  PC_NXT;


assign  PC_JMP=IR[ADDR_LEN-1:0];
assign  PC_INC=PC+1;
assign  PC_NXT=Jmux?PC_INC:PC_JMP;


always @(posedge clock) 
    begin
    if(IRload)
        IR  <=  instruction;
end

always  @(posedge clock)
    begin
        if(reset)
            PC  <=  0;
        else    if(PCload)
            PC  <=  PC_NXT;
    end

programmemory programmemory_inst(
    .addra(PC),
    .clka(clock),
    .douta(instruction)
);

endmodule