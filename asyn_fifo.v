module async_fifo(
 wr_en_i, wdata_i, full_o,
 rd_en_i, rdata_o, empty_o,
 wr_clk_i, rd_clk_i, rst_i, error_o
);
parameter DEPTH=16;
parameter WIDTH=8;
parameter PTR_WDITH=4;

input wr_en_i, rd_en_i;
input [WIDTH-1:0] wdata_i;
output reg full_o;
output reg [WIDTH-1:0] rdata_o;
output reg empty_o;
input wr_clk_i, rd_clk_i, rst_i;
output reg error_o;

reg [WIDTH-1:0] mem [DEPTH-1:0];
reg [PTR_WDITH-1:0] wr_ptr, rd_ptr;
reg [PTR_WDITH-1:0] wr_ptr_gray, rd_ptr_gray;
reg [PTR_WDITH-1:0] wr_ptr_gray_rd_clk, rd_ptr_gray_wr_clk;
reg wr_toggle_f, rd_toggle_f;
reg wr_toggle_f_rd_clk, rd_toggle_f_wr_clk;
integer i;

//Write related logic
always @(posedge wr_clk_i) begin
if (rst_i == 1) begin
	full_o = 0;
	empty_o = 1;
	rdata_o = 0;
	error_o = 0;
	wr_ptr = 0;
	rd_ptr = 0;
	wr_ptr_gray = 0;
	rd_ptr_gray = 0;
	wr_ptr_gray_rd_clk = 0;
	rd_ptr_gray_wr_clk = 0;
	wr_toggle_f = 0;
	rd_toggle_f = 0;
	for (i = 0; i < DEPTH; i=i+1) begin
		mem[i] = 0;
	end
end
else begin
	error_o = 0;
	if (wr_en_i == 1) begin
		if (full_o == 1) begin
			error_o = 1;
		end
		else begin
			mem[wr_ptr] = wdata_i;
			if (wr_ptr == DEPTH-1) begin
				wr_toggle_f =  ~wr_toggle_f;
			end
			wr_ptr = wr_ptr + 1;
			wr_ptr_gray = bin2gray(wr_ptr); //change happend compred to synch. fifo
		end
	end
end
end

function reg [3:0] bin2gray(input reg [3:0] bin);
reg [3:0] gray;
begin
	gray[3] = bin[3];	
	gray[2] = bin[3]^bin[2];
	gray[1] = bin[2]^bin[1];
	gray[0] = bin[1]^bin[0];
	bin2gray = gray;
end
endfunction

//Read related logic
always @(posedge rd_clk_i) begin
if (rst_i != 1) begin
	error_o = 0;
	if (rd_en_i == 1) begin
		if (empty_o == 1) begin
			error_o = 1;
		end
		else begin
			rdata_o = mem[rd_ptr];
			if (rd_ptr == DEPTH-1) begin
				rd_toggle_f =  ~rd_toggle_f;
			end
			rd_ptr = rd_ptr + 1;
			rd_ptr_gray = bin2gray(rd_ptr);
		end
	end
end
end
//synchronizing
always @(posedge rd_clk_i) begin
	wr_ptr_gray_rd_clk <= wr_ptr_gray;
	wr_toggle_f_rd_clk <= wr_toggle_f;
end

always @(posedge wr_clk_i) begin
	rd_ptr_gray_wr_clk <= rd_ptr_gray;
	rd_toggle_f_wr_clk <= rd_toggle_f;
end

always @(*) begin
	empty_o = 0;
	full_o = 0;
	if (wr_ptr_gray_rd_clk == rd_ptr_gray && wr_toggle_f_rd_clk == rd_toggle_f) begin //rd_toggle_f and rd_ptr_gray all ready in read clock so its dont need to do again..
		empty_o = 1;
	end
	if (wr_ptr_gray == rd_ptr_gray_wr_clk && wr_toggle_f != rd_toggle_f_wr_clk) begin
		full_o = 1;
	end
end
endmodule

