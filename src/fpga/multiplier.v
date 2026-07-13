`include "constants.vh"
`include "rv32_opcodes.vh"
`include "alu_ops.vh"
`default_nettype none
module mux_4x1(                                 ///MD EXEC_MUL
	       input wire [1:0] 	    sel,        ///DATA_HC EXEC_MUL
	       input wire [2*`DATA_LEN-1:0] dat0,   ///DATA_HC EXEC_MUL
	       input wire [2*`DATA_LEN-1:0] dat1,   ///DATA_HC EXEC_MUL
	       input wire [2*`DATA_LEN-1:0] dat2,   ///DATA_HC EXEC_MUL
	       input wire [2*`DATA_LEN-1:0] dat3,   ///DATA_HC EXEC_MUL
	       output reg [2*`DATA_LEN-1:0] out     ///DATA_HC EXEC_MUL
	       );
   always @(*) begin   ///DATA_CL EXEC_MUL
      case(sel)        ///DATA_CL EXEC_MUL
	0: begin           ///DATA_CL EXEC_MUL
	   out = dat0;     ///DATA_DT EXEC_MUL
	end
	1: begin           ///DATA_CL EXEC_MUL
	   out = dat1;     ///DATA_DT EXEC_MUL
	end
	2: begin           ///DATA_CL EXEC_MUL
	   out = dat2;     ///DATA_DT EXEC_MUL
	end
	3: begin           ///DATA_CL EXEC_MUL
	   out = dat3;     ///DATA_DT EXEC_MUL
	end
      endcase
   end
endmodule // mux_4x1

// sel_lohi = md_req_out_sel[0]
module multiplier(   ///MD EXEC_MUL
		  input wire signed [`DATA_LEN-1:0] src1,  ///DATA_HC EXEC_MUL
		  input wire signed [`DATA_LEN-1:0] src2,  ///DATA_HC EXEC_MUL
		  input wire 			    src1_signed,   ///DATA_HC EXEC_MUL
		  input wire 			    src2_signed,   ///DATA_HC EXEC_MUL
		  input wire 			    sel_lohi,      ///DATA_HC EXEC_MUL
		  output wire [`DATA_LEN-1:0] 	    result ///DATA_HC EXEC_MUL
		  );

   wire signed [`DATA_LEN:0] 			    src1_unsign = {1'b0, src1};            ///DATA_CL EXEC_MUL
   wire signed [`DATA_LEN:0] 			    src2_unsign = {1'b0, src2};            ///DATA_CL EXEC_MUL

   wire signed [2*`DATA_LEN-1:0] 		    res_ss = src1 * src2;          ///DATA_CL EXEC_MUL
   wire signed [2*`DATA_LEN-1:0] 		    res_su = src1 * src2_unsign;   ///DATA_CL EXEC_MUL
   wire signed [2*`DATA_LEN-1:0] 		    res_us = src1_unsign * src2;   ///DATA_CL EXEC_MUL
   wire signed [2*`DATA_LEN-1:0] 		    res_uu = src1_unsign * src2_unsign;   ///DATA_CL EXEC_MUL

   wire [2*`DATA_LEN-1:0] 			        res;   ///DATA_HWD EXEC_MUL

   mux_4x1 mxres(                            ///MD EXEC_MUL
		 .sel({src1_signed, src2_signed}),   ///DATA_HC+DATA_CL EXEC_MUL
		 .dat0(res_uu),                      ///DATA_HC EXEC_MUL
		 .dat1(res_us),                      ///DATA_HC EXEC_MUL
		 .dat2(res_su),                      ///DATA_HC EXEC_MUL
		 .dat3(res_ss),                      ///DATA_HC EXEC_MUL
		 .out(res)                           ///DATA_HC EXEC_MUL
		 );
   
   assign result = sel_lohi ? res[`DATA_LEN+:`DATA_LEN] : res[`DATA_LEN-1:0];   ///DATA_CL EXEC_MUL
   
endmodule // multiplier


`default_nettype wire
