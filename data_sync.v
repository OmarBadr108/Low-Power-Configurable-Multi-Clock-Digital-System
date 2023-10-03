module DATA_SYNC #(

	parameter NUM_STAGES = 2 ,
	parameter BUS_WIDTH = 8 ) 
	(

	input wire [BUS_WIDTH-1:0] unsync_bus ,
	input wire   			   CLK , RST,
	input wire 	 	 	 	   bus_enable,

	output reg  	  	 	   enable_pulse,
	output reg [BUS_WIDTH-1:0] sync_bus

	);

	reg enable_pulse_comb ;
	reg pulse_gen_after_ff ;

	reg [NUM_STAGES-1:0] enable_shift_register ;



	always @(posedge CLK or negedge RST) begin
		if (!RST) begin
			
		end
					
		else begin
			if (enable_pulse_comb) begin
				sync_bus <= unsync_bus ;
			end
		end
	end


	always @(posedge CLK or negedge RST) begin 
		if(!RST) begin
			enable_shift_register <= 0 ;
		end 
		else begin
			enable_shift_register [NUM_STAGES-1:0] <= {enable_shift_register [NUM_STAGES-2:0],bus_enable} ;
		end
	end

	always @(posedge CLK or negedge RST) begin 
		if(!RST) begin
			pulse_gen_after_ff <= 0 ;
		end 
		else begin
			pulse_gen_after_ff <= enable_shift_register [NUM_STAGES-1] ;
		end
	end



	always @(*)begin
		enable_pulse_comb = (enable_shift_register [NUM_STAGES-1]) & (~pulse_gen_after_ff);
	end



	always @(posedge CLK or negedge RST)begin
		if(!RST)
			enable_pulse <= 0 ;
		else 
			enable_pulse <= enable_pulse_comb ;

	end




endmodule 