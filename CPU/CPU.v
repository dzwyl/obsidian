`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/15 18:52:51
// Design Name: 
// Module Name: CPU
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


module CPU#(
    parameter REGISTER_LEN = 10,
    parameter ADDR_LEN = 4,
    parameter INSTRUCTION_LEN = 10
)(
    input                     clock,
    input  [REGISTER_LEN-1:0] datain,
    output [REGISTER_LEN-1:0] dataout

    );

    wire [INSTRUCTION_LEN-1:0] IR;
    wire [REGISTER_LEN-1:0] A,B;
    wire [REGISTER_LEN-1:0] datain_tmp;
    assign datain_tmp = IR[9] ? {3'b000,IR[6:0]}: datain;               //datain_tmp没看懂

    reg reset,Jmux,IRload = 1,PCload;
    wire Q;
    reg IE,ZE,OE,WE,RAE,RBE;
    reg [1:0] WA = 0;
    reg [1:0] RAA = 0;
    reg [1:0] RBA = 0;
    reg [3:0] cal_value = 0;
    reg [2:0] op = 0;
    reg [3:0] phase = 0;
    always @ (posedge clock) begin
        phase <= phase + 1;
    end

//memory
    //phase 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0  1  2  3  4  5....
    //IRload                                0  1  0
    //IR                                          U
    //JMUX                                           U
    //PCload                                            U 
    always @ (posedge clock) begin
        if(IR == 0)
        begin
            reset <= 1;
        end
        else
        begin
            reset <= 0;
        end
    end

    always @ (posedge clock) begin
        if(phase == 14)
        begin
            IRload <= 1;
        end
        else
        begin
            IRload <= 0;
        end 
    end

    always @ (posedge clock) begin         
        if(phase == 0) begin
            casex (IR)
                'b00_0100_xxxx: Jmux <= 0;
                'b00_0101_xxxx: Jmux <= Q;          //Q=Z,Z=0时jmux=0，Z=1时Jmux=0，即发生跳转，未定义则不跳转
                'b00_0110_xxxx: Jmux <= !Q;
                default: Jmux <= 1; 
            endcase
      end
    end

    always @ (posedge clock) begin
        if(phase == 1) begin
            PCload <= 1;
        end
        else
            PCload <= 0;
    end

    /////////////////////////////////////////////////////////////////
    //RF

    //phase 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0  1  2  3  4  5....
    //IR                                          U
    //RA/RE (A/B)                                    U   
    //OP                                                U
    //WE/WA                                                   U      
    //IE                                             U
    //ZE                                                      U
    //OE                                                      U
    //CAL TIME                                       0  1  1  0    
    always @ (posedge clock) begin
        if(phase == 3) 
            casex(IR)
                'b1x_xxxx_xxxx:     
                    begin
                        WA <= IR[8:7];
                        WE <= 1;
                    end
                'b00_1xxx_xxxx,'b01_0xxx_xxxx,'b01_1xxx_xxxx:
                    begin
                        WA <= IR[5:4];              
                        WE <= 1;
                    end
                'b00_0001_xxxx: 
                    begin
                        WA <= IR[3:2];
                        WE <= 1;
                    end
                'b00_0010_00xx:
                    begin
                        WA <= IR[1:0];
                        WE <= 1;
                    end
                'b00_0011_xxxx:
                    begin
                        WA <= IR[3:2];
                        WE <= 1;
                    end
                default: WE <= 0;
            endcase
        else
            WE <= 0;
        
    end

    always @ (posedge clock) begin
        if(phase == 0) begin
            casex (IR)
                'b01_XXXX_XXXX,
                'b00_0111_XXXX: begin
                    RAA <= IR[3:2];
                    RAE <= 1;
                end
                'b00_1XXX_XXXX: begin
                    RAA <= IR[5:4];
                    RAE <= 1;
                end

                'b00_0001_XXXX,
                'b00_0010_01XX,
                'b00_0011_XXXX:
                begin
                    RAA <= IR[1:0];
                    RAE <= 1;
                end 

                default: begin
                    RAE <= 0;
                end
            endcase
        end
        else
        begin
            RAE <= 0;
        end
    end

    always @ (posedge clock) begin
        if(phase == 0) begin
            casex (IR)
                'b01_XXXX_XXXX,
                'b00_0111_XXXX:
                begin
                    RBA <= IR[1:0];
                    RBE <= 1;
                end
                default: begin
                    RBE <= 0;
                end
            endcase
        end
        else
        begin
            RBE <= 0;
        end
    end

    //CAL
    always @ (posedge clock) begin
        if(phase == 1) begin
            cal_value <= IR[3:0];
        end
            
    end

    always @ (posedge clock) begin
        if(phase == 1) begin
            op <= IR[8:6];
        end
            
    end

    always @ (posedge clock) begin          //  没看懂
        if(phase == 0) 
            if((IR[5:2] == 'b10_00) || IR[9])
                IE <= 1;
            else
                IE <= 0;
    end

    always @ (posedge clock) begin
        if(phase == 3)  begin
            casex (IR)
                'b01_XXXX_XXXX,
                'b00_1XXX_XXXX,
                'b00_0111_xxxx,
                'b00_0011_XXXX: ZE <= 1; 
                default: ZE <= 0;
            endcase
        end
        else    begin
            ZE <= 0;
        end
    end

    always @ (posedge clock) begin
        if(phase == 3)  begin
            if(IR[9:2] == 'b00_0010_01)
                OE <= 1;
            else
                OE <= 0;
        end
        else    begin
            OE <= 0;
        end
    end

    memory memory_inst(
        .clock(clock),  
        .PCload(PCload), 
        .reset(reset),  
        .Jmux(Jmux),   
        .IRload(IRload), 
        .IR(IR)
    );


    calpart calpart_inst(
        .clock   (clock),   
        .IE      (IE),
        .ZE      (ZE),
        .OE      (OE),
        .Q       (Q),
        .dataout (dataout),
        .datain  (datain_tmp),
        .WE      (WE),
        .WA      (WA),
        .RAE     (RAE),
        .RAA     (RAA),
        .RBE     (RBE),
        .RBA     (RBA),
        .op      (op),
        .cal_value(cal_value)
    );

endmodule
