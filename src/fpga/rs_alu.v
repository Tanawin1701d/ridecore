`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module rs_alu_ent   ///MD RSV_ALU
  (
   //Memory
   input wire 			     clk,                                    ///CTRL_HC RSV_ALU
   input wire 			     reset,                                  ///CTRL_HC RSV_ALU
   input wire 			     busy,                                   ///CTRL_HC RSV_ALU
   input wire [`ADDR_LEN-1:0] 	     wpc,                            ///DATA_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     wsrc1,                          ///DATA_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     wsrc2,                          ///DATA_HC RSV_ALU
   input wire 			     wvalid1,                                ///CTRL_HC RSV_ALU
   input wire 			     wvalid2,                                ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     wimm,                           ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 	     wrrftag,                        ///CTRL_HC RSV_ALU
   input wire 			     wdstval,                                ///CTRL_HC RSV_ALU
   input wire [`SRC_A_SEL_WIDTH-1:0] wsrc_a,                         ///DATA_HC RSV_ALU
   input wire [`SRC_B_SEL_WIDTH-1:0] wsrc_b,                         ///DATA_HC RSV_ALU
   input wire [`ALU_OP_WIDTH-1:0]    walu_op,                        ///DATA_HC RSV_ALU
   input wire [`SPECTAG_LEN-1:0]     wspectag,                       ///CTRL_HC RSV_ALU
   input wire 			     we,                                     ///CTRL_HC RSV_ALU
   output wire [`DATA_LEN-1:0] 	     ex_src1,                        ///DATA_HC RSV_ALU
   output wire [`DATA_LEN-1:0] 	     ex_src2,                        ///DATA_HC RSV_ALU
   output wire 			     ready /* verilator public */,           ///CTRL_HC RSV_ALU
   output reg [`ADDR_LEN-1:0] 	     pc /* verilator public */,      ///DATA_HC RSV_ALU
   output reg [`DATA_LEN-1:0] 	     imm /* verilator public */,     ///DATA_HC RSV_ALU
   output reg [`RRF_SEL-1:0] 	     rrftag /* verilator public */,  ///CTRL_HC RSV_ALU
   output reg 			             dstval /* verilator public */,  ///CTRL_HC RSV_ALU
   output reg [`SRC_A_SEL_WIDTH-1:0] src_a /* verilator public */,   ///DATA_HC RSV_ALU
   output reg [`SRC_B_SEL_WIDTH-1:0] src_b /* verilator public */,   ///DATA_HC RSV_ALU
   output reg [`ALU_OP_WIDTH-1:0]    alu_op /* verilator public */,  ///DATA_HC RSV_ALU
   output reg [`SPECTAG_LEN-1:0]     spectag /* verilator public */, ///CTRL_HC RSV_ALU
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	     exrslt1,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 	     exdst1,    ///CTRL_HC RSV_ALU
   input wire 			     kill_spec1,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     exrslt2,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 	     exdst2,    ///CTRL_HC RSV_ALU
   input wire 			     kill_spec2,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     exrslt3,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 	     exdst3,    ///CTRL_HC RSV_ALU
   input wire 			     kill_spec3,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     exrslt4,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 	     exdst4,    ///CTRL_HC RSV_ALU
   input wire 			     kill_spec4,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 	     exrslt5,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 	     exdst5,    ///CTRL_HC RSV_ALU
   input wire 			     kill_spec5         ///CTRL_HC RSV_ALU
   );

   reg [`DATA_LEN-1:0] 		     src1 /* verilator public */;   ///DATA_HWD RSV_ALU
   reg [`DATA_LEN-1:0] 		     src2 /* verilator public */;   ///DATA_HWD RSV_ALU
   reg 				     valid1 /* verilator public */;         ///CTRL_HWD RSV_ALU
   reg 				     valid2 /* verilator public */;         ///CTRL_HWD RSV_ALU

   wire [`DATA_LEN-1:0] 	     nextsrc1;   ///DATA_HWD RSV_ALU
   wire [`DATA_LEN-1:0] 	     nextsrc2;   ///DATA_HWD RSV_ALU
   wire 			     nextvalid1;         ///CTRL_HWD RSV_ALU
   wire 			     nextvalid2;         ///CTRL_HWD RSV_ALU
   
   assign ready = busy & valid1 & valid2;    ///CTRL_CL RSV_ALU
   assign ex_src1 = ~valid1 & nextvalid1 ?   ///DATA_CL RSV_ALU
		    nextsrc1 : src1;                 ///DATA_CL RSV_ALU
   assign ex_src2 = ~valid2 & nextvalid2 ?   ///DATA_CL RSV_ALU
		    nextsrc2 : src2;                 ///DATA_CL RSV_ALU
   
   always @ (posedge clk) begin ///CTRL_CL RSV_ALU
      if (reset) begin          ///CTRL_CL RSV_ALU
	 pc <= 0;                   ///DATA_DT RSV_ALU
	 imm <= 0;                  ///DATA_DT RSV_ALU
	 rrftag <= 0;               ///CTRL_DT RSV_ALU
	 dstval <= 0;               ///CTRL_DT RSV_ALU
	 src_a <= 0;                ///DATA_DT RSV_ALU
	 src_b <= 0;                ///DATA_DT RSV_ALU
	 alu_op <= 0;               ///DATA_DT RSV_ALU
	 spectag <= 0;              ///CTRL_DT RSV_ALU

	 src1 <= 0;                 ///DATA_DT RSV_ALU
	 src2 <= 0;                 ///DATA_DT RSV_ALU
	 valid1 <= 0;               ///CTRL_DT RSV_ALU
	 valid2 <= 0;               ///CTRL_DT RSV_ALU
      end else if (we) begin    ///CTRL_CL RSV_ALU
	 pc <= wpc;                 ///DATA_DT RSV_ALU
	 imm <= wimm;               ///DATA_DT RSV_ALU
	 rrftag <= wrrftag;         ///CTRL_DT RSV_ALU
	 dstval <= wdstval;         ///CTRL_DT RSV_ALU
	 src_a <= wsrc_a;           ///DATA_DT RSV_ALU
	 src_b <= wsrc_b;           ///DATA_DT RSV_ALU
	 alu_op <= walu_op;         ///DATA_DT RSV_ALU
	 spectag <= wspectag;       ///CTRL_DT RSV_ALU

	 src1 <= wsrc1;       ///DATA_DT RSV_ALU
	 src2 <= wsrc2;       ///DATA_DT RSV_ALU
	 valid1 <= wvalid1;   ///CTRL_DT RSV_ALU
	 valid2 <= wvalid2;   ///CTRL_DT RSV_ALU
      end else begin // if (we)
	 src1 <= nextsrc1;       ///DATA_DT RSV_ALU
	 src2 <= nextsrc2;       ///DATA_DT RSV_ALU
	 valid1 <= nextvalid1;   ///CTRL_DT RSV_ALU
	 valid2 <= nextvalid2;   ///CTRL_DT RSV_ALU
      end
   end
   
   src_manager srcmng1(                  ///MD RSV_ALU
		       .opr(src1),               ///DATA_HC RSV_ALU
		       .opr_rdy(valid1),         ///CTRL_HC RSV_ALU
		       .exrslt1(exrslt1),        ///DATA_HC RSV_ALU
		       .exdst1(exdst1),          ///CTRL_HC RSV_ALU
		       .kill_spec1(kill_spec1),  ///CTRL_HC RSV_ALU
		       .exrslt2(exrslt2),        ///DATA_HC RSV_ALU
		       .exdst2(exdst2),          ///CTRL_HC RSV_ALU
		       .kill_spec2(kill_spec2),  ///CTRL_HC RSV_ALU
		       .exrslt3(exrslt3),        ///DATA_HC RSV_ALU
		       .exdst3(exdst3),          ///CTRL_HC RSV_ALU
		       .kill_spec3(kill_spec3),  ///CTRL_HC RSV_ALU
		       .exrslt4(exrslt4),        ///DATA_HC RSV_ALU
		       .exdst4(exdst4),          ///CTRL_HC RSV_ALU
		       .kill_spec4(kill_spec4),  ///CTRL_HC RSV_ALU
		       .exrslt5(exrslt5),        ///DATA_HC RSV_ALU
		       .exdst5(exdst5),          ///CTRL_HC RSV_ALU
		       .kill_spec5(kill_spec5),  ///CTRL_HC RSV_ALU
		       .src(nextsrc1),           ///DATA_HC RSV_ALU
		       .resolved(nextvalid1)     ///CTRL_HC RSV_ALU
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


module rs_alu   ///MD RSV_ALU
  (
   //System
   input wire 				       clk,                                    ///CTRL_HC RSV_ALU
   input wire 				       reset,                                  ///CTRL_HC RSV_ALU
   output reg [`ALU_ENT_NUM-1:0] 	       busyvec /* verilator public */, ///CTRL_HC RSV_ALU
   input wire 				       prmiss,                                 ///CTRL_HC RSV_ALU
   input wire 				       prsuccess,                              ///CTRL_HC RSV_ALU
   input wire [`SPECTAG_LEN-1:0] 	       prtag,                          ///CTRL_HC RSV_ALU
   input wire [`SPECTAG_LEN-1:0] 	       specfixtag,                     ///CTRL_HC RSV_ALU
   output wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect,                   ///CTRL_HC RSV_ALU
   input wire 				       nextrrfcyc,                             ///CTRL_HC RSV_ALU
   //WriteSignal
   input wire 				       clearbusy, //Issue                      ///CTRL_HC RSV_ALU
   input wire [`ALU_ENT_SEL-1:0] 	       issueaddr,                      ///CTRL_HC RSV_ALU
   input wire 				       we1, //alloc1                           ///CTRL_HC RSV_ALU
   input wire 				       we2, //alloc2                           ///CTRL_HC RSV_ALU
   input wire [`ALU_ENT_SEL-1:0] 	       waddr1, //allocent1             ///CTRL_HC RSV_ALU
   input wire [`ALU_ENT_SEL-1:0] 	       waddr2, //allocent2             ///CTRL_HC RSV_ALU
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 		       wpc_1,                          ///DATA_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       wsrc1_1,                        ///DATA_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       wsrc2_1,                        ///DATA_HC RSV_ALU
   input wire 				       wvalid1_1,                              ///CTRL_HC RSV_ALU
   input wire 				       wvalid2_1,                              ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       wimm_1,                         ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 		       wrrftag_1,                      ///CTRL_HC RSV_ALU
   input wire 				       wdstval_1,                              ///CTRL_HC RSV_ALU
   input wire [`SRC_A_SEL_WIDTH-1:0] 	       wsrc_a_1,                   ///DATA_HC RSV_ALU
   input wire [`SRC_B_SEL_WIDTH-1:0] 	       wsrc_b_1,                   ///DATA_HC RSV_ALU
   input wire [`ALU_OP_WIDTH-1:0] 	       walu_op_1,                      ///DATA_HC RSV_ALU
   input wire [`SPECTAG_LEN-1:0] 	       wspectag_1,                     ///CTRL_HC RSV_ALU
   input wire 				       wspecbit_1,                             ///CTRL_HC RSV_ALU
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
   output wire [`DATA_LEN-1:0] 		       ex_src1,   ///DATA_HC RSV_ALU
   output wire [`DATA_LEN-1:0] 		       ex_src2,   ///DATA_HC RSV_ALU
   output wire [`ALU_ENT_NUM-1:0] 	       ready,     ///CTRL_HC RSV_ALU
   output wire [`ADDR_LEN-1:0] 		       pc,        ///DATA_HC RSV_ALU
   output wire [`DATA_LEN-1:0] 		       imm,       ///DATA_HC RSV_ALU
   output wire [`RRF_SEL-1:0] 		       rrftag,    ///CTRL_HC RSV_ALU
   output wire 				       dstval,            ///CTRL_HC RSV_ALU
   output wire [`SRC_A_SEL_WIDTH-1:0] 	       src_a, ///DATA_HC RSV_ALU
   output wire [`SRC_B_SEL_WIDTH-1:0] 	       src_b, ///DATA_HC RSV_ALU
   output wire [`ALU_OP_WIDTH-1:0] 	       alu_op,    ///DATA_HC RSV_ALU
   output wire [`SPECTAG_LEN-1:0] 	       spectag,   ///CTRL_HC RSV_ALU
   output wire 				       specbit,           ///CTRL_HC RSV_ALU
  
   //EXRSLT
   input wire [`DATA_LEN-1:0] 		       exrslt1,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 		       exdst1,    ///CTRL_HC RSV_ALU
   input wire 				       kill_spec1,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       exrslt2,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 		       exdst2,    ///CTRL_HC RSV_ALU
   input wire 				       kill_spec2,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       exrslt3,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 		       exdst3,    ///CTRL_HC RSV_ALU
   input wire 				       kill_spec3,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       exrslt4,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 		       exdst4,    ///CTRL_HC RSV_ALU
   input wire 				       kill_spec4,        ///CTRL_HC RSV_ALU
   input wire [`DATA_LEN-1:0] 		       exrslt5,   ///DATA_HC RSV_ALU
   input wire [`RRF_SEL-1:0] 		       exdst5,    ///CTRL_HC RSV_ALU
   input wire 				       kill_spec5         ///CTRL_HC RSV_ALU
   );
   
   //_0
   wire [`DATA_LEN-1:0] 	      ex_src1_0;     ///DATA_HWD RSV_ALU
   wire [`DATA_LEN-1:0] 	      ex_src2_0;     ///DATA_HWD RSV_ALU
   wire 			      ready_0;               ///CTRL_HWD RSV_ALU
   wire [`ADDR_LEN-1:0] 	      pc_0;          ///DATA_HWD RSV_ALU
   wire [`DATA_LEN-1:0] 	      imm_0;         ///DATA_HWD RSV_ALU
   wire [`RRF_SEL-1:0] 		      rrftag_0;      ///CTRL_HWD RSV_ALU
   wire 			      dstval_0;              ///CTRL_HWD RSV_ALU
   wire [`SRC_A_SEL_WIDTH-1:0] 	      src_a_0;   ///DATA_HWD RSV_ALU
   wire [`SRC_B_SEL_WIDTH-1:0] 	      src_b_0;   ///DATA_HWD RSV_ALU
   wire [`ALU_OP_WIDTH-1:0] 	      alu_op_0;  ///DATA_HWD RSV_ALU
   wire [`SPECTAG_LEN-1:0] 	      spectag_0;     ///CTRL_HWD RSV_ALU
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

   reg [`ALU_ENT_NUM-1:0] 	      specbitvec /* verilator public */;   ///CTRL_HWD RSV_ALU
   reg [`ALU_ENT_NUM-1:0] 	      sortbit /* verilator public */;   ///CTRL_HWD RSV_ALU
   
   
   wire [`ALU_ENT_NUM-1:0] 	      inv_vector =   ///CTRL_CL RSV_ALU
				      {(spectag_7 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_6 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_5 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_4 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_3 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_2 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,   ///CTRL_CL RSV_ALU
				       (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};   ///CTRL_CL RSV_ALU

   wire [`ALU_ENT_NUM-1:0] 	      inv_vector_spec =   ///CTRL_CL RSV_ALU
				      {(spectag_7 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_6 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_5 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_4 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_3 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_2 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_1 == prtag) ? 1'b0 : 1'b1,   ///CTRL_CL RSV_ALU
				       (spectag_0 == prtag) ? 1'b0 : 1'b1};   ///CTRL_CL RSV_ALU

   wire [`ALU_ENT_NUM-1:0] 	      specbitvec_next =   ///CTRL_CL RSV_ALU
				      (inv_vector_spec & specbitvec);   ///CTRL_CL RSV_ALU
   /* |
    (we1 & wspecbit_1 ? (`ALU_ENT_SEL'b1 << waddr1) : 0) |
    (we2 & wspecbit_2 ? (`ALU_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? specbitvec_next[issueaddr] : specbitvec[issueaddr];   ///CTRL_CL RSV_ALU
   
   /*   
    assign specbit = prsuccess ? 
    ((inv_vector & busyvec) |
    (we1 & wspecbit_1 ? (`ALU_ENT_SEL'b1 << waddr1) : 0) |
    (we2 & wspecbit_2 ? (`ALU_ENT_SEL'b1 << waddr2) : 0)) : 
    specbitvec[issueaddr];
    */
   
   assign ready = {ready_7, ready_6, ready_5, ready_4,   ///CTRL_CL RSV_ALU
		   ready_3, ready_2, ready_1, ready_0};   ///CTRL_CL RSV_ALU

   assign histvect = {   ///CTRL_CL RSV_ALU
		      {~ready_7, sortbit[7], rrftag_7},   ///CTRL_CL RSV_ALU
		      {~ready_6, sortbit[6], rrftag_6},   ///CTRL_CL RSV_ALU
		      {~ready_5, sortbit[5], rrftag_5},   ///CTRL_CL RSV_ALU
		      {~ready_4, sortbit[4], rrftag_4},   ///CTRL_CL RSV_ALU
		      {~ready_3, sortbit[3], rrftag_3},   ///CTRL_CL RSV_ALU
		      {~ready_2, sortbit[2], rrftag_2},   ///CTRL_CL RSV_ALU
		      {~ready_1, sortbit[1], rrftag_1},   ///CTRL_CL RSV_ALU
		      {~ready_0, sortbit[0], rrftag_0}   ///CTRL_CL RSV_ALU
		      };

   always @ (posedge clk) begin                                           ///CTRL_CL RSV_ALU
      if (reset) begin                                                    ///CTRL_CL RSV_ALU
	 sortbit <= `ALU_ENT_NUM'b1;                                          ///CTRL_DT RSV_ALU
      end else if (nextrrfcyc) begin                                      ///CTRL_CL RSV_ALU
	 sortbit <= (we1 ? (`ALU_ENT_NUM'b1 << waddr1) : `ALU_ENT_NUM'b0) |   ///CTRL_CL RSV_ALU
		    (we2 ? (`ALU_ENT_NUM'b1 << waddr2) : `ALU_ENT_NUM'b0);        ///CTRL_CL RSV_ALU
      end else begin
	 if (we1) begin                ///CTRL_CL RSV_ALU
	    sortbit[waddr1] <= 1'b1;   ///CTRL_DT RSV_ALU
	 end
	 if (we2) begin                ///CTRL_CL RSV_ALU
	    sortbit[waddr2] <= 1'b1;   ///CTRL_DT RSV_ALU
	 end
      end
   end
   
   always @ (posedge clk) begin   ///CTRL_CL RSV_ALU
      if (reset) begin            ///CTRL_CL RSV_ALU
	 busyvec <= 0;                ///CTRL_DT RSV_ALU
	 specbitvec <= 0;             ///CTRL_DT RSV_ALU
      end else begin
	 if (prmiss) begin                     ///CTRL_CL RSV_ALU
	    busyvec <= inv_vector & busyvec;   ///CTRL_CL RSV_ALU
	    specbitvec <= 0;                   ///CTRL_DT RSV_ALU
	 end else if (prsuccess) begin         ///CTRL_CL RSV_ALU
	    /*
	     specbitvec <= (inv_vector & busyvec) |
	     (we1 & wspecbit_1 ? (`ALU_ENT_SEL'b1 << waddr1) : 0) |
	     (we2 & wspecbit_2 ? (`ALU_ENT_SEL'b1 << waddr2) : 0);
	     */
	    specbitvec <= specbitvec_next;   ///CTRL_DT RSV_ALU
	    /*
	     if (we1) begin
	     busyvec[waddr1] <= 1'b1;
	    end
	     if (we2) begin
	     busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin             ///CTRL_CL RSV_ALU
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_ALU
	    end
	 end else begin
	    if (we1) begin                         ///CTRL_CL RSV_ALU
	       busyvec[waddr1] <= 1'b1;            ///CTRL_DT RSV_ALU
	       specbitvec[waddr1] <= wspecbit_1;   ///CTRL_DT RSV_ALU
	    end
	    if (we2) begin                         ///CTRL_CL RSV_ALU
	       busyvec[waddr2] <= 1'b1;            ///CTRL_DT RSV_ALU
	       specbitvec[waddr2] <= wspecbit_2;   ///CTRL_DT RSV_ALU
	    end
	    if (clearbusy) begin                   ///CTRL_CL RSV_ALU
	       busyvec[issueaddr] <= 1'b0;         ///CTRL_DT RSV_ALU
	    end
	 end
      end
   end

   rs_alu_ent ent0(                                                        ///MD RSV_ALU
		   .clk(clk),                                                      ///CTRL_HC RSV_ALU
		   .reset(reset),                                                  ///CTRL_HC RSV_ALU
		   .busy(busyvec[0]),                                              ///CTRL_HC RSV_ALU
		   .wpc((we1 && (waddr1 == 0)) ? wpc_1 : wpc_2),                   ///DATA_HC+DATA_CL RSV_ALU
		   .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),             ///DATA_HC+DATA_CL RSV_ALU
		   .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),             ///DATA_HC+DATA_CL RSV_ALU
		   .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),       ///CTRL_HC+CTRL_CL RSV_ALU
		   .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),       ///CTRL_HC+CTRL_CL RSV_ALU
		   .wimm((we1 && (waddr1 == 0)) ? wimm_1 : wimm_2),                ///DATA_HC+DATA_CL RSV_ALU
		   .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),       ///CTRL_HC+CTRL_CL RSV_ALU
		   .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),       ///CTRL_HC+CTRL_CL RSV_ALU
		   .wsrc_a((we1 && (waddr1 == 0)) ? wsrc_a_1 : wsrc_a_2),          ///DATA_HC+DATA_CL RSV_ALU
		   .wsrc_b((we1 && (waddr1 == 0)) ? wsrc_b_1 : wsrc_b_2),          ///DATA_HC+DATA_CL RSV_ALU
		   .walu_op((we1 && (waddr1 == 0)) ? walu_op_1 : walu_op_2),       ///DATA_HC+DATA_CL RSV_ALU
		   .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),    ///CTRL_HC+CTRL_CL RSV_ALU
		   .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),          ///CTRL_HC+CTRL_CL RSV_ALU
		   .ex_src1(ex_src1_0),                                            ///DATA_HC RSV_ALU
		   .ex_src2(ex_src2_0),                                            ///DATA_HC RSV_ALU
		   .ready(ready_0),                                                ///CTRL_HC RSV_ALU
		   .pc(pc_0),                                                      ///DATA_HC RSV_ALU
		   .imm(imm_0),                                                    ///DATA_HC RSV_ALU
		   .rrftag(rrftag_0),                                              ///CTRL_HC RSV_ALU
		   .dstval(dstval_0),                                              ///CTRL_HC RSV_ALU
		   .src_a(src_a_0),                                                ///DATA_HC RSV_ALU
		   .src_b(src_b_0),                                                ///DATA_HC RSV_ALU
		   .alu_op(alu_op_0),                                              ///DATA_HC RSV_ALU
		   .spectag(spectag_0),                                            ///CTRL_HC RSV_ALU
		   .exrslt1(exrslt1),                                              ///DATA_HC RSV_ALU
		   .exdst1(exdst1),                                                ///CTRL_HC RSV_ALU
		   .kill_spec1(kill_spec1),                                        ///CTRL_HC RSV_ALU
		   .exrslt2(exrslt2),                                              ///DATA_HC RSV_ALU
		   .exdst2(exdst2),                                                ///CTRL_HC RSV_ALU
		   .kill_spec2(kill_spec2),                                        ///CTRL_HC RSV_ALU
		   .exrslt3(exrslt3),                                              ///DATA_HC RSV_ALU
		   .exdst3(exdst3),                                                ///CTRL_HC RSV_ALU
		   .kill_spec3(kill_spec3),                                        ///CTRL_HC RSV_ALU
		   .exrslt4(exrslt4),                                              ///DATA_HC RSV_ALU
		   .exdst4(exdst4),                                                ///CTRL_HC RSV_ALU
		   .kill_spec4(kill_spec4),                                        ///CTRL_HC RSV_ALU
		   .exrslt5(exrslt5),                                              ///DATA_HC RSV_ALU
		   .exdst5(exdst5),                                                ///CTRL_HC RSV_ALU
		   .kill_spec5(kill_spec5)                                         ///CTRL_HC RSV_ALU
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
   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 :   ///DATA_CL RSV_ALU
		    (issueaddr == 1) ? ex_src1_1 :              ///DC
		    (issueaddr == 2) ? ex_src1_2 :              ///DC
		    (issueaddr == 3) ? ex_src1_3 :              ///DC
		    (issueaddr == 4) ? ex_src1_4 :              ///DC
		    (issueaddr == 5) ? ex_src1_5 :              ///DC
		    (issueaddr == 6) ? ex_src1_6 : ex_src1_7;   ///DC

   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 :   ///DATA_CL RSV_ALU
		    (issueaddr == 1) ? ex_src2_1 :              ///DC
		    (issueaddr == 2) ? ex_src2_2 :              ///DC
		    (issueaddr == 3) ? ex_src2_3 :              ///DC
		    (issueaddr == 4) ? ex_src2_4 :              ///DC
		    (issueaddr == 5) ? ex_src2_5 :              ///DC
		    (issueaddr == 6) ? ex_src2_6 : ex_src2_7;   ///DC

   assign pc = (issueaddr == 0) ? pc_0 :   ///DATA_CL RSV_ALU
	       (issueaddr == 1) ? pc_1 :                    ///DC
	       (issueaddr == 2) ? pc_2 :                    ///DC
	       (issueaddr == 3) ? pc_3 :                    ///DC
	       (issueaddr == 4) ? pc_4 :                    ///DC
	       (issueaddr == 5) ? pc_5 :                    ///DC
	       (issueaddr == 6) ? pc_6 : pc_7;              ///DC
   
   assign imm = (issueaddr == 0) ? imm_0 :   ///DATA_CL RSV_ALU
		(issueaddr == 1) ? imm_1 :                      ///DC
		(issueaddr == 2) ? imm_2 :                      ///DC
		(issueaddr == 3) ? imm_3 :                      ///DC
		(issueaddr == 4) ? imm_4 :                      ///DC
		(issueaddr == 5) ? imm_5 :                      ///DC
		(issueaddr == 6) ? imm_6 : imm_7;               ///DC
   
   assign rrftag = (issueaddr == 0) ? rrftag_0 :   ///CTRL_CL RSV_ALU
		   (issueaddr == 1) ? rrftag_1 :                 ///DC
		   (issueaddr == 2) ? rrftag_2 :                 ///DC
		   (issueaddr == 3) ? rrftag_3 :                 ///DC
		   (issueaddr == 4) ? rrftag_4 :                 ///DC
		   (issueaddr == 5) ? rrftag_5 :                 ///DC
		   (issueaddr == 6) ? rrftag_6 : rrftag_7;       ///DC
   
   assign dstval = (issueaddr == 0) ? dstval_0 :   ///CTRL_CL RSV_ALU
		   (issueaddr == 1) ? dstval_1 :                  ///DC
		   (issueaddr == 2) ? dstval_2 :                  ///DC
		   (issueaddr == 3) ? dstval_3 :                  ///DC
		   (issueaddr == 4) ? dstval_4 :                  ///DC
		   (issueaddr == 5) ? dstval_5 :                  ///DC
		   (issueaddr == 6) ? dstval_6 : dstval_7;        ///DC
   
   assign src_a = (issueaddr == 0) ? src_a_0 :   ///DATA_CL RSV_ALU
		  (issueaddr == 1) ? src_a_1 :                    ///DC
		  (issueaddr == 2) ? src_a_2 :                    ///DC
		  (issueaddr == 3) ? src_a_3 :                    ///DC
		  (issueaddr == 4) ? src_a_4 :                    ///DC
		  (issueaddr == 5) ? src_a_5 :                    ///DC
		  (issueaddr == 6) ? src_a_6 : src_a_7;           ///DC
   
   assign src_b = (issueaddr == 0) ? src_b_0 :   ///DATA_CL RSV_ALU
		  (issueaddr == 1) ? src_b_1 :                    ///DC
		  (issueaddr == 2) ? src_b_2 :                    ///DC
		  (issueaddr == 3) ? src_b_3 :                    ///DC
		  (issueaddr == 4) ? src_b_4 :                    ///DC
		  (issueaddr == 5) ? src_b_5 :                    ///DC
		  (issueaddr == 6) ? src_b_6 : src_b_7;           ///DC
   
   assign alu_op = (issueaddr == 0) ? alu_op_0 :   ///DATA_CL RSV_ALU
		   (issueaddr == 1) ? alu_op_1 :                  ///DC
		   (issueaddr == 2) ? alu_op_2 :                  ///DC
		   (issueaddr == 3) ? alu_op_3 :                  ///DC
		   (issueaddr == 4) ? alu_op_4 :                  ///DC
		   (issueaddr == 5) ? alu_op_5 :                  ///DC
		   (issueaddr == 6) ? alu_op_6 : alu_op_7;        ///DC
   
   assign spectag = (issueaddr == 0) ? spectag_0 :   ///CTRL_CL RSV_ALU
		    (issueaddr == 1) ? spectag_1 :                ///DC
		    (issueaddr == 2) ? spectag_2 :                ///DC
		    (issueaddr == 3) ? spectag_3 :                ///DC
		    (issueaddr == 4) ? spectag_4 :                ///DC
		    (issueaddr == 5) ? spectag_5 :                ///DC
		    (issueaddr == 6) ? spectag_6 : spectag_7;     ///DC

   
endmodule // rs_alu
`default_nettype wire
