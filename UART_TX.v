module UART_TX # (parameter DATA_WIDTH = 8) 
(
	input wire [7:0]   P_DATA ,
	input wire 	       DATA_VALID ,
	input wire  	   PAR_EN ,
	input wire  	   PAR_TYP ,
	input wire  	   CLK ,
	input wire  	   RST ,

	output  		   TX_OUT ,
	output       	   Busy
	);

wire 	ser_en ;
wire  	ser_done ;
wire  	ser_data ;
wire 	par_bit ;

wire [1:0] mux_sel ;



TX_FSM U0_FSM (
.CLK(CLK),
.RST(RST),
.DATA_VALID(DATA_VALID), 
.PAR_EN(PAR_EN),
.ser_done(ser_done), 
.ser_en(ser_en),
.mux_sel(mux_sel), 
.Busy(Busy)
);






Serializer # (.WIDTH(DATA_WIDTH)) U0_Serializer (
.CLK(CLK),
.RST(RST),
.P_DATA(P_DATA),
.Busy(Busy),
.ser_en(ser_en), 
.DATA_VALID(DATA_VALID), 
.ser_data(ser_data),
.ser_done(ser_done)
);





mux U0_mux (
.CLK(CLK),
.RST(RST),
.IN_0(1'b0),
.IN_1(1'b1),
.IN_2(ser_data),
.IN_3(par_bit),
.mux_sel(mux_sel),
.TX_OUT(TX_OUT) 
);








parity_calc # (.WIDTH(DATA_WIDTH)) U0_parity_calc (
.CLK(CLK),
.RST(RST),
.PAR_EN(PAR_EN),
.PAR_TYP(PAR_TYP),
.P_DATA(P_DATA),
.Busy(Busy),
.DATA_VALID(DATA_VALID), 
.par_bit(par_bit)
); 





endmodule 