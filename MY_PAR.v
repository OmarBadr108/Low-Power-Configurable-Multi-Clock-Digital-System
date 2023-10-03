module parity_calc # ( parameter WIDTH = 8 )

(
 input   wire                  CLK,
 input   wire                  RST,
 input   wire                  PAR_EN,
 input   wire                  PAR_TYP,
 input   wire                  Busy, 
 input   wire   [WIDTH-1:0]    P_DATA,

 input   wire                  DATA_VALID,
 output  reg                   par_bit 
);

reg  [WIDTH-1:0]    tmp_frame ;
reg 	 		    parity_check ;





	always @ (posedge CLK or negedge RST) begin
		 if(!RST) tmp_frame <= 8'b0 ;

		 else if (DATA_VALID && !Busy) begin
			tmp_frame <= P_DATA ; // sampling the input data once at the beggining 
		end
	end


	// parity calc
	
	always @ (posedge CLK or negedge RST) begin
		if (!RST) begin
			par_bit <= 1'b0 ;
		end

		else begin
			if (PAR_EN) begin 
				parity_check <= ^ tmp_frame ;
					if (PAR_TYP) par_bit <= ~^ tmp_frame ;
					else 	     par_bit <=  ^ tmp_frame ;
		
			end
			else parity_check <= 1'b0 ;
		end
	end

endmodule 