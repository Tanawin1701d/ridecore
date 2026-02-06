`include "constants.vh"
`default_nettype none
module tag_generator(
		     input wire 		    clk,
		     input wire 		    reset,
		     input wire 		    branchvalid1,
		     input wire 		    branchvalid2,
		     input wire 		    prmiss,
		     input wire 		    prsuccess,
		     input wire 		    enable,
		     input wire [`SPECTAG_LEN-1:0]  tagregfix,
		     output wire [`SPECTAG_LEN-1:0] sptag1,
		     output wire [`SPECTAG_LEN-1:0] sptag2,
		     output wire 		    speculative1,
		     output wire 		    speculative2,
		     output wire 		    attachable,
		     output reg [`SPECTAG_LEN-1:0]  tagreg /* verilator public */
		     );

//   reg [`SPECTAG_LEN-1:0] 		       tagreg;
   reg [`BRDEPTH_LEN-1:0] 		       brdepth /* verilator public */;
   
   assign sptag1 = (branchvalid1) ? 
		   {tagreg[`SPECTAG_LEN-2:0], tagreg[`SPECTAG_LEN-1]}
		   : tagreg;
   assign sptag2 = (branchvalid2) ? 
		   {sptag1[`SPECTAG_LEN-2:0], sptag1[`SPECTAG_LEN-1]}
		   : sptag1;
   assign speculative1 = (brdepth != 0) ? 1'b1 : 1'b0;
   assign speculative2 = ((brdepth != 0) || branchvalid1) ? 1'b1 : 1'b0;
//    assign attachable = (brdepth + branchvalid1 + branchvalid2) 
//      > (`BRANCH_ENT_NUM + prsuccess) ? 1'b0 : 1'b1;

	 assign attachable =
    (brdepth
     + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid1}
     + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid2}
    ) > (`BRANCH_ENT_NUM + 
		{{(`BRDEPTH_LEN-1){1'b0}}, prsuccess}
		)
      ? 1'b0 : 1'b1;


   always @ (posedge clk) begin  ///CTRL TAGGEN
      if (reset) begin  ///CTRL TAGGEN
	 tagreg <= `SPECTAG_LEN'b1;
	 brdepth <= `BRDEPTH_LEN'b0;
      end else begin
	 tagreg <= prmiss ? tagregfix :   ///CTRL TAGGEN      
		   ~enable ? tagreg : 
		   sptag2;
	 brdepth <= prmiss ? `BRDEPTH_LEN'b0 : ///CTRL TAGGEN
		    ~enable ? brdepth - {{(`BRDEPTH_LEN-1){1'b0}}, prsuccess} :
		    brdepth + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid1} + {{(`BRDEPTH_LEN-1){1'b0}}, branchvalid2} - {{(`BRDEPTH_LEN-1){1'b0}}, prsuccess};
      end
   end
   
endmodule // tag_generator
`default_nettype wire
