`include "constants.vh"
`default_nettype none
module sourceoperand_manager   ///MD DISPATCH
  (
   input wire [`DATA_LEN-1:0]  arfdata,   ///DATA_HC DISPATCH
   input wire 		       arf_busy,   ///CTRL_HC DISPATCH
   input wire 		       rrf_valid,   ///CTRL_HC DISPATCH
   input wire [`RRF_SEL-1:0]   rrftag,   ///CTRL_HC DISPATCH
   input wire [`DATA_LEN-1:0]  rrfdata,   ///DATA_HC DISPATCH
   input wire [`RRF_SEL-1:0]   dst1_renamed,   ///CTRL_HC DISPATCH
   input wire 		       src_eq_dst1,   ///CTRL_HC DISPATCH
   input wire 		       src_eq_0,   ///CTRL_HC DISPATCH
   output wire [`DATA_LEN-1:0] src,   ///DATA_HC DISPATCH
   output wire 		       rdy   ///CTRL_HC DISPATCH
   );

   assign src = src_eq_0 ? `DATA_LEN'b0 :   ///DATA_CL DISPATCH
		src_eq_dst1 ? {{(`DATA_LEN-`RRF_SEL){1'b0}}, dst1_renamed} :   ///DATA_CL DISPATCH
		~arf_busy ? arfdata :   ///DATA_CL DISPATCH
		rrf_valid ? rrfdata :   ///DATA_CL DISPATCH
		{{(`DATA_LEN-`RRF_SEL){1'b0}}, rrftag};   ///DATA_CL DISPATCH
   assign rdy = src_eq_0 | (~src_eq_dst1 & (~arf_busy | rrf_valid));   ///CTRL_CL DISPATCH


  //  assign src = src_eq_0 ? `DATA_LEN'b0 :
	// 	src_eq_dst1 ? dst1_renamed :
	// 	~arf_busy ? arfdata :
	// 	rrf_valid ? rrfdata :
	// 	rrftag;

endmodule // sourceoperand_manager
`default_nettype wire
