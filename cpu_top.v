module cpu_top (DIN, Resetn, Clock, Run, Done, BusWires, debug_reg0, debug_reg1, step_debug, debug_IR, sel_debug, dec_debug,
DIN_out_debug, Rin_debug, debug_ALU, debug_reg2, debug_reg3, debug_reg4, debug_reg5, debug_reg6, debug_reg7, mux_debug); 
	input wire [8:0] DIN;
	input wire Resetn, Clock, Run;
	output reg Done;
	output wire[8:0] BusWires;
	
	// inner variables
	reg reset_all;
	
	// debug
	output wire [8:0] debug_reg0, debug_reg1, debug_IR, debug_ALU;
	output wire [8:0] debug_reg2, debug_reg3, debug_reg4, debug_reg5, debug_reg6, debug_reg7;
	output wire [1:0] step_debug;
	output wire [9:0] sel_debug;
	output wire [7:0] dec_debug;
	output wire DIN_out_debug;
	output wire [7:0] Rin_debug;
	output wire [9:0] mux_debug;

	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11, // clock cycle parameters
			  mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011, // OP codes
			  sll = 3'b111, srl = 3'b110; // OP codes
	
	reg [1:0] Tstep_Q, Nstep_Q; // TstepQ is the current state and NstepQ is the next state
	wire [2:0] I;
	wire [7:0] Xreg, Yreg;
	reg [7:0] Rin;
	wire [8:0] R0, R1, R2, R3, R4, R5, R6, R7, IR, G, A;
	reg [7:0] Rout;
	reg DIN_out, Gout, IRin, Ain, Gin;
	wire [9:0] mux_10_1_sel;
	wire [8:0] ALU_out;
	assign mux_10_1_sel = {Rout, Gout, DIN_out};
	
	// assign instruction from input
	assign I = IR[8:6];
	
	//////////////////////////
	// instaces decleration //
	//////////////////////////
	
	// assign X and Y registers
	dec3to8 decX (IR[5:3], 1'b1, Xreg); 
	dec3to8 decY (IR[2:0], 1'b1, Yreg);
	// register declerations
	regn reg_0 (.R(BusWires), .Rin(Rin[0]), .Clock(Clock), .Q(R0));
	regn reg_1 (BusWires, Rin[1], Clock, R1);
	regn reg_2 (BusWires, Rin[2], Clock, R2);
	regn reg_3 (BusWires, Rin[3], Clock, R3);
	regn reg_4 (BusWires, Rin[4], Clock, R4);
	regn reg_5 (BusWires, Rin[5], Clock, R5);
	regn reg_6 (BusWires, Rin[6], Clock, R6);
	regn reg_7 (BusWires, Rin[7], Clock, R7);
	regn Ireg (.R(DIN), .Rin(IRin), .Clock(Clock), .Q(IR));
	regn Greg (.R(ALU_out), .Rin (Gin), .Clock(Clock), .Q(G));
	regn Areg (.R(BusWires), .Rin (Ain), .Clock(Clock), .Q(A));
	mux_10_to_1 multiplexer (.DIN(DIN), .R0(R0), .R1(R1), .R2(R2), .R3(R3),
							 .R4(R4), .R5(R5), .R6(R6), .R7(R7), .G(G), .sel(mux_10_1_sel),
							 .bus_out(BusWires));
	ALU add_sub (.instruction(I), .input_a(A), .input_b(BusWires), .result(ALU_out));
	always @(Tstep_Q, Run, Done) 
	begin
		case (Tstep_Q)
		T0:
		begin
			if(~Run)
				Nstep_Q <= T0;
			else
				Nstep_Q <= T1;
		end
		T1:
		begin
			if(Done)
				Nstep_Q <= T0;
			else
				Nstep_Q <= T2;
		end
		T2:
		begin
			if(Done)
				Nstep_Q <= T0;
			else
				Nstep_Q <= T3;
		end
		T3:
		begin
			Nstep_Q <= T0;
		end
		endcase
	end

	always @(Tstep_Q or I or Xreg or Yreg or reset_all) 
	begin
	//... specify initial values 
		Rout <= 8'b0;
		DIN_out <= 1'b0;
		Gout <= 1'b0;
		Rin <= 8'b0;
		Ain <= 1'b0;
		IRin <= 1'b0;// check location
		Gin <= 1'b0;
		Done <= 1'b0;
		case (Tstep_Q) 
			T0: 
			begin  // store DIN in IR in time step 0 begin
				IRin <= 1'b1;
				if (reset_all)
					Rin <= 8'b11111111;
			end
			T1: //define signals in time step 1 case (I) ... endcase
			begin
				case (I)
					mv:
					begin
						Rin <= Xreg;
						Rout <= Yreg;
						Done <= 1'b1;
					end
					mvi:
					begin
						Rin <= Xreg;
						DIN_out <= 1'b1;
						Done <= 1'b1;
					end
					add:
					begin
						Rout <= Xreg;
						Ain <= 1'b1;
					end
					sub:
					begin
						Rout <= Xreg;
						Ain <= 1'b1;
					end
					sll:
					begin
						Rout <= Xreg;
						Ain <= 1'b1;
					end
					srl:
					begin
						Rout <= Xreg;
						Ain <= 1'b1;
					end
				endcase
			end
			T2:
			begin
				case(I)
					add:
					begin
						Rout <= Yreg;
						Gin <= 1'b1;
					end
					sub:
					begin
						Rout <= Yreg;
						Gin <= 1'b1;
					end
					sll:
					begin
						Rout <= Yreg;
						Gin <= 1'b1;
					end
					srl:
					begin
						Rout <= Yreg;
						Gin <= 1'b1;
					end
				endcase
			end
			T3:
			begin
				case(I)
					add:
					begin
						Gout <= 1'b1;
						Rin <= Xreg;
						Done <= 1'b1;
					end
					sub:
					begin
						Gout <= 1'b1;
						Rin <= Xreg;
						Done <= 1'b1;
					end
					sll:
					begin
						Gout <= 1'b1;
						Rin <= Xreg;
						Done <= 1'b1;
					end
					srl:
					begin
						Gout <= 1'b1;
						Rin <= Xreg;
						Done <= 1'b1;
					end
				endcase
			end
		endcase
	end

// Control FSM flip-flops 
	always @(posedge Clock, negedge Resetn) 
	begin
		if (!Resetn)
		begin
			Tstep_Q <= T0;
			reset_all <= 1'b1;
		end
		else
		begin
			Tstep_Q <= Nstep_Q;
			reset_all <= 1'b0;
		end
	end
	
	// debug
	assign debug_reg0 = R0;
	assign debug_reg1 = R1;
	assign debug_reg2 = R2;
	assign debug_reg3 = R3;
	assign debug_reg4 = R4;
	assign debug_reg5 = R5;
	assign debug_reg6 = R6;
	assign debug_reg7 = R7;
	assign step_debug = Tstep_Q;
	assign debug_IR = IR;
	assign sel_debug = mux_10_1_sel;
	assign dec_debug = Rout;
	assign DIN_out_debug = DIN_out; 
	assign Rin_debug = Rin;
	assign debug_ALU = ALU_out;
endmodule
