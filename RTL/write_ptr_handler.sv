module write_ptr_handler#(
parameter Data_Width = 8,
parameter Addr_bits = 4)(
    input clk,
    input rstn,
    input wr_en,
    output logic full,
    input [Addr_bits:0]rd_ptr_sync,
    output logic [Addr_bits:0]wr_ptr
    );

    logic [Addr_bits:0]wr_ptr_int;
    wire [Addr_bits:0] wbin_next;
    logic full_next;
    wire [Addr_bits:0] wgray_next;
    assign wbin_next = wr_ptr_int + (wr_en && !full);
    assign wgray_next = wbin_next ^ (wbin_next >> 1);

    assign wr_ptr = wr_ptr_int;

    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            wr_ptr_int <= 0;
            full <= 0;
        end
        else begin
            if(wr_en && !full_next)
                wr_ptr_int <= wr_ptr_int + 1;
             full <= full_next;
        end

    end

    //wfull_next=(wgray_next=={∼wq2_rgray[A:A-1],wq2_rgray[A-2:0]})

//    assign full = (wgray_next == {∼rd_ptr_sync[Addr_bits:Addr_bits-1],rd_ptr_sync[Addr_bits-2:0]});
    assign full_next = (wgray_next == {~rd_ptr_sync[Addr_bits:Addr_bits-1],rd_ptr_sync[Addr_bits-2:0]});

endmodule