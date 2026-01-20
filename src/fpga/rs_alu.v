`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module rs_alu_ent
  (
   //Memory
   input wire 			     clk,
   input wire 			     reset,
   input wire 			     busy,
   input wire [`ADDR_LEN-1:0] 	     wpc,
   input wire [`DATA_LEN-1:0] 	     wsrc1,
   input wire [`DATA_LEN-1:0] 	     wsrc2,
   input wire 			     wvalid1,
   input wire 			     wvalid2,
   input wire [`DATA_LEN-1:0] 	     wimm,
   input wire [`RRF_SEL-1:0] 	     wrrftag,
   input wire 			     wdstval,
   input wire [`SRC_A_SEL_WIDTH-1:0] wsrc_a,
   input wire [`SRC_B_SEL_WIDTH-1:0] wsrc_b,
   input wire [`ALU_OP_WIDTH-1:0]    walu_op,
   input wire [`SPECTAG_LEN-1:0]     wspectag,
   input wire 			     we,
   output wire [`DATA_LEN-1:0] 	     ex_src1,
   output wire [`DATA_LEN-1:0] 	     ex_src2,
   output wire 			     ready /* verilator public */,
   output reg [`ADDR_LEN-1:0] 	     pc /* verilator public */,
   output reg [`DATA_LEN-1:0] 	     imm /* verilator public */,
   output reg [`RRF_SEL-1:0] 	     rrftag /* verilator public */,
   output reg 			             dstval /* verilator public */,
   output reg [`SRC_A_SEL_WIDTH-1:0] src_a /* verilator public */,
   output reg [`SRC_B_SEL_WIDTH-1:0] src_b /* verilator public */,
   output reg [`ALU_OP_WIDTH-1:0]    alu_op /* verilator public */,
   output reg [`SPECTAG_LEN-1:0]     spectag /* verilator public */,
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	     exrslt1,
   input wire [`RRF_SEL-1:0] 	     exdst1,
   input wire 			     kill_spec1,
   input wire [`DATA_LEN-1:0] 	     exrslt2,
   input wire [`RRF_SEL-1:0] 	     exdst2,
   input wire 			     kill_spec2,
   input wire [`DATA_LEN-1:0] 	     exrslt3,
   input wire [`RRF_SEL-1:0] 	     exdst3,
   input wire 			     kill_spec3,
   input wire [`DATA_LEN-1:0] 	     exrslt4,
   input wire [`RRF_SEL-1:0] 	     exdst4,
   input wire 			     kill_spec4,
   input wire [`DATA_LEN-1:0] 	     exrslt5,
   input wire [`RRF_SEL-1:0] 	     exdst5,
   input wire 			     kill_spec5
   );

   reg [`DATA_LEN-1:0] 		     src1 /* verilator public */;
   reg [`DATA_LEN-1:0] 		     src2 /* verilator public */;
   reg 				     valid1 /* verilator public */;
   reg 				     valid2 /* verilator public */;

   wire [`DATA_LEN-1:0] 	     nextsrc1;
   wire [`DATA_LEN-1:0] 	     nextsrc2;   
   wire 			     nextvalid1;
   wire 			     nextvalid2;
   
   assign ready = busy & valid1 & valid2;
   assign ex_src1 = ~valid1 & nextvalid1 ?
		    nextsrc1 : src1;
   assign ex_src2 = ~valid2 & nextvalid2 ?
		    nextsrc2 : src2;
   
   always @ (posedge clk) begin  ///CTRL RSV_ALU
      if (reset) begin           ///CTRL RSV_ALU
	 pc <= 0;
	 imm <= 0;
	 rrftag <= 0;
	 dstval <= 0;
	 src_a <= 0;
	 src_b <= 0;
	 alu_op <= 0;
	 spectag <= 0;

	 src1 <= 0;
	 src2 <= 0;
	 valid1 <= 0;
	 valid2 <= 0;
      end else if (we) begin  ///CTRL RSV_ALU
	 pc <= wpc;
	 imm <= wimm;
	 rrftag <= wrrftag;
	 dstval <= wdstval;
	 src_a <= wsrc_a;
	 src_b <= wsrc_b;
	 alu_op <= walu_op;
	 spectag <= wspectag;

	 src1 <= wsrc1;
	 src2 <= wsrc2;
	 valid1 <= wvalid1;
	 valid2 <= wvalid2;
      end else begin // if (we)
	 src1 <= nextsrc1;
	 src2 <= nextsrc2;
	 valid1 <= nextvalid1;
	 valid2 <= nextvalid2;
      end
   end
   
   src_manager srcmng1(
		       .opr(src1),
		       .opr_rdy(valid1),
		       .exrslt1(exrslt1),
		       .exdst1(exdst1),
		       .kill_spec1(kill_spec1),
		       .exrslt2(exrslt2),
		       .exdst2(exdst2),
		       .kill_spec2(kill_spec2),
		       .exrslt3(exrslt3),
		       .exdst3(exdst3),
		       .kill_spec3(kill_spec3),
		       .exrslt4(exrslt4),
		       .exdst4(exdst4),
		       .kill_spec4(kill_spec4),
		       .exrslt5(exrslt5),
		       .exdst5(exdst5),
		       .kill_spec5(kill_spec5),
		       .src(nextsrc1),
		       .resolved(nextvalid1)
		       );

   src_manager srcmng2(                 ///DC
		       .opr(src2),              ///DC
		       .opr_rdy(valid2),        ///DC
		       .exrslt1(exrslt1),       ///DC
		       .exdst1(exdst1),         ///DC
		       .kill_spec1(kill_spec1), ///DC
		       .exrslt2(exrslt2),       ///DC
		       .exdst2(exdst2),         ///DC
		       .kill_spec2(kill_spec2), ///DC
		       .exrslt3(exrslt3),       ///DC
		       .exdst3(exdst3),         ///DC
		       .kill_spec3(kill_spec3), ///DC
		       .exrslt4(exrslt4),       ///DC
		       .exdst4(exdst4),         ///DC
		       .kill_spec4(kill_spec4), ///DC
		       .exrslt5(exrslt5),       ///DC
		       .exdst5(exdst5),         ///DC
		       .kill_spec5(kill_spec5), ///DC
		       .src(nextsrc2),          ///DC
		       .resolved(nextvalid2)    ///DC
		       );                       ///DC
   
