`include "constants.vh"
`include "alu_ops.vh"
`default_nettype none
module rs_mul_ent   ///MD RSV_MUL
  (
   //Memory
   input wire 			 clk,   ///CTRL_HC RSV_MUL
   input wire 			 reset,   ///CTRL_HC RSV_MUL
   input wire 			 busy,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	 wsrc1,   ///DATA_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	 wsrc2,   ///DATA_HC RSV_MUL
   input wire 			 wvalid1,   ///CTRL_HC RSV_MUL
   input wire 			 wvalid2,   ///CTRL_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	 wrrftag,   ///CTRL_HC RSV_MUL
   input wire 			 wdstval,   ///CTRL_HC RSV_MUL
   input wire [`SPECTAG_LEN-1:0] 	 wspectag,   ///CTRL_HC RSV_MUL
   input wire 			 wsrc1_signed,   ///DATA_HC RSV_MUL
   input wire 			 wsrc2_signed,   ///DATA_HC RSV_MUL
   input wire 			 wsel_lohi,   ///DATA_HC RSV_MUL
   input wire 			 we,   ///CTRL_HC RSV_MUL
   output wire [`DATA_LEN-1:0] 	 ex_src1,   ///DATA_HC RSV_MUL
   output wire [`DATA_LEN-1:0] 	 ex_src2,   ///DATA_HC RSV_MUL
   output wire 			 ready /* verilator public */,   ///CTRL_HC RSV_MUL
   output reg [`RRF_SEL-1:0] 	 rrftag /* verilator public */,   ///CTRL_HC RSV_MUL
   output reg 			 dstval /* verilator public */,   ///CTRL_HC RSV_MUL
   output reg [`SPECTAG_LEN-1:0] spectag /* verilator public */,   ///CTRL_HC RSV_MUL
   output reg 			 src1_signed /* verilator public */,   ///DATA_HC RSV_MUL
   output reg 			 src2_signed /* verilator public */,   ///DATA_HC RSV_MUL
   output reg 			 sel_lohi /* verilator public */,   ///DATA_HC RSV_MUL
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	 exrslt1,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	 exdst1,   ///CTRL_HC RSV_MUL
   input wire 			 kill_spec1,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	 exrslt2,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	 exdst2,   ///CTRL_HC RSV_MUL
   input wire 			 kill_spec2,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	 exrslt3,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	 exdst3,   ///CTRL_HC RSV_MUL
   input wire 			 kill_spec3,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	 exrslt4,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	 exdst4,   ///CTRL_HC RSV_MUL
   input wire 			 kill_spec4,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	 exrslt5,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	 exdst5,   ///CTRL_HC RSV_MUL
   input wire 			 kill_spec5   ///CTRL_HC RSV_MUL
   );

   reg [`DATA_LEN-1:0] 		 src1 /* verilator public */;   ///DATA_HWD RSV_MUL
   reg [`DATA_LEN-1:0] 		 src2 /* verilator public */;   ///DATA_HWD RSV_MUL
   reg 				 valid1 /* verilator public */;   ///CTRL_HWD RSV_MUL
   reg 				 valid2 /* verilator public */;   ///CTRL_HWD RSV_MUL

   wire [`DATA_LEN-1:0] 	 nextsrc1;   ///DATA_HWD RSV_MUL
   wire [`DATA_LEN-1:0] 	 nextsrc2;   ///DATA_HWD RSV_MUL
   wire 			 nextvalid1;   ///CTRL_HWD RSV_MUL
   wire 			 nextvalid2;   ///CTRL_HWD RSV_MUL
   
   assign ready = busy & valid1 & valid2;   ///CTRL_CL RSV_MUL
   assign ex_src1 = ~valid1 & nextvalid1 ?   ///DATA_CL RSV_MUL
		    nextsrc1 : src1;   ///DATA_CL RSV_MUL
   assign ex_src2 = ~valid2 & nextvalid2 ?   ///DATA_CL RSV_MUL
		    nextsrc2 : src2;   ///DATA_CL RSV_MUL
   
   always @ (posedge clk) begin   ///CTRL_CL RSV_MUL
      if (reset) begin   ///CTRL_CL RSV_MUL
	 rrftag <= 0;   ///CTRL_DT RSV_MUL
	 dstval <= 0;   ///CTRL_DT RSV_MUL
	 spectag <= 0;   ///CTRL_DT RSV_MUL
	 src1_signed <= 0;   ///DATA_DT RSV_MUL
	 src2_signed <= 0;   ///DATA_DT RSV_MUL
	 sel_lohi <= 0;   ///DATA_DT RSV_MUL

	 src1 <= 0;   ///DATA_DT RSV_MUL
	 src2 <= 0;   ///DATA_DT RSV_MUL
	 valid1 <= 0;   ///CTRL_DT RSV_MUL
	 valid2 <= 0;   ///CTRL_DT RSV_MUL
      end else if (we) begin   ///CTRL_CL RSV_MUL
	 rrftag <= wrrftag;   ///CTRL_DT RSV_MUL
	 dstval <= wdstval;   ///CTRL_DT RSV_MUL
	 spectag <= wspectag;   ///CTRL_DT RSV_MUL
	 src1_signed <= wsrc1_signed;   ///DATA_DT RSV_MUL
	 src2_signed <= wsrc2_signed;   ///DATA_DT RSV_MUL
	 sel_lohi <= wsel_lohi;   ///DATA_DT RSV_MUL

	 src1 <= wsrc1;   ///DATA_DT RSV_MUL
	 src2 <= wsrc2;   ///DATA_DT RSV_MUL
	 valid1 <= wvalid1;   ///CTRL_DT RSV_MUL
	 valid2 <= wvalid2;   ///CTRL_DT RSV_MUL
      end else begin // if (we)
	 src1 <= nextsrc1;   ///DATA_DT RSV_MUL
	 src2 <= nextsrc2;   ///DATA_DT RSV_MUL
	 valid1 <= nextvalid1;   ///CTRL_DT RSV_MUL
	 valid2 <= nextvalid2;   ///CTRL_DT RSV_MUL
      end
   end
   
   src_manager srcmng1(   ///MD RSV_MUL
		       .opr(src1),   ///DATA_HC RSV_MUL
		       .opr_rdy(valid1),   ///CTRL_HC RSV_MUL
		       .exrslt1(exrslt1),   ///DATA_HC RSV_MUL
		       .exdst1(exdst1),   ///CTRL_HC RSV_MUL
		       .kill_spec1(kill_spec1),   ///CTRL_HC RSV_MUL
		       .exrslt2(exrslt2),   ///DATA_HC RSV_MUL
		       .exdst2(exdst2),   ///CTRL_HC RSV_MUL
		       .kill_spec2(kill_spec2),   ///CTRL_HC RSV_MUL
		       .exrslt3(exrslt3),   ///DATA_HC RSV_MUL
		       .exdst3(exdst3),   ///CTRL_HC RSV_MUL
		       .kill_spec3(kill_spec3),   ///CTRL_HC RSV_MUL
		       .exrslt4(exrslt4),   ///DATA_HC RSV_MUL
		       .exdst4(exdst4),   ///CTRL_HC RSV_MUL
		       .kill_spec4(kill_spec4),   ///CTRL_HC RSV_MUL
		       .exrslt5(exrslt5),   ///DATA_HC RSV_MUL
		       .exdst5(exdst5),   ///CTRL_HC RSV_MUL
		       .kill_spec5(kill_spec5),   ///CTRL_HC RSV_MUL
		       .src(nextsrc1),   ///DATA_HC RSV_MUL
		       .resolved(nextvalid1)   ///CTRL_HC RSV_MUL
		       );

   src_manager srcmng2(                  ///DC
		       .opr(src2),               ///DC
		       .opr_rdy(valid2),         ///DC
		       .exrslt1(exrslt1),        ///DC
		       .exdst1(exdst1),          ///DC
		       .kill_spec1(kill_spec1),  ///DC
		       .exrslt2(exrslt2),        ///DC
		       .exdst2(exdst2),          ///DC
		       .kill_spec2(kill_spec2),  ///DC
		       .exrslt3(exrslt3),        ///DC
		       .exdst3(exdst3),          ///DC
		       .kill_spec3(kill_spec3),  ///DC
		       .exrslt4(exrslt4),        ///DC
		       .exdst4(exdst4),          ///DC
		       .kill_spec4(kill_spec4),  ///DC
		       .exrslt5(exrslt5),        ///DC
		       .exdst5(exdst5),          ///DC
		       .kill_spec5(kill_spec5),  ///DC
		       .src(nextsrc2),           ///DC
		       .resolved(nextvalid2)     ///DC
		       );                        ///DC
   
