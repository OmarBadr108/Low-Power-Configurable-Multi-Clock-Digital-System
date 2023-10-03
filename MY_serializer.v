
module Serializer # ( parameter WIDTH = 8 )

(
 input   wire                  CLK,
 input   wire                  RST,
 input   wire   [WIDTH-1:0]    P_DATA,
 input   wire                  ser_en, 
 input   wire                  Busy,
 input   wire                  DATA_VALID, 

 output  reg                   ser_data,
 output  wire                  ser_done
);

reg  [WIDTH-1:0]    tmp_frame ;
reg  [3:0]          counter ;



	always @ (posedge CLK or negedge RST) begin
		 if(!RST) tmp_frame <= 8'd0 ;

		 else if (DATA_VALID && !Busy) begin
			tmp_frame <= P_DATA ; // sampling the input data once at the beggining 
		end

	end



// counter always block 
	always@ (posedge CLK or negedge RST) begin
		if(!RST) begin
			counter <= 4'b0 ;
		end
		else if (ser_en) begin

			ser_data <= tmp_frame[counter] ;
			counter <= counter + 1 ;

			if (counter == 4'd8) begin
				counter  <= 4'd0 ;
			end
			
		end 
		else counter <= 0 ;
	end 


	assign ser_done = (counter == 4'd8) ? 1'b1 : 1'b0 ;



endmodule 