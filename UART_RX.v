module UART_RX (

	input wire  	 CLK ,
	input wire  	 RST ,
	input wire  	 PAR_EN ,
	input wire  	 PAR_TYP ,
	input wire  	 RX_IN ,
	input wire [5:0] Prescale ,

	output     	     data_valid ,
	output 	  [7:0]  P_DATA ,

	output 	 	 	 par_err , 
	output  	 	 stp_err 
	);

// par_check ports
	wire      par_chk_en ;
	wire      sampled_bit ;
	//wire      par_err ;

//start_check ports
	wire      strt_chk_en ;
	wire      strt_glitch ;
 
//stop_check ports
	wire  	  stp_chk_en ;
 	//wire  	  stp_err ;

//FSM ports 
	wire [5:0] edge_cnt ;
	wire [5:0] bit_cnt ;
	wire   	   dat_samp_en ;	   
	wire  	   deser_en ;
	wire  	   enable ;

// serilizer ports
	// kolo mawgod

//edge_bit_counter ports 
	// kolo mawgod

//data_sampling ports 
	// kolo mawgod



	FSM m0 (
		.CLK(CLK),
		.RST(RST),
		.edge_cnt(edge_cnt),
		.bit_cnt(bit_cnt),
		.RX_IN(RX_IN),
		.stp_err(stp_err),
		.strt_glitch(strt_glitch),
		.par_err(par_err),
		.PAR_EN(PAR_EN),
		.dat_samp_en(dat_samp_en),
		.par_chk_en(par_chk_en),
		.strt_chk_en(strt_chk_en),
		.stp_chk_en(stp_chk_en),
		.data_valid(data_valid),
		.deser_en(deser_en),
		.enable(enable),
		.Prescale(Prescale)
		);

	deserializer m1 (
		.CLK(CLK),
		.RST(RST),
		.deser_en(deser_en),
		.sampled_bit(sampled_bit),
		.bit_cnt(bit_cnt), // mine 
		.P_DATA(P_DATA)	

		);

	edge_bit_counter m2 (
		.CLK(CLK),
		.RST(RST),
		.enable(enable),
		.edge_cnt(edge_cnt),
		.bit_cnt(bit_cnt),
		.Prescale(Prescale)
		);

	data_sampling m3 (
		.CLK(CLK),
		.RST(RST),
		.Prescale(Prescale),
		.RX_IN(RX_IN),
		.dat_samp_en(dat_samp_en),
		.edge_cnt(edge_cnt),
		.sampled_bit(sampled_bit)

		);

	stop_check m4 (
		.CLK(CLK),
		.RST(RST),
		.stp_chk_en(stp_chk_en),
		.sampled_bit(sampled_bit),
		.stp_err(stp_err)

		);

	start_check m5 (
		.CLK(CLK),
		.RST(RST),
		.strt_chk_en(strt_chk_en),
		.sampled_bit(sampled_bit),
		.strt_glitch(strt_glitch)


		);


	parity_check m6 (
		.CLK(CLK),
		.RST(RST),
		.PAR_TYP(PAR_TYP),
		.P_DATA(P_DATA),
		.par_chk_en(par_chk_en),
		.sampled_bit(sampled_bit),
		.par_err(par_err)

		);

endmodule