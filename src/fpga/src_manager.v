`include "constants.vh"
`default_nettype none
module src_manager   ///MD RSV_SHARED
  (
   input wire [`DATA_LEN-1:0]  opr,   ///DATA_HC RSV_SHARED
   input wire 		       opr_rdy,   ///CTRL_HC RSV_SHARED
   input wire [`DATA_LEN-1:0]  exrslt1,   ///DATA_HC RSV_SHARED
   input wire [`RRF_SEL-1:0]   exdst1,   ///CTRL_HC RSV_SHARED
   input wire 		       kill_spec1,   ///CTRL_HC RSV_SHARED
   input wire [`DATA_LEN-1:0]  exrslt2,   ///DATA_HC RSV_SHARED
   input wire [`RRF_SEL-1:0]   exdst2,   ///CTRL_HC RSV_SHARED
   input wire 		       kill_spec2,   ///CTRL_HC RSV_SHARED
   input wire [`DATA_LEN-1:0]  exrslt3,   ///DATA_HC RSV_SHARED
   input wire [`RRF_SEL-1:0]   exdst3,   ///CTRL_HC RSV_SHARED
   input wire 		       kill_spec3,   ///CTRL_HC RSV_SHARED
   input wire [`DATA_LEN-1:0]  exrslt4,   ///DATA_HC RSV_SHARED
   input wire [`RRF_SEL-1:0]   exdst4,   ///CTRL_HC RSV_SHARED
   input wire 		       kill_spec4,   ///CTRL_HC RSV_SHARED
   input wire [`DATA_LEN-1:0]  exrslt5,   ///DATA_HC RSV_SHARED
   input wire [`RRF_SEL-1:0]   exdst5,   ///CTRL_HC RSV_SHARED
   input wire 		       kill_spec5,   ///CTRL_HC RSV_SHARED
   output wire [`DATA_LEN-1:0] src,   ///DATA_HC RSV_SHARED
   output wire 		       resolved   ///CTRL_HC RSV_SHARED
   );

   assign src = opr_rdy ? opr :   ///DATA_CL RSV_SHARED
		~kill_spec1 & (exdst1 == opr[`RRF_SEL-1:0]) ? exrslt1 :   ///DATA_CL RSV_SHARED
		~kill_spec2 & (exdst2 == opr[`RRF_SEL-1:0]) ? exrslt2 :   ///DATA_CL RSV_SHARED
		~kill_spec3 & (exdst3 == opr[`RRF_SEL-1:0]) ? exrslt3 :   ///DATA_CL RSV_SHARED
		~kill_spec4 & (exdst4 == opr[`RRF_SEL-1:0]) ? exrslt4 :   ///DATA_CL RSV_SHARED
		~kill_spec5 & (exdst5 == opr[`RRF_SEL-1:0]) ? exrslt5 : opr;   ///DATA_CL RSV_SHARED

   assign resolved = opr_rdy |   ///CTRL_CL RSV_SHARED
		     (~kill_spec1 & (exdst1 == opr[`RRF_SEL-1:0])) |   ///CTRL_CL RSV_SHARED
		     (~kill_spec2 & (exdst2 == opr[`RRF_SEL-1:0])) |   ///CTRL_CL RSV_SHARED
		     (~kill_spec3 & (exdst3 == opr[`RRF_SEL-1:0])) |   ///CTRL_CL RSV_SHARED
		     (~kill_spec4 & (exdst4 == opr[`RRF_SEL-1:0])) |   ///CTRL_CL RSV_SHARED
		     (~kill_spec5 & (exdst5 == opr[`RRF_SEL-1:0]));   ///CTRL_CL RSV_SHARED

  //    assign src = opr_rdy ? opr :
	// 	~kill_spec1 & (exdst1 == opr) ? exrslt1 :
	// 	~kill_spec2 & (exdst2 == opr) ? exrslt2 :
	// 	~kill_spec3 & (exdst3 == opr) ? exrslt3 :
	// 	~kill_spec4 & (exdst4 == opr) ? exrslt4 :
	// 	~kill_spec5 & (exdst5 == opr) ? exrslt5 : opr;

  //  assign resolved = opr_rdy |
	// 	     (~kill_spec1 & (exdst1 == opr)) |
	// 	     (~kill_spec2 & (exdst2 == opr)) |
	// 	     (~kill_spec3 & (exdst3 == opr)) |
	// 	     (~kill_spec4 & (exdst4 == opr)) |
	// 	     (~kill_spec5 & (exdst5 == opr));
   
endmodule // src_manager


`default_nettype wire
