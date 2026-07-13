`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 05:17:21 PM
// Design Name: 
// Module Name: tb_async
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


`timescale 1ns/1ps

module top_async_tb;

parameter Data_Width = 8;
parameter Addr_bits  = 4;

reg wclk;
reg rclk;
reg rstn;
reg wr_en;
reg rd_en;
reg [Data_Width-1:0] data_in;

wire full;
wire empty;
wire [Data_Width-1:0] data_out;

top_async #(
    .Data_Width(Data_Width),
    .Addr_bits(Addr_bits)
) dut (
    .rclk(rclk),
    .wclk(wclk),
    .rstn(rstn),
    .wr_en(wr_en),
    .data_in(data_in),
    .rd_en(rd_en),
    .full(full),
    .empty(empty),
    .data_out(data_out)
);

//////////////////////
// Clock Generation
//////////////////////

initial begin
    wclk = 0;
    forever #5 wclk = ~wclk;      //100 MHz
end

initial begin
    rclk = 0;
    forever #7 rclk = ~rclk;      //Different frequency
end

//////////////////////
// Monitor
//////////////////////

initial begin
    $monitor("T=%0t wr=%b rd=%b din=%0d dout=%0d full=%b empty=%b",
              $time,wr_en,rd_en,data_in,data_out,full,empty);
end

//////////////////////
// Stimulus
//////////////////////

integer i;

initial begin

    rstn    = 0;
    wr_en   = 0;
    rd_en   = 0;
    data_in = 0;

    #20;
    rstn = 1;

    //---------------------------------------------------
    // Test 1 : Single Write
    //---------------------------------------------------
    @(posedge wclk);
    wr_en   = 1;
    data_in = 8'd10;

    @(posedge wclk);
    wr_en = 0;

    //---------------------------------------------------
    // Test 2 : Single Read
    //---------------------------------------------------
    #40;
    @(posedge rclk);
    rd_en = 1;

    @(posedge rclk);
    rd_en = 0;

    //---------------------------------------------------
    // Test 3 : Fill FIFO
    //---------------------------------------------------
    $display("\nFill FIFO");

    for(i=0;i<(1<<Addr_bits);i=i+1)
    begin
        @(posedge wclk);
        wr_en   = 1;
        data_in = i;
    end

    @(posedge wclk);
    wr_en = 0;

    //---------------------------------------------------
    // Test 4 : Overflow
    //---------------------------------------------------
    $display("\nOverflow Test");

    @(posedge wclk);
    wr_en   = 1;
    data_in = 8'hAA;

    @(posedge wclk);
    wr_en = 0;

    //---------------------------------------------------
    // Test 5 : Empty FIFO
    //---------------------------------------------------
    $display("\nRead all");

    for(i=0;i<(1<<Addr_bits);i=i+1)
    begin
        @(posedge rclk);
        rd_en = 1;
    end

    @(posedge rclk);
    rd_en = 0;

    //---------------------------------------------------
    // Test 6 : Underflow
    //---------------------------------------------------
    $display("\nUnderflow Test");

    @(posedge rclk);
    rd_en = 1;

    @(posedge rclk);
    rd_en = 0;

    //---------------------------------------------------
    // Test 7 : Simultaneous Read/Write
    //---------------------------------------------------
    $display("\nSimultaneous Read/Write");

    @(posedge wclk);
    wr_en   = 1;
    data_in = 8'h55;

    @(posedge rclk);
    rd_en = 1;

    #30;

    wr_en = 0;
    rd_en = 0;

    //---------------------------------------------------
    // Test 8 : Alternate Read/Write
    //---------------------------------------------------
    repeat(5)
    begin
        @(posedge wclk);
        wr_en   = 1;
        data_in = $random;

        @(posedge wclk);
        wr_en = 0;

        @(posedge rclk);
        rd_en = 1;

        @(posedge rclk);
        rd_en = 0;
    end

    #100;

    $display("\nSimulation Finished");
    $finish;

end

endmodule