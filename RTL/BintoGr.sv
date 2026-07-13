`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 06:00:24 PM
// Design Name: 
// Module Name: BintoGr
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


module BintoGr #(
    parameter Data_Width = 8,
    parameter Addr_bits = 4) (
    input [Addr_bits:0] bin,
    output [Addr_bits:0] gray
    );
    
    assign gray = (bin>>1)^bin;
    
endmodule
