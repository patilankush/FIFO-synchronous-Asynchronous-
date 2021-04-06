`timescale 1ns/1ps
`include "asyn_fifo.v"
module tb;
parameter DEPTH=16;
parameter WIDTH=8;
parameter PTR_WDITH=4;
parameter WR_DELAY=13;
parameter RD_DELAY=12;
parameter WR_TP=15;
parameter RD_TP=15;

reg wr_en_i, rd_en_i;
reg [WIDTH-1:0] wdata_i;
wire full_o;
wire [WIDTH-1:0] rdata_o;
wire empty_o;
reg wr_clk_i, rd_clk_i, rst_i;
wire error_o;
integer i;
integer wr_delay, rd_delay;
reg [30*8:1] testname;

async_fifo dut(
 wr_en_i, wdata_i, full_o,
 rd_en_i, rdata_o, empty_o,
 wr_clk_i, rd_clk_i, rst_i, error_o
);

initial begin
	wr_clk_i = 0;
	forever #(WR_TP/2.0) wr_clk_i = ~wr_clk_i;
end

initial begin
	rd_clk_i = 0;
	forever #(RD_TP/2.0) rd_clk_i = ~rd_clk_i;
end

initial begin
	$value$plusargs("testname=%s",testname);
	rst_i = 1;
	repeat(2) @(posedge wr_clk_i);
	rst_i = 0;
	case (testname)
		"test_full" : begin
			//make FIFO full
			for (i = 0; i < DEPTH; i=i+1) begin
				@(posedge wr_clk_i);
				wdata_i = $random;
				wr_en_i = 1;
			end
				@(posedge wr_clk_i);
				wdata_i = 0;
				wr_en_i = 0;
		end
		"test_empty" : begin
			//make FIFO full
			for (i = 0; i < DEPTH; i=i+1) begin
				@(posedge wr_clk_i);
				wdata_i = $random;
				wr_en_i = 1;
			end
				@(posedge wr_clk_i);
				wdata_i = 0;
				wr_en_i = 0;
			//make FIFO empty
			for (i = 0; i < DEPTH; i=i+1) begin
				@(posedge rd_clk_i);
				rd_en_i = 1;
			end
				@(posedge rd_clk_i);
				rd_en_i = 0;
		end
		"test_full_error" : begin
			for (i = 0; i < DEPTH+1; i=i+1) begin
				@(posedge wr_clk_i);
				wdata_i = $random;
				wr_en_i = 1;
			end
				@(posedge wr_clk_i);
				wdata_i = 0;
				wr_en_i = 0;
		end
		"test_empty_error" : begin
			//make FIFO full
			for (i = 0; i < DEPTH; i=i+1) begin
				@(posedge wr_clk_i);
				wdata_i = $random;
				wr_en_i = 1;
			end
				@(posedge wr_clk_i);
				wdata_i = 0;
				wr_en_i = 0;
			//make FIFO empty
			for (i = 0; i < DEPTH+1; i=i+1) begin
				@(posedge rd_clk_i);
				rd_en_i = 1;
			end
				@(posedge rd_clk_i);
				rd_en_i = 0;
		end
		"test_concurrent_wr_rd" : begin
		fork
		begin //write process
			for (i = 0; i < 500; i=i+1) begin
				@(posedge wr_clk_i);
				wdata_i = $random;
				wr_en_i = 1;
				wr_delay = $urandom_range(1, WR_DELAY);
				@(posedge wr_clk_i);
				wr_en_i = 0;
				repeat(wr_delay-1) @(posedge wr_clk_i);
			end
		end
		begin //read process
			for (i = 0; i < 500+1; i=i+1) begin
				@(posedge rd_clk_i);
				rd_en_i = 1;
				rd_delay = $urandom_range(1, RD_DELAY);
				@(posedge rd_clk_i);
				rd_en_i = 0;
				repeat(rd_delay-1) @(posedge rd_clk_i);
			end
		end
		join
		end
	endcase
	#100;
	$finish;
end
endmodule
