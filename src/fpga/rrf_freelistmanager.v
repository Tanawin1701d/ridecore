`include "constants.vh"
`default_nettype none
module rrf_freelistmanager   ///MD RRF
  (
   input wire 		      clk,                                  ///CTRL_HC RRF
   input wire 		      reset,                                ///CTRL_HC RRF
   input wire 		      invalid1,                             ///CTRL_HC RRF
   input wire 		      invalid2,                             ///CTRL_HC RRF
   input wire [1:0] 	      comnum,                           ///CTRL_HC RRF
   input wire 		      prmiss,                               ///CTRL_HC RRF
   input wire [`RRF_SEL-1:0]  rrftagfix,                        ///CTRL_HC RRF
   output wire [`RRF_SEL-1:0] rename_dst1,                      ///CTRL_HC RRF
   output wire [`RRF_SEL-1:0] rename_dst2,                      ///CTRL_HC RRF
   output wire 		      allocatable,                          ///CTRL_HC RRF
   input wire 		      stall_DP, //= ~allocatable && ~prmiss ///CTRL_HC RRF
   output reg [`RRF_SEL:0]    freenum /* verilator public */,   ///CTRL_HC RRF
   output reg [`RRF_SEL-1:0]  rrfptr /* verilator public */,    ///CTRL_HC RRF
   input wire [`RRF_SEL-1:0]  comptr,                           ///CTRL_HC RRF
   output reg 		      nextrrfcyc /* verilator public */     ///CTRL_HC RRF
   );
   
   wire [1:0] 		      reqnum = {1'b0, ~invalid1} + {1'b0, ~invalid2};              ///CTRL_CL RRF
   wire 		      hi = (comptr > rrftagfix) ? 1'b1 : 1'b0;                         ///CTRL_CL RRF
   wire [`RRF_SEL-1:0] 	      rrfptr_next = rrfptr + {{(`RRF_SEL-2){1'b0}}, reqnum};   ///CTRL_CL RRF
   
   assign allocatable = (freenum + {{(`RRF_SEL+1-2){1'b0}}, comnum}) <     ///// -2 is comnum   ///CTRL_CL RRF
                        ({{(`RRF_SEL+1-2){1'b0}}, reqnum}) ? 1'b0 : 1'b1;                       ///CTRL_CL RRF

   //  wire [`RRF_SEL-1:0] 	      rrfptr_next = rrfptr + reqnum;
   // assign allocatable = (freenum + comnum) < reqnum ? 1'b0 : 1'b1;
   assign rename_dst1 = rrfptr;                         ///CTRL_DT RRF
   assign rename_dst2 = rrfptr + (~invalid1 ? 1 : 0);   ///CTRL_CL RRF
   
   always @ (posedge clk) begin                                    ///CTRL_CL RRF
      if (reset) begin                                             ///CTRL_CL RRF
	 freenum <= `RRF_NUM;                                          ///CTRL_DT RRF
	 rrfptr <= 0;                                                  ///CTRL_DT RRF
	 nextrrfcyc <= 0;                                              ///CTRL_DT RRF
      end else if (prmiss) begin                                   ///CTRL_CL RRF
	 rrfptr <= rrftagfix; //== prmiss_rrftag+1                     ///CTRL_DT RRF
	 freenum <= `RRF_NUM - ({hi, rrftagfix} - {1'b0, comptr});     ///CTRL_CL RRF
	 nextrrfcyc <= 0;                                              ///CTRL_DT RRF
      end else if (stall_DP) begin                                 ///CTRL_CL RRF
	 rrfptr <= rrfptr;                                             ///CTRL_DT RRF
	 freenum <= freenum + {{(`RRF_SEL+1-2){1'b0}}, comnum};        ///CTRL_CL RRF
    /// freenum <= freenum + {{(`RRF_SEL+1-$bits(comnum)){1'b0}}, comnum};
	 nextrrfcyc <= 0;                                              ///CTRL_DT RRF
      end else begin
	 rrfptr <= rrfptr_next;                                                                        ///CTRL_DT RRF
	 freenum <= freenum + {{(`RRF_SEL+1-2){1'b0}}, comnum} - ({{(`RRF_SEL+1-2){1'b0}}, reqnum});   ///CTRL_CL RRF
    //// freenum <= freenum + {{(`RRF_SEL+1-$bits(comnum)){1'b0}}, comnum} - ({{(`RRF_SEL+1-$bits(reqnum)){1'b0}}, reqnum});
	 nextrrfcyc <= (rrfptr > rrfptr_next) ? 1'b1 : 1'b0;                                           ///CTRL_CL RRF
      end
   end
endmodule // rrf_freelistmanager


`default_nettype wire
