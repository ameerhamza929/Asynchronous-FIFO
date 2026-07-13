`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 04:43:14 PM
// Design Name: 
// Module Name: synchronizer
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


module synchronizer#(
parameter Data_Width = 8,
parameter Addr_bits = 4)(
    input clk,
    input rstn,
    input [Addr_bits:0]data_in,
    output logic [Addr_bits:0]data_out
    );
    
    reg [Addr_bits-1:0]data_sync;
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            data_sync <= 0;
            data_out  <= 0;
        end
        else begin
            data_sync <= data_in;
            data_out  <= data_sync;
        end
    end
    
endmodule
