module SYS_CTRL #(parameter DATA_WIDTH = 8 , ADDR_WIDTH = 4)(

	// inputs from RX (Data synchronizer)
	input wire [DATA_WIDTH-1:0] RX_P_Data ,
	input wire 	 	 	 	 	RX_D_VLD , // 

	// input from FIFO
	input wire 	 	  		 	FIFO_FULL,

	// inputs from ALU
	input wire [15:0]   	 	ALU_OUT ,
	input wire         	 	 	OUT_Valid ,
	
	// inputs from REG FILE
	input wire [DATA_WIDTH-1:0] RdData ,
	input wire  	 		 	RdData_Valid ,

	// general inputs
	input wire  	 	 	 	CLK ,
	input wire  	 	 	 	RST ,
	




	// fifo 
	output reg 	  	 	 	 	WR_INC ,
	output reg [DATA_WIDTH-1:0] WrData_FIFO ,  // 8

	// ALU
	output reg  	 	 	  	ALU_EN ,
	output reg [ADDR_WIDTH-1:0]	ALU_FUN ,  // 4 bits 

	// REG FILE
	output reg [ADDR_WIDTH-1:0] Address ,  // 4 bits 
	output reg 	 	 	 	 	WrEn ,
	output reg  	 	 		RdEn ,
	output reg [DATA_WIDTH-1:0] WrData , // 8

	// clk gating
	output reg  		 	 	Gate_EN ,
	output reg  		 	 	clk_div_en 
	
		//output reg  	 	 	 	CLK_CN ,

	);

localparam IDLE 	  = 9'b0_0000_0000 ;
localparam WR_ADDR_RF = 9'b0_0000_0001 ;
localparam WR_DATA_RF = 9'b0_0000_0010 ;

localparam RD_RF_ADDR    	 = 9'b0_0000_0100 ;
localparam RD_RF_AND_WR_FIFO = 9'b0_0000_1000 ;
localparam WR_OP_A   	 	 = 9'b0_0001_0000 ;
localparam WR_OP_B    	  	 = 9'b0_0010_0000 ;

localparam ALU_INPUT 	 	 	  = 9'b0_0100_0000 ;
localparam ALU_OUTPUT_AND_WR_FIFO_1 = 9'b0_1000_0000 ;
localparam ALU_OUTPUT_AND_WR_FIFO_2 = 9'b1_0000_0000 ;

reg [8:0] ns , cs ;

	// state memory 
	always @(posedge CLK or negedge RST) begin

		if (~RST)
			cs <= IDLE ;

		else 
			cs <= ns ;
	end

	// ns logic 	
	reg [ADDR_WIDTH-1:0] tmp_addres ; // 4 bits
	//reg [15:0] 	 	 	 my_out ;

always@ (*) begin
	// ALU
	ALU_EN      = 1'b0 ;
	ALU_FUN 	= 4'b0000 ; 

 	// REG FILE
 	Address	 	= 4'b0000 ; 
	WrEn	    = 1'b0 ;
	RdEn 	 	= 1'b0 ;
	WrData  	= 0 ;

	// FIFO
	WrData_FIFO = 8'b0000_0000 ;
	WR_INC  	= 1'b0 ;

	// CLK GATING 
	Gate_EN     = 1'b1 ;
	clk_div_en 	= 1'b1 ;

	//CLK_CN  	= 1'b0 ;

	case (cs) 
	IDLE : begin
		case ({RX_D_VLD,RX_P_Data})
		9'b1_1010_1010 : begin	 	 	// command AA
			Gate_EN     = 1'b0 ;
			ns = WR_ADDR_RF ;
			//WrEn = 1 ;
		end
		9'b1_1011_1011 : begin	 	 	// command BB
			Gate_EN     = 1'b0 ;
			ns = RD_RF_ADDR ;
			RdEn = 1 ;
		end
		9'b1_1100_1100 : begin	 	 	// command CC
			ns = WR_OP_A ;
			//WrEn = 1 ;
		end
		9'b1_1101_1101 : begin	 	 	// command DD
			ns = ALU_INPUT ;
			//WrEn = 1 ;
		end  
		default : ns = IDLE ;
	endcase 

		Gate_EN     = 1'b0 ;
	end


	WR_ADDR_RF : begin
		if(RX_D_VLD) begin // waiting next frame to capture the address
			WrEn 	   = 1'b1 ;
			tmp_addres = RX_P_Data ;

			ns         = WR_DATA_RF ;
		end
		else ns = cs ;

		Gate_EN     = 1'b0 ;
	end

	WR_DATA_RF : begin
		if(RX_D_VLD) begin
			WrEn    = 1'b1 ;
			Address = tmp_addres ;
		    WrData  = RX_P_Data ;  // directly with no tmp 

			ns      = IDLE ;
		end
		else ns = cs ;

		Gate_EN     = 1'b0 ;
	end 

	RD_RF_ADDR : begin
		if(RX_D_VLD) begin
			RdEn  	= 1'b1 ;
			Address = RX_P_Data ;

			ns      = RD_RF_AND_WR_FIFO ;
		end
		else ns = cs ;

		Gate_EN     = 1'b0 ;
	end 

	RD_RF_AND_WR_FIFO : begin  // i want to read from the rf and wr it in the fifo in the same clk cycle
			RdEn  	= 1'b1 ;
			if(!FIFO_FULL) begin
				WR_INC  	 = 1'b1 ;
				WrData_FIFO  = RdData ;

				ns       	 = IDLE ;
			end

			else ns  = cs ;

			Gate_EN     = 1'b0 ;
	end 
/*
	OUT_FIFO : begin 
			if(!FIFO_FULL) begin
				WrData_FIFO  = my_out ;
				WR_INC  	 = 1'b1 ;

				ns       	 = IDLE ;
			end
		else ns = cs ;
	end  
*/
	WR_OP_A : begin
		if(RX_D_VLD) begin
			WrEn    = 1'b1 ;
			Address = 4'b0000 ;  // REG0
		    WrData  = RX_P_Data ;

			ns      = WR_OP_B ;
		end
		else ns = cs ;
	end 

	WR_OP_B : begin
		if(RX_D_VLD) begin
			WrEn    = 1'b1 ;
			Address = 4'b0001 ;  // REG1
		    WrData  = RX_P_Data ;

			ns      = ALU_INPUT ;
		end
		else begin 
			ns = cs ;
		end
	end

	ALU_INPUT : begin
		if(RX_D_VLD) begin
			ALU_EN  = 1 ;
			ALU_FUN = RX_P_Data ;

			ns      = ALU_OUTPUT_AND_WR_FIFO_1 ;
		end
		else ns = cs ;
	end

	ALU_OUTPUT_AND_WR_FIFO_1 : begin 	  	 	// LSB
			ALU_EN  = 1 ;
			ALU_FUN = RX_P_Data ;

			if(!FIFO_FULL && OUT_Valid) begin
				WR_INC  	 = 1'b1 ;
				WrData_FIFO  = ALU_OUT[7:0] ;

				ns       	 = ALU_OUTPUT_AND_WR_FIFO_2 ;
			end
			else ns = cs ;

	end

	ALU_OUTPUT_AND_WR_FIFO_2 : begin 		  // MSB
			ALU_EN  = 1 ;
			ALU_FUN = RX_P_Data ;

			if(!FIFO_FULL && OUT_Valid) begin
				WR_INC  	 = 1'b1 ;
				WrData_FIFO  = ALU_OUT[15:8] ;

				ns       	 = IDLE ;
			end
			else ns = cs ;

	end

	default : ns = IDLE ;
endcase 

end
endmodule 