endmodule // rs_alu


module rs_alu
  (
   //System
   input wire 				       clk,
   input wire 				       reset,
   output reg [`ALU_ENT_NUM-1:0] 	       busyvec /* verilator public */,
   input wire 				       prmiss,
   input wire 				       prsuccess,
   input wire [`SPECTAG_LEN-1:0] 	       prtag,
   input wire [`SPECTAG_LEN-1:0] 	       specfixtag,
   output wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect,
   input wire 				       nextrrfcyc, 
   //WriteSignal
   input wire 				       clearbusy, //Issue
   input wire [`ALU_ENT_SEL-1:0] 	       issueaddr,
   input wire 				       we1, //alloc1
   input wire 				       we2, //alloc2
   input wire [`ALU_ENT_SEL-1:0] 	       waddr1, //allocent1
   input wire [`ALU_ENT_SEL-1:0] 	       waddr2, //allocent2
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 		       wpc_1,
   input wire [`DATA_LEN-1:0] 		       wsrc1_1,
   input wire [`DATA_LEN-1:0] 		       wsrc2_1,
   input wire 				       wvalid1_1,
   input wire 				       wvalid2_1,
   input wire [`DATA_LEN-1:0] 		       wimm_1,
   input wire [`RRF_SEL-1:0] 		       wrrftag_1,
   input wire 				       wdstval_1,
   input wire [`SRC_A_SEL_WIDTH-1:0] 	       wsrc_a_1,
   input wire [`SRC_B_SEL_WIDTH-1:0] 	       wsrc_b_1,
   input wire [`ALU_OP_WIDTH-1:0] 	       walu_op_1,
   input wire [`SPECTAG_LEN-1:0] 	       wspectag_1,
   input wire 				       wspecbit_1,
   //WriteSignal2
   input wire [`ADDR_LEN-1:0] 		       wpc_2,        ///DC
   input wire [`DATA_LEN-1:0] 		       wsrc1_2,      ///DC
   input wire [`DATA_LEN-1:0] 		       wsrc2_2,      ///DC
   input wire 				       wvalid1_2,            ///DC
   input wire 				       wvalid2_2,            ///DC
   input wire [`DATA_LEN-1:0] 		       wimm_2,       ///DC
   input wire [`RRF_SEL-1:0] 		       wrrftag_2,    ///DC
   input wire 				       wdstval_2,            ///DC
   input wire [`SRC_A_SEL_WIDTH-1:0] 	       wsrc_a_2, ///DC
   input wire [`SRC_B_SEL_WIDTH-1:0] 	       wsrc_b_2, ///DC
   input wire [`ALU_OP_WIDTH-1:0] 	       walu_op_2,    ///DC
   input wire [`SPECTAG_LEN-1:0] 	       wspectag_2,   ///DC
   input wire 				       wspecbit_2,           ///DC

   //ReadSignal
   output wire [`DATA_LEN-1:0] 		       ex_src1,
   output wire [`DATA_LEN-1:0] 		       ex_src2,
   output wire [`ALU_ENT_NUM-1:0] 	       ready,
   output wire [`ADDR_LEN-1:0] 		       pc,
   output wire [`DATA_LEN-1:0] 		       imm,
   output wire [`RRF_SEL-1:0] 		       rrftag,
   output wire 				       dstval,
   output wire [`SRC_A_SEL_WIDTH-1:0] 	       src_a,
   output wire [`SRC_B_SEL_WIDTH-1:0] 	       src_b,
   output wire [`ALU_OP_WIDTH-1:0] 	       alu_op,
   output wire [`SPECTAG_LEN-1:0] 	       spectag,
   output wire 				       specbit,
  
   //EXRSLT
   input wire [`DATA_LEN-1:0] 		       exrslt1,
   input wire [`RRF_SEL-1:0] 		       exdst1,
   input wire 				       kill_spec1,
   input wire [`DATA_LEN-1:0] 		       exrslt2,
   input wire [`RRF_SEL-1:0] 		       exdst2,
   input wire 				       kill_spec2,
   input wire [`DATA_LEN-1:0] 		       exrslt3,
   input wire [`RRF_SEL-1:0] 		       exdst3,
   input wire 				       kill_spec3,
   input wire [`DATA_LEN-1:0] 		       exrslt4,
   input wire [`RRF_SEL-1:0] 		       exdst4,
   input wire 				       kill_spec4,
   input wire [`DATA_LEN-1:0] 		       exrslt5,
   input wire [`RRF_SEL-1:0] 		       exdst5,
   input wire 				       kill_spec5
   );
   
   //_0
   wire [`DATA_LEN-1:0] 	      ex_src1_0;
   wire [`DATA_LEN-1:0] 	      ex_src2_0;
   wire 			      ready_0;
   wire [`ADDR_LEN-1:0] 	      pc_0;
   wire [`DATA_LEN-1:0] 	      imm_0;
   wire [`RRF_SEL-1:0] 		      rrftag_0;
   wire 			      dstval_0;
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_0;
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_0;
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_0;
   wire [`SPECTAG_LEN-1:0] 	      spectag_0;
   //_1
   wire [`DATA_LEN-1:0] 	      ex_src1_1;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_1;        ///DC
   wire 			      ready_1;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_1;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_1;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_1;         ///DC
   wire 			      dstval_1;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_1;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_1;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_1;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_1;        ///DC
   //_2
   wire [`DATA_LEN-1:0] 	      ex_src1_2;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_2;        ///DC
   wire 			      ready_2;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_2;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_2;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_2;         ///DC
   wire 			      dstval_2;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_2;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_2;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_2;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_2;        ///DC
   //_3
   wire [`DATA_LEN-1:0] 	      ex_src1_3;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_3;        ///DC
   wire 			      ready_3;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_3;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_3;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_3;         ///DC
   wire 			      dstval_3;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_3;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_3;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_3;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_3;        ///DC
   //_4
   wire [`DATA_LEN-1:0] 	      ex_src1_4;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_4;        ///DC
   wire 			      ready_4;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_4;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_4;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_4;         ///DC
   wire 			      dstval_4;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_4;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_4;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_4;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_4;        ///DC
   //_5
   wire [`DATA_LEN-1:0] 	      ex_src1_5;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_5;        ///DC
   wire 			      ready_5;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_5;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_5;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_5;         ///DC
   wire 			      dstval_5;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_5;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_5;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_5;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_5;        ///DC
   //_6
   wire [`DATA_LEN-1:0] 	      ex_src1_6;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_6;        ///DC
   wire 			      ready_6;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_6;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_6;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_6;         ///DC
   wire 			      dstval_6;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_6;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_6;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_6;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_6;        ///DC
   //_7
   wire [`DATA_LEN-1:0] 	      ex_src1_7;        ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_7;        ///DC
   wire 			      ready_7;                  ///DC
   wire [`ADDR_LEN-1:0] 	      pc_7;             ///DC
   wire [`DATA_LEN-1:0] 	      imm_7;            ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_7;         ///DC
   wire 			      dstval_7;                 ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_7;      ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_7;      ///DC
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_7;     ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_7;        ///DC

   reg [`ALU_ENT_NUM-1:0] 	      specbitvec /* verilator public */;
   reg [`ALU_ENT_NUM-1:0] 	      sortbit /* verilator public */;
   
   
   wire [`ALU_ENT_NUM-1:0] 	      inv_vector =
				      {(spectag_7 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_6 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_5 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_4 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_3 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_2 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,
				       (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};

   wire [`ALU_ENT_NUM-1:0] 	      inv_vector_spec =
				      {(spectag_7 == prtag) ? 1'b0 : 1'b1,
				       (spectag_6 == prtag) ? 1'b0 : 1'b1,
				       (spectag_5 == prtag) ? 1'b0 : 1'b1,
				       (spectag_4 == prtag) ? 1'b0 : 1'b1,
				       (spectag_3 == prtag) ? 1'b0 : 1'b1,
				       (spectag_2 == prtag) ? 1'b0 : 1'b1,
				       (spectag_1 == prtag) ? 1'b0 : 1'b1,
				       (spectag_0 == prtag) ? 1'b0 : 1'b1};

   wire [`ALU_ENT_NUM-1:0] 	      specbitvec_next =
				      (inv_vector_spec & specbitvec);
   /* |
    (we1 & wspecbit_1 ? (`ALU_ENT_SEL'b1 << waddr1) : 0) |
    (we2 & wspecbit_2 ? (`ALU_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? 
		    specbitvec_next[issueaddr] : specbitvec[issueaddr];
   
   /*   
    assign specbit = prsuccess ? 
    ((inv_vector & busyvec) |
    (we1 & wspecbit_1 ? (`ALU_ENT_SEL'b1 << waddr1) : 0) |
    (we2 & wspecbit_2 ? (`ALU_ENT_SEL'b1 << waddr2) : 0)) : 
    specbitvec[issueaddr];
    */
   
   assign ready = {ready_7, ready_6, ready_5, ready_4,
		   ready_3, ready_2, ready_1, ready_0};

   assign histvect = {
		      {~ready_7, sortbit[7], rrftag_7},
		      {~ready_6, sortbit[6], rrftag_6},
		      {~ready_5, sortbit[5], rrftag_5},
		      {~ready_4, sortbit[4], rrftag_4},
		      {~ready_3, sortbit[3], rrftag_3},
		      {~ready_2, sortbit[2], rrftag_2},
		      {~ready_1, sortbit[1], rrftag_1},
		      {~ready_0, sortbit[0], rrftag_0}		      
		      };

   always @ (posedge clk) begin   ///CTRL RSV_ALU
      if (reset) begin            ///CTRL RSV_ALU
	 sortbit <= `ALU_ENT_NUM'b1;
      end else if (nextrrfcyc) begin
	 sortbit <= (we1 ? (`ALU_ENT_NUM'b1 << waddr1) : `ALU_ENT_NUM'b0) |
		    (we2 ? (`ALU_ENT_NUM'b1 << waddr2) : `ALU_ENT_NUM'b0);
      end else begin
	 if (we1) begin                ///CTRL RSV_ALU
	    sortbit[waddr1] <= 1'b1;
	 end
	 if (we2) begin                ///CTRL RSV_ALU
	    sortbit[waddr2] <= 1'b1;
	 end
      end
   end
   
   always @ (posedge clk) begin    ///CTRL RSV_ALU
      if (reset) begin             ///CTRL RSV_ALU
	 busyvec <= 0;
	 specbitvec <= 0;
      end else begin
	 if (prmiss) begin             ///CTRL RSV_ALU
	    busyvec <= inv_vector & busyvec;
	    specbitvec <= 0;
	 end else if (prsuccess) begin     ///CTRL RSV_ALU
	    /*
	     specbitvec <= (inv_vector & busyvec) |
	     (we1 & wspecbit_1 ? (`ALU_ENT_SEL'b1 << waddr1) : 0) |
	     (we2 & wspecbit_2 ? (`ALU_ENT_SEL'b1 << waddr2) : 0);
	     */
	    specbitvec <= specbitvec_next;
	    /*
	     if (we1) begin
	     busyvec[waddr1] <= 1'b1;
	    end
	     if (we2) begin
	     busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end else begin
	    if (we1) begin              ///CTRL RSV_ALU
	       busyvec[waddr1] <= 1'b1;
	       specbitvec[waddr1] <= wspecbit_1;
	    end
	    if (we2) begin              ///CTRL RSV_ALU
	       busyvec[waddr2] <= 1'b1;
	       specbitvec[waddr2] <= wspecbit_2;
	    end
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end
      end
   end

   rs_alu_ent ent0(
		   .clk(clk),
		   .reset(reset),
		   .busy(busyvec[0]),
		   .wpc((we1 && (waddr1 == 0)) ? wpc_1 : wpc_2),
		   .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),
		   .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),
		   .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),
		   .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),
		   .wimm((we1 && (waddr1 == 0)) ? wimm_1 : wimm_2),
		   .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),
		   .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),
		   .wsrc_a((we1 && (waddr1 == 0)) ? wsrc_a_1 : wsrc_a_2),
		   .wsrc_b((we1 && (waddr1 == 0)) ? wsrc_b_1 : wsrc_b_2),
		   .walu_op((we1 && (waddr1 == 0)) ? walu_op_1 : walu_op_2),
		   .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),
		   .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),
		   .ex_src1(ex_src1_0),
		   .ex_src2(ex_src2_0),
		   .ready(ready_0),
		   .pc(pc_0),
		   .imm(imm_0),
		   .rrftag(rrftag_0),
		   .dstval(dstval_0),
		   .src_a(src_a_0),
		   .src_b(src_b_0),
		   .alu_op(alu_op_0),
		   .spectag(spectag_0),
		   .exrslt1(exrslt1),
		   .exdst1(exdst1),
		   .kill_spec1(kill_spec1),
		   .exrslt2(exrslt2),
		   .exdst2(exdst2),
		   .kill_spec2(kill_spec2),
		   .exrslt3(exrslt3),
		   .exdst3(exdst3),
		   .kill_spec3(kill_spec3),
		   .exrslt4(exrslt4),
		   .exdst4(exdst4),
		   .kill_spec4(kill_spec4),
		   .exrslt5(exrslt5),
		   .exdst5(exdst5),
		   .kill_spec5(kill_spec5)
		   );

   rs_alu_ent ent1(                                                       ///DC
		   .clk(clk),                                                     ///DC
		   .reset(reset),		                                          ///DC
		   .busy(busyvec[1]),                                             ///DC
		   .wpc((we1 && (waddr1 == 1)) ? wpc_1 : wpc_2),                  ///DC
		   .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),            ///DC
		   .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),            ///DC
		   .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),      ///DC
		   .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),      ///DC
		   .wimm((we1 && (waddr1 == 1)) ? wimm_1 : wimm_2),               ///DC
		   .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),      ///DC
		   .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),      ///DC
		   .wsrc_a((we1 && (waddr1 == 1)) ? wsrc_a_1 : wsrc_a_2),         ///DC
		   .wsrc_b((we1 && (waddr1 == 1)) ? wsrc_b_1 : wsrc_b_2),         ///DC
		   .walu_op((we1 && (waddr1 == 1)) ? walu_op_1 : walu_op_2),      ///DC
		   .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),   ///DC
		   .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),         ///DC
		   .ex_src1(ex_src1_1),                                           ///DC
		   .ex_src2(ex_src2_1),                                           ///DC
		   .ready(ready_1),                                               ///DC
		   .pc(pc_1),                                                     ///DC
		   .imm(imm_1),                                                   ///DC
		   .rrftag(rrftag_1),                                             ///DC
		   .dstval(dstval_1),                                             ///DC
		   .src_a(src_a_1),                                               ///DC
		   .src_b(src_b_1),                                               ///DC
		   .alu_op(alu_op_1),                                             ///DC
		   .spectag(spectag_1),                                           ///DC
		   .exrslt1(exrslt1),                                             ///DC
		   .exdst1(exdst1),                                               ///DC
		   .kill_spec1(kill_spec1),                                       ///DC
		   .exrslt2(exrslt2),                                             ///DC
		   .exdst2(exdst2),                                               ///DC
		   .kill_spec2(kill_spec2),                                       ///DC
		   .exrslt3(exrslt3),                                             ///DC
		   .exdst3(exdst3),                                               ///DC
		   .kill_spec3(kill_spec3),                                       ///DC
		   .exrslt4(exrslt4),                                             ///DC
		   .exdst4(exdst4),                                               ///DC
		   .kill_spec4(kill_spec4),                                       ///DC
		   .exrslt5(exrslt5),                                             ///DC
		   .exdst5(exdst5),                                               ///DC
		   .kill_spec5(kill_spec5)                                        ///DC
		   );                                                             ///DC

   rs_alu_ent ent2(                                                       ///DC
		   .clk(clk),                                                     ///DC
		   .reset(reset),		                                          ///DC
		   .busy(busyvec[2]),                                             ///DC
		   .wpc((we1 && (waddr1 == 2)) ? wpc_1 : wpc_2),                  ///DC
		   .wsrc1((we1 && (waddr1 == 2)) ? wsrc1_1 : wsrc1_2),            ///DC
		   .wsrc2((we1 && (waddr1 == 2)) ? wsrc2_1 : wsrc2_2),            ///DC
		   .wvalid1((we1 && (waddr1 == 2)) ? wvalid1_1 : wvalid1_2),      ///DC
		   .wvalid2((we1 && (waddr1 == 2)) ? wvalid2_1 : wvalid2_2),      ///DC
		   .wimm((we1 && (waddr1 == 2)) ? wimm_1 : wimm_2),               ///DC
		   .wrrftag((we1 && (waddr1 == 2)) ? wrrftag_1 : wrrftag_2),      ///DC
		   .wdstval((we1 && (waddr1 == 2)) ? wdstval_1 : wdstval_2),      ///DC
		   .wsrc_a((we1 && (waddr1 == 2)) ? wsrc_a_1 : wsrc_a_2),         ///DC
		   .wsrc_b((we1 && (waddr1 == 2)) ? wsrc_b_1 : wsrc_b_2),         ///DC
		   .walu_op((we1 && (waddr1 == 2)) ? walu_op_1 : walu_op_2),      ///DC
		   .wspectag((we1 && (waddr1 == 2)) ? wspectag_1 : wspectag_2),   ///DC
		   .we((we1 && (waddr1 == 2)) || (we2 && (waddr2 == 2))),         ///DC
		   .ex_src1(ex_src1_2),                                           ///DC
		   .ex_src2(ex_src2_2),                                           ///DC
		   .ready(ready_2),                                               ///DC
		   .pc(pc_2),                                                     ///DC
		   .imm(imm_2),                                                   ///DC
		   .rrftag(rrftag_2),                                             ///DC
		   .dstval(dstval_2),                                             ///DC
		   .src_a(src_a_2),                                               ///DC
		   .src_b(src_b_2),                                               ///DC
		   .alu_op(alu_op_2),                                             ///DC
		   .spectag(spectag_2),                                           ///DC
		   .exrslt1(exrslt1),                                             ///DC
		   .exdst1(exdst1),                                               ///DC
		   .kill_spec1(kill_spec1),                                       ///DC
		   .exrslt2(exrslt2),                                             ///DC
		   .exdst2(exdst2),                                               ///DC
		   .kill_spec2(kill_spec2),                                       ///DC
		   .exrslt3(exrslt3),                                             ///DC
		   .exdst3(exdst3),                                               ///DC
		   .kill_spec3(kill_spec3),                                       ///DC
		   .exrslt4(exrslt4),                                             ///DC
		   .exdst4(exdst4),                                               ///DC
		   .kill_spec4(kill_spec4),                                       ///DC
		   .exrslt5(exrslt5),                                             ///DC
		   .exdst5(exdst5),                                               ///DC
		   .kill_spec5(kill_spec5)                                        ///DC
		   );                                                             ///DC

   rs_alu_ent ent3(                                                       ///DC
		   .clk(clk),                                                     ///DC
		   .reset(reset),		                                          ///DC
		   .busy(busyvec[3]),                                             ///DC
		   .wpc((we1 && (waddr1 == 3)) ? wpc_1 : wpc_2),                  ///DC
		   .wsrc1((we1 && (waddr1 == 3)) ? wsrc1_1 : wsrc1_2),            ///DC
		   .wsrc2((we1 && (waddr1 == 3)) ? wsrc2_1 : wsrc2_2),            ///DC
		   .wvalid1((we1 && (waddr1 == 3)) ? wvalid1_1 : wvalid1_2),      ///DC
		   .wvalid2((we1 && (waddr1 == 3)) ? wvalid2_1 : wvalid2_2),      ///DC
		   .wimm((we1 && (waddr1 == 3)) ? wimm_1 : wimm_2),               ///DC
		   .wrrftag((we1 && (waddr1 == 3)) ? wrrftag_1 : wrrftag_2),      ///DC
		   .wdstval((we1 && (waddr1 == 3)) ? wdstval_1 : wdstval_2),      ///DC
		   .wsrc_a((we1 && (waddr1 == 3)) ? wsrc_a_1 : wsrc_a_2),         ///DC
		   .wsrc_b((we1 && (waddr1 == 3)) ? wsrc_b_1 : wsrc_b_2),         ///DC
		   .walu_op((we1 && (waddr1 == 3)) ? walu_op_1 : walu_op_2),      ///DC
		   .wspectag((we1 && (waddr1 == 3)) ? wspectag_1 : wspectag_2),   ///DC
		   .we((we1 && (waddr1 == 3)) || (we2 && (waddr2 == 3))),         ///DC
		   .ex_src1(ex_src1_3),                                           ///DC
		   .ex_src2(ex_src2_3),                                           ///DC
		   .ready(ready_3),                                               ///DC
		   .pc(pc_3),                                                     ///DC
		   .imm(imm_3),                                                   ///DC
		   .rrftag(rrftag_3),                                             ///DC
		   .dstval(dstval_3),                                             ///DC
		   .src_a(src_a_3),                                               ///DC
		   .src_b(src_b_3),                                               ///DC
		   .alu_op(alu_op_3),                                             ///DC
		   .spectag(spectag_3),                                           ///DC
		   .exrslt1(exrslt1),                                             ///DC
		   .exdst1(exdst1),                                               ///DC
		   .kill_spec1(kill_spec1),                                       ///DC
		   .exrslt2(exrslt2),                                             ///DC
		   .exdst2(exdst2),                                               ///DC
		   .kill_spec2(kill_spec2),                                       ///DC
		   .exrslt3(exrslt3),                                             ///DC
		   .exdst3(exdst3),                                               ///DC
		   .kill_spec3(kill_spec3),                                       ///DC
		   .exrslt4(exrslt4),                                             ///DC
		   .exdst4(exdst4),                                               ///DC
		   .kill_spec4(kill_spec4),                                       ///DC
		   .exrslt5(exrslt5),                                             ///DC
		   .exdst5(exdst5),                                               ///DC
		   .kill_spec5(kill_spec5)                                        ///DC
		   );                                                             ///DC

   rs_alu_ent ent4(                                                      ///DC
		   .clk(clk),                                                    ///DC
		   .reset(reset),		   		                                 ///DC
		   .busy(busyvec[4]),                                            ///DC
		   .wpc((we1 && (waddr1 == 4)) ? wpc_1 : wpc_2),                 ///DC
		   .wsrc1((we1 && (waddr1 == 4)) ? wsrc1_1 : wsrc1_2),           ///DC
		   .wsrc2((we1 && (waddr1 == 4)) ? wsrc2_1 : wsrc2_2),           ///DC
		   .wvalid1((we1 && (waddr1 == 4)) ? wvalid1_1 : wvalid1_2),     ///DC
		   .wvalid2((we1 && (waddr1 == 4)) ? wvalid2_1 : wvalid2_2),     ///DC
		   .wimm((we1 && (waddr1 == 4)) ? wimm_1 : wimm_2),              ///DC
		   .wrrftag((we1 && (waddr1 == 4)) ? wrrftag_1 : wrrftag_2),     ///DC
		   .wdstval((we1 && (waddr1 == 4)) ? wdstval_1 : wdstval_2),     ///DC
		   .wsrc_a((we1 && (waddr1 == 4)) ? wsrc_a_1 : wsrc_a_2),        ///DC
		   .wsrc_b((we1 && (waddr1 == 4)) ? wsrc_b_1 : wsrc_b_2),        ///DC
		   .walu_op((we1 && (waddr1 == 4)) ? walu_op_1 : walu_op_2),     ///DC
		   .wspectag((we1 && (waddr1 == 4)) ? wspectag_1 : wspectag_2),  ///DC
		   .we((we1 && (waddr1 == 4)) || (we2 && (waddr2 == 4))),        ///DC
		   .ex_src1(ex_src1_4),                                          ///DC
		   .ex_src2(ex_src2_4),                                          ///DC
		   .ready(ready_4),                                              ///DC
		   .pc(pc_4),                                                    ///DC
		   .imm(imm_4),                                                  ///DC
		   .rrftag(rrftag_4),                                            ///DC
		   .dstval(dstval_4),                                            ///DC
		   .src_a(src_a_4),                                              ///DC
		   .src_b(src_b_4),                                              ///DC
		   .alu_op(alu_op_4),                                            ///DC
		   .spectag(spectag_4),                                          ///DC
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

   rs_alu_ent ent5(                                                        ///DC
		   .clk(clk),                                                      ///DC
		   .reset(reset),		                                           ///DC
		   .busy(busyvec[5]),                                              ///DC
		   .wpc((we1 && (waddr1 == 5)) ? wpc_1 : wpc_2),                   ///DC
		   .wsrc1((we1 && (waddr1 == 5)) ? wsrc1_1 : wsrc1_2),             ///DC
		   .wsrc2((we1 && (waddr1 == 5)) ? wsrc2_1 : wsrc2_2),             ///DC
		   .wvalid1((we1 && (waddr1 == 5)) ? wvalid1_1 : wvalid1_2),       ///DC
		   .wvalid2((we1 && (waddr1 == 5)) ? wvalid2_1 : wvalid2_2),       ///DC
		   .wimm((we1 && (waddr1 == 5)) ? wimm_1 : wimm_2),                ///DC
		   .wrrftag((we1 && (waddr1 == 5)) ? wrrftag_1 : wrrftag_2),       ///DC
		   .wdstval((we1 && (waddr1 == 5)) ? wdstval_1 : wdstval_2),       ///DC
		   .wsrc_a((we1 && (waddr1 == 5)) ? wsrc_a_1 : wsrc_a_2),          ///DC
		   .wsrc_b((we1 && (waddr1 == 5)) ? wsrc_b_1 : wsrc_b_2),          ///DC
		   .walu_op((we1 && (waddr1 == 5)) ? walu_op_1 : walu_op_2),       ///DC
		   .wspectag((we1 && (waddr1 == 5)) ? wspectag_1 : wspectag_2),    ///DC
		   .we((we1 && (waddr1 == 5)) || (we2 && (waddr2 == 5))),          ///DC
		   .ex_src1(ex_src1_5),                                            ///DC
		   .ex_src2(ex_src2_5),                                            ///DC
		   .ready(ready_5),                                                ///DC
		   .pc(pc_5),                                                      ///DC
		   .imm(imm_5),                                                    ///DC
		   .rrftag(rrftag_5),                                              ///DC
		   .dstval(dstval_5),                                              ///DC
		   .src_a(src_a_5),                                                ///DC
		   .src_b(src_b_5),                                                ///DC
		   .alu_op(alu_op_5),                                              ///DC
		   .spectag(spectag_5),                                            ///DC
		   .exrslt1(exrslt1),                                              ///DC
		   .exdst1(exdst1),                                                ///DC
		   .kill_spec1(kill_spec1),                                        ///DC
		   .exrslt2(exrslt2),                                              ///DC
		   .exdst2(exdst2),                                                ///DC
		   .kill_spec2(kill_spec2),                                        ///DC
		   .exrslt3(exrslt3),                                              ///DC
		   .exdst3(exdst3),                                                ///DC
		   .kill_spec3(kill_spec3),                                        ///DC
		   .exrslt4(exrslt4),                                              ///DC
		   .exdst4(exdst4),                                                ///DC
		   .kill_spec4(kill_spec4),                                        ///DC
		   .exrslt5(exrslt5),                                              ///DC
		   .exdst5(exdst5),                                                ///DC
		   .kill_spec5(kill_spec5)                                         ///DC
		   );                                                              ///DC

   rs_alu_ent ent6(                                                        ///DC
		   .clk(clk),                                                      ///DC
		   .reset(reset),		                                           ///DC
		   .busy(busyvec[6]),                                              ///DC
		   .wpc((we1 && (waddr1 == 6)) ? wpc_1 : wpc_2),                   ///DC
		   .wsrc1((we1 && (waddr1 == 6)) ? wsrc1_1 : wsrc1_2),             ///DC
		   .wsrc2((we1 && (waddr1 == 6)) ? wsrc2_1 : wsrc2_2),             ///DC
		   .wvalid1((we1 && (waddr1 == 6)) ? wvalid1_1 : wvalid1_2),       ///DC
		   .wvalid2((we1 && (waddr1 == 6)) ? wvalid2_1 : wvalid2_2),       ///DC
		   .wimm((we1 && (waddr1 == 6)) ? wimm_1 : wimm_2),                ///DC
		   .wrrftag((we1 && (waddr1 == 6)) ? wrrftag_1 : wrrftag_2),       ///DC
		   .wdstval((we1 && (waddr1 == 6)) ? wdstval_1 : wdstval_2),       ///DC
		   .wsrc_a((we1 && (waddr1 == 6)) ? wsrc_a_1 : wsrc_a_2),          ///DC
		   .wsrc_b((we1 && (waddr1 == 6)) ? wsrc_b_1 : wsrc_b_2),          ///DC
		   .walu_op((we1 && (waddr1 == 6)) ? walu_op_1 : walu_op_2),       ///DC
		   .wspectag((we1 && (waddr1 == 6)) ? wspectag_1 : wspectag_2),    ///DC
		   .we((we1 && (waddr1 == 6)) || (we2 && (waddr2 == 6))),          ///DC
		   .ex_src1(ex_src1_6),                                            ///DC
		   .ex_src2(ex_src2_6),                                            ///DC
		   .ready(ready_6),                                                ///DC
		   .pc(pc_6),                                                      ///DC
		   .imm(imm_6),                                                    ///DC
		   .rrftag(rrftag_6),                                              ///DC
		   .dstval(dstval_6),                                              ///DC
		   .src_a(src_a_6),                                                ///DC
		   .src_b(src_b_6),                                                ///DC
		   .alu_op(alu_op_6),                                              ///DC
		   .spectag(spectag_6),                                            ///DC
		   .exrslt1(exrslt1),                                              ///DC
		   .exdst1(exdst1),                                                ///DC
		   .kill_spec1(kill_spec1),                                        ///DC
		   .exrslt2(exrslt2),                                              ///DC
		   .exdst2(exdst2),                                                ///DC
		   .kill_spec2(kill_spec2),                                        ///DC
		   .exrslt3(exrslt3),                                              ///DC
		   .exdst3(exdst3),                                                ///DC
		   .kill_spec3(kill_spec3),                                        ///DC
		   .exrslt4(exrslt4),                                              ///DC
		   .exdst4(exdst4),                                                ///DC
		   .kill_spec4(kill_spec4),                                        ///DC
		   .exrslt5(exrslt5),                                              ///DC
		   .exdst5(exdst5),                                                ///DC
		   .kill_spec5(kill_spec5)                                         ///DC
		   );                                                              ///DC

   rs_alu_ent ent7(                                                     ///DC
		   .clk(clk),                                                   ///DC
		   .reset(reset),		                                        ///DC
		   .busy(busyvec[7]),                                           ///DC
		   .wpc((we1 && (waddr1 == 7)) ? wpc_1 : wpc_2),                ///DC
		   .wsrc1((we1 && (waddr1 == 7)) ? wsrc1_1 : wsrc1_2),          ///DC
		   .wsrc2((we1 && (waddr1 == 7)) ? wsrc2_1 : wsrc2_2),          ///DC
		   .wvalid1((we1 && (waddr1 == 7)) ? wvalid1_1 : wvalid1_2),    ///DC
		   .wvalid2((we1 && (waddr1 == 7)) ? wvalid2_1 : wvalid2_2),    ///DC
		   .wimm((we1 && (waddr1 == 7)) ? wimm_1 : wimm_2),             ///DC
		   .wrrftag((we1 && (waddr1 == 7)) ? wrrftag_1 : wrrftag_2),    ///DC
		   .wdstval((we1 && (waddr1 == 7)) ? wdstval_1 : wdstval_2),    ///DC
		   .wsrc_a((we1 && (waddr1 == 7)) ? wsrc_a_1 : wsrc_a_2),       ///DC
		   .wsrc_b((we1 && (waddr1 == 7)) ? wsrc_b_1 : wsrc_b_2),       ///DC
		   .walu_op((we1 && (waddr1 == 7)) ? walu_op_1 : walu_op_2),    ///DC
		   .wspectag((we1 && (waddr1 == 7)) ? wspectag_1 : wspectag_2), ///DC
		   .we((we1 && (waddr1 == 7)) || (we2 && (waddr2 == 7))),       ///DC
		   .ex_src1(ex_src1_7),                                         ///DC
		   .ex_src2(ex_src2_7),                                         ///DC
		   .ready(ready_7),                                             ///DC
		   .pc(pc_7),                                                   ///DC
		   .imm(imm_7),                                                 ///DC
		   .rrftag(rrftag_7),                                           ///DC
		   .dstval(dstval_7),                                           ///DC
		   .src_a(src_a_7),                                             ///DC
		   .src_b(src_b_7),                                             ///DC
		   .alu_op(alu_op_7),                                           ///DC
		   .spectag(spectag_7),                                         ///DC
		   .exrslt1(exrslt1),                                           ///DC
		   .exdst1(exdst1),                                             ///DC
		   .kill_spec1(kill_spec1),                                     ///DC
		   .exrslt2(exrslt2),                                           ///DC
		   .exdst2(exdst2),                                             ///DC
		   .kill_spec2(kill_spec2),                                     ///DC
		   .exrslt3(exrslt3),                                           ///DC
		   .exdst3(exdst3),                                             ///DC
		   .kill_spec3(kill_spec3),                                     ///DC
		   .exrslt4(exrslt4),                                           ///DC
		   .exdst4(exdst4),                                             ///DC
		   .kill_spec4(kill_spec4),                                     ///DC
		   .exrslt5(exrslt5),                                           ///DC
		   .exdst5(exdst5),                                             ///DC
		   .kill_spec5(kill_spec5)                                      ///DC
		   );                                                           ///DC
   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 :
		    (issueaddr == 1) ? ex_src1_1 :              ///DC
		    (issueaddr == 2) ? ex_src1_2 :              ///DC
		    (issueaddr == 3) ? ex_src1_3 :              ///DC
		    (issueaddr == 4) ? ex_src1_4 :              ///DC
		    (issueaddr == 5) ? ex_src1_5 :              ///DC
		    (issueaddr == 6) ? ex_src1_6 : ex_src1_7;   ///DC

   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 :
		    (issueaddr == 1) ? ex_src2_1 :              ///DC
		    (issueaddr == 2) ? ex_src2_2 :              ///DC
		    (issueaddr == 3) ? ex_src2_3 :              ///DC
		    (issueaddr == 4) ? ex_src2_4 :              ///DC
		    (issueaddr == 5) ? ex_src2_5 :              ///DC
		    (issueaddr == 6) ? ex_src2_6 : ex_src2_7;   ///DC

   assign pc = (issueaddr == 0) ? pc_0 :
	       (issueaddr == 1) ? pc_1 :                    ///DC
	       (issueaddr == 2) ? pc_2 :                    ///DC
	       (issueaddr == 3) ? pc_3 :                    ///DC
	       (issueaddr == 4) ? pc_4 :                    ///DC
	       (issueaddr == 5) ? pc_5 :                    ///DC
	       (issueaddr == 6) ? pc_6 : pc_7;              ///DC
   
   assign imm = (issueaddr == 0) ? imm_0 :
		(issueaddr == 1) ? imm_1 :                      ///DC
		(issueaddr == 2) ? imm_2 :                      ///DC
		(issueaddr == 3) ? imm_3 :                      ///DC
		(issueaddr == 4) ? imm_4 :                      ///DC
		(issueaddr == 5) ? imm_5 :                      ///DC
		(issueaddr == 6) ? imm_6 : imm_7;               ///DC
   
   assign rrftag = (issueaddr == 0) ? rrftag_0 :
		   (issueaddr == 1) ? rrftag_1 :                 ///DC
		   (issueaddr == 2) ? rrftag_2 :                 ///DC
		   (issueaddr == 3) ? rrftag_3 :                 ///DC
		   (issueaddr == 4) ? rrftag_4 :                 ///DC
		   (issueaddr == 5) ? rrftag_5 :                 ///DC
		   (issueaddr == 6) ? rrftag_6 : rrftag_7;       ///DC
   
   assign dstval = (issueaddr == 0) ? dstval_0 :
		   (issueaddr == 1) ? dstval_1 :                  ///DC
		   (issueaddr == 2) ? dstval_2 :                  ///DC
		   (issueaddr == 3) ? dstval_3 :                  ///DC
		   (issueaddr == 4) ? dstval_4 :                  ///DC
		   (issueaddr == 5) ? dstval_5 :                  ///DC
		   (issueaddr == 6) ? dstval_6 : dstval_7;        ///DC
   
   assign src_a = (issueaddr == 0) ? src_a_0 :
		  (issueaddr == 1) ? src_a_1 :                    ///DC
		  (issueaddr == 2) ? src_a_2 :                    ///DC
		  (issueaddr == 3) ? src_a_3 :                    ///DC
		  (issueaddr == 4) ? src_a_4 :                    ///DC
		  (issueaddr == 5) ? src_a_5 :                    ///DC
		  (issueaddr == 6) ? src_a_6 : src_a_7;           ///DC
   
   assign src_b = (issueaddr == 0) ? src_b_0 :
		  (issueaddr == 1) ? src_b_1 :                    ///DC
		  (issueaddr == 2) ? src_b_2 :                    ///DC
		  (issueaddr == 3) ? src_b_3 :                    ///DC
		  (issueaddr == 4) ? src_b_4 :                    ///DC
		  (issueaddr == 5) ? src_b_5 :                    ///DC
		  (issueaddr == 6) ? src_b_6 : src_b_7;           ///DC
   
   assign alu_op = (issueaddr == 0) ? alu_op_0 :
		   (issueaddr == 1) ? alu_op_1 :                  ///DC
		   (issueaddr == 2) ? alu_op_2 :                  ///DC
		   (issueaddr == 3) ? alu_op_3 :                  ///DC
		   (issueaddr == 4) ? alu_op_4 :                  ///DC
		   (issueaddr == 5) ? alu_op_5 :                  ///DC
		   (issueaddr == 6) ? alu_op_6 : alu_op_7;        ///DC
   
   assign spectag = (issueaddr == 0) ? spectag_0 :
		    (issueaddr == 1) ? spectag_1 :                ///DC
		    (issueaddr == 2) ? spectag_2 :                ///DC
		    (issueaddr == 3) ? spectag_3 :                ///DC
		    (issueaddr == 4) ? spectag_4 :                ///DC
		    (issueaddr == 5) ? spectag_5 :                ///DC
		    (issueaddr == 6) ? spectag_6 : spectag_7;     ///DC

   
endmodule // rs_alu
`default_nettype wire
