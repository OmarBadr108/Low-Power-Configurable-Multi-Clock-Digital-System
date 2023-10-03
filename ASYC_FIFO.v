module ASYC_FIFO #(
	parameter DATA_WADTH = 8 
	) (
	input wire [DATA_WADTH-1:0] WR_DATA ,
	input wire 	 	 	 	 	W_CLK ,
	input wire 	 	 	 	 	W_RST ,
	input wire 	 	 	 	 	W_INC ,
	input wire 	 	 	 	 	R_CLK ,
	input wire 	 	 	 	 	R_RST ,
	input wire 	 	 	 	 	R_INC ,

	output  	 	 	 	    FULL ,
	output  	 	 	 	    EMPTY ,
	output   [DATA_WADTH-1:0]	RD_DATA 

	);

	wire [2:0] waddr ;
	wire [3:0] wptr ;

	wire [2:0] raddr ;
	wire [3:0] rptr ;

	wire [3:0] rq2_wptr ;
	wire [3:0] wq2_rptr ;

//	reg 	  SYN_R_RST ;
//	reg       SYN_W_RST ;



	W_ctrl m1 (
		.W_INC(W_INC),
		.wq2_rptr(wq2_rptr),
		.W_CLK(W_CLK),
		.W_RST(W_RST),
		.wfull(FULL),
		.waddr(waddr),
		.wptr(wptr)
		);



	R_ctrl m2 (
		.R_INC(R_INC),
		.rq2_wptr(rq2_wptr),
		.R_CLK(R_CLK),
		.R_RST(R_RST),
		.rempty(EMPTY),
		.raddr(raddr),
		.rptr(rptr)
		);



	FIFO_MEMORY #(8) m3 (
		.wdata(WR_DATA),
		.W_INC(W_INC),
		.W_FULL(FULL),
		.waddr(waddr),
		.W_CLK(W_CLK),
		.W_RST(W_RST),
		.raddr(raddr),
		.rdata(RD_DATA)
		);


	// W_CLK
	BIT_SYNC #(
		.NUM_STAGES(2),
		.BUS_WIDTH(4)
		) m4 (
		.ASYNC(rptr),
		.CLK(W_CLK),
		.RST(W_RST),
		.SYNC(wq2_rptr)
		);


	// R_CLK
	BIT_SYNC #(
		.NUM_STAGES(2),
		.BUS_WIDTH(4)

		) m5 (
		.ASYNC(wptr),
		.CLK(R_CLK),
		.RST(R_RST),

		.SYNC(rq2_wptr)
		);

/*
	// W_RST
	RST_SYNC #(
		.NUM_STAGES(2)) m6 (
		.CLK(W_CLK),
		.RST(W_RST),
		.SYNC_RST(SYN_W_RST)
		);


	// R_RST
	RST_SYNC #(
		.NUM_STAGES(2)) m7 (
		.CLK(R_CLK),
		.RST(R_RST),
		.SYNC_RST(SYN_R_RST)
		);
*/


endmodule 