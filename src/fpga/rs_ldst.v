`include "constants.vh"
`default_nettype none
module rs_ldst_ent   ///MD RSV_LDST
  (
   //Memory
   input wire 			 clk,                                     ///CTRL_HC RSV_LDST
   input wire 			 reset,                                   ///CTRL_HC RSV_LDST
   input wire 			 busy,                                    ///CTRL_HC RSV_LDST
   input wire [`ADDR_LEN-1:0] 	 wpc,                             ///DATA_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 wsrc1,                           ///DATA_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 wsrc2,                           ///DATA_HC RSV_LDST
   input wire 			 wvalid1,                                 ///CTRL_HC RSV_LDST
   input wire 			 wvalid2,                                 ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 wimm,                            ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	 wrrftag,                         ///CTRL_HC RSV_LDST
   input wire 			 wdstval,                                 ///CTRL_HC RSV_LDST
   input wire [`SPECTAG_LEN-1:0] 	 wspectag,                    ///CTRL_HC RSV_LDST
   input wire 			 we,                                      ///CTRL_HC RSV_LDST
   output wire [`DATA_LEN-1:0] 	 ex_src1,                         ///DATA_HC RSV_LDST
   output wire [`DATA_LEN-1:0] 	 ex_src2,                         ///DATA_HC RSV_LDST
   output wire 			 ready /* verilator public */,            ///CTRL_HC RSV_LDST
   output reg [`ADDR_LEN-1:0] 	 pc /* verilator public */,       ///DATA_HC RSV_LDST
   output reg [`DATA_LEN-1:0] 	 imm /* verilator public */,      ///DATA_HC RSV_LDST
   output reg [`RRF_SEL-1:0] 	 rrftag /* verilator public */,   ///CTRL_HC RSV_LDST
   output reg 			 dstval /* verilator public */,           ///CTRL_HC RSV_LDST
   output reg [`SPECTAG_LEN-1:0] spectag /* verilator public */,  ///CTRL_HC RSV_LDST
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	 exrslt1,   ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	 exdst1,    ///CTRL_HC RSV_LDST
   input wire 			 kill_spec1,        ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 exrslt2,   ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	 exdst2,    ///CTRL_HC RSV_LDST
   input wire 			 kill_spec2,        ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 exrslt3,   ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	 exdst3,    ///CTRL_HC RSV_LDST
   input wire 			 kill_spec3,        ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 exrslt4,   ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	 exdst4,    ///CTRL_HC RSV_LDST
   input wire 			 kill_spec4,        ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	 exrslt5,   ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	 exdst5,    ///CTRL_HC RSV_LDST
   input wire 			 kill_spec5         ///CTRL_HC RSV_LDST
   );

   reg [`DATA_LEN-1:0] 		 src1 /* verilator public */;   ///DATA_HWD RSV_LDST
   reg [`DATA_LEN-1:0] 		 src2 /* verilator public */;   ///DATA_HWD RSV_LDST
   reg 				 valid1 /* verilator public */;         ///CTRL_HWD RSV_LDST
   reg 				 valid2 /* verilator public */;         ///CTRL_HWD RSV_LDST

   wire [`DATA_LEN-1:0] 	 nextsrc1;   ///DATA_HWD RSV_LDST
   wire [`DATA_LEN-1:0] 	 nextsrc2;   ///DATA_HWD RSV_LDST
   wire 			 nextvalid1;         ///CTRL_HWD RSV_LDST
   wire 			 nextvalid2;         ///CTRL_HWD RSV_LDST
   
   assign ready = busy & valid1 & valid2;    ///CTRL_CL RSV_LDST
   assign ex_src1 = ~valid1 & nextvalid1 ? nextsrc1 : src1;   ///DATA_CL RSV_LDST
   assign ex_src2 = ~valid2 & nextvalid2 ? nextsrc2 : src2;   ///DATA_CL RSV_LDST
   
   always @ (posedge clk) begin   ///CTRL_CL RSV_LDST
      if (reset) begin            ///CTRL_CL RSV_LDST
	 pc <= 0;                     ///DATA_DT RSV_LDST
	 imm <= 0;                    ///DATA_DT RSV_LDST
	 rrftag <= 0;                 ///CTRL_DT RSV_LDST
	 dstval <= 0;                 ///CTRL_DT RSV_LDST
	 spectag <= 0;                ///CTRL_DT RSV_LDST

	 src1 <= 0;                   ///DATA_DT RSV_LDST
	 src2 <= 0;                   ///DATA_DT RSV_LDST
	 valid1 <= 0;                 ///CTRL_DT RSV_LDST
	 valid2 <= 0;                 ///CTRL_DT RSV_LDST
      end else if (we) begin      ///CTRL_CL RSV_LDST
	 pc <= wpc;                   ///DATA_DT RSV_LDST
	 imm <= wimm;                 ///DATA_DT RSV_LDST
	 rrftag <= wrrftag;           ///CTRL_DT RSV_LDST
	 dstval <= wdstval;           ///CTRL_DT RSV_LDST
	 spectag <= wspectag;         ///CTRL_DT RSV_LDST

	 src1 <= wsrc1;            ///DATA_DT RSV_LDST
	 src2 <= wsrc2;            ///DATA_DT RSV_LDST
	 valid1 <= wvalid1;        ///CTRL_DT RSV_LDST
	 valid2 <= wvalid2;        ///CTRL_DT RSV_LDST
      end else begin // if (we)
	 src1 <= nextsrc1;       ///DATA_DT RSV_LDST
	 src2 <= nextsrc2;       ///DATA_DT RSV_LDST
	 valid1 <= nextvalid1;   ///CTRL_DT RSV_LDST
	 valid2 <= nextvalid2;   ///CTRL_DT RSV_LDST
      end
   end
   
   src_manager srcmng1(                 ///MD RSV_LDST
		       .opr(src1),              ///DATA_HC RSV_LDST
		       .opr_rdy(valid1),        ///CTRL_HC RSV_LDST
		       .exrslt1(exrslt1),       ///DATA_HC RSV_LDST
		       .exdst1(exdst1),         ///CTRL_HC RSV_LDST
		       .kill_spec1(kill_spec1), ///CTRL_HC RSV_LDST
		       .exrslt2(exrslt2),       ///DATA_HC RSV_LDST
		       .exdst2(exdst2),         ///CTRL_HC RSV_LDST
		       .kill_spec2(kill_spec2), ///CTRL_HC RSV_LDST
		       .exrslt3(exrslt3),       ///DATA_HC RSV_LDST
		       .exdst3(exdst3),         ///CTRL_HC RSV_LDST
		       .kill_spec3(kill_spec3), ///CTRL_HC RSV_LDST
		       .exrslt4(exrslt4),       ///DATA_HC RSV_LDST
		       .exdst4(exdst4),         ///CTRL_HC RSV_LDST
		       .kill_spec4(kill_spec4), ///CTRL_HC RSV_LDST
		       .exrslt5(exrslt5),       ///DATA_HC RSV_LDST
		       .exdst5(exdst5),         ///CTRL_HC RSV_LDST
		       .kill_spec5(kill_spec5), ///CTRL_HC RSV_LDST
		       .src(nextsrc1),          ///DATA_HC RSV_LDST
		       .resolved(nextvalid1)    ///CTRL_HC RSV_LDST
		       );

   src_manager srcmng2(                   ///DC
		       .opr(src2),                ///DC
		       .opr_rdy(valid2),          ///DC
		       .exrslt1(exrslt1),         ///DC
		       .exdst1(exdst1),           ///DC
		       .kill_spec1(kill_spec1),   ///DC
		       .exrslt2(exrslt2),         ///DC
		       .exdst2(exdst2),           ///DC
		       .kill_spec2(kill_spec2),   ///DC
		       .exrslt3(exrslt3),         ///DC
		       .exdst3(exdst3),           ///DC
		       .kill_spec3(kill_spec3),   ///DC
		       .exrslt4(exrslt4),         ///DC
		       .exdst4(exdst4),           ///DC
		       .kill_spec4(kill_spec4),   ///DC
		       .exrslt5(exrslt5),         ///DC
		       .exdst5(exdst5),           ///DC
		       .kill_spec5(kill_spec5),   ///DC
		       .src(nextsrc2),            ///DC
		       .resolved(nextvalid2)      ///DC
		       );                         ///DC
   
