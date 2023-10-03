module FIFO_MEMORY #(

	parameter DATA_WIDTH = 8

	)(

	input wire [DATA_WIDTH-1:0] wdata ,
	input wire  	 	 	  	W_INC ,
	input wire  		 	 	W_FULL ,
	input wire [2:0] 	 	 	waddr ,
	input wire   	 	 	 	W_CLK ,
	input wire	 	 	  	 	W_RST , 	 	 		
	input wire [2:0]  	 	 	raddr ,

	output     [DATA_WIDTH-1:0]  		rdata

	);

	reg [DATA_WIDTH-1:0] FIFO_MEM [7:0];
	integer i ;

	always @(posedge W_CLK or negedge W_RST) begin

		if (!W_RST) begin
			for(i=0 ; i < DATA_WIDTH ; i=i+1) FIFO_MEM [i] <= 0;	
		end

		else if(W_INC && !W_FULL) begin
 			FIFO_MEM [waddr] <= wdata ; // write operation has enable condition
		end
	end

	assign rdata = FIFO_MEM [raddr] ; // reading operation is alwyas on

endmodule 
