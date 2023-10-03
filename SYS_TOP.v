
module SYS_TOP # ( parameter DATA_WIDTH = 8 ,  ADDR_WIDTH = 4 )

(
 input   wire                          RST_N,
 input   wire                          UART_CLK,
 input   wire                          REF_CLK,
 input   wire                          UART_RX_IN,

 output  wire                          UART_TX_O,
 output  wire                          parity_error,
 output  wire                          framing_error
);


wire                                   SYNC_UART_RST,
                                       SYNC_REF_RST;
									   
wire					               UART_TX_CLK;
wire					               UART_RX_CLK;


wire      [DATA_WIDTH-1:0]             Operand_A,
                                       Operand_B,
									   UART_Config,
									   DIV_RATIO;
									   
wire      [DATA_WIDTH-1:0]             DIV_RATIO_RX;
									   
wire      [DATA_WIDTH-1:0]             UART_RX_OUT;
wire         						   UART_RX_V_OUT;
wire      [DATA_WIDTH-1:0]			   UART_RX_SYNC;
wire                                   UART_RX_V_SYNC;

wire      [DATA_WIDTH-1:0]             UART_TX_IN;
wire        						   UART_TX_VLD;
wire      [DATA_WIDTH-1:0]             UART_TX_SYNC;
wire        						   UART_TX_V_SYNC;

wire                                   UART_TX_Busy;	
wire                                   UART_TX_Busy_PULSE;	
									   
wire                                   RF_WrEn;
wire                                   RF_RdEn;
wire      [ADDR_WIDTH-1:0]             RF_Address;
wire      [DATA_WIDTH-1:0]             RF_WrData;
wire      [DATA_WIDTH-1:0]             RF_RdData;
wire                                   RF_RdData_VLD;									   

wire                                   CLKG_EN;
wire                                   ALU_EN;
wire      [3:0]                        ALU_FUN; 
wire      [DATA_WIDTH*2-1:0]           ALU_OUT;
wire                                   ALU_OUT_VLD; 
									   
wire                                   ALU_CLK ;								   

wire                                   FIFO_FULL ;
	
wire                                   CLKDIV_EN ;
								   
///********************************************************///
//////////////////// Reset synchronizers /////////////////////
///********************************************************///

RST_SYNC # (.NUM_STAGES(2)) U0_RST_SYNC (
.RST(RST_N),
.CLK(UART_CLK),
.SYNC_RST(SYNC_UART_RST) // TX
);

RST_SYNC # (.NUM_STAGES(2)) U1_RST_SYNC (
.RST(RST_N),
.CLK(REF_CLK),
.SYNC_RST(SYNC_REF_RST)  // RX and the rest of the system
);

///********************************************************///
////////////////////// Data Synchronizer /////////////////////
///********************************************************///

DATA_SYNC # (.NUM_STAGES(2) , .BUS_WIDTH(8)) U0_DATA_REF_sync (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.unsync_bus(UART_RX_OUT),
.bus_enable(UART_RX_V_OUT),
.sync_bus(UART_RX_SYNC),
.enable_pulse(UART_RX_V_SYNC)
);

///********************************************************///
///////////////////////// Async FIFO /////////////////////////
///********************************************************///

// my FIFO

ASYC_FIFO #(.DATA_WADTH(8)) U0_UART_FIFO (
	.WR_DATA(UART_TX_IN),
	.W_CLK(REF_CLK),
	.W_RST(SYNC_REF_RST),
	.W_INC(UART_TX_VLD),
	.R_CLK(UART_TX_CLK),
	.R_RST(SYNC_UART_RST),
	.R_INC(UART_TX_Busy_PULSE),

	.FULL(FIFO_FULL),
	.EMPTY(UART_TX_V_SYNC),
	.RD_DATA(UART_TX_SYNC)


	); 

/*
Async_fifo #(.D_SIZE(DATA_WIDTH) , .P_SIZE(4)  , .F_DEPTH(8)) U0_UART_FIFO (
.i_w_clk(REF_CLK),
.i_w_rstn(SYNC_REF_RST),  
.i_w_inc(UART_TX_VLD),
.i_w_data(UART_TX_IN),             
.i_r_clk(UART_TX_CLK),              
.i_r_rstn(SYNC_UART_RST),              
.i_r_inc(UART_TX_Busy_PULSE),              
.o_r_data(UART_TX_SYNC),             
.o_full(FIFO_FULL),               
.o_empty(UART_TX_V_SYNC)               
);

*/
///********************************************************///
//////////////////////// Pulse Generator /////////////////////
///********************************************************///

PULSE_GEN U0_PULSE_GEN (
.clk(UART_TX_CLK),
.rst(SYNC_UART_RST),
.lvl_sig(UART_TX_Busy),
.pulse_sig(UART_TX_Busy_PULSE)
);

///********************************************************///
//////////// Clock Divider for UART_TX Clock /////////////////
///********************************************************///

ClkDiv U0_ClkDiv_TX (
.i_ref_clk(UART_CLK),             
.i_rst(SYNC_UART_RST),                 
.i_clk_en(CLKDIV_EN),               
.i_div_ratio(DIV_RATIO),           
.o_div_clk(UART_TX_CLK)             
);

///********************************************************///
//////////// Custom Mux Clock /////////////////
///********************************************************///

CLKDIV_MUX U0_CLKDIV_MUX (
.IN(UART_Config[7:2]),
.OUT(DIV_RATIO_RX)
);

