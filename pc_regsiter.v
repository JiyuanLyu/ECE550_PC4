module pc_regsiter (clock, reset, en, pc_in, pc_out);

	input clock, reset, en;
	input [31:0] pc_in;
	output [31:0] pc_out;
	
	genvar i;
   generate
      for (i = 0; i < 32; i = i + 1) begin: pc_loop
			dffe_ref dffe_pc(pc_out[i], pc_in[i], clock, en, reset);
      end
   endgenerate
	
endmodule