endmodule // rs_ldst


module rs_ldst   ///MD RSV_LDST
  (
   //System
   input wire 			   clk,                                    ///CTRL_HC RSV_LDST
   input wire 			   reset,                                  ///CTRL_HC RSV_LDST
   output reg [`LDST_ENT_NUM-1:0]  busyvec /* verilator public */, ///CTRL_HC RSV_LDST
   input wire 			   prmiss,                                 ///CTRL_HC RSV_LDST
   input wire 			   prsuccess,                              ///CTRL_HC RSV_LDST
   input wire [`SPECTAG_LEN-1:0] 	   prtag,                      ///CTRL_HC RSV_LDST
   input wire [`SPECTAG_LEN-1:0] 	   specfixtag,                 ///CTRL_HC RSV_LDST
   output wire [`LDST_ENT_NUM-1:0] prbusyvec_next,                 ///CTRL_HC RSV_LDST
   //WriteSignal
   input wire 			   clearbusy, //Issue                            ///CTRL_HC RSV_LDST
   input wire [`LDST_ENT_SEL-1:0] 	   issueaddr, //= raddr, clsbsyadr   ///CTRL_HC RSV_LDST
   input wire 			   we1, //alloc1                                 ///CTRL_HC RSV_LDST
   input wire 			   we2, //alloc2                                 ///CTRL_HC RSV_LDST
   input wire [`LDST_ENT_SEL-1:0] 	   waddr1, //allocent1               ///CTRL_HC RSV_LDST
   input wire [`LDST_ENT_SEL-1:0] 	   waddr2, //allocent2               ///CTRL_HC RSV_LDST
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 	   wpc_1,           ///DATA_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   wsrc1_1,         ///DATA_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   wsrc2_1,         ///DATA_HC RSV_LDST
   input wire 			   wvalid1_1,               ///CTRL_HC RSV_LDST
   input wire 			   wvalid2_1,               ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   wimm_1,          ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	   wrrftag_1,       ///CTRL_HC RSV_LDST
   input wire 			   wdstval_1,               ///CTRL_HC RSV_LDST
   input wire [`SPECTAG_LEN-1:0] 	   wspectag_1,  ///CTRL_HC RSV_LDST
   input wire 			   wspecbit_1,              ///CTRL_HC RSV_LDST
   //WriteSignal2
   input wire [`ADDR_LEN-1:0] 	   wpc_2,           ///DC
   input wire [`DATA_LEN-1:0] 	   wsrc1_2,         ///DC
   input wire [`DATA_LEN-1:0] 	   wsrc2_2,         ///DC
   input wire 			   wvalid1_2,               ///DC
   input wire 			   wvalid2_2,               ///DC
   input wire [`DATA_LEN-1:0] 	   wimm_2,          ///DC
   input wire [`RRF_SEL-1:0] 	   wrrftag_2,       ///DC
   input wire 			   wdstval_2,               ///DC
   input wire [`SPECTAG_LEN-1:0] 	   wspectag_2,  ///DC
   input wire 			   wspecbit_2,              ///DC

   //ReadSignal
   output wire [`DATA_LEN-1:0] 	   ex_src1, ///DATA_HC RSV_LDST
   output wire [`DATA_LEN-1:0] 	   ex_src2, ///DATA_HC RSV_LDST
   output wire [`LDST_ENT_NUM-1:0] ready,   ///CTRL_HC RSV_LDST
   output wire [`ADDR_LEN-1:0] 	   pc,      ///DATA_HC RSV_LDST
   output wire [`DATA_LEN-1:0] 	   imm,     ///DATA_HC RSV_LDST
   output wire [`RRF_SEL-1:0] 	   rrftag,  ///CTRL_HC RSV_LDST
   output wire 			   dstval,          ///CTRL_HC RSV_LDST
   output wire [`SPECTAG_LEN-1:0]  spectag, ///CTRL_HC RSV_LDST
   output wire 			   specbit,         ///CTRL_HC RSV_LDST
  
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	   exrslt1,    ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	   exdst1,     ///CTRL_HC RSV_LDST
   input wire 			   kill_spec1,         ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   exrslt2,    ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	   exdst2,     ///CTRL_HC RSV_LDST
   input wire 			   kill_spec2,         ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   exrslt3,    ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	   exdst3,     ///CTRL_HC RSV_LDST
   input wire 			   kill_spec3,         ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   exrslt4,    ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	   exdst4,     ///CTRL_HC RSV_LDST
   input wire 			   kill_spec4,         ///CTRL_HC RSV_LDST
   input wire [`DATA_LEN-1:0] 	   exrslt5,    ///DATA_HC RSV_LDST
   input wire [`RRF_SEL-1:0] 	   exdst5,     ///CTRL_HC RSV_LDST
   input wire 			   kill_spec5          ///CTRL_HC RSV_LDST
   );

   //_0
   wire [`DATA_LEN-1:0] 	      ex_src1_0;   ///DATA_HWD RSV_LDST
   wire [`DATA_LEN-1:0] 	      ex_src2_0;   ///DATA_HWD RSV_LDST
   wire 			      ready_0;   ///CTRL_HWD RSV_LDST
   wire [`ADDR_LEN-1:0] 	      pc_0;   ///DATA_HWD RSV_LDST
   wire [`DATA_LEN-1:0] 	      imm_0;   ///DATA_HWD RSV_LDST
   wire [`RRF_SEL-1:0] 		      rrftag_0;   ///CTRL_HWD RSV_LDST
   wire 			      dstval_0;   ///CTRL_HWD RSV_LDST
   wire [`SPECTAG_LEN-1:0] 	      spectag_0;   ///CTRL_HWD RSV_LDST
   //_1
   wire [`DATA_LEN-1:0] 	      ex_src1_1;       ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_1;       ///DC
   wire 			      ready_1;                 ///DC
   wire [`ADDR_LEN-1:0] 	      pc_1;            ///DC
   wire [`DATA_LEN-1:0] 	      imm_1;           ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_1;        ///DC
   wire 			      dstval_1;                ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_1;       ///DC
   //_2
   wire [`DATA_LEN-1:0] 	      ex_src1_2;       ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_2;       ///DC
   wire 			      ready_2;                 ///DC
   wire [`ADDR_LEN-1:0] 	      pc_2;            ///DC
   wire [`DATA_LEN-1:0] 	      imm_2;           ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_2;        ///DC
   wire 			      dstval_2;                ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_2;       ///DC
   //_3
   wire [`DATA_LEN-1:0] 	      ex_src1_3;       ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_3;       ///DC
   wire 			      ready_3;                 ///DC
   wire [`ADDR_LEN-1:0] 	      pc_3;            ///DC
   wire [`DATA_LEN-1:0] 	      imm_3;           ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_3;        ///DC
   wire 			      dstval_3;                ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_3;       ///DC
   
   reg [`LDST_ENT_NUM-1:0] 	   specbitvec /* verilator public */;   ///CTRL_HWD RSV_LDST

   //busy invalidation
   wire [`LDST_ENT_NUM-1:0] 	   inv_vector =   ///CTRL_CL RSV_LDST
				   {(spectag_3 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_LDST
				    (spectag_2 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_LDST
				    (spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_LDST
				    (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};   ///CTRL_CL RSV_LDST

   wire [`LDST_ENT_NUM-1:0] 	   inv_vector_spec =      ///CTRL_CL RSV_LDST
				   {(spectag_3 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_LDST
				    (spectag_2 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_LDST
				    (spectag_1 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_LDST
				    (spectag_0 == prtag) ? 1'b0 : 1'b1};  ///CTRL_CL RSV_LDST

   wire [`LDST_ENT_NUM-1:0] 	   specbitvec_next = (inv_vector_spec & specbitvec); ///CTRL_CL RSV_LDST
   /*| 
				   (we1 & wspecbit_1 ? (`LDST_ENT_SEL'b1 << waddr1) : 0) |
				   (we2 & wspecbit_2 ? (`LDST_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? specbitvec_next[issueaddr] : specbitvec[issueaddr];   ///CTRL_CL RSV_LDST
   
   assign ready = {ready_3, ready_2, ready_1, ready_0};   ///CTRL_CL RSV_LDST
   assign prbusyvec_next = inv_vector & busyvec;          ///CTRL_CL RSV_LDST
   
   always @ (posedge clk) begin ///CTRL_CL RSV_LDST
      if (reset) begin          ///CTRL_CL RSV_LDST
	 busyvec <= 0;              ///CTRL_DT RSV_LDST
	 specbitvec <= 0;           ///CTRL_DT RSV_LDST
      end else begin
	 if (prmiss) begin                   ///CTRL_CL RSV_LDST
	    busyvec <= prbusyvec_next;       ///CTRL_DT RSV_LDST
	    specbitvec <= 0;                 ///CTRL_DT RSV_LDST
	 end else if (prsuccess) begin       ///CTRL_CL RSV_LDST
	    specbitvec <= specbitvec_next;   ///CTRL_DT RSV_LDST
	    /*
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin             ///CTRL_CL RSV_LDST
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_LDST
	    end
	 end else begin
	    if (we1) begin                         ///CTRL_CL RSV_LDST
	       busyvec[waddr1] <= 1'b1;            ///CTRL_DT RSV_LDST
	       specbitvec[waddr1] <= wspecbit_1;   ///CTRL_DT RSV_LDST
	    end
	    if (we2) begin                         ///CTRL_CL RSV_LDST
	       busyvec[waddr2] <= 1'b1;            ///CTRL_DT RSV_LDST
	       specbitvec[waddr2] <= wspecbit_2;   ///CTRL_DT RSV_LDST
	    end
	    if (clearbusy) begin             ///CTRL_CL RSV_LDST
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_LDST
	    end
	 end
      end
   end

   rs_ldst_ent ent0(                                                       ///MD RSV_LDST
		    .clk(clk),                                                     ///CTRL_HC RSV_LDST
		    .reset(reset),                                                 ///CTRL_HC RSV_LDST
		    .busy(busyvec[0]),                                             ///CTRL_HC RSV_LDST
		    .wpc((we1 && (waddr1 == 0)) ? wpc_1 : wpc_2),                  ///DATA_HC+DATA_CL RSV_LDST
		    .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),            ///DATA_HC+DATA_CL RSV_LDST
		    .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),            ///DATA_HC+DATA_CL RSV_LDST
		    .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),      ///CTRL_HC+CTRL_CL RSV_LDST
		    .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),      ///CTRL_HC+CTRL_CL RSV_LDST
		    .wimm((we1 && (waddr1 == 0)) ? wimm_1 : wimm_2),               ///DATA_HC+DATA_CL RSV_LDST
		    .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),      ///CTRL_HC+CTRL_CL RSV_LDST
		    .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),      ///CTRL_HC+CTRL_CL RSV_LDST
		    .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),   ///CTRL_HC+CTRL_CL RSV_LDST
		    .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),         ///CTRL_HC+CTRL_CL RSV_LDST
		    .ex_src1(ex_src1_0),                                           ///DATA_HC RSV_LDST
		    .ex_src2(ex_src2_0),                                           ///DATA_HC RSV_LDST
		    .ready(ready_0),                                               ///CTRL_HC RSV_LDST
		    .pc(pc_0),                                                     ///DATA_HC RSV_LDST
		    .imm(imm_0),                                                   ///DATA_HC RSV_LDST
		    .rrftag(rrftag_0),                                             ///CTRL_HC RSV_LDST
		    .dstval(dstval_0),                                             ///CTRL_HC RSV_LDST
		    .spectag(spectag_0),                                           ///CTRL_HC RSV_LDST
		    .exrslt1(exrslt1),                                             ///DATA_HC RSV_LDST
		    .exdst1(exdst1),                                               ///CTRL_HC RSV_LDST
		    .kill_spec1(kill_spec1),                                       ///CTRL_HC RSV_LDST
		    .exrslt2(exrslt2),                                             ///DATA_HC RSV_LDST
		    .exdst2(exdst2),                                               ///CTRL_HC RSV_LDST
		    .kill_spec2(kill_spec2),                                       ///CTRL_HC RSV_LDST
		    .exrslt3(exrslt3),                                             ///DATA_HC RSV_LDST
		    .exdst3(exdst3),                                               ///CTRL_HC RSV_LDST
		    .kill_spec3(kill_spec3),                                       ///CTRL_HC RSV_LDST
		    .exrslt4(exrslt4),                                             ///DATA_HC RSV_LDST
		    .exdst4(exdst4),                                               ///CTRL_HC RSV_LDST
		    .kill_spec4(kill_spec4),                                       ///CTRL_HC RSV_LDST
		    .exrslt5(exrslt5),                                             ///DATA_HC RSV_LDST
		    .exdst5(exdst5),                                               ///CTRL_HC RSV_LDST
		    .kill_spec5(kill_spec5)                                        ///CTRL_HC RSV_LDST
		    );

   rs_ldst_ent ent1(                                                      ///DC
		    .clk(clk),                                                    ///DC
		    .reset(reset),		                                          ///DC
		    .busy(busyvec[1]),                                            ///DC
		    .wpc((we1 && (waddr1 == 1)) ? wpc_1 : wpc_2),                 ///DC
		    .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),           ///DC
		    .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),           ///DC
		    .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),     ///DC
		    .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),     ///DC
		    .wimm((we1 && (waddr1 == 1)) ? wimm_1 : wimm_2),              ///DC
		    .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),     ///DC
		    .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),     ///DC
		    .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),  ///DC
		    .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),        ///DC
		    .ex_src1(ex_src1_1),                                          ///DC
		    .ex_src2(ex_src2_1),                                          ///DC
		    .ready(ready_1),                                              ///DC
		    .pc(pc_1),                                                    ///DC
		    .imm(imm_1),                                                  ///DC
		    .rrftag(rrftag_1),                                            ///DC
		    .dstval(dstval_1),                                            ///DC
		    .spectag(spectag_1),                                          ///DC
		    .exrslt1(exrslt1),                                            ///DC
		    .exdst1(exdst1),                                              ///DC
		    .kill_spec1(kill_spec1),                                      ///DC
		    .exrslt2(exrslt2),                                            ///DC
		    .exdst2(exdst2),                                              ///DC
		    .kill_spec2(kill_spec2),                                      ///DC
		    .exrslt3(exrslt3),                                            ///DC
		    .exdst3(exdst3),                                              ///DC
		    .kill_spec3(kill_spec3),                                      ///DC
		    .exrslt4(exrslt4),                                            ///DC
		    .exdst4(exdst4),                                              ///DC
		    .kill_spec4(kill_spec4),                                      ///DC
		    .exrslt5(exrslt5),                                            ///DC
		    .exdst5(exdst5),                                              ///DC
		    .kill_spec5(kill_spec5)                                       ///DC
		    );                                                            ///DC

   rs_ldst_ent ent2(                                                      ///DC        
		    .clk(clk),                                                    ///DC          
		    .reset(reset),		                                          ///DC                        
		    .busy(busyvec[2]),                                            ///DC                  
		    .wpc((we1 && (waddr1 == 2)) ? wpc_1 : wpc_2),                 ///DC                                             
		    .wsrc1((we1 && (waddr1 == 2)) ? wsrc1_1 : wsrc1_2),           ///DC                                                   
		    .wsrc2((we1 && (waddr1 == 2)) ? wsrc2_1 : wsrc2_2),           ///DC                                                   
		    .wvalid1((we1 && (waddr1 == 2)) ? wvalid1_1 : wvalid1_2),     ///DC                                                         
		    .wvalid2((we1 && (waddr1 == 2)) ? wvalid2_1 : wvalid2_2),     ///DC                                                         
		    .wimm((we1 && (waddr1 == 2)) ? wimm_1 : wimm_2),              ///DC                                                
		    .wrrftag((we1 && (waddr1 == 2)) ? wrrftag_1 : wrrftag_2),     ///DC                                                         
		    .wdstval((we1 && (waddr1 == 2)) ? wdstval_1 : wdstval_2),     ///DC                                                         
		    .wspectag((we1 && (waddr1 == 2)) ? wspectag_1 : wspectag_2),  ///DC                                                            
		    .we((we1 && (waddr1 == 2)) || (we2 && (waddr2 == 2))),        ///DC                                                      
		    .ex_src1(ex_src1_2),                                          ///DC                    
		    .ex_src2(ex_src2_2),                                          ///DC                    
		    .ready(ready_2),                                              ///DC                
		    .pc(pc_2),                                                    ///DC          
		    .imm(imm_2),                                                  ///DC            
		    .rrftag(rrftag_2),                                            ///DC                  
		    .dstval(dstval_2),                                            ///DC                  
		    .spectag(spectag_2),                                          ///DC                    
		    .exrslt1(exrslt1),                                            ///DC                  
		    .exdst1(exdst1),                                              ///DC                
		    .kill_spec1(kill_spec1),                                      ///DC                        
		    .exrslt2(exrslt2),                                            ///DC                  
		    .exdst2(exdst2),                                              ///DC                
		    .kill_spec2(kill_spec2),                                      ///DC                        
		    .exrslt3(exrslt3),                                            ///DC                  
		    .exdst3(exdst3),                                              ///DC                
		    .kill_spec3(kill_spec3),                                      ///DC                        
		    .exrslt4(exrslt4),                                            ///DC                  
		    .exdst4(exdst4),                                              ///DC                
		    .kill_spec4(kill_spec4),                                      ///DC                        
		    .exrslt5(exrslt5),                                            ///DC                  
		    .exdst5(exdst5),                                              ///DC                
		    .kill_spec5(kill_spec5)                                       ///DC                       
		    );                                                            ///DC  

   rs_ldst_ent ent3(                                                      ///DC
		    .clk(clk),                                                    ///DC
		    .reset(reset),		                                          ///DC
		    .busy(busyvec[3]),                                            ///DC
		    .wpc((we1 && (waddr1 == 3)) ? wpc_1 : wpc_2),                 ///DC
		    .wsrc1((we1 && (waddr1 == 3)) ? wsrc1_1 : wsrc1_2),           ///DC
		    .wsrc2((we1 && (waddr1 == 3)) ? wsrc2_1 : wsrc2_2),           ///DC
		    .wvalid1((we1 && (waddr1 == 3)) ? wvalid1_1 : wvalid1_2),     ///DC
		    .wvalid2((we1 && (waddr1 == 3)) ? wvalid2_1 : wvalid2_2),     ///DC
		    .wimm((we1 && (waddr1 == 3)) ? wimm_1 : wimm_2),              ///DC
		    .wrrftag((we1 && (waddr1 == 3)) ? wrrftag_1 : wrrftag_2),     ///DC
		    .wdstval((we1 && (waddr1 == 3)) ? wdstval_1 : wdstval_2),     ///DC
		    .wspectag((we1 && (waddr1 == 3)) ? wspectag_1 : wspectag_2),  ///DC
		    .we((we1 && (waddr1 == 3)) || (we2 && (waddr2 == 3))),        ///DC
		    .ex_src1(ex_src1_3),                                          ///DC
		    .ex_src2(ex_src2_3),                                          ///DC
		    .ready(ready_3),                                              ///DC
		    .pc(pc_3),                                                    ///DC
		    .imm(imm_3),                                                  ///DC
		    .rrftag(rrftag_3),                                            ///DC
		    .dstval(dstval_3),                                            ///DC
		    .spectag(spectag_3),                                          ///DC
		    .exrslt1(exrslt1),                                            ///DC
		    .exdst1(exdst1),                                              ///DC
		    .kill_spec1(kill_spec1),                                      ///DC
		    .exrslt2(exrslt2),                                            ///DC
		    .exdst2(exdst2),                                              ///DC
		    .kill_spec2(kill_spec2),                                      ///DC
		    .exrslt3(exrslt3),                                            ///DC
		    .exdst3(exdst3),                                              ///DC
		    .kill_spec3(kill_spec3),                                      ///DC
		    .exrslt4(exrslt4),                                            ///DC
		    .exdst4(exdst4),                                              ///DC
		    .kill_spec4(kill_spec4),                                      ///DC
		    .exrslt5(exrslt5),                                            ///DC
		    .exdst5(exdst5),                                              ///DC
		    .kill_spec5(kill_spec5)                                       ///DC
		    );                                                            ///DC

   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 :   ///DATA_CL RSV_LDST
		    (issueaddr == 1) ? ex_src1_1 :              ///DC
		    (issueaddr == 2) ? ex_src1_2 : ex_src1_3;   ///DC

   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 :   ///DATA_CL RSV_LDST
		    (issueaddr == 1) ? ex_src2_1 :  ///DC
		    (issueaddr == 2) ? ex_src2_2 : ex_src2_3; ///DC

   assign pc = (issueaddr == 0) ? pc_0 :   ///DATA_CL RSV_LDST
	       (issueaddr == 1) ? pc_1 :       ///DC
	       (issueaddr == 2) ? pc_2 : pc_3; ///DC

   assign imm = (issueaddr == 0) ? imm_0 :   ///DATA_CL RSV_LDST
		(issueaddr == 1) ? imm_1 : ///DC
		(issueaddr == 2) ? imm_2 : imm_3; ///DC

   assign rrftag = (issueaddr == 0) ? rrftag_0 :   ///CTRL_CL RSV_LDST
		   (issueaddr == 1) ? rrftag_1 : ///DC
		   (issueaddr == 2) ? rrftag_2 : rrftag_3; ///DC

   assign dstval = (issueaddr == 0) ? dstval_0 :   ///CTRL_CL RSV_LDST
		   (issueaddr == 1) ? dstval_1 :  ///DC
		   (issueaddr == 2) ? dstval_2 : dstval_3; ///DC

   assign spectag = (issueaddr == 0) ? spectag_0 :   ///CTRL_CL RSV_LDST
		    (issueaddr == 1) ? spectag_1 : ///DC
		    (issueaddr == 2) ? spectag_2 : spectag_3; ///DC
   
   
endmodule // rs_ldst
`default_nettype wire
