

module read_ptr_handler#(
    parameter Data_Width = 8,
    parameter Addr_bits = 4)(
    input clk,
    input rstn,
    input rd_en,
    output logic empty,
    input [Addr_bits:0] wr_ptr_sync,
    output logic [Addr_bits:0] rd_ptr
    );
    
    logic empty_next;
    logic [Addr_bits:0] rbin_next, rgray_next;
    logic [Addr_bits:0] rgray;   // registered gray code of CURRENT rd_ptr

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rd_ptr <= 0;
            rgray  <= 0;
            empty <= 1;
            
        end
        else begin
            if(!empty_next && rd_en)
                rd_ptr <= rd_ptr + 1;
            empty <= empty_next;
//            rgray  <= rgray_next;
        end
    end

    assign empty_next = (rgray_next == wr_ptr_sync);

    
    assign rbin_next  = rd_ptr + (rd_en && !empty);
    assign rgray_next = rbin_next ^ (rbin_next >> 1);

endmodule