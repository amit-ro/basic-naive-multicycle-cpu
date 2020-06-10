module num_on_bits(num_in, num_of_ones);
	// I/O declerations
	input wire [7:0] num_in;
	output reg [3:0] num_of_ones;
	
	integer i;
	
	always @ (num_in)
	begin
		num_of_ones = 4'b0;
		for (i = 0; i < 8; i = i+1)
			num_of_ones = num_of_ones + num_in[i];
	end
endmodule
