module mux_10_to_1(DIN, R0, R1, R2, R3, R4, R5, R6, R7, G, sel, bus_out);
	
	input wire [8:0] DIN, R0, R1, R2, R3, R4, R5, R6, R7, G;
	input wire [9:0] sel;
	output wire [8:0] bus_out;
	
	parameter DIN_code = 10'b000000001, G_code = 10'b0000000010, R0_code = 10'b0000000100,
			  R1_code = 10'b0000001000, R2_code = 10'b0000010000, R3_code = 10'b0000100000,
			  R4_code = 10'b0001000000, R5_code = 10'b0010000000, R6_code = 10'b0100000000,
			  R7_code = 10'b1000000000;
			  
			  
	//assign bus_out =  DIN;
	assign bus_out = (sel == DIN_code) ? DIN:
					 (sel == R0_code) ? R0:
					 (sel == R1_code) ? R1:
					 (sel == R2_code) ? R2:
					 (sel == R3_code) ? R3:
					 (sel == R4_code) ? R4:
					 (sel == R5_code) ? R5:
					 (sel == R6_code) ? R6:
					 (sel == R7_code) ? R7:
					 (sel == G_code) ? G:
					 DIN; // default value
endmodule
