`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 05:05:07 PM
// Design Name: 
// Module Name: top_async
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


module top_async#(
    parameter Data_Width = 8,
    parameter Addr_bits = 4)
(
  input rclk,
  input wclk,
  input rstn,
  input wr_en,
  input [Data_Width-1:0] data_in,
  input rd_en,
  output full,
  output empty,
  output logic [Data_Width-1:0] data_out
    );
    
    
    wire [Addr_bits:0] wr_ptr, rd_ptr,wr_ptr_grey, rd_ptr_grey;
    wire [Addr_bits:0] rd_ptr_sync;
    wire [Addr_bits:0] wr_ptr_sync;
       
        write_ptr_handler #(
            .Data_Width(Data_Width),
             .Addr_bits(Addr_bits)
         ) write_ptr_handler_inst (
             .clk(wclk),
             .rstn(rstn),
             .wr_en(wr_en),
             .full(full),
             .rd_ptr_sync(rd_ptr_sync),
             .wr_ptr(wr_ptr)
         );
         
         
         BintoGr #(
             .Data_Width(Data_Width),
             .Addr_bits(Addr_bits)
         ) BintoGr_inst (
             .bin(rd_ptr),
             .gray(rd_ptr_grey)
         );
         
         
         
         synchronizer #(
            .Data_Width(Data_Width),
            .Addr_bits(Addr_bits)
        ) synchronizer_inst (
            .clk(wclk),
            .rstn(rstn),
            .data_in(rd_ptr_grey),
            .data_out(rd_ptr_sync)
        );
        
        
        
        read_ptr_handler #(
            .Data_Width(Data_Width),
            .Addr_bits(Addr_bits)
        ) read_ptr_handler_inst (
            .clk(rclk),
            .rstn(rstn),
            .rd_en(rd_en),
            .empty(empty),
            .wr_ptr_sync(wr_ptr_sync),
            .rd_ptr(rd_ptr)
        );
        
        
        BintoGr #(
             .Data_Width(Data_Width),
             .Addr_bits(Addr_bits)
         ) BintoGr_inst2 (
             .bin(wr_ptr),
             .gray(wr_ptr_grey)
         );
        
        synchronizer #(
            .Data_Width(Data_Width),
            .Addr_bits(Addr_bits)
        ) synchronizer_inst2 (
            .clk(rclk),
            .rstn(rstn),
            .data_in(wr_ptr_grey),
            .data_out(wr_ptr_sync)
        );
        
        
        
        Async_FIFO #(
            .Data_Width(Data_Width),
            .Addr_bits(Addr_bits)
        ) async_fifo_inst (
            .rclk(rclk),
            .wclk(wclk),
            .rstn(rstn),
            .wr_en(wr_en),
            .wr_ptr(wr_ptr[Addr_bits-1:0]),
            .rd_ptr(rd_ptr[Addr_bits-1:0]),
            .data_in(data_in),
            .rd_en(rd_en),
            .full(full),
            .empty(empty),
            .data_out(data_out)
        );
        
        
        
    
endmodule
