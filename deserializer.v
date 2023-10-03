module deserializer (

	input wire 	 	 CLK ,
	input wire  	 RST ,
	input wire  	 deser_en ,
	input wire  	 sampled_bit ,
	input wire [5:0] bit_cnt ,  // mine

	output reg [7:0] P_DATA
	);

//	reg [7:0] tmp_frame ;
//	reg [15:0] counter ;

	always @(posedge CLK or negedge RST) begin

		if (!RST) begin 
			P_DATA  <= 8'b1111_1111 ; 
			//counter <= 'd0 ;
		end 

		else begin
			if (deser_en) begin
				if (bit_cnt != 6'b0) begin
					P_DATA[bit_cnt - 1] <= sampled_bit ;			
				end
			end

/*
			if (deser_en) begin
				tmp_frame[counter] <= sampled_bit ;
				counter <= counter + 1 ;

					if (counter == 8) begin 
						P_DATA <= tmp_frame ;
						counter <= 'd0 ;
					end
			end
*/



		end

	end
endmodule 