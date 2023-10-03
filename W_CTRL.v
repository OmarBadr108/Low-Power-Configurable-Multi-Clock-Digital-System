module W_ctrl (

	input wire 	 	 W_INC ,
	input wire [3:0] wq2_rptr,
	input wire  	 W_CLK ,
	input wire  	 W_RST ,

	output reg  	 wfull,
	output reg [2:0] waddr,
	output reg [3:0] wptr 

	);

reg [3:0] before_gray_wr_ptr ;  //  >> gray coding >> wptr  

// pointer 
	always @(posedge W_CLK or negedge W_RST) begin
		if (!W_RST) begin
			before_gray_wr_ptr <= 4'b0 ;
		end
		else if (W_INC && !wfull) begin
				before_gray_wr_ptr <= before_gray_wr_ptr + 1 ;
		end
	end

// full flag
	always@(posedge W_CLK or negedge W_RST) begin

		if(!W_RST) begin
			wfull <= 1'b0 ;
		end

		else if (wptr[3] != wq2_rptr[3] && wptr[2] != wq2_rptr[2] && wptr[1:0] == wq2_rptr[1:0]) begin
			wfull <= 1'b1 ;
		end

		else wfull <= 1'b0 ; // mlhash lazma bs mashy 
		
		 
	end

// waddr 
	always @(*) begin
		waddr = before_gray_wr_ptr[2:0] ;
	end

// gray code inversion
	always @(*)begin
		case (before_gray_wr_ptr)
		4'b0000 : wptr = 4'b0000 ;
		4'b0001 : wptr = 4'b0001 ;
		4'b0010 : wptr = 4'b0011 ;
		4'b0011 : wptr = 4'b0010 ;

		4'b0100 : wptr = 4'b0110 ;
		4'b0101 : wptr = 4'b0111 ;
		4'b0110 : wptr = 4'b0101 ;
		4'b0111 : wptr = 4'b0100 ;

		4'b1000 : wptr = 4'b1100 ;
		4'b1001 : wptr = 4'b1101 ;
		4'b1010 : wptr = 4'b1111 ;
		4'b1011 : wptr = 4'b1110 ;

		4'b1100 : wptr = 4'b1010 ;
		4'b1101 : wptr = 4'b1011 ;
		4'b1110 : wptr = 4'b1001 ;
		4'b1111 : wptr = 4'b1000 ;
		 
		default : wptr = 4'b0000 ;

		endcase
	end
endmodule