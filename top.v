/*
=======================================
MODULE TẦNG CAO NHẤT
KẾT NỐI VỚI KIT FPGA DE10-LITE
=======================================
*/

module top #(
    parameter W = 8,
    parameter L = 8
) (
    input CLOCK_50,
    input KEY0, //wr_en
    input KEY1, //rd_en
    input [8:0] SW, //wr_data, reset
    output [9:0] LEDR,   //rd_data, empty, full,
	 output [6:0] HEX0,  //Màn hình hiển thị số phần tử trong FIFO
	 output [6:0] HEX2,  //Màn hình hiển thị 4 bit LSB của wr_data
	 output [6:0] HEX3,  //Màn hình hiển thị 4 bit MSB của wr_data
	 output [6:0] HEX4,  //Màn hình hiển thị 4 bit LSB của rd_data
	 output [6:0] HEX5   //Màn hình hiển thị 4 bit MSB của rd_data
);

    wire reset;
    wire wr_en;
    wire rd_en;
    wire [W - 1:0] wr_data;
    wire [W - 1:0] rd_data;
    wire empty;
    wire full;
	 wire [3:0] cnt;

    wire wr_pulse;
    wire rd_pulse;
	 
	 //================================
	 //Kết nối với module con FIFO
	 //================================
    fifo #(.W(W), .L(L)) map (
        .clk(CLOCK_50),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .empty(empty),
        .full(full),
		  .cnt(cnt)
    );

	 //==========================================
	 //Kết nối module con chống nhiễu nút nhấn
	 //Nút nhấn cho phép đọc
	 //==========================================
    key_one_pulse u1 (
        .clk   (CLOCK_50),
        .key_n (KEY0),
        .pulse (wr_pulse)
    );

	 //==========================================
	 //Kết nối module con chống nhiễu nút nhấn
	 //Nút nhấn cho phép ghi
	 //==========================================
    key_one_pulse u2 (
        .clk   (CLOCK_50),
        .key_n (KEY1),
        .pulse (rd_pulse)
    );
	 
	 
	 // ==================================================
	 // Kết nối module con hiển thị số phần tử trong FIFO
	 // Hiển thị số phần tử của FIFO trên màn hình HEX0
	 // ==================================================
	 cnt_byte cntbyte (
		.bin(cnt),
		.seg(HEX0)
	 );
	 
	 // ==================================================
	 // Kết nối module con hiển thị giá trị của wr_data
	 // 4 bit LSB hiển thị trên màn hình HEX2
	 // ==================================================
	 hex_7_seg hexdisplay2 (
		.hex(wr_data[3:0]),
		.hex_seg(HEX2)
	 );
	 
	 // ==================================================
	 // Kết nối module con hiển thị giá trị của wr_data
	 // 4 bit MSB hiển thị trên màn hình HEX3
	 // ==================================================
	 hex_7_seg hexdisplay3 (
		.hex(wr_data[7:4]),
		.hex_seg(HEX3)
	 );
	 
	 // ==================================================
	 // Kết nối module con hiển thị giá trị của rd_data
	 // 4 bit LSB hiển thị trên màn hình HEX4
	 // ==================================================
	 hex_7_seg hexdisplay4 (
		.hex(rd_data[3:0]),
		.hex_seg(HEX4)
	 );
	 
	 // ==================================================
	 // Kết nối module con hiển thị giá trị của rd_data
	 // 4 bit MSB hiển thị trên màn hình HEX5
	 // ==================================================
	 hex_7_seg hexdisplay5 (
		.hex(rd_data[7:4]),
		.hex_seg(HEX5)
	 );
	 
	 //==========================================
	 //Gán chân kit FPGA
	 //==========================================
    assign reset = ~SW[8];
    assign wr_en = wr_pulse;
    assign rd_en = rd_pulse;
    assign wr_data = SW [7:0];
    assign LEDR [7:0] = rd_data;
    assign LEDR[8] = empty;
    assign LEDR[9] = full;
    
endmodule