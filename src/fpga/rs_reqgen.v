`include "constants.vh"
`default_nettype none
module rs_requestgenerator   ///MD DISPATCH
  (
   input wire [`RS_ENT_SEL-1:0] rsent_1,   ///DATA_HC DISPATCH
   input wire [`RS_ENT_SEL-1:0] rsent_2,   ///DATA_HC DISPATCH
   output wire 			req1_alu,          ///CTRL_HC DISPATCH
   output wire 			req2_alu,          ///CTRL_HC DISPATCH
   output wire [1:0] 		req_alunum,    ///CTRL_HC DISPATCH
   output wire 			req1_branch,       ///CTRL_HC DISPATCH
   output wire 			req2_branch,       ///CTRL_HC DISPATCH
   output wire [1:0] 		req_branchnum, ///CTRL_HC DISPATCH
   output wire 			req1_mul,          ///CTRL_HC DISPATCH
   output wire 			req2_mul,          ///CTRL_HC DISPATCH
   output wire [1:0] 		req_mulnum,    ///CTRL_HC DISPATCH
   output wire 			req1_ldst,         ///CTRL_HC DISPATCH
   output wire 			req2_ldst,         ///CTRL_HC DISPATCH
   output wire [1:0] 		req_ldstnum    ///CTRL_HC DISPATCH
   );

   assign req1_alu = (rsent_1 == `RS_ENT_ALU) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req2_alu = (rsent_2 == `RS_ENT_ALU) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req_alunum = {1'b0, req1_alu} + {1'b0, req2_alu};    ///CTRL_CL DISPATCH

   assign req1_branch = (rsent_1 == `RS_ENT_BRANCH) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req2_branch = (rsent_2 == `RS_ENT_BRANCH) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req_branchnum = {1'b0, req1_branch} + {1'b0, req2_branch}; ///CTRL_CL DISPATCH

   assign req1_mul = (rsent_1 == `RS_ENT_MUL) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req2_mul = (rsent_2 == `RS_ENT_MUL) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req_mulnum = {1'b0, req1_mul} + {1'b0, req2_mul};    ///CTRL_CL DISPATCH

   assign req1_ldst = (rsent_1 == `RS_ENT_LDST) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req2_ldst = (rsent_2 == `RS_ENT_LDST) ? 1'b1 : 1'b0;   ///CTRL_CL DISPATCH
   assign req_ldstnum = {1'b0, req1_ldst} + {1'b0, req2_ldst};   ///CTRL_CL DISPATCH
   
endmodule // rs_requestgenerator
`default_nettype wire
