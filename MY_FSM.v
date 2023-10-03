module TX_FSM  (

 input   wire                  CLK,
 input   wire                  RST,
 input   wire                  DATA_VALID, 
 input   wire                  ser_done, 
 input   wire                  PAR_EN, 
 output  reg                   ser_en,
 output  reg     [1:0]         mux_sel, 
 output  reg                   Busy
);


	localparam IDLE = 3'b000 ;
	localparam STR  = 3'b001 ;
	localparam DATA = 3'b011 ;
	localparam PAR  = 3'b010 ;
	localparam STP  = 3'b110 ;

	reg [7:0]  tmp_frame ;
	reg [2:0]  cs , ns ; // current state and next state
	reg        Busy_c ;




// state memory 
	always @(posedge CLK or negedge RST) begin
		if (!RST)
			cs <= IDLE ;
		else 
			cs <= ns ; 
	end


// FSM  // all states has to drive 4 outputs 
//									    1- busy 
//									    1- ser_en 
//									    1- mux_sel 
//									    1- ns  



	always @(*) begin
		case (cs)
			IDLE : begin
				// state transition 
				   if (DATA_VALID) begin
				   	  ns = STR ;
				   	  ser_en = 1'b0 ;
				   end
				   else begin 
				   	  ns = IDLE ;
				   	  ser_en = 1'b0 ;
				   end

				// state description 
				   ser_en = 1'b0 ;
				   Busy_c    = 1'b0 ;
				   mux_sel = 2'b01 ; // 1 aka stop bit 
		   		   
		   		end	

			STR : begin
				// state transition
				   ns = DATA ;

				// state description
					ser_en  = 1'b1 ;
				  	Busy_c  = 1'b1 ;
				  	mux_sel = 2'b00 ; // start bit
		       	  
		       	end	       


			DATA : begin
				// state description
					ser_en  = 1'b1 ;
					Busy_c    = 1'b1 ;
					mux_sel = 2'b10 ; // serial data

				// state transition
				 
					if (!ser_done)   ns = DATA ;
					else if (PAR_EN) begin
						ns = PAR ;
						ser_en  = 1'b0 ;
					end 
					else begin
						ns = STP ;
						ser_en  = 1'b0 ;
					end		     
					
		           end	
				

			PAR : begin
				// state description
					ser_en  = 1'b0 ;
					Busy_c  = 1'b1 ;
					mux_sel = 2'b11 ; // parity bit


				// state transition
					ns = STP ;
		        end	

			STP : begin
				// state description
					ser_en  = 1'b0 ;
				    Busy_c    = 1'b1 ;
				    mux_sel = 2'b01 ; // stop bit	


				   	ns     = IDLE ;
				   	
				

		        end	

			default : begin
						ser_en  = 1'b0 ;
				        Busy_c  = 1'b0 ;
				        mux_sel = 2'b01 ;   //stop bit =  1 by default

					  	ns 	 	= IDLE ;
					  end
		endcase
	end

//register Busy 

always @ (posedge CLK or negedge RST)  begin
	if (!RST) begin
		Busy <= 1'b0 ;
	end
	else begin
    	Busy <= Busy_c ;
    end
 end

endmodule 