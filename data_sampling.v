module data_sampling (
	input wire 	 	 CLK ,
	input wire 	 	 RST ,
	input wire [5:0] Prescale ,
	input wire  	 RX_IN ,
	input wire  	 dat_samp_en ,
	input wire [5:0] edge_cnt ,

	output reg  	 sampled_bit 
	);

reg  [2:0]  my_bits ;
wire A1 , A2 , A3 ;


	always @(posedge CLK or negedge RST) begin
		if (!RST) begin
			sampled_bit <= 1'b1 ;
			my_bits <= 3'b111 ;
		end
		else begin
							
				if (dat_samp_en && edge_cnt == (Prescale/2 -1)) 
						my_bits[2] <= RX_IN ; 
				else if (dat_samp_en && edge_cnt == (Prescale/2)) 
						my_bits[1] <= RX_IN ; 
				else if (dat_samp_en && edge_cnt == (Prescale/2 +1)) 
						my_bits[0] <= RX_IN ; 


				if(edge_cnt == (Prescale/2 +1)) begin
	
					if ( A1 || A2 || A3 ) 
						sampled_bit <= 1'b1 ; 
					else
			 	   	    sampled_bit <= 1'b0 ;
				end	

		end
	end

	assign A1 = my_bits[0] & my_bits[1] ;
	assign A2 = my_bits[0] & my_bits[2] ;
	assign A3 = my_bits[1] & my_bits[2] ;


endmodule