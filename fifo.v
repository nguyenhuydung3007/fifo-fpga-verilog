/*
=======================================
MODULE FIFO
=======================================
*/

module fifo #(
    parameter W = 8,
    parameter L = 8
)(
    input  wire clk,
    input  wire reset,     // active-low reset
    input  wire wr_en,
    input  wire rd_en,
    input  wire [W-1:0] wr_data,
    output reg  [W-1:0] rd_data,
    output wire empty,
    output wire full,
	 
	 //Test
	 output [3:0] cnt
);

    localparam ADDR_W = $clog2(L);

    reg [W-1:0] mem [0:L-1];
    reg [ADDR_W-1:0] wr_ptr, rd_ptr;
    reg [ADDR_W:0]   count;

    assign empty = (count == 0);
    assign full  = (count == L);
	 
	 //Test
	 assign cnt = count;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            wr_ptr  <= 0;
            rd_ptr  <= 0;
            count   <= 0;
            rd_data <= 0;
        end else begin
            case ({wr_en & ~full, rd_en & ~empty})

                // Ghi
                2'b10: begin
                    mem[wr_ptr] <= wr_data;
                    wr_ptr <= (wr_ptr == L-1) ? 0 : wr_ptr + 1;
                    count  <= count + 1;
                end

                // Đọc
                2'b01: begin
                    rd_data <= mem[rd_ptr];
                    rd_ptr <= (rd_ptr == L-1) ? 0 : rd_ptr + 1;
                    count  <= count - 1;
                end

                // Ghi + đọc đồng thời
                2'b11: begin
                    mem[wr_ptr] <= wr_data;
                    wr_ptr <= (wr_ptr == L-1) ? 0 : wr_ptr + 1;

                    rd_data <= mem[rd_ptr];
                    rd_ptr <= (rd_ptr == L-1) ? 0 : rd_ptr + 1;

                    count <= count; // giữ nguyên
                end

                default: begin
                    count <= count;
                end
            endcase
        end
    end

endmodule
