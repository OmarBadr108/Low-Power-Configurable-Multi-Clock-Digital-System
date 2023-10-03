module parity_check (
	input wire 	 	 	 CLK , RST ,
	input wire  	   PAR_TYP ,
	input wire [7:0] P_DATA ,
	input wire 		   par_chk_en ,
	input wire 		   sampled_bit ,

	output reg 		   par_err

	);

	wire	 	 par_check ;

	assign par_check = ^P_DATA ;


always @ (posedge CLK or negedge RST) begin 
	if (!RST) begin
		par_err <= 0 ;
	end
	else if (par_chk_en) begin
		if (par_check) begin
			if (PAR_TYP) begin
				if (sampled_bit) par_err <= 1 ;
				else 	 	         par_err <= 0 ;
			end

			else begin
				if (sampled_bit)  par_err <= 0 ;
				else 	 	    	    par_err <= 1 ;
			end
		end

		else begin
			if (PAR_TYP) begin
				if (sampled_bit)  par_err <= 0 ;
				else 	 	    	    par_err <= 1 ;
			end

			else begin
				if (!sampled_bit) par_err <= 0 ;
				else 	 	    	    par_err <= 1 ;
			end
		end
	end 

	
	else par_err <= 0 ; // not enabled 
end
endmodule