endmodule // rs_mul


module rs_mul   ///MD RSV_MUL
  (
   //System
   input wire 			  clk,   ///CTRL_HC RSV_MUL
   input wire 			  reset,   ///CTRL_HC RSV_MUL
   output reg [`MUL_ENT_NUM-1:0]  busyvec /* verilator public */,   ///CTRL_HC RSV_MUL
   input wire 			  prmiss,   ///CTRL_HC RSV_MUL
   input wire 			  prsuccess,   ///CTRL_HC RSV_MUL
   input wire [`SPECTAG_LEN-1:0] 	  prtag,   ///CTRL_HC RSV_MUL
   input wire [`SPECTAG_LEN-1:0] 	  specfixtag,   ///CTRL_HC RSV_MUL
   //WriteSignal
   input wire 			  clearbusy, //Issue   ///CTRL_HC RSV_MUL
   input wire [`MUL_ENT_SEL-1:0] 	  issueaddr, //= raddr, clsbsyadr   ///CTRL_HC RSV_MUL
   input wire 			  we1, //alloc1   ///CTRL_HC RSV_MUL
   input wire 			  we2, //alloc2   ///CTRL_HC RSV_MUL
   input wire [`MUL_ENT_SEL-1:0] 	  waddr1, //allocent1   ///CTRL_HC RSV_MUL
   input wire [`MUL_ENT_SEL-1:0] 	  waddr2, //allocent2   ///CTRL_HC RSV_MUL
   //WriteSignal1
   input wire [`DATA_LEN-1:0] 	  wsrc1_1,   ///DATA_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	  wsrc2_1,   ///DATA_HC RSV_MUL
   input wire 			  wvalid1_1,   ///CTRL_HC RSV_MUL
   input wire 			  wvalid2_1,   ///CTRL_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	  wrrftag_1,   ///CTRL_HC RSV_MUL
   input wire 			  wdstval_1,   ///CTRL_HC RSV_MUL
   input wire [`SPECTAG_LEN-1:0] 	  wspectag_1,   ///CTRL_HC RSV_MUL
   input wire 			  wspecbit_1,   ///CTRL_HC RSV_MUL
   input wire 			  wsrc1_signed_1,   ///DATA_HC RSV_MUL
   input wire 			  wsrc2_signed_1,   ///DATA_HC RSV_MUL
   input wire 			  wsel_lohi_1,   ///DATA_HC RSV_MUL

   //WriteSignal2
   input wire [`DATA_LEN-1:0] 	  wsrc1_2,        ///DC
   input wire [`DATA_LEN-1:0] 	  wsrc2_2,        ///DC
   input wire 			  wvalid1_2,              ///DC
   input wire 			  wvalid2_2,              ///DC
   input wire [`RRF_SEL-1:0] 	  wrrftag_2,      ///DC
   input wire 			  wdstval_2,              ///DC
   input wire [`SPECTAG_LEN-1:0] 	  wspectag_2, ///DC
   input wire 			  wspecbit_2,             ///DC
   input wire 			  wsrc1_signed_2,         ///DC
   input wire 			  wsrc2_signed_2,         ///DC
   input wire 			  wsel_lohi_2,            ///DC

   //ReadSignal
   output wire [`DATA_LEN-1:0] 	  ex_src1,   ///DATA_HC RSV_MUL
   output wire [`DATA_LEN-1:0] 	  ex_src2,   ///DATA_HC RSV_MUL
   output wire [`MUL_ENT_NUM-1:0] ready,   ///CTRL_HC RSV_MUL
   output wire [`RRF_SEL-1:0] 	  rrftag,   ///CTRL_HC RSV_MUL
   output wire 			  dstval,   ///CTRL_HC RSV_MUL
   output wire [`SPECTAG_LEN-1:0] spectag,   ///CTRL_HC RSV_MUL
   output wire 			  specbit,   ///CTRL_HC RSV_MUL
   output wire 			  src1_signed,   ///DATA_HC RSV_MUL
   output wire 			  src2_signed,   ///DATA_HC RSV_MUL
   output wire 			  sel_lohi,   ///DATA_HC RSV_MUL

   //EXRSLT
   input wire [`DATA_LEN-1:0] 	  exrslt1,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	  exdst1,   ///CTRL_HC RSV_MUL
   input wire 			  kill_spec1,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	  exrslt2,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	  exdst2,   ///CTRL_HC RSV_MUL
   input wire 			  kill_spec2,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	  exrslt3,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	  exdst3,   ///CTRL_HC RSV_MUL
   input wire 			  kill_spec3,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	  exrslt4,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	  exdst4,   ///CTRL_HC RSV_MUL
   input wire 			  kill_spec4,   ///CTRL_HC RSV_MUL
   input wire [`DATA_LEN-1:0] 	  exrslt5,   ///DATA_HC RSV_MUL
   input wire [`RRF_SEL-1:0] 	  exdst5,   ///CTRL_HC RSV_MUL
   input wire 			  kill_spec5   ///CTRL_HC RSV_MUL
   );

   //_0
   wire [`DATA_LEN-1:0] 	      ex_src1_0;   ///DATA_HWD RSV_MUL
   wire [`DATA_LEN-1:0] 	      ex_src2_0;   ///DATA_HWD RSV_MUL
   wire 			      ready_0;   ///CTRL_HWD RSV_MUL
   wire [`RRF_SEL-1:0] 		      rrftag_0;   ///CTRL_HWD RSV_MUL
   wire 			      dstval_0;   ///CTRL_HWD RSV_MUL
   wire [`SPECTAG_LEN-1:0] 	      spectag_0;   ///CTRL_HWD RSV_MUL
   wire 			      src1_signed_0;   ///DATA_HWD RSV_MUL
   wire 			      src2_signed_0;   ///DATA_HWD RSV_MUL
   wire 			      sel_lohi_0;   ///DATA_HWD RSV_MUL
   
   //_1
   wire [`DATA_LEN-1:0] 	      ex_src1_1;  ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_1;  ///DC
   wire 			      ready_1;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_1;   ///DC
   wire 			      dstval_1;           ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_1;  ///DC
   wire 			      src1_signed_1;      ///DC
   wire 			      src2_signed_1;      ///DC
   wire 			      sel_lohi_1;         ///DC

   reg [`MUL_ENT_NUM-1:0] 	  specbitvec /* verilator public */;   ///CTRL_HWD RSV_MUL

   wire [`MUL_ENT_NUM-1:0] 	  inv_vector =   ///CTRL_CL RSV_MUL
				  {(spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_MUL
				   (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};   ///CTRL_CL RSV_MUL

   wire [`MUL_ENT_NUM-1:0] 	  inv_vector_spec =   ///CTRL_CL RSV_MUL
				  {(spectag_1 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_MUL
				   (spectag_0 == prtag) ? 1'b0 : 1'b1};   ///CTRL_CL RSV_MUL

   wire [`MUL_ENT_NUM-1:0] 	  specbitvec_next =   ///CTRL_CL RSV_MUL
				  (inv_vector_spec & specbitvec);   ///CTRL_CL RSV_MUL
   /* |
				  (we1 & wspecbit_1 ? (`MUL_ENT_SEL'b1 << waddr1) : 0) |
				  (we2 & wspecbit_2 ? (`MUL_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ?   ///CTRL_CL RSV_MUL
		    specbitvec_next[issueaddr] : specbitvec[issueaddr];   ///CTRL_CL RSV_MUL

   assign ready = {ready_1, ready_0};   ///CTRL_CL RSV_MUL
   
   always @ (posedge clk) begin   ///CTRL_CL RSV_MUL
      if (reset) begin   ///CTRL_CL RSV_MUL
	 busyvec <= 0;   ///CTRL_DT RSV_MUL
	 specbitvec <= 0;   ///CTRL_DT RSV_MUL
      end else begin
	 if (prmiss) begin   ///CTRL_CL RSV_MUL
	    busyvec <= inv_vector & busyvec;   ///CTRL_CL RSV_MUL
	    specbitvec <= 0;   ///CTRL_DT RSV_MUL
	 end else if (prsuccess) begin   ///CTRL_CL RSV_MUL
	    specbitvec <= specbitvec_next;   ///CTRL_DT RSV_MUL
	    /*
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin   ///CTRL_CL RSV_MUL
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_MUL
	    end
	 end else begin
	    if (we1) begin   ///CTRL_CL RSV_MUL
	       busyvec[waddr1] <= 1'b1;   ///CTRL_DT RSV_MUL
	       specbitvec[waddr1] <= wspecbit_1;   ///CTRL_DT RSV_MUL
	    end
	    if (we2) begin   ///CTRL_CL RSV_MUL
	       busyvec[waddr2] <= 1'b1;   ///CTRL_DT RSV_MUL
	       specbitvec[waddr2] <= wspecbit_2;   ///CTRL_DT RSV_MUL
	    end
	    if (clearbusy) begin   ///CTRL_CL RSV_MUL
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_MUL
	    end
	 end
      end
   end

   rs_mul_ent ent0(   ///MD RSV_MUL
		   .clk(clk),   ///CTRL_HC RSV_MUL
		   .reset(reset),   ///CTRL_HC RSV_MUL
		   .busy(busyvec[0]),   ///CTRL_HC RSV_MUL
		   .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),   ///DATA_HC+DATA_CL RSV_MUL
		   .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),   ///DATA_HC+DATA_CL RSV_MUL
		   .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),   ///CTRL_HC+CTRL_CL RSV_MUL
		   .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),   ///CTRL_HC+CTRL_CL RSV_MUL
		   .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),   ///CTRL_HC+CTRL_CL RSV_MUL
		   .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),   ///CTRL_HC+CTRL_CL RSV_MUL
		   .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),   ///CTRL_HC+CTRL_CL RSV_MUL
		   .wsrc1_signed((we1 && (waddr1 == 0)) ? wsrc1_signed_1 : wsrc1_signed_2),   ///DATA_HC+DATA_CL RSV_MUL
		   .wsrc2_signed((we1 && (waddr1 == 0)) ? wsrc2_signed_1 : wsrc2_signed_2),   ///DATA_HC+DATA_CL RSV_MUL
		   .wsel_lohi((we1 && (waddr1 == 0)) ? wsel_lohi_1 : wsel_lohi_2),   ///DATA_HC+DATA_CL RSV_MUL
		   .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),   ///CTRL_HC+CTRL_CL RSV_MUL
		   .ex_src1(ex_src1_0),   ///DATA_HC RSV_MUL
		   .ex_src2(ex_src2_0),   ///DATA_HC RSV_MUL
		   .ready(ready_0),   ///CTRL_HC RSV_MUL
		   .rrftag(rrftag_0),   ///CTRL_HC RSV_MUL
		   .dstval(dstval_0),   ///CTRL_HC RSV_MUL
		   .spectag(spectag_0),   ///CTRL_HC RSV_MUL
		   .src1_signed(src1_signed_0),   ///DATA_HC RSV_MUL
		   .src2_signed(src2_signed_0),   ///DATA_HC RSV_MUL
		   .sel_lohi(sel_lohi_0),   ///DATA_HC RSV_MUL
		   .exrslt1(exrslt1),   ///DATA_HC RSV_MUL
		   .exdst1(exdst1),   ///CTRL_HC RSV_MUL
		   .kill_spec1(kill_spec1),   ///CTRL_HC RSV_MUL
		   .exrslt2(exrslt2),   ///DATA_HC RSV_MUL
		   .exdst2(exdst2),   ///CTRL_HC RSV_MUL
		   .kill_spec2(kill_spec2),   ///CTRL_HC RSV_MUL
		   .exrslt3(exrslt3),   ///DATA_HC RSV_MUL
		   .exdst3(exdst3),   ///CTRL_HC RSV_MUL
		   .kill_spec3(kill_spec3),   ///CTRL_HC RSV_MUL
		   .exrslt4(exrslt4),   ///DATA_HC RSV_MUL
		   .exdst4(exdst4),   ///CTRL_HC RSV_MUL
		   .kill_spec4(kill_spec4),   ///CTRL_HC RSV_MUL
		   .exrslt5(exrslt5),   ///DATA_HC RSV_MUL
		   .exdst5(exdst5),   ///CTRL_HC RSV_MUL
		   .kill_spec5(kill_spec5)   ///CTRL_HC RSV_MUL
		   );

   rs_mul_ent ent1(                                                                    ///DC
		   .clk(clk),                                                                  ///DC
		   .reset(reset),		                                                       ///DC
		   .busy(busyvec[1]),                                                          ///DC
		   .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),                         ///DC
		   .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),                         ///DC
		   .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),                   ///DC
		   .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),                   ///DC
		   .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),                   ///DC
		   .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),                   ///DC
		   .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),                ///DC
		   .wsrc1_signed((we1 && (waddr1 == 1)) ? wsrc1_signed_1 : wsrc1_signed_2),    ///DC
		   .wsrc2_signed((we1 && (waddr1 == 1)) ? wsrc2_signed_1 : wsrc2_signed_2),    ///DC
		   .wsel_lohi((we1 && (waddr1 == 1)) ? wsel_lohi_1 : wsel_lohi_2),             ///DC
		   .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),                      ///DC
		   .ex_src1(ex_src1_1),                                                        ///DC
		   .ex_src2(ex_src2_1),                                                        ///DC
		   .ready(ready_1),                                                            ///DC
		   .rrftag(rrftag_1),                                                          ///DC
		   .dstval(dstval_1),                                                          ///DC
		   .spectag(spectag_1),                                                        ///DC
		   .src1_signed(src1_signed_1),                                                ///DC
		   .src2_signed(src2_signed_1),                                                ///DC
		   .sel_lohi(sel_lohi_1),                                                      ///DC
		   .exrslt1(exrslt1),                                                          ///DC
		   .exdst1(exdst1),                                                            ///DC
		   .kill_spec1(kill_spec1),                                                    ///DC
		   .exrslt2(exrslt2),                                                          ///DC
		   .exdst2(exdst2),                                                            ///DC
		   .kill_spec2(kill_spec2),                                                    ///DC
		   .exrslt3(exrslt3),                                                          ///DC
		   .exdst3(exdst3),                                                            ///DC
		   .kill_spec3(kill_spec3),                                                    ///DC
		   .exrslt4(exrslt4),                                                          ///DC
		   .exdst4(exdst4),                                                            ///DC
		   .kill_spec4(kill_spec4),                                                    ///DC
		   .exrslt5(exrslt5),                                                          ///DC
		   .exdst5(exdst5),                                                            ///DC
		   .kill_spec5(kill_spec5)                                                     ///DC
		   );                                                                          ///DC
   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 : ex_src1_1;   ///DATA_CL RSV_MUL
   
   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 : ex_src2_1;   ///DATA_CL RSV_MUL

   assign rrftag = (issueaddr == 0) ? rrftag_0 : rrftag_1;   ///CTRL_CL RSV_MUL
   
   assign dstval = (issueaddr == 0) ? dstval_0 : dstval_1;   ///CTRL_CL RSV_MUL

   assign spectag = (issueaddr == 0) ? spectag_0 : spectag_1;   ///CTRL_CL RSV_MUL

   assign src1_signed = (issueaddr == 0) ? src1_signed_0 : src1_signed_1;   ///DATA_CL RSV_MUL

   assign src2_signed = (issueaddr == 0) ? src2_signed_0 : src2_signed_1;   ///DATA_CL RSV_MUL

   assign sel_lohi = (issueaddr == 0) ? sel_lohi_0 : sel_lohi_1;   ///DATA_CL RSV_MUL
endmodule // rs_mul
`default_nettype wire
