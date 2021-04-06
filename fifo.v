module fifo (clk_i, rst_i, wr_en_i, rd_en_i, wdata_i, full_o, rdata_o, empty_o, error_o ); // 9 PORTS: 5 i/p, 4 o/p
parameter DEPTH =16;
parameter WIDTH =8;
parameter PTR_WIDTH=4;

input [WIDTH -1:0] wdata_i;
output reg [WIDTH-1:0] rdata_o;

input clk_i, rst_i, wr_en_i, rd_en_i;
output reg empty_o, error_o, full_o;  //1st step completed here

reg [WIDTH-1:0] mem [DEPTH-1:0];  // defining memory
reg [PTR_WIDTH-1:0] wr_ptr, rd_ptr;  //its work like a address in memory, ptr:pointer
reg wr_toggle_f, rd_toggle_f;
integer i;

always @(posedge clk_i)begin
	if (rst_i==1) begin
		empty_o=0;
		full_o=0;
		error_o=0;
		wr_ptr=0;
		rd_ptr=0;
		wr_toggle_f=0;
		rd_toggle_f=0;
		for(i=0; i<DEPTH; i=i+1)begin
			mem[i]=0;               //it means we intering in memory now i means depth of memory
		end
	end
	
	else begin
		error_o=0; // if fifo is full and you try to write in fifo then it indicats error,also fifo is empty and you try to read then error indicates.
		//for write
		if (wr_en_i==1)begin  
			if (full_o==1) begin   //if wr_en=1 but our fifo is full then error occurd
				error_o=1;  
			end
			else begin
				//writing the data
				mem[wr_ptr]= wdata_i;
				if (wr_ptr== DEPTH-1)begin      //if pointer reached final location
					wr_toggle_f= ~wr_toggle_f;
				end
				wr_ptr= wr_ptr + 1;
			end
		end
		//for read
		if (rd_en_i ==1)begin
			if(empty_o==1)begin
				error_o=1;     // our fifo is empty and we try to read then error will be occured
			end
			else begin
				//reading the data
				rdata_o= mem[rd_ptr];
				if (rd_ptr== DEPTH-1)begin
					rd_toggle_f= ~rd_toggle_f;
				end
				rd_ptr=rd_ptr+1;
			end
		end
	end
end

always@(*)begin      //(wr_ptr or rd_ptr)
	empty_o=0;
	full_o=0;
	if(wr_ptr == rd_ptr && wr_toggle_f == rd_toggle_f)begin  // both pointer in same point and if toggle same fifo is empty
		empty_o=1;
	end
	if(wr_ptr== rd_ptr && wr_toggle_f != rd_toggle_f) begin   // pointer in same point but if toggle different fifo is full
		full_o =1;
	end
end
endmodule




