module R_ctrl (

	input wire 	 	 R_INC ,
	input wire [3:0] rq2_wptr,
	input wire  	 R_CLK ,
	input wire  	 R_RST ,

	output   	 rempty,
	output reg [2:0] raddr,
	output reg [3:0] rptr 

	);

reg [3:0] before_gray_rd_ptr ;  //  >> gray coding >> rptr  

// pointer 
	always @(posedge R_CLK or negedge R_RST) begin
		if (!R_RST) begin
			before_gray_rd_ptr <= 4'b0 ;
		end
		else begin
			if (R_INC && !rempty)begin
				before_gray_rd_ptr <= before_gray_rd_ptr + 1 ;
			end
		end
	end

// empty flag

assign rempty = (rptr == rq2_wptr) ;


/*
	always@(posedge R_CLK or negedge R_RST) begin

		if(!R_RST) begin
			rempty <= 1'b1 ;
		end

		else begin

			if (rptr == rq2_wptr) begin
				 rempty <= 1'b1 ;
			end

			else rempty <= 1'b0 ; // mlhash lazma bs mashy 
		end 
		 
	end
*/


// raddr 
	always @(*) begin
		raddr = before_gray_rd_ptr[2:0] ;
	end

// gray code inversion
	always @(*)begin
		case (before_gray_rd_ptr)
		4'b0000 : rptr = 4'b0000 ;
		4'b0001 : rptr = 4'b0001 ;
		4'b0010 : rptr = 4'b0011 ;
		4'b0011 : rptr = 4'b0010 ;

		4'b0100 : rptr = 4'b0110 ;
		4'b0101 : rptr = 4'b0111 ;
		4'b0110 : rptr = 4'b0101 ;
		4'b0111 : rptr = 4'b0100 ;

		4'b1000 : rptr = 4'b1100 ;
		4'b1001 : rptr = 4'b1101 ;
		4'b1010 : rptr = 4'b1111 ;
		4'b1011 : rptr = 4'b1110 ;

		4'b1100 : rptr = 4'b1010 ;
		4'b1101 : rptr = 4'b1011 ;
		4'b1110 : rptr = 4'b1001 ;
		4'b1111 : rptr = 4'b1000 ;
		 
		default : rptr = 4'b0000 ;

		endcase
	end
endmodule
