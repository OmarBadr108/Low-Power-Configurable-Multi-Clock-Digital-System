module BIT_SYNC #(

	parameter NUM_STAGES = 2 ,
	parameter BUS_WIDTH = 4 ) 
	(

	input wire [BUS_WIDTH-1:0] ASYNC ,
	input wire   			   CLK , RST,

	output reg [BUS_WIDTH-1:0] SYNC

	);


	reg [NUM_STAGES-1:0] my_sync [BUS_WIDTH-1:0] ;

	integer i , j ;

	always @(posedge CLK or negedge RST) begin
		if (!RST) begin
			for (i=0 ; i < BUS_WIDTH ; i=i+1)
				my_sync [i] <= 'b0 ;
		end
			
		
		else begin
			for (j=0 ; j < BUS_WIDTH ; j=j+1) 

			my_sync [j] <= {my_sync [j] [NUM_STAGES-2:0] , ASYNC[j]} ;

			

		end
	end


	always@(*)begin
		for (j=0 ; j < BUS_WIDTH ; j=j+1)
		SYNC [j] = my_sync [j] [NUM_STAGES-1] ;

	end
endmodule 