module stop_check (
	input wire CLK ,RST,
	input wire stp_chk_en ,
	input wire sampled_bit ,

	output reg stp_err	

);

always @(posedge CLK or negedge RST) begin
	if(!RST) stp_err <= 0 ;

	else if (stp_chk_en) begin

		if(sampled_bit) 
			stp_err <= 0 ;
		else 
			stp_err <= 1 ;

	end
	
	else    stp_err <= 0 ;
	
end
endmodule


