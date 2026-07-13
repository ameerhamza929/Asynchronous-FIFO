`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 04:50:47 PM
// Design Name: 
// Module Name: Async_FIFO
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


module Async_FIFO#(
    parameter Data_Width = 8,
    parameter Addr_bits = 4)
(
  input rclk,
  input wclk,
  input rstn,
  input wr_en,
  input [Addr_bits-1:0] wr_ptr, rd_ptr,
  input [Data_Width-1:0] data_in,
  input rd_en,
  input full,
  input empty,
  output logic [Data_Width-1:0] data_out
    );
    
    
    localparam Depth = 2**Addr_bits;
    logic [Data_Width-1:0]FIFO [0:Depth-1];
    logic [Addr_bits-1:0] wr_ptr, rd_ptr;
    
    integer i;
    always@(posedge wclk or negedge rstn)begin
        if(!rstn)begin
            for(i=0; i<Depth; i = i+1)begin
                FIFO[i] <= 0;
            end
        end
        else begin
            if(wr_en && !full)begin
                FIFO[wr_ptr] <= data_in;
            end
        end
    
    end
    
    always@(posedge rclk or negedge rstn)begin
        if (!rstn)begin
            data_out <= 0;
        end
        else begin
            if(rd_en && !empty)
                data_out <= FIFO[rd_ptr];
        end
    end
    

    
endmodule
