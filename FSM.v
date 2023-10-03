module FSM (
	input wire 		 CLK ,
	input wire  	 RST , 
	input wire [5:0] edge_cnt ,
	input wire [5:0] bit_cnt ,
	input wire   	 RX_IN ,
	input wire [5:0] Prescale ,

	input wire stp_err ,
	input wire strt_glitch ,
	input wire par_err ,
	input wire PAR_EN ,

	output reg dat_samp_en ,
	output reg par_chk_en ,
	output reg strt_chk_en ,
	output reg stp_chk_en ,
	output reg data_valid ,
	output reg deser_en ,
	output reg enable 

	);

	localparam IDLE    = 6'b00_0000 ;
	localparam STR_CHK = 6'b00_0001 ;
	localparam STR     = 6'b00_0010 ;
	localparam DATA    = 6'b00_0100 ;
	localparam PAR     = 6'b00_1000 ;
	localparam STP     = 6'b01_0000 ;
	localparam ERR_CHK = 6'b10_0000 ;


	reg [5:0] ns , cs ;
	reg 	  PAR_EN_DELAYED ;
	wire  	  Prescale_minus_one ;
	wire  	  Prescale_minus_two ;

	assign Prescale_minus_one = (edge_cnt == Prescale-'d1) ? 1'b1 : 1'b0 ;
	assign Prescale_minus_two = (edge_cnt == Prescale-'d2) ? 1'b1 : 1'b0 ;

// state memory 
	always @(posedge CLK or negedge RST) begin

		if (~RST) begin
			cs <= IDLE ;
		end

		else begin
			cs <= ns ; 
		end

	end

// 

always @(posedge CLK or negedge RST) begin
	if(~RST) begin
		PAR_EN_DELAYED <= 0;
	end 
	else begin
		PAR_EN_DELAYED <= PAR_EN;
	end
end


// ns logic 
	always @ (*)begin
		case(cs)
			IDLE : begin
				if (!RX_IN) begin 
					ns = STR_CHK ;
				end
				else begin
					ns = IDLE ;
				end
			end 

			STR_CHK : begin

				if (RX_IN && strt_glitch)
					ns = IDLE ;
				
				else if (Prescale_minus_two)  // after sampling the bit
					ns = STR ;

				else ns = STR_CHK ;
				
			end 

			STR : begin
				if (Prescale_minus_one) begin // waiting the bit to finish 
					ns = DATA ;
				end
				else begin
					ns = STR ;
				end
			end 

			DATA : begin
				if (bit_cnt == 6'd9) begin 
					if(PAR_EN) ns = PAR ;
					
					else       ns = STP ;
				end
				else begin
					ns = DATA ;
				end
			end 

			PAR : begin // after sampling (edge_cnt > 9)
				if (Prescale_minus_one)  
					ns = STP ;

				else ns = PAR ;
			end 


			STP : begin

				if (PAR_EN) begin
					if((Prescale_minus_two) && (bit_cnt == 10)) begin // finish
						ns = ERR_CHK ;
					end
					
					else begin
						ns = STP ;
					end
				end

				else begin
		 			if((Prescale_minus_two) && (bit_cnt == 9)) begin // finish
		 				ns = ERR_CHK ;
					end
					
		
					else begin
						ns = STP ;
					end
				end
			end 

			ERR_CHK : begin
				if (!RX_IN) ns = STR ;
				else  	    ns = IDLE ;

			end

			default : ns = IDLE ;

		endcase
	end


// output logic 
	always @ (*) begin 

			// default values 
				dat_samp_en   = 1'b0 ;
				enable 		  = 1'b0 ;

				par_chk_en	  = 1'b0 ;
				strt_chk_en   = 1'b0 ;
				stp_chk_en    = 1'b0 ;

				deser_en      = 1'b0 ;
				data_valid    = 1'b0 ;


		case(cs)
			IDLE : begin

				if (!RX_IN) begin 
					dat_samp_en   = 1'b1 ;
					enable 		  = 1'b1 ;
					strt_chk_en   = 1'b1 ;
				end

				else begin
				
					dat_samp_en   = 1'b0 ;
					enable 		  = 1'b0 ;
					strt_chk_en   = 1'b0 ;
				end

				
			end 

			STR_CHK : begin
				if(!RX_IN) begin
					dat_samp_en   = 1'b1 ;
					enable 		  = 1'b1 ;
					strt_chk_en   = 1'b1 ;
					
				end
			end 

			STR : begin

				dat_samp_en   = 1'b1 ;
				enable 		  = 1'b1 ;
				strt_chk_en   = 1'b0 ;

				if (Prescale_minus_one) begin 
					strt_chk_en   = 1'b0 ;
					deser_en      = 1'b1 ;
				end
			end 

			DATA : begin
					dat_samp_en   = 1'b1 ;
					enable 		  = 1'b1 ;
					deser_en      = 1'b1 ;

			end 

			PAR : begin
				dat_samp_en   = 1'b1 ;
				par_chk_en	  = 1'b1 ;
				enable    	  = 1'b1 ;

			end 
 

			
			STP : begin
				dat_samp_en   = 1'b1 ;
				enable 		  = 1'b1 ;
				stp_chk_en	  = 1'b1 ;
				enable 	      = 1'b1 ;
								
			end

			ERR_CHK : begin
				dat_samp_en   = 1'b1 ;
				enable 		  = 1'b0 ;
				stp_chk_en	  = 1'b0 ;
				enable 	      = 1'b0 ;

				if (par_err | stp_err)  data_valid = 1'b0 ;
				else  	 			    data_valid = 1'b1 ;

			end

			default : begin
				dat_samp_en   = 1'b0 ;
				enable 		  = 1'b0 ;

				par_chk_en	  = 1'b0 ;
				strt_chk_en   = 1'b0 ;
				stp_chk_en    = 1'b0 ;

				deser_en      = 1'b0 ;
				data_valid    = 1'b0 ;

			end

		endcase

	end 

endmodule 









////////////////////////////////
////////////////////////////////
///////////////////////////////
///////////////////////////////
////////////////////////////////
/////////////////////////////////
///////////////////////////////