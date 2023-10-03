module edge_bit_counter (
	input wire    	  CLK ,RST ,
	input wire		  enable ,
	input wire  [5:0] Prescale ,

	output reg  [5:0] edge_cnt ,
	output reg  [5:0] bit_cnt 

	);

always @(posedge CLK or negedge RST) begin
		
	if (!RST) begin
		bit_cnt  <= 6'b0 ;
		edge_cnt <= 6'b0 ;
	end

	else if (enable) begin
		if (edge_cnt == (Prescale-1)) begin 
			bit_cnt  <= bit_cnt + 1 ;
			edge_cnt <= 0 ;
		end
		
		else edge_cnt <= edge_cnt + 1  ;
	end
	else begin
		bit_cnt  <= 0 ;
		edge_cnt <= 0 ;
	end

end
endmodule