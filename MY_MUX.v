module mux  (

 input   wire                  CLK,
 input   wire                  RST,
 input   wire                  IN_0,
 input   wire                  IN_1,
 input   wire                  IN_2,
 input   wire                  IN_3,
 input   wire     [1:0]        mux_sel,
 output  reg                   TX_OUT 

 );

reg              mux_out_comb ;
 



	always @ (posedge CLK or negedge RST) begin
		if (!RST) begin
			TX_OUT <= 1'b0 ;
		end 
		else TX_OUT <= mux_out_comb ;
	end



// mux
	always @ (*) begin
		case (mux_sel)
			2'b00 : mux_out_comb = IN_0 ; // start bit = 0
			2'b01 : mux_out_comb = IN_1 ; // stop bit = 1
			2'b10 : mux_out_comb = IN_2 ; // serial data 
			2'b11 : mux_out_comb = IN_3 ; // parity bit

			//default : mux_out_comb = 1'b1 ; // standard idle state of tx_serial output is 1
		endcase
	end

	
endmodule 