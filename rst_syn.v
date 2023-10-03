module RST_SYNC #(
	parameter NUM_STAGES = 2
	) (

	input wire RST ,CLK,
	output reg SYNC_RST

	);

	reg [NUM_STAGES-1:0] rst_syn  ;


always @(posedge CLK or negedge RST) begin
	if (!RST) begin
		rst_syn <= 'd0 ;
		
	end
	else begin
		rst_syn [NUM_STAGES-1:0] <= {rst_syn [NUM_STAGES-2:0] , 1'b1} ;

	end
end



always @ (*) begin
	SYNC_RST = rst_syn [NUM_STAGES-1] ;
end




endmodule 