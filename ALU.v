module ALU(instruction, input_a, input_b, result);
	// I/O declerations
	input wire [8:0] input_a, input_b;
	input wire [2:0] instruction;
	output reg [8:0] result;
	
	// inner variables
	wire [7:0] temp_a, temp_b;
	wire sign_a, sign_b;
	wire [3:0] num_of_ones;
	assign temp_a = input_a[7:0];
	assign temp_b = input_b[7:0];
	assign sign_a = input_a[8];
	assign sign_b = input_b[8];
	num_on_bits ones (.num_in(temp_b), .num_of_ones(num_of_ones));
	parameter ADD = 3'b010, SUB = 3'b011, SLL = 3'b111, SRL = 3'b110, POS = 1'b0, NEG = 1'b1;
	
	// ALU logic - this ALU supports addition, subtruction, shift left and shfit right.
	always @ (instruction)
	begin
		case(instruction)
			ADD:
			begin
				if((sign_a == POS) && (sign_b == POS))
				begin
					result = temp_a + temp_b;
					result[8] = sign_a;
				end
				else if((sign_a == POS) && (sign_b == NEG))
				begin
					if(temp_a >= temp_b)
					begin
						result = temp_a - temp_b;
						result[8] = sign_a;
					end
					else
					begin
						result = temp_b - temp_a;
						result[8] = sign_b;
					end
				end
				else if((sign_a == NEG) && (sign_b == POS))
				begin
					if(temp_a >= temp_b)
					begin
						result = temp_a - temp_b;
						result[8] = sign_b;
					end
					else
					begin
						result = temp_b - temp_a;
						result[8] = sign_a;
					end
				end
				else
				begin
					result = temp_a + temp_b;
					result[8] = sign_a;
				end
			end
			SUB:
			begin
				if((sign_a == POS) && (sign_b == POS))
				begin
					if(temp_a >= temp_b)
					begin
						result = temp_a - temp_b;
						result[8] = sign_a;
					end
					else
					begin
						result = temp_b - temp_a;
						result[8] = ~sign_a;
					end
				end
				else if((sign_a == POS) && (sign_b == NEG))
				begin
					result = temp_a + temp_b;
					result[8] = sign_a;
				end
				else if((sign_a == NEG) && (sign_b == POS))
				begin
					result = temp_b - temp_a;
					result[8] = sign_a;
				end
				else
				begin
					if(temp_a >= temp_b)
					begin
						result = temp_a - temp_b;
						result[8] = sign_b;
					end
					else
					begin
						result = temp_b - temp_a;
						result[8] = ~sign_a;
					end
				end
			end
			SLL:
			begin
				result[7:0] = temp_a << num_of_ones;
				result[8] = sign_a;
			end
			SRL:
			begin
				result[7:0] = temp_a >> (num_of_ones); // opereration needs to be normalized 
				result[8] = sign_a;
			end
		endcase
	end
endmodule