///********************************************************///
//////////// Clock Divider for UART_RX Clock /////////////////
///********************************************************///

ClkDiv U1_ClkDiv_RX (
.i_ref_clk(UART_CLK),             
.i_rst(SYNC_UART_RST),                 
.i_clk_en(CLKDIV_EN),               
.i_div_ratio(DIV_RATIO_RX),           
.o_div_clk(UART_RX_CLK)             
);

///********************************************************///
/////////////////////////// UART_TX /////////////////////////////
///********************************************************///
/*
UART  U0_UART (
.RST(SYNC_UART_RST),
.TX_CLK(UART_TX_CLK),
.RX_CLK(UART_RX_CLK),
.parity_enable(UART_Config[0]),
.parity_type(UART_Config[1]),
.Prescale(UART_Config[7:2]),
.RX_IN_S(UART_RX_IN),
.RX_OUT_P(UART_RX_OUT),                      
.RX_OUT_V(UART_RX_V_OUT),                      
.TX_IN_P(UART_TX_SYNC), 
.TX_IN_V(!UART_TX_V_SYNC), 
.TX_OUT_S(UART_TX_O),
.TX_OUT_V(UART_TX_Busy),
.parity_error(parity_error),
.framing_error(framing_error)                  
);
*/


UART_TX  U0_UART_TX (
.RST(SYNC_UART_RST),
.CLK(UART_TX_CLK),

.PAR_EN(UART_Config[0]),
.PAR_TYP(UART_Config[1]),  

.P_DATA(UART_TX_SYNC), 
.DATA_VALID(!UART_TX_V_SYNC), 
.TX_OUT(UART_TX_O),
.Busy(UART_TX_Busy)
                 
);


///********************************************************///
/////////////////////////// UART_RX /////////////////////////////
///********************************************************///

UART_RX  U0_UART_RX (
.RST(SYNC_UART_RST),
.CLK(UART_RX_CLK),
.PAR_EN(UART_Config[0]),
.PAR_TYP(UART_Config[1]),
.Prescale(UART_Config[7:2]),
.RX_IN(UART_RX_IN),
.P_DATA(UART_RX_OUT),                      
.data_valid(UART_RX_V_OUT),                      

.par_err(parity_error),
.stp_err(framing_error)                  
);


///********************************************************///
//////////////////// System Controller ///////////////////////
///********************************************************///
/*
SYS_CTRL U0_SYS_CTRL (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.RF_RdData(RF_RdData),
.RF_RdData_VLD(RF_RdData_VLD),
.RF_WrEn(RF_WrEn),
.RF_RdEn(RF_RdEn),
.RF_Address(RF_Address),
.RF_WrData(RF_WrData),
.ALU_EN(ALU_EN),
.ALU_FUN(ALU_FUN), 
.ALU_OUT(ALU_OUT),
.ALU_OUT_VLD(ALU_OUT_VLD),  
.CLKG_EN(CLKG_EN), 
.CLKDIV_EN(CLKDIV_EN),   
.FIFO_FULL(FIFO_FULL),
.UART_RX_DATA(UART_RX_SYNC), 
.UART_RX_VLD(UART_RX_V_SYNC),
.UART_TX_DATA(UART_TX_IN), 
.UART_TX_VLD(UART_TX_VLD)
);
*/

// badr
SYS_CTRL #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
U0_SYS_CTRL
	(
	  .RX_P_Data(UART_RX_SYNC),
	  .RX_D_VLD(UART_RX_V_SYNC),
	 
	  .WrData_FIFO(UART_TX_IN),
	  .WR_INC(UART_TX_VLD),
	  .FIFO_FULL(FIFO_FULL),

	  .ALU_OUT(ALU_OUT),
	  .OUT_Valid(ALU_OUT_VLD),
	  .ALU_EN(ALU_EN),
	  .ALU_FUN(ALU_FUN),

	  .RdData(RF_RdData),
	  .RdData_Valid(RF_RdData_VLD),
	  .WrData(RF_WrData),
	  .Address(RF_Address),
	  .RdEn(RF_RdEn),
	  .WrEn(RF_WrEn),

	  .clk_div_en(CLKDIV_EN),
	  .Gate_EN(CLKG_EN),

	  .CLK(REF_CLK),
	  .RST(SYNC_REF_RST) 
	  );

///********************************************************///
/////////////////////// Register File ////////////////////////
///********************************************************///

RegFile U0_RegFile (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.WrEn(RF_WrEn),
.RdEn(RF_RdEn),
.Address(RF_Address),
.WrData(RF_WrData),
.RdData(RF_RdData),
.RdData_VLD(RF_RdData_VLD),
.REG0(Operand_A),
.REG1(Operand_B),
.REG2(UART_Config),
.REG3(DIV_RATIO)
);

///********************************************************///
//////////////////////////// ALU /////////////////////////////
///********************************************************///
 
ALU U0_ALU (
.CLK(ALU_CLK),
.RST(SYNC_REF_RST),  
.A(Operand_A), 
.B(Operand_B),
.EN(ALU_EN),
.ALU_FUN(ALU_FUN),
.ALU_OUT(ALU_OUT),
.OUT_VALID(ALU_OUT_VLD)
);

///********************************************************///
///////////////////////// Clock Gating ///////////////////////
///********************************************************///

CLK_GATE U0_CLK_GATE (
.CLK_EN(CLKG_EN),
.CLK(REF_CLK),
.GATED_CLK(ALU_CLK)
);


endmodule
 