`include "constants.vh"
`default_nettype none
module tag_generator(   ///MD TAG
		     input wire 		    clk,                                   ///CTRL_HC TAG
		     input wire 		    reset,                                 ///CTRL_HC TAG
		     input wire 		    branchvalid1,                          ///CTRL_HC TAG
		     input wire 		    branchvalid2,                          ///CTRL_HC TAG
		     input wire 		    prmiss,                                ///CTRL_HC TAG
		     input wire 		    prsuccess,                             ///CTRL_HC TAG
		     input wire 		    enable,                                ///CTRL_HC TAG
		     input wire [`SPECTAG_LEN-1:0]  tagregfix,                     ///CTRL_HC TAG
		     output wire [`SPECTAG_LEN-1:0] sptag1,                        ///CTRL_HC TAG
		     output wire [`SPECTAG_LEN-1:0] sptag2,                        ///CTRL_HC TAG
		     output wire 		    speculative1,                          ///CTRL_HC TAG
		     output wire 		    speculative2,                          ///CTRL_HC TAG
		     output wire 		    attachable,                            ///CTRL_HC TAG
		     output reg [`SPECTAG_LEN-1:0]  tagreg /* verilator public */  ///CTRL_HC TAG
		     );

//   reg [`SPECTAG_LEN-1:0] 		       tagreg;
   reg [`BRDEPTH_LEN-1:0] 		       brdepth /* verilator public */;   ///CTRL_HWD TAG
   
   assign sptag1 = (branchvalid1) ?                                        ///CTRL_CL TAG
		   {tagreg[`SPECTAG_LEN-2:0], tagreg[`SPECTAG_LEN-1]}              ///CTRL_CL TAG
		   : tagreg;                                                       ///CTRL_CL TAG
   assign sptag2 = (branchvalid2) ?                                        ///CTRL_CL TAG
		   {sptag1[`SPECTAG_LEN-2:0], sptag1[`SPECTAG_LEN-1]}              ///CTRL_CL TAG
		   : sptag1;                                                       ///CTRL_CL TAG
   assign speculative1 = (brdepth != 0) ? 1'b1 : 1'b0;                     ///CTRL_CL TAG
   assign speculative2 = ((brdepth != 0) || branchvalid1) ? 1'b1 : 1'b0;   ///CTRL_CL TAG
//    assign attachable = (brdepth + branchvalid1 + branchvalid2) 
//      > (`BRANCH_ENT_NUM + prsuccess) ? 1'b0 : 1'b1;

	 assign attachable =   ///CTRL_CL TAG
    (brdepth   ///CTRL_CL TAG
     + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid1}   ///CTRL_CL TAG
     + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid2}   ///CTRL_CL TAG
    ) > (`BRANCH_ENT_NUM +                        ///CTRL_CL TAG
		{{(`BRDEPTH_LEN-1){1'b0}}, prsuccess}     ///CTRL_CL TAG
		)
      ? 1'b0 : 1'b1;                              ///CTRL_CL TAG


   always @ (posedge clk) begin    ///CTRL_CL TAG
      if (reset) begin             ///CTRL_CL TAG
	 tagreg <= `SPECTAG_LEN'b1;    ///CTRL_DT TAG
	 brdepth <= `BRDEPTH_LEN'b0;   ///CTRL_DT TAG
      end else begin
	 tagreg <= prmiss ? tagregfix :   ///CTRL_CL TAG
		   ~enable ? tagreg :         ///CTRL_CL TAG
		   sptag2;                    ///CTRL_CL TAG
	 brdepth <= prmiss ? `BRDEPTH_LEN'b0 :   ///CTRL_CL TAG
		    ~enable ? brdepth - {{(`BRDEPTH_LEN-1){1'b0}}, prsuccess} :    ///CTRL_CL TAG
		    brdepth + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid1} + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid2} - {{(`BRDEPTH_LEN-1){1'b0}}, prsuccess};   ///CTRL_CL TAG
      end
   end
   
endmodule // tag_generator
`default_nettype wire
