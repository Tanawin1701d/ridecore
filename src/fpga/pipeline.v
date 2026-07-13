`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"

`default_nettype none

module pipeline   ///MD CORE
  (
   input wire 			clk,                  ///CTRL_HC CORE
   input wire 			reset,                ///CTRL_HC CORE
   output reg [`ADDR_LEN-1:0] 	pc,           ///DATA_HC FETCH
   input wire [4*`INSN_LEN-1:0] idata,        ///DATA_HC FETCH
   output wire [`DATA_LEN-1:0] 	dmem_wdata,   ///DATA_HC EXEC_LDST
   output wire 			dmem_we,              ///CTRL_HC EXEC_LDST
   output wire [`ADDR_LEN-1:0] 	dmem_addr,    ///DATA_HC EXEC_LDST
   input wire [`DATA_LEN-1:0] 	dmem_data     ///DATA_HC EXEC_LDST
   );

   
   wire  stall_IF /* verilator public */;   ///CTRL_HWD FETCH
   wire  kill_IF  /* verilator public */;   ///CTRL_HWD FETCH
   wire  stall_ID /* verilator public */;   ///CTRL_HWD DECODE
   wire  kill_ID  /* verilator public */;   ///CTRL_HWD DECODE
   wire  stall_DP /* verilator public */;   ///CTRL_HWD DISPATCH
   wire  kill_DP  /* verilator public */;   ///CTRL_HWD DISPATCH
//   reg [`ADDR_LEN-1:0] pc;

   //IF
   // Signal from pipe_if
   wire     	        prcond = 0; ///DC
   wire [`ADDR_LEN-1:0] npc;        ///DATA_HWD FETCH
   wire [`INSN_LEN-1:0] inst1;      ///DATA_HWD FETCH
   wire [`INSN_LEN-1:0] inst2;      ///DATA_HWD FETCH
   wire 		invalid2_pipe;      ///CTRL_HWD FETCH
   wire [`GSH_BHR_LEN-1:0] bhr = 0; ///DC
   
   //Instruction Buffer
   reg 			   prcond_if /* verilator public */          ; ///DC
   reg [`ADDR_LEN-1:0] 	   npc_if /* verilator public */     ; ///DATA_HWD FETCH
   reg [`ADDR_LEN-1:0] 	   pc_if /* verilator public */      ; ///DATA_HWD FETCH
   reg [`INSN_LEN-1:0] 	   inst1_if /* verilator public */   ; ///DATA_HWD FETCH
   reg [`INSN_LEN-1:0] 	   inst2_if /* verilator public */   ; ///DATA_HWD FETCH
   reg 			           inv1_if /* verilator public */    ; ///CTRL_HWD FETCH
   reg 			           inv2_if /* verilator public */    ; ///CTRL_HWD FETCH
   reg [`GSH_BHR_LEN-1:0]  bhr_if /* verilator public */     ; ///DC
   wire 		           attachable /* verilator public */ ; ///CTRL_HWD DECODE

   //ID
   //Decode Info1
   wire [`IMM_TYPE_WIDTH-1:0] imm_type_1;           ///DATA_HWD DECODE
   wire [`REG_SEL-1:0] 	      rs1_1;                ///DATA_HWD DECODE
   wire [`REG_SEL-1:0] 	      rs2_1;                ///DATA_HWD DECODE
   wire [`REG_SEL-1:0] 	      rd_1;                 ///DATA_HWD DECODE
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel_1;         ///DATA_HWD DECODE
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel_1;         ///DATA_HWD DECODE
   wire 		       wr_reg_1;                    ///CTRL_HWD DECODE
   wire 		       uses_rs1_1;                  ///CTRL_HWD DECODE
   wire 		       uses_rs2_1;                  ///CTRL_HWD DECODE
   wire 		       illegal_instruction_1;       ///CTRL_HWD DECODE
   wire [`ALU_OP_WIDTH-1:0]    alu_op_1;            ///DATA_HWD DECODE
   wire [`RS_ENT_SEL-1:0]      rs_ent_1;            ///DATA_HWD DECODE
   wire [2:0] 		       dmem_size_1;             ///DATA_HWD DECODE
   wire [`MEM_TYPE_WIDTH-1:0]  dmem_type_1;         ///DATA_HWD DECODE
   wire [`MD_OP_WIDTH-1:0]     md_req_op_1;         ///DATA_HWD DECODE
   wire 		       md_req_in_1_signed_1;        ///DATA_HWD DECODE
   wire 		       md_req_in_2_signed_1;        ///DATA_HWD DECODE
   wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1;   ///DATA_HWD DECODE
   //Decode Info2
   wire [`IMM_TYPE_WIDTH-1:0] 	imm_type_2;        ///DC
   wire [`REG_SEL-1:0] 		rs1_2;                 ///DC
   wire [`REG_SEL-1:0] 		rs2_2;                 ///DC
   wire [`REG_SEL-1:0] 		rd_2;                  ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] 	src_a_sel_2;       ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] 	src_b_sel_2;       ///DC
   wire 			wr_reg_2;                      ///DC
   wire 			uses_rs1_2;                    ///DC
   wire 			uses_rs2_2;                    ///DC
   wire 			illegal_instruction_2;         ///DC
   wire [`ALU_OP_WIDTH-1:0] 	alu_op_2;          ///DC
   wire [`RS_ENT_SEL-1:0] 	rs_ent_2;              ///DC
   wire [2:0] 			dmem_size_2;               ///DC
   wire [`MEM_TYPE_WIDTH-1:0] 	dmem_type_2;	   ///DC
   wire [`MD_OP_WIDTH-1:0] 	md_req_op_2;           ///DC
   wire 			md_req_in_1_signed_2;          ///DC
   wire 			md_req_in_2_signed_2;          ///DC
   wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_2;  ///DC
   //Additional Info
   wire [`SPECTAG_LEN-1:0] 	sptag1;   ///CTRL_HWD TAG
   wire [`SPECTAG_LEN-1:0] 	sptag2;   ///CTRL_HWD TAG
   wire [`SPECTAG_LEN-1:0] 	tagreg;   ///CTRL_HWD TAG
   wire 			spec1;            ///CTRL_HWD TAG
   wire 			spec2;            ///CTRL_HWD TAG
   wire 			isbranch1;        ///CTRL_HWD DECODE
   wire 			isbranch2;        ///CTRL_HWD DECODE
   wire 			branchvalid1;     ///CTRL_HWD TAG
   wire 			branchvalid2;     ///CTRL_HWD TAG
   
   //Latch
   //Decode Info1
   reg [`IMM_TYPE_WIDTH-1:0] 	imm_type_1_id /* verilator public */;               ///DATA_HWD DECODE
   reg [`REG_SEL-1:0] 		    rs1_1_id /* verilator public */;                    ///DATA_HWD DECODE
   reg [`REG_SEL-1:0] 		    rs2_1_id /* verilator public */;                    ///DATA_HWD DECODE
   reg [`REG_SEL-1:0] 		    rd_1_id /* verilator public */;                     ///DATA_HWD DECODE
   reg [`SRC_A_SEL_WIDTH-1:0] 	src_a_sel_1_id /* verilator public */;              ///DATA_HWD DECODE
   reg [`SRC_B_SEL_WIDTH-1:0] 	src_b_sel_1_id /* verilator public */;              ///DATA_HWD DECODE
   reg 				            wr_reg_1_id /* verilator public */;                 ///CTRL_HWD DECODE
   reg 				            uses_rs1_1_id /* verilator public */;               ///CTRL_HWD DECODE
   reg 				            uses_rs2_1_id /* verilator public */;               ///CTRL_HWD DECODE
   reg 				            illegal_instruction_1_id /* verilator public */;    ///CTRL_HWD DECODE
   reg [`ALU_OP_WIDTH-1:0] 	    alu_op_1_id /* verilator public */;                 ///DATA_HWD DECODE
   reg [`RS_ENT_SEL-1:0] 	    rs_ent_1_id /* verilator public */;                 ///DATA_HWD DECODE
   reg [2:0] 			        dmem_size_1_id /* verilator public */;              ///DATA_HWD DECODE
   reg [`MEM_TYPE_WIDTH-1:0] 	dmem_type_1_id /* verilator public */;              ///DATA_HWD DECODE
   reg [`MD_OP_WIDTH-1:0] 	    md_req_op_1_id /* verilator public */;              ///DATA_HWD DECODE
   reg 				            md_req_in_1_signed_1_id /* verilator public */;     ///CTRL_HWD DECODE
   reg 				            md_req_in_2_signed_1_id /* verilator public */;     ///CTRL_HWD DECODE
   reg [`MD_OUT_SEL_WIDTH-1:0] 	md_req_out_sel_1_id /* verilator public */;         ///DATA_HWD DECODE
   //Decode Info2
   reg [`IMM_TYPE_WIDTH-1:0] 	imm_type_2_id  /* verilator public */;             ///DC
   reg [`REG_SEL-1:0] 		    rs1_2_id  /* verilator public */;                  ///DC
   reg [`REG_SEL-1:0] 		    rs2_2_id  /* verilator public */;                  ///DC
   reg [`REG_SEL-1:0] 		    rd_2_id  /* verilator public */;                   ///DC
   reg [`SRC_A_SEL_WIDTH-1:0] 	src_a_sel_2_id  /* verilator public */;            ///DC
   reg [`SRC_B_SEL_WIDTH-1:0] 	src_b_sel_2_id  /* verilator public */;            ///DC
   reg 				            wr_reg_2_id  /* verilator public */;               ///DC
   reg 				            uses_rs1_2_id  /* verilator public */;             ///DC
   reg 				            uses_rs2_2_id  /* verilator public */;             ///DC
   reg 				            illegal_instruction_2_id  /* verilator public */;  ///DC
   reg [`ALU_OP_WIDTH-1:0] 	    alu_op_2_id  /* verilator public */;               ///DC
   reg [`RS_ENT_SEL-1:0] 	    rs_ent_2_id  /* verilator public */;               ///DC
   reg [2:0] 			        dmem_size_2_id  /* verilator public */;            ///DC
   reg [`MEM_TYPE_WIDTH-1:0] 	dmem_type_2_id  /* verilator public */;			   ///DC
   reg [`MD_OP_WIDTH-1:0] 	    md_req_op_2_id  /* verilator public */;            ///DC
   reg 				            md_req_in_1_signed_2_id  /* verilator public */;   ///DC
   reg 				            md_req_in_2_signed_2_id  /* verilator public */;   ///DC
   reg [`MD_OUT_SEL_WIDTH-1:0] 	md_req_out_sel_2_id  /* verilator public */;       ///DC
   //Additional Info
   reg 				            rs1_2_eq_dst1_id   /* verilator public */;   ///CTRL_HWD DECODE
   reg 				            rs2_2_eq_dst1_id   /* verilator public */;   ///CTRL_HWD DECODE
   reg [`SPECTAG_LEN-1:0] 	    sptag1_id   /* verilator public */;          ///CTRL_HWD TAG
   reg [`SPECTAG_LEN-1:0] 	    sptag2_id   /* verilator public */;          ///CTRL_HWD TAG
   reg [`SPECTAG_LEN-1:0] 	    tagreg_id   /* verilator public */;          ///CTRL_HWD TAG
   reg 				            spec1_id   /* verilator public */;           ///CTRL_HWD TAG
   reg 				            spec2_id   /* verilator public */;           ///CTRL_HWD TAG
   reg [`INSN_LEN-1:0] 		    inst1_id   /* verilator public */;           ///DATA_HWD DECODE
   reg [`INSN_LEN-1:0] 		    inst2_id   /* verilator public */;           ///DATA_HWD DECODE
   reg 				            prcond1_id   /* verilator public */;         ///DC
   reg 				            prcond2_id   /* verilator public */;         ///DC
   reg 				            inv1_id   /* verilator public */;            ///CTRL_HWD DECODE
   reg 				            inv2_id   /* verilator public */;            ///CTRL_HWD DECODE
   reg [`ADDR_LEN-1:0] 		    praddr1_id   /* verilator public */;         ///DATA_HWD FETCH
   reg [`ADDR_LEN-1:0] 		    praddr2_id   /* verilator public */;         ///DATA_HWD FETCH
   reg [`ADDR_LEN-1:0] 		    pc_id   /* verilator public */;              ///DATA_HWD FETCH
   reg [`GSH_BHR_LEN-1:0] 	    bhr_id   /* verilator public */;             ///DC
   reg 				            isbranch1_id   /* verilator public */;       ///CTRL_HWD DECODE
   reg 				            isbranch2_id   /* verilator public */;       ///CTRL_HWD DECODE

   //DP
   //Source Operand Manager wire
   wire [`DATA_LEN-1:0] opr1_1;   ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] opr2_1;   ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] opr1_2;   ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] opr2_2;   ///DATA_HWD DISPATCH
   wire 		rdy1_1;           ///CTRL_HWD DISPATCH
   wire 		rdy2_1;           ///CTRL_HWD DISPATCH
   wire 		rdy1_2;           ///CTRL_HWD DISPATCH
   wire 		rdy2_2;           ///CTRL_HWD DISPATCH

   //rrf_FL wire
   wire 		alloc_rrf /* verilator public */;   ///CTRL_HWD RRF
   wire [`RRF_SEL-1:0] 	dst1_renamed;               ///CTRL_HWD RRF
   wire [`RRF_SEL-1:0] 	dst2_renamed;               ///CTRL_HWD RRF
   wire [`RRF_SEL:0] 	freenum;                    ///CTRL_HWD RRF
   wire [`RRF_SEL-1:0] 	rrfptr;                     ///CTRL_HWD RRF
   wire [`RRF_SEL-1:0] 	rrftagfix;                  ///CTRL_HWD RRF

   //arf wire 
   wire [`RRF_SEL-1:0] 	rs1_1tag;      ///CTRL_HWD ARF
   wire [`RRF_SEL-1:0] 	rs2_1tag;      ///CTRL_HWD ARF
   wire [`RRF_SEL-1:0] 	rs1_2tag;      ///CTRL_HWD ARF
   wire [`RRF_SEL-1:0] 	rs2_2tag;      ///CTRL_HWD ARF
   wire [`DATA_LEN-1:0] adat1_1;       ///DATA_HWD ARF
   wire [`DATA_LEN-1:0] adat2_1;       ///DATA_HWD ARF
   wire [`DATA_LEN-1:0] adat1_2;       ///DATA_HWD ARF
   wire [`DATA_LEN-1:0] adat2_2;       ///DATA_HWD ARF
   wire 		abusy1_1;              ///CTRL_HWD ARF
   wire 		abusy2_1;              ///CTRL_HWD ARF
   wire 		abusy1_2;              ///CTRL_HWD ARF
   wire 		abusy2_2;              ///CTRL_HWD ARF

   //rrf wire
   wire [`DATA_LEN-1:0] rdat1_1;   ///DATA_HWD RRF
   wire [`DATA_LEN-1:0] rdat2_1;   ///DATA_HWD RRF
   wire [`DATA_LEN-1:0] rdat1_2;   ///DATA_HWD RRF
   wire [`DATA_LEN-1:0] rdat2_2;   ///DATA_HWD RRF
   wire 		rvalid1_1;         ///CTRL_HWD RRF
   wire 		rvalid2_1;         ///CTRL_HWD RRF
   wire 		rvalid1_2;         ///CTRL_HWD RRF
   wire 		rvalid2_2;         ///CTRL_HWD RRF
   wire [`DATA_LEN-1:0] com1data;  ///DATA_HWD RRF
   wire [`DATA_LEN-1:0] com2data;  ///DATA_HWD RRF
   
   //Src Manager wire
   wire [`DATA_LEN-1:0] src1_1; //To reservation station   ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] src2_1;                            ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] src1_2;                            ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] src2_2;                            ///DATA_HWD DISPATCH
   wire 		resolved1_1;                               ///CTRL_HWD DISPATCH
   wire 		resolved2_1;                               ///CTRL_HWD DISPATCH
   wire 		resolved1_2;                               ///CTRL_HWD DISPATCH
   wire 		resolved2_2;                               ///CTRL_HWD DISPATCH

   //Immgen wire
   wire [`DATA_LEN-1:0] imm1; // To reservation station   ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] imm2;                             ///DATA_HWD DISPATCH
   //BrImmgen wire
   wire [`DATA_LEN-1:0] brimm1; //To reservation station   ///DATA_HWD DISPATCH
   wire [`DATA_LEN-1:0] brimm2;                            ///DATA_HWD DISPATCH
   
   //RS Request Generator wire
   wire 		req1_alu;                                ///CTRL_HWD DISPATCH
   wire 		req2_alu;                                ///CTRL_HWD DISPATCH
   wire [1:0] 		req_alunum;                          ///CTRL_HWD DISPATCH
   wire 		req1_branch;                             ///CTRL_HWD DISPATCH
   wire 		req2_branch;                             ///CTRL_HWD DISPATCH
   wire [1:0] 		req_branchnum;                       ///CTRL_HWD DISPATCH
   wire 		req1_mul;                                ///CTRL_HWD DISPATCH
   wire 		req2_mul;                                ///CTRL_HWD DISPATCH
   wire [1:0] 		req_mulnum;                          ///CTRL_HWD DISPATCH
   wire 		req1_ldst;                               ///CTRL_HWD DISPATCH
   wire 		req2_ldst;                               ///CTRL_HWD DISPATCH
   wire [1:0] 		req_ldstnum;                         ///CTRL_HWD DISPATCH

   wire [`ALU_ENT_SEL:0] allocent1_alu;                  ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_SEL:0] allocent2_alu;                  ///CTRL_HWD RSV_ALU
   wire 		 rsalu1_we1;                             ///CTRL_HWD RSV_ALU
   wire 		 rsalu1_we2;                             ///CTRL_HWD RSV_ALU
   wire 		 rsalu2_we1;                             ///CTRL_HWD RSV_ALU
   wire 		 rsalu2_we2;                             ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_NUM-1:0]   busyvec_alu1;               ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_NUM-1:0]   busyvec_alu2;               ///CTRL_HWD RSV_ALU
   wire [2*`ALU_ENT_NUM-1:0] busyvec_alu;                ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_NUM:0]     ready_alu;                  ///CTRL_HWD RSV_ALU

   wire 		   issuevalid_alu1;                                ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_SEL-1:0] issueent_alu1 /* verilator public */;   ///CTRL_HWD RSV_ALU
   wire 		   issue_alu1 /* verilator public */;              ///CTRL_HWD RSV_ALU
   wire 		   issuevalid_alu2;                                ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_SEL-1:0] issueent_alu2 /* verilator public */;   ///CTRL_HWD RSV_ALU
   wire 		   issue_alu2 /* verilator public */;              ///CTRL_HWD RSV_ALU
   wire 		   allocatable_alu /* verilator public */;         ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect1;                 ///CTRL_HWD RSV_ALU
   wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect2;                 ///CTRL_HWD RSV_ALU
   wire [`RRF_SEL+1:0] 			entval_alu1;                       ///CTRL_HWD RSV_ALU
   wire [`RRF_SEL+1:0] 			entval_alu2;                       ///CTRL_HWD RSV_ALU
   
   wire 				nextrrfcyc;                                ///CTRL_HWD RRF

   wire [`DATA_LEN-1:0]    ex_src1_alu1;                           ///DATA_HWD RSV_ALU
   wire [`DATA_LEN-1:0]    ex_src2_alu1;                           ///DATA_HWD RSV_ALU
   wire [`ALU_ENT_NUM-1:0] ready_alu1;                             ///CTRL_HWD RSV_ALU
   wire [`ADDR_LEN-1:0]    pc_alu1;                                ///DATA_HWD RSV_ALU
   wire [`DATA_LEN-1:0]    imm_alu1;                               ///DATA_HWD RSV_ALU
   wire [`RRF_SEL-1:0] 	   rrftag_alu1;                            ///CTRL_HWD RSV_ALU
   wire 		   dstval_alu1;                                    ///CTRL_HWD RSV_ALU
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_alu1;                         ///DATA_HWD RSV_ALU
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_alu1;                         ///DATA_HWD RSV_ALU
   wire [`ALU_OP_WIDTH-1:0]    alu_op_alu1;                        ///DATA_HWD RSV_ALU
   wire [`SPECTAG_LEN-1:0]     spectag_alu1;                       ///CTRL_HWD RSV_ALU
   wire 		       specbit_alu1;                               ///CTRL_HWD RSV_ALU

   wire [`DATA_LEN-1:0]        ex_src1_alu2;               ///DC
   wire [`DATA_LEN-1:0]        ex_src2_alu2;               ///DC
   wire [`ALU_ENT_NUM-1:0]     ready_alu2;                 ///DC
   wire [`ADDR_LEN-1:0]        pc_alu2;                    ///DC
   wire [`DATA_LEN-1:0]        imm_alu2;                   ///DC
   wire [`RRF_SEL-1:0] 	       rrftag_alu2;                ///DC
   wire 		       dstval_alu2;                        ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_alu2;                 ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_alu2;                 ///DC
   wire [`ALU_OP_WIDTH-1:0]    alu_op_alu2;                ///DC
   wire [`SPECTAG_LEN-1:0]     spectag_alu2;               ///DC
   wire 		       specbit_alu2;                       ///DC
   
   wire [`LDST_ENT_SEL-1:0]    allocent1_ldst;                         ///CTRL_HWD RSV_LDST
   wire [`LDST_ENT_SEL-1:0]    allocent2_ldst;                         ///CTRL_HWD RSV_LDST
   wire [`LDST_ENT_NUM-1:0]    busyvec_ldst;                           ///CTRL_HWD RSV_LDST
   wire [`LDST_ENT_NUM-1:0]    prbusyvec_next_ldst;                    ///CTRL_HWD RSV_LDST
   wire [`LDST_ENT_NUM-1:0]    ready_ldst;                             ///CTRL_HWD RSV_LDST
   wire 		       issuevalid_ldst;                                ///CTRL_HWD RSV_LDST
   wire [`LDST_ENT_SEL-1:0]    issueent_ldst /* verilator public */;   ///CTRL_HWD RSV_LDST
   wire 		       issue_ldst /* verilator public */;              ///CTRL_HWD RSV_LDST
   wire 		       allocatable_ldst;                               ///CTRL_HWD RSV_LDST

   wire [`DATA_LEN-1:0]        ex_src1_ldst;                           ///DATA_HWD RSV_LDST
   wire [`DATA_LEN-1:0]        ex_src2_ldst;                           ///DATA_HWD RSV_LDST
   wire [`ADDR_LEN-1:0]        pc_ldst;                                ///DATA_HWD RSV_LDST
   wire [`DATA_LEN-1:0]        imm_ldst;                               ///DATA_HWD RSV_LDST
   wire [`RRF_SEL-1:0] 	       rrftag_ldst;                            ///CTRL_HWD RSV_LDST
   wire 		       dstval_ldst;                                    ///CTRL_HWD RSV_LDST
   wire [`SPECTAG_LEN-1:0]     spectag_ldst;                           ///CTRL_HWD RSV_LDST
   wire 		       specbit_ldst;                                   ///CTRL_HWD RSV_LDST

   wire [`BRANCH_ENT_SEL-1:0]  allocent1_branch;                         ///CTRL_HWD RSV_BRANCH
   wire [`BRANCH_ENT_SEL-1:0]  allocent2_branch;                         ///CTRL_HWD RSV_BRANCH
   wire [`BRANCH_ENT_NUM-1:0]  busyvec_branch;                           ///CTRL_HWD RSV_BRANCH
   wire [`BRANCH_ENT_NUM-1:0]  prbusyvec_next_branch;                    ///CTRL_HWD RSV_BRANCH
   wire [`BRANCH_ENT_NUM-1:0]  ready_branch;                             ///CTRL_HWD RSV_BRANCH
   wire 		       issuevalid_branch;                                ///CTRL_HWD RSV_BRANCH
   wire [`BRANCH_ENT_SEL-1:0]  issueent_branch /* verilator public */;   ///CTRL_HWD RSV_BRANCH
   wire 		       issue_branch /* verilator public */;              ///CTRL_HWD RSV_BRANCH
   wire 		       allocatable_branch /* verilator public */;        ///CTRL_HWD RSV_BRANCH

   wire [`DATA_LEN-1:0]        ex_src1_branch;    ///DATA_HWD RSV_BRANCH
   wire [`DATA_LEN-1:0]        ex_src2_branch;    ///DATA_HWD RSV_BRANCH
   wire [`ADDR_LEN-1:0]        pc_branch;         ///DATA_HWD RSV_BRANCH
   wire [`DATA_LEN-1:0]        imm_branch;        ///DATA_HWD RSV_BRANCH
   wire [`RRF_SEL-1:0] 	       rrftag_branch;     ///CTRL_HWD RSV_BRANCH
   wire 		       dstval_branch;             ///CTRL_HWD RSV_BRANCH
   wire [`ALU_OP_WIDTH-1:0]    alu_op_branch;     ///DATA_HWD RSV_BRANCH
   wire [`SPECTAG_LEN-1:0]     spectag_branch;    ///CTRL_HWD RSV_BRANCH
   wire 		       specbit_branch;            ///CTRL_HWD RSV_BRANCH
   wire [`GSH_BHR_LEN-1:0]     bhr_branch;        ///DC
   wire 		       prcond_branch;             ///DC
   wire [`ADDR_LEN-1:0]        praddr_branch;     ///DATA_HWD RSV_BRANCH
   wire [6:0] 		       opcode_branch;         ///DATA_HWD RSV_BRANCH

   wire [`MUL_ENT_SEL-1:0]       allocent1_mul;                       ///CTRL_HWD RSV_MUL
   wire [`MUL_ENT_SEL-1:0]       allocent2_mul;                       ///CTRL_HWD RSV_MUL
   wire [`MUL_ENT_NUM-1:0]     busyvec_mul;                           ///CTRL_HWD RSV_MUL
   wire [`MUL_ENT_NUM-1:0]     ready_mul;                             ///CTRL_HWD RSV_MUL
   wire 		       issuevalid_mul;                                ///CTRL_HWD RSV_MUL
   wire [`MUL_ENT_SEL-1:0]     issueent_mul /* verilator public */;   ///CTRL_HWD RSV_MUL
   wire 		       issue_mul /* verilator public */;              ///CTRL_HWD RSV_MUL
   wire 		       allocatable_mul;                               ///CTRL_HWD RSV_MUL

   wire [`DATA_LEN-1:0]        ex_src1_mul;                           ///DATA_HWD RSV_MUL
   wire [`DATA_LEN-1:0]        ex_src2_mul;                           ///DATA_HWD RSV_MUL
   wire [`ADDR_LEN-1:0]        pc_mul;                                ///DATA_HWD RSV_MUL
   wire [`RRF_SEL-1:0] 	       rrftag_mul;                            ///CTRL_HWD RSV_MUL
   wire 		       dstval_mul;                                    ///CTRL_HWD RSV_MUL
   wire [`SPECTAG_LEN-1:0]     spectag_mul;                           ///CTRL_HWD RSV_MUL
   wire 		       specbit_mul;                                   ///CTRL_HWD RSV_MUL
   wire 		       src1_signed_mul;                               ///DATA_HWD RSV_MUL
   wire 		       src2_signed_mul;                               ///DATA_HWD RSV_MUL
   wire 		       sel_lohi_mul;                                  ///DATA_HWD RSV_MUL

   //EX
   //ALU1
   wire [`DATA_LEN-1:0]        result_alu1;   ///DATA_HWD EXEC_ALU
   wire 		       rrfwe_alu1;            ///CTRL_HWD EXEC_ALU
   wire 		       robwe_alu1;            ///CTRL_HWD EXEC_ALU
   wire 		       kill_speculative_alu1; ///CTRL_HWD EXEC_ALU

   reg [`DATA_LEN-1:0] 	       buf_ex_src1_alu1     /* verilator public */;   ///DATA_HWD EXEC_ALU
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_alu1     /* verilator public */;   ///DATA_HWD EXEC_ALU
   reg [`ADDR_LEN-1:0] 	       buf_pc_alu1     /* verilator public */;        ///DATA_HWD EXEC_ALU
   reg [`DATA_LEN-1:0] 	       buf_imm_alu1     /* verilator public */;       ///DATA_HWD EXEC_ALU
   reg [`RRF_SEL-1:0] 	       buf_rrftag_alu1     /* verilator public */;    ///CTRL_HWD EXEC_ALU
   reg 			       buf_dstval_alu1     /* verilator public */;            ///CTRL_HWD EXEC_ALU
   reg [`SRC_A_SEL_WIDTH-1:0]  buf_src_a_alu1     /* verilator public */;     ///DATA_HWD EXEC_ALU
   reg [`SRC_B_SEL_WIDTH-1:0]  buf_src_b_alu1     /* verilator public */;     ///DATA_HWD EXEC_ALU
   reg [`ALU_OP_WIDTH-1:0]     buf_alu_op_alu1     /* verilator public */;    ///DATA_HWD EXEC_ALU
   reg [`SPECTAG_LEN-1:0]      buf_spectag_alu1     /* verilator public */;   ///CTRL_HWD EXEC_ALU
   reg 			       buf_specbit_alu1     /* verilator public */;           ///CTRL_HWD EXEC_ALU
   //ALU2
   wire [`DATA_LEN-1:0]        result_alu2;                                ///DC
   wire 		               rrfwe_alu2;                                 ///DC
   wire 		               robwe_alu2;                                 ///DC
   wire 		               kill_speculative_alu2;                      ///DC

   reg [`DATA_LEN-1:0] 	       buf_ex_src1_alu2 /* verilator public */;    ///DC
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_alu2 /* verilator public */;    ///DC
   reg [`ADDR_LEN-1:0] 	       buf_pc_alu2 /* verilator public */;         ///DC
   reg [`DATA_LEN-1:0] 	       buf_imm_alu2 /* verilator public */;        ///DC
   reg [`RRF_SEL-1:0] 	       buf_rrftag_alu2 /* verilator public */;     ///DC
   reg 			       buf_dstval_alu2 /* verilator public */;             ///DC
   reg [`SRC_A_SEL_WIDTH-1:0]  buf_src_a_alu2 /* verilator public */;      ///DC
   reg [`SRC_B_SEL_WIDTH-1:0]  buf_src_b_alu2 /* verilator public */;      ///DC
   reg [`ALU_OP_WIDTH-1:0]     buf_alu_op_alu2 /* verilator public */;     ///DC
   reg [`SPECTAG_LEN-1:0]      buf_spectag_alu2 /* verilator public */;    ///DC
   reg 			       buf_specbit_alu2 /* verilator public */;            ///DC

   //LDST
   wire [`DATA_LEN-1:0]        result_ldst;     ///DATA_HWD EXEC_LDST
   wire 		       rrfwe_ldst;              ///CTRL_HWD EXEC_LDST
   wire 		       robwe_ldst;              ///CTRL_HWD EXEC_LDST
   wire [`RRF_SEL-1:0] 	       wrrftag_ldst;    ///CTRL_HWD EXEC_LDST
   wire 		       kill_speculative_ldst;   ///CTRL_HWD EXEC_LDST
   wire 		       busy_next_ldst;          ///CTRL_HWD EXEC_LDST

   //wire [`DATA_LEN-1:0]        dmem_data;
   /*
   wire [`DATA_LEN-1:0]        dmem_wdata;
   wire 		       dmem_we;
   wire [`ADDR_LEN-1:0]        dmem_addr;
    */
   wire 		       sb_full;            ///CTRL_HWD STOREBUF
   wire 		       hitsb;              ///CTRL_HWD STOREBUF
   wire 		       memoccupy_ld;       ///CTRL_HWD EXEC_LDST
   wire [`ADDR_LEN-1:0]        ldaddr;     ///DATA_HWD STOREBUF
   wire [`DATA_LEN-1:0]        lddatasb;   ///DATA_HWD STOREBUF
   wire [`ADDR_LEN-1:0]        retaddr;    ///DATA_HWD STOREBUF
   wire [`DATA_LEN-1:0]        storedata;  ///DATA_HWD STOREBUF
   wire [`ADDR_LEN-1:0]        storeaddr;  ///DATA_HWD STOREBUF
   wire 		       stfin;              ///CTRL_HWD EXEC_LDST
   
   reg [`DATA_LEN-1:0] 	       buf_ex_src1_ldst /* verilator public */;   ///DATA_HWD EXEC_LDST
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_ldst /* verilator public */;   ///DATA_HWD EXEC_LDST
   reg [`ADDR_LEN-1:0] 	       buf_pc_ldst /* verilator public */;        ///DATA_HWD EXEC_LDST
   reg [`DATA_LEN-1:0] 	       buf_imm_ldst /* verilator public */;       ///DATA_HWD EXEC_LDST
   reg [`RRF_SEL-1:0] 	       buf_rrftag_ldst /* verilator public */;    ///CTRL_HWD EXEC_LDST
   reg 			       buf_dstval_ldst /* verilator public */;            ///CTRL_HWD EXEC_LDST
   reg [`SPECTAG_LEN-1:0]      buf_spectag_ldst /* verilator public */;   ///CTRL_HWD EXEC_LDST
   reg 			       buf_specbit_ldst /* verilator public */;           ///CTRL_HWD EXEC_LDST

   //MUL
   wire [`DATA_LEN-1:0]        result_mul;                                ///DATA_HWD EXEC_MUL
   wire 		       rrfwe_mul;                                         ///CTRL_HWD EXEC_MUL
   wire 		       robwe_mul;                                         ///CTRL_HWD EXEC_MUL
   wire 		       kill_speculative_mul;                              ///CTRL_HWD EXEC_MUL

   reg [`DATA_LEN-1:0] 	       buf_ex_src1_mul /* verilator public */;    ///DATA_HWD EXEC_MUL
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_mul /* verilator public */;    ///DATA_HWD EXEC_MUL
   reg [`ADDR_LEN-1:0] 	       buf_pc_mul /* verilator public */;         ///DATA_HWD EXEC_MUL
   reg [`RRF_SEL-1:0] 	       buf_rrftag_mul /* verilator public */;     ///CTRL_HWD EXEC_MUL
   reg 			       buf_dstval_mul /* verilator public */;             ///CTRL_HWD EXEC_MUL
   reg [`SPECTAG_LEN-1:0]      buf_spectag_mul /* verilator public */;    ///CTRL_HWD EXEC_MUL
   reg 			       buf_specbit_mul /* verilator public */;            ///CTRL_HWD EXEC_MUL
   reg 			       buf_src1_signed_mul /* verilator public */;        ///DATA_HWD EXEC_MUL
   reg 			       buf_src2_signed_mul /* verilator public */;        ///DATA_HWD EXEC_MUL
   reg 			       buf_sel_lohi_mul /* verilator public */;           ///DATA_HWD EXEC_MUL
   
   //BRANCH
   wire 		       prmiss /* verilator public */;      ///CTRL_HWD EXEC_BRANCH
   wire 		       prsuccess /* verilator public */;   ///CTRL_HWD EXEC_BRANCH
   wire [`ADDR_LEN-1:0]        jmpaddr;                    ///DATA_HWD EXEC_BRANCH
   wire [`ADDR_LEN-1:0]        jmpaddr_taken;              ///DATA_HWD EXEC_BRANCH
   wire 		       brcond;                             ///DC
   wire [`SPECTAG_LEN-1:0]     tagregfix;                  ///CTRL_HWD TAG
   
   wire [`DATA_LEN-1:0]        result_branch;              ///DATA_HWD EXEC_BRANCH
   wire 		       rrfwe_branch;                       ///CTRL_HWD EXEC_BRANCH
   wire 		       robwe_branch;                       ///CTRL_HWD EXEC_BRANCH
   
   reg [`DATA_LEN-1:0] 	       buf_ex_src1_branch /* verilator public */;   ///DATA_HWD EXEC_BRANCH
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_branch /* verilator public */;   ///DATA_HWD EXEC_BRANCH
   reg [`ADDR_LEN-1:0] 	       buf_pc_branch /* verilator public */;        ///DATA_HWD EXEC_BRANCH
   reg [`DATA_LEN-1:0] 	       buf_imm_branch /* verilator public */;       ///DATA_HWD EXEC_BRANCH
   reg [`RRF_SEL-1:0] 	       buf_rrftag_branch /* verilator public */;    ///CTRL_HWD EXEC_BRANCH
   reg 			       buf_dstval_branch /* verilator public */;            ///CTRL_HWD EXEC_BRANCH
   reg [`ALU_OP_WIDTH-1:0]     buf_alu_op_branch /* verilator public */;    ///DATA_HWD EXEC_BRANCH
   reg [`SPECTAG_LEN-1:0]      buf_spectag_branch /* verilator public */;   ///CTRL_HWD EXEC_BRANCH
   reg 			       buf_specbit_branch /* verilator public */;           ///CTRL_HWD EXEC_BRANCH
   reg [`ADDR_LEN-1:0] 	       buf_praddr_branch /* verilator public */;    ///DATA_HWD EXEC_BRANCH
   reg [6:0] 		       buf_opcode_branch /* verilator public */;        ///DATA_HWD EXEC_BRANCH
   
   //miss prediction fix table
   wire [`SPECTAG_LEN-1:0] mpft_valid;   ///CTRL_HWD MPFT
   wire [`SPECTAG_LEN-1:0] spectagfix;   ///CTRL_HWD TAG

   //COM
   wire [`RRF_SEL-1:0] 	   comptr;            ///CTRL_HWD ROB
   wire [`RRF_SEL-1:0] 	   comptr2;           ///CTRL_HWD ROB
   wire [1:0] 		   comnum;                ///CTRL_HWD ROB
   wire 		   stcommit;                  ///CTRL_HWD ROB
   wire 		   arfwe1;                    ///CTRL_HWD ROB
   wire 		   arfwe2;                    ///CTRL_HWD ROB
   wire [`REG_SEL-1:0] 	   dstarf1;           ///DATA_HWD ROB
   wire [`REG_SEL-1:0] 	   dstarf2;           ///DATA_HWD ROB
   wire [`ADDR_LEN-1:0]    pc_combranch;      ///DC
   wire [`GSH_BHR_LEN-1:0] bhr_combranch;     ///DC
   wire 		   brcond_combranch;          ///DC
   wire 		   combranch;                 ///DC
   wire [`ADDR_LEN-1:0]    jmpaddr_combranch; ///DC
   
   //IF Stage********************************************************
//   assign stall_IF = stall_ID;
//   assign kill_IF = prmiss;
   assign stall_IF = stall_ID | stall_DP;   ///CTRL_CL FETCH
   assign kill_IF = prmiss;                 ///CTRL_CL FETCH
   
   always @ (posedge clk) begin             ///CTRL_CL FETCH
      if (reset) begin                      ///CTRL_CL FETCH
	 pc <= `ENTRY_POINT;                    ///DATA_DT FETCH
      end else if (prmiss) begin            ///CTRL_CL FETCH
	 pc <= jmpaddr;                         ///DATA_DT FETCH
      end else if (stall_IF) begin          ///CTRL_CL FETCH
	 pc <= pc;                              ///DATA_DT FETCH
      end else begin
	 pc <= npc;                             ///DATA_DT FETCH
      end
   end

   
   pipeline_if pipe_if(                    ///MD FETCH
		       .clk(clk),                  ///CTRL_HC FETCH
		       .reset(reset),              ///CTRL_HC FETCH
		       .pc(pc),                    ///DATA_HC FETCH
		       //.predict_cond(prcond),
		       .npc(npc),                  ///DATA_HC FETCH
		       .inst1(inst1),              ///DATA_HC FETCH
		       .inst2(inst2),              ///DATA_HC FETCH
		       .invalid2(invalid2_pipe),   ///CTRL_HC FETCH
		       // .btbpht_we(combranch),         
		       // .btbpht_pc(pc_combranch),      
		       // .btb_jmpdst(jmpaddr_combranch),
		       // .pht_wcond(brcond_combranch),  
		       // .mpft_valid(mpft_valid),       
		       // .pht_bhr(bhr_combranch), //when PHT write
		       .prmiss(prmiss),              ///CTRL_HC FETCH
		       .prsuccess(prsuccess),        ///CTRL_HC FETCH
		       //.prtag(buf_spectag_branch),
		       //.bhr(bhr),                 
		       //.spectagnow(tagreg),       
		       .idata(idata)                 ///DATA_HC FETCH
		       );

   always @ (posedge clk) begin   ///CTRL_CL FETCH
      if (reset | kill_IF) begin   ///CTRL_CL FETCH
	 prcond_if <= 0;  ///DC
	 npc_if <= 0;     ///DATA_DT FETCH
	 pc_if <= 0;      ///DATA_DT FETCH
	 inst1_if <= 0;   ///DATA_DT FETCH
	 inst2_if <= 0;   ///DATA_DT FETCH
	 inv1_if <= 1;    ///CTRL_DT FETCH
	 inv2_if <= 1;    ///CTRL_DT FETCH
	 bhr_if <= 0;     ///DC
	 
      end else if (~stall_IF) begin   ///CTRL_CL FETCH
	 prcond_if <= prcond;             ///DC
	 npc_if <= npc;                   ///DATA_DT FETCH
	 pc_if <= pc;                     ///DATA_DT FETCH
	 inst1_if <= inst1;               ///DATA_DT FETCH
	 inst2_if <= inst2;               ///DATA_DT FETCH
	 inv1_if <= 0;                    ///CTRL_DT FETCH
	 inv2_if <= invalid2_pipe;        ///CTRL_DT FETCH
	 bhr_if <= bhr;                   ///DC
	 
      end
   end // always @ (posedge clk)

   //ID Stage********************************************************
//   assign stall_ID = stall_DP | ~attachable | (prsuccess & (isbranch1 | isbranch2));
//   assign kill_ID = prmiss;
   assign stall_ID = ~attachable | prsuccess;                        ///CTRL_CL DECODE
   assign kill_ID = (stall_ID & ~stall_DP) | prmiss;                 ///CTRL_CL DECODE
   
   assign isbranch1 = (~inv1_if && (rs_ent_1 == `RS_ENT_BRANCH)) ?   ///CTRL_CL DECODE
		      1'b1 : 1'b0;                                           ///CTRL_CL DECODE
   assign isbranch2 = (~inv2_if && (rs_ent_2 == `RS_ENT_BRANCH)) ?   ///CTRL_CL DECODE
		      1'b1 : 1'b0;                                           ///CTRL_CL DECODE
   assign branchvalid1 = isbranch1 & prcond_if;                      ///CTRL_CL DECODE
   assign branchvalid2 = isbranch2 & ~branchvalid1;                  ///CTRL_CL DECODE
   
   tag_generator taggen(                      ///MD TAG
			.clk(clk),                        ///CTRL_HC TAG
			.reset(reset),                    ///CTRL_HC TAG
			.branchvalid1(isbranch1),         ///CTRL_HC TAG
			.branchvalid2(branchvalid2),      ///CTRL_HC TAG
			.prmiss(prmiss),                  ///CTRL_HC TAG
			.prsuccess(prsuccess),            ///CTRL_HC TAG
			.enable(~stall_ID & ~stall_DP),   ///CTRL_HC+CTRL_CL TAG
			.tagregfix(tagregfix),            ///CTRL_HC TAG
			.sptag1(sptag1),                  ///CTRL_HC TAG
			.sptag2(sptag2),                  ///CTRL_HC TAG
			.speculative1(spec1),             ///CTRL_HC TAG
			.speculative2(spec2),             ///CTRL_HC TAG
			.attachable(attachable),          ///CTRL_HC TAG
			.tagreg(tagreg)                   ///CTRL_HC TAG
			);
   
   decoder dec1(                                      ///MD DECODE
		.inst(inst1_if),                              ///DATA_HC DECODE
		.imm_type(imm_type_1),                        ///DATA_HC DECODE
		.rs1(rs1_1),                                  ///DATA_HC DECODE
		.rs2(rs2_1),                                  ///DATA_HC DECODE
		.rd(rd_1),                                    ///DATA_HC DECODE
		.src_a_sel(src_a_sel_1),                      ///DATA_HC DECODE
		.src_b_sel(src_b_sel_1),                      ///DATA_HC DECODE
		.wr_reg(wr_reg_1),                            ///CTRL_HC DECODE
		.uses_rs1(uses_rs1_1),                        ///CTRL_HC DECODE
		.uses_rs2(uses_rs2_1),                        ///CTRL_HC DECODE
		.illegal_instruction(illegal_instruction_1),  ///CTRL_HC DECODE
		.alu_op(alu_op_1),                            ///DATA_HC DECODE
		.rs_ent(rs_ent_1),                            ///DATA_HC DECODE
		.dmem_size(dmem_size_1),                      ///DATA_HC DECODE
		.dmem_type(dmem_type_1),                      ///DATA_HC DECODE
		.md_req_op(md_req_op_1),                      ///DATA_HC DECODE
		.md_req_in_1_signed(md_req_in_1_signed_1),    ///DATA_HC DECODE
		.md_req_in_2_signed(md_req_in_2_signed_1),    ///DATA_HC DECODE
		.md_req_out_sel(md_req_out_sel_1)             ///DATA_HC DECODE
		);

   decoder dec2(                                      ///DC
		.inst(inst2_if),                              ///DC
		.imm_type(imm_type_2),                        ///DC
		.rs1(rs1_2),                                  ///DC
		.rs2(rs2_2),                                  ///DC
		.rd(rd_2),                                    ///DC
		.src_a_sel(src_a_sel_2),                      ///DC
		.src_b_sel(src_b_sel_2),                      ///DC
		.wr_reg(wr_reg_2),                            ///DC
		.uses_rs1(uses_rs1_2),                        ///DC
		.uses_rs2(uses_rs2_2),                        ///DC
		.illegal_instruction(illegal_instruction_2),  ///DC
		.alu_op(alu_op_2),                            ///DC
		.rs_ent(rs_ent_2),                            ///DC
		.dmem_size(dmem_size_2),                      ///DC
		.dmem_type(dmem_type_2),                      ///DC
		.md_req_op(md_req_op_2),                      ///DC
		.md_req_in_1_signed(md_req_in_1_signed_2),    ///DC
		.md_req_in_2_signed(md_req_in_2_signed_2),    ///DC
		.md_req_out_sel(md_req_out_sel_2)             ///DC
		);                                            ///DC

   always @ (posedge clk) begin      ///CTRL_CL DECODE
      if (reset | kill_ID) begin     ///CTRL_CL DECODE
	 imm_type_1_id <= 0;             ///DATA_DT DECODE
	 rs1_1_id <= 0;                  ///DATA_DT DECODE
	 rs2_1_id <= 0;                  ///DATA_DT DECODE
	 rd_1_id <= 0;                   ///DATA_DT DECODE
	 src_a_sel_1_id <= 0;            ///DATA_DT DECODE
	 src_b_sel_1_id <= 0;            ///DATA_DT DECODE
	 wr_reg_1_id <= 0;               ///CTRL_DT DECODE
	 uses_rs1_1_id <= 0;             ///CTRL_DT DECODE
	 uses_rs2_1_id <= 0;             ///CTRL_DT DECODE
	 illegal_instruction_1_id <= 0;  ///CTRL_DT DECODE
	 alu_op_1_id <= 0;               ///DATA_DT DECODE
	 rs_ent_1_id <= 0;               ///DATA_DT DECODE
	 dmem_size_1_id <= 0;            ///DATA_DT DECODE
	 dmem_type_1_id <= 0;            ///DATA_DT DECODE
	 md_req_op_1_id <= 0;            ///DATA_DT DECODE
	 md_req_in_1_signed_1_id <= 0;   ///CTRL_DT DECODE
	 md_req_in_2_signed_1_id <= 0;   ///CTRL_DT DECODE
	 md_req_out_sel_1_id <= 0;       ///DATA_DT DECODE

	 imm_type_2_id <= 0;             ///DC
	 rs1_2_id <= 0;                  ///DC
	 rs2_2_id <= 0;                  ///DC
	 rd_2_id <= 0;                   ///DC
	 src_a_sel_2_id <= 0;            ///DC
	 src_b_sel_2_id <= 0;            ///DC
	 wr_reg_2_id <= 0;               ///DC
	 uses_rs1_2_id <= 0;             ///DC
	 uses_rs2_2_id <= 0;             ///DC
	 illegal_instruction_2_id <= 0;  ///DC
	 alu_op_2_id <= 0;               ///DC
	 rs_ent_2_id <= 0;               ///DC
	 dmem_size_2_id <= 0;            ///DC
	 dmem_type_2_id <= 0;			 ///DC
	 md_req_op_2_id <= 0;            ///DC
	 md_req_in_1_signed_2_id <= 0;   ///DC
	 md_req_in_2_signed_2_id <= 0;   ///DC
	 md_req_out_sel_2_id <= 0;       ///DC

	 rs1_2_eq_dst1_id <= 0;   ///CTRL_DT DECODE
  	 rs2_2_eq_dst1_id <= 0;   ///CTRL_DT DECODE
	 sptag1_id <= 0;          ///CTRL_DT TAG
	 sptag2_id <= 0;          ///CTRL_DT TAG
	 tagreg_id <= 0;          ///CTRL_DT TAG
//	 spec1_id <= 0;
//	 spec2_id <= 0;
	 inst1_id <= 0;           ///DATA_DT DECODE
	 inst2_id <= 0;           ///DATA_DT DECODE
	 prcond1_id <= 0;         ///DC
	 prcond2_id <= 0;         ///DC
	 inv1_id <= 1;            ///CTRL_DT DECODE
	 inv2_id <= 1;            ///CTRL_DT DECODE
	 praddr1_id <= 0;         ///DATA_DT FETCH
	 praddr2_id <= 0;         ///DATA_DT FETCH
	 pc_id <= 0;              ///DATA_DT FETCH
	 bhr_id <= 0;             ///DC
	 isbranch1_id <= 0;       ///CTRL_DT DECODE
	 isbranch2_id <= 0;       ///CTRL_DT DECODE
	 
      end else if (~stall_DP) begin                     ///CTRL_CL DECODE
	 imm_type_1_id <= imm_type_1;                       ///DATA_DT DECODE
	 rs1_1_id <= rs1_1;                                 ///DATA_DT DECODE
	 rs2_1_id <= rs2_1;                                 ///DATA_DT DECODE
	 rd_1_id <= rd_1;                                   ///DATA_DT DECODE
	 src_a_sel_1_id <= src_a_sel_1;                     ///DATA_DT DECODE
	 src_b_sel_1_id <= src_b_sel_1;                     ///DATA_DT DECODE
	 wr_reg_1_id <= wr_reg_1;                           ///CTRL_DT DECODE
	 uses_rs1_1_id <= uses_rs1_1;                       ///CTRL_DT DECODE
	 uses_rs2_1_id <= uses_rs2_1;                       ///CTRL_DT DECODE
	 illegal_instruction_1_id <= illegal_instruction_1; ///CTRL_DT DECODE
	 alu_op_1_id <= alu_op_1;                           ///DATA_DT DECODE
	 rs_ent_1_id <= inv1_if ? 0 : rs_ent_1;             ///DATA_CL DECODE
	 dmem_size_1_id <= dmem_size_1;                     ///DATA_DT DECODE
	 dmem_type_1_id <= dmem_type_1;                     ///DATA_DT DECODE
	 md_req_op_1_id <= md_req_op_1;                     ///DATA_DT DECODE
	 md_req_in_1_signed_1_id <= md_req_in_1_signed_1;   ///CTRL_DT DECODE
	 md_req_in_2_signed_1_id <= md_req_in_2_signed_1;   ///CTRL_DT DECODE
	 md_req_out_sel_1_id <= md_req_out_sel_1;           ///DATA_DT DECODE

	 imm_type_2_id <= imm_type_2;                                        ///DC
	 rs1_2_id <= rs1_2;                                                  ///DC
	 rs2_2_id <= rs2_2;                                                  ///DC
	 rd_2_id <= rd_2;                                                    ///DC
	 src_a_sel_2_id <= src_a_sel_2;                                      ///DC
	 src_b_sel_2_id <= src_b_sel_2;                                      ///DC
	 wr_reg_2_id <= wr_reg_2;                                            ///DC
	 uses_rs1_2_id <= uses_rs1_2;                                        ///DC
	 uses_rs2_2_id <= uses_rs2_2;                                        ///DC
	 illegal_instruction_2_id <= illegal_instruction_2;                  ///DC
	 alu_op_2_id <= alu_op_2;                                            ///DC
	 rs_ent_2_id <= (inv2_if | (prcond_if & isbranch1)) ? 0 : rs_ent_2;  ///DC
	 dmem_size_2_id <= dmem_size_2;                                      ///DC
	 dmem_type_2_id <= dmem_type_2;			                             ///DC
	 md_req_op_2_id <= md_req_op_2;                                      ///DC
	 md_req_in_1_signed_2_id <= md_req_in_1_signed_2;                    ///DC
	 md_req_in_2_signed_2_id <= md_req_in_2_signed_2;                    ///DC
	 md_req_out_sel_2_id <= md_req_out_sel_2;                            ///DC
	 
	 rs1_2_eq_dst1_id <= (rs1_2 == rd_1 && wr_reg_1) ? 1'b1 : 1'b0;   ///CTRL_CL DECODE
  	 rs2_2_eq_dst1_id <= (rs2_2 == rd_1 && wr_reg_1) ? 1'b1 : 1'b0;   ///CTRL_CL DECODE
	 sptag1_id <= sptag1;                                             ///CTRL_DT TAG
	 sptag2_id <= sptag2;                                             ///CTRL_DT TAG
	 tagreg_id <= tagreg;                                             ///CTRL_DT TAG
//	 spec1_id <= spec1;
//	 spec2_id <= spec2;
	 inst1_id <= inst1_if;                                            ///DATA_DT DECODE
	 inst2_id <= inst2_if;                                            ///DATA_DT DECODE
	 prcond1_id <= prcond_if & isbranch1;                             ///DC
	 prcond2_id <= isbranch2 & prcond_if & ~isbranch1;                ///DC
	 inv1_id <= inv1_if;                                              ///CTRL_DT DECODE
	 inv2_id <= inv2_if | (prcond_if & isbranch1);                    ///CTRL_CL DECODE
	 /*
	 praddr1_id <= prcond_if & isbranch1 ? npc_if : pc_if + 4;
	 praddr2_id <= prcond_if & ~isbranch1 & isbranch2 ?
		       npc_if : pc_if + 8;
	  */
	 praddr1_id <= (prcond_if & isbranch1) ? npc_if : (pc_if + 4);    ///DATA_CL FETCH
	 praddr2_id <= npc_if;                                            ///DATA_DT FETCH
	 pc_id <= pc_if;                                                  ///DATA_DT FETCH
	 bhr_id <= bhr_if;                                                ///DC
	 isbranch1_id <= isbranch1;                                       ///CTRL_DT DECODE
	 isbranch2_id <= isbranch2;                                       ///CTRL_DT DECODE
	 
      end
   end

   //Invalidation of specbit when prsuccess(stall)
   always @ (posedge clk) begin                                      ///CTRL_CL DISPATCH
      if (reset | kill_ID) begin                                     ///CTRL_CL DISPATCH
	 spec1_id <= 0;                                                  ///CTRL_DT DISPATCH
	 spec2_id <= 0;                                                  ///CTRL_DT DISPATCH
      end else if (prsuccess) begin                                  ///CTRL_CL DISPATCH
	 spec1_id <= (spec1_id && (buf_spectag_branch == sptag1_id)) ?   ///CTRL_CL DISPATCH
		     1'b0 : spec1_id;                                        ///CTRL_CL DISPATCH
	 spec2_id <= (spec2_id && (buf_spectag_branch == sptag2_id)) ?   ///CTRL_CL DISPATCH
		     1'b0 : spec2_id;                                        ///CTRL_CL DISPATCH
      end else if ( (~stall_ID) && (~stall_DP)) begin                ///CTRL_CL DISPATCH
	 spec1_id <= spec1;                                              ///CTRL_DT DISPATCH
	 spec2_id <= spec2;                                              ///CTRL_DT DISPATCH
      end
   end
   
   //DP & SW Stage***************************************************
   assign stall_DP = ~allocatable_alu | ~allocatable_ldst |                     ///CTRL_CL DISPATCH
		     ~allocatable_mul | ~allocatable_branch | ~alloc_rrf | prsuccess;   ///CTRL_CL DISPATCH

   assign kill_DP = prmiss;                                                     ///CTRL_CL DISPATCH
   
   
   sourceoperand_manager sopm1_1(                            ///MD DISPATCH
				 .arfdata(adat1_1),                          ///DATA_HC DISPATCH
				 .arf_busy(abusy1_1),                        ///CTRL_HC DISPATCH
				 .rrf_valid(rvalid1_1),                      ///CTRL_HC DISPATCH
				 .rrftag(rs1_1tag),                          ///CTRL_HC DISPATCH
				 .rrfdata(rdat1_1),                          ///DATA_HC DISPATCH
				 .dst1_renamed(dst1_renamed),                ///CTRL_HC DISPATCH
				 .src_eq_dst1(1'b0),                         ///CTRL_HC DISPATCH
				 .src_eq_0((rs1_1_id == 0) ? 1'b1 : 1'b0),   ///CTRL_HC+CTRL_CL DISPATCH
				 .src(opr1_1),                               ///DATA_HC DISPATCH
				 .rdy(rdy1_1)                                ///CTRL_HC DISPATCH
				 );

   sourceoperand_manager sopm2_1(                            ///MD DISPATCH
				 .arfdata(adat2_1),                          ///DATA_HC DISPATCH
				 .arf_busy(abusy2_1),                        ///CTRL_HC DISPATCH
				 .rrf_valid(rvalid2_1),                      ///CTRL_HC DISPATCH
				 .rrftag(rs2_1tag),                          ///CTRL_HC DISPATCH
				 .rrfdata(rdat2_1),                          ///DATA_HC DISPATCH
				 .dst1_renamed(dst1_renamed),                ///CTRL_HC DISPATCH
				 .src_eq_dst1(1'b0),                         ///CTRL_HC DISPATCH
				 .src_eq_0((rs2_1_id == 0) ? 1'b1 : 1'b0),   ///CTRL_HC+CTRL_CL DISPATCH
				 .src(opr2_1),                               ///DATA_HC DISPATCH
				 .rdy(rdy2_1)                                ///CTRL_HC DISPATCH
				 );

   sourceoperand_manager sopm1_2(                            ///MD DISPATCH
				 .arfdata(adat1_2),                          ///DATA_HC DISPATCH
				 .arf_busy(abusy1_2),                        ///CTRL_HC DISPATCH
				 .rrf_valid(rvalid1_2),                      ///CTRL_HC DISPATCH
				 .rrftag(rs1_2tag),                          ///CTRL_HC DISPATCH
				 .rrfdata(rdat1_2),                          ///DATA_HC DISPATCH
				 .dst1_renamed(dst1_renamed),                ///CTRL_HC DISPATCH
				 .src_eq_dst1(rs1_2_eq_dst1_id),             ///CTRL_HC DISPATCH
				 .src_eq_0((rs1_2_id == 0) ? 1'b1 : 1'b0),   ///CTRL_HC+CTRL_CL DISPATCH
				 .src(opr1_2),                               ///DATA_HC DISPATCH
				 .rdy(rdy1_2)                                ///CTRL_HC DISPATCH
				 );

   sourceoperand_manager sopm2_2(                            ///MD DISPATCH
				 .arfdata(adat2_2),                          ///DATA_HC DISPATCH
				 .arf_busy(abusy2_2),                        ///CTRL_HC DISPATCH
				 .rrf_valid(rvalid2_2),                      ///CTRL_HC DISPATCH
				 .rrftag(rs2_2tag),                          ///CTRL_HC DISPATCH
				 .rrfdata(rdat2_2),                          ///DATA_HC DISPATCH
				 .dst1_renamed(dst1_renamed),                ///CTRL_HC DISPATCH
				 .src_eq_dst1(rs2_2_eq_dst1_id),             ///CTRL_HC DISPATCH
				 .src_eq_0((rs2_2_id == 0) ? 1'b1 : 1'b0),   ///CTRL_HC+CTRL_CL DISPATCH
				 .src(opr2_2),                               ///DATA_HC DISPATCH
				 .rdy(rdy2_2)                                ///CTRL_HC DISPATCH
				 );

   
   rrf_freelistmanager rrf_fl(                ///MD RRF
			      .clk(clk),                  ///CTRL_HC RRF
			      .reset(reset),              ///CTRL_HC RRF
			      .invalid1(inv1_id),         ///CTRL_HC RRF
			      .invalid2(inv2_id),         ///CTRL_HC RRF
			      .comnum(comnum),            ///CTRL_HC RRF
			      .prmiss(prmiss),            ///CTRL_HC RRF
			      .rrftagfix(rrftagfix),      ///CTRL_HC RRF
			      .rename_dst1(dst1_renamed), ///CTRL_HC RRF
			      .rename_dst2(dst2_renamed), ///CTRL_HC RRF
			      .allocatable(alloc_rrf),    ///CTRL_HC RRF
			      .stall_DP(stall_DP),        ///CTRL_HC RRF
			      .freenum(freenum),          ///CTRL_HC RRF
			      .rrfptr(rrfptr),            ///CTRL_HC RRF
			      .comptr(comptr),            ///CTRL_HC RRF
			      .nextrrfcyc(nextrrfcyc)     ///CTRL_HC RRF
			      );

   arf aregfile(                                                      ///MD ARF
		.clk(clk),                                                    ///CTRL_HC ARF
		.reset(reset),                                                ///CTRL_HC ARF
		.rs1_1(rs1_1_id),                                             ///DATA_HC ARF
		.rs2_1(rs2_1_id),                                             ///DATA_HC ARF
		.rs1_2(rs1_2_id),                                             ///DATA_HC ARF
		.rs2_2(rs2_2_id),                                             ///DATA_HC ARF
		.rs1_1data(adat1_1),                                          ///DATA_HC ARF
		.rs2_1data(adat2_1),                                          ///DATA_HC ARF
		.rs1_2data(adat1_2),                                          ///DATA_HC ARF
		.rs2_2data(adat2_2),                                          ///DATA_HC ARF
		.wreg1(dstarf1),                                              ///DATA_HC ARF
		.wreg2(dstarf2),                                              ///DATA_HC ARF
		.wdata1(com1data),                                            ///DATA_HC ARF
		.wdata2(com2data),                                            ///DATA_HC ARF
		.we1(arfwe1),                                                 ///CTRL_HC ARF
		.we2(arfwe2),                                                 ///CTRL_HC ARF
		.wrrfent1(comptr),                                            ///CTRL_HC ARF
		.wrrfent2(comptr2),                                           ///CTRL_HC ARF
		.rs1_1tag(rs1_1tag),                                          ///CTRL_HC ARF
		.rs2_1tag(rs2_1tag),                                          ///CTRL_HC ARF
		.rs1_2tag(rs1_2tag),                                          ///CTRL_HC ARF
		.rs2_2tag(rs2_2tag),                                          ///CTRL_HC ARF
		.tagbusy1_addr(rd_1_id),                                      ///DATA_HC ARF
		.tagbusy2_addr(rd_2_id),                                      ///DATA_HC ARF
		.tagbusy1_we(~inv1_id & ~stall_DP & wr_reg_1_id),             ///CTRL_HC+CTRL_CL ARF
		.tagbusy2_we(~inv2_id & ~stall_DP & wr_reg_2_id),             ///CTRL_HC+CTRL_CL ARF
		.settag1(dst1_renamed),                                       ///CTRL_HC ARF
		.settag2(dst2_renamed),                                       ///CTRL_HC ARF
		.tagbusy1_spectag(sptag1_id),                                 ///CTRL_HC ARF
		.tagbusy2_spectag(sptag2_id),                                 ///CTRL_HC ARF
		.rs1_1busy(abusy1_1),                                         ///CTRL_HC ARF
		.rs2_1busy(abusy2_1),                                         ///CTRL_HC ARF
		.rs1_2busy(abusy1_2),                                         ///CTRL_HC ARF
		.rs2_2busy(abusy2_2),                                         ///CTRL_HC ARF
		.prmiss(prmiss),                                              ///CTRL_HC ARF
		.prsuccess(prsuccess),                                        ///CTRL_HC ARF
		.prtag(buf_spectag_branch),                                   ///CTRL_HC ARF
//		.mpft_valid1(mpft_valid1_id), //PRsuccess & stall Bug
//		.mpft_valid2(mpft_valid2_id)
		.mpft_valid1(mpft_valid &                                     ///CTRL_HC+CTRL_CL ARF
			     (isbranch1_id ? ~sptag1_id : ~(`SPECTAG_LEN'b0)) &   ///CTRL_CL ARF
			     (isbranch2_id ? ~sptag2_id : ~(`SPECTAG_LEN'b0))),   ///CTRL_CL ARF
		.mpft_valid2(mpft_valid &                                     ///CTRL_HC+CTRL_CL ARF
			     (isbranch2_id ? ~sptag2_id : ~(`SPECTAG_LEN'b0)))    ///CTRL_CL ARF
		);
   
   assign	rrftagfix = buf_rrftag_branch + 1;             ///CTRL_CL RRF
   rrf rregfile(                                           ///MD RRF
		.clk(clk),                                         ///CTRL_HC RRF
		.reset(reset),                                     ///CTRL_HC RRF
		.rs1_1tag(rs1_1tag),                               ///CTRL_HC RRF
		.rs2_1tag(rs2_1tag),                               ///CTRL_HC RRF
		.rs1_2tag(rs1_2tag),                               ///CTRL_HC RRF
		.rs2_2tag(rs2_2tag),                               ///CTRL_HC RRF
		.com1tag(comptr),                                  ///CTRL_HC RRF
		.com2tag(comptr2),                                 ///CTRL_HC RRF
		.rs1_1valid(rvalid1_1),                            ///CTRL_HC RRF
		.rs2_1valid(rvalid2_1),                            ///CTRL_HC RRF
		.rs1_2valid(rvalid1_2),                            ///CTRL_HC RRF
		.rs2_2valid(rvalid2_2),                            ///CTRL_HC RRF
		.rs1_1data(rdat1_1),                               ///DATA_HC RRF
		.rs2_1data(rdat2_1),                               ///DATA_HC RRF
		.rs1_2data(rdat1_2),                               ///DATA_HC RRF
		.rs2_2data(rdat2_2),                               ///DATA_HC RRF
		.com1data(com1data),                               ///DATA_HC RRF
		.com2data(com2data),                               ///DATA_HC RRF
		.wrrfaddr1(buf_rrftag_alu1),                       ///CTRL_HC RRF
		.wrrfaddr2(buf_rrftag_alu2),                       ///CTRL_HC RRF
		.wrrfaddr3(wrrftag_ldst),                          ///CTRL_HC RRF
		.wrrfaddr4(buf_rrftag_branch),                     ///CTRL_HC RRF
		.wrrfaddr5(buf_rrftag_mul),                        ///CTRL_HC RRF
		.wrrfdata1(result_alu1),                           ///DATA_HC RRF
		.wrrfdata2(result_alu2),                           ///DATA_HC RRF
		.wrrfdata3(result_ldst),                           ///DATA_HC RRF
		.wrrfdata4(result_branch),                         ///DATA_HC RRF
		.wrrfdata5(result_mul),                            ///DATA_HC RRF
		.wrrfen1(rrfwe_alu1),                              ///CTRL_HC RRF
		.wrrfen2(rrfwe_alu2),                              ///CTRL_HC RRF
		.wrrfen3(rrfwe_ldst),                              ///CTRL_HC RRF
		.wrrfen4(rrfwe_branch),                            ///CTRL_HC RRF
		.wrrfen5(rrfwe_mul),                               ///CTRL_HC RRF
		.dpaddr1(dst1_renamed),                            ///CTRL_HC RRF
		.dpaddr2(dst2_renamed),                            ///CTRL_HC RRF
		.dpen1(~stall_DP & ~kill_DP & ~inv1_id), // hoge   ///CTRL_HC+CTRL_CL RRF
		.dpen2(~stall_DP & ~kill_DP & ~inv2_id)  // hoge   ///CTRL_HC+CTRL_CL RRF
		);


   src_manager srcmng1_1(                                        ///MD DISPATCH
			 .opr(opr1_1),                                       ///DATA_HC DISPATCH
			 .opr_rdy(rdy1_1),                                   ///CTRL_HC DISPATCH
			 .exrslt1(result_alu1),                              ///DATA_HC DISPATCH
			 .exdst1(buf_rrftag_alu1),                           ///CTRL_HC DISPATCH
			 .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),   ///CTRL_HC+CTRL_CL DISPATCH
			 .exrslt2(result_alu2),                              ///DATA_HC DISPATCH
			 .exdst2(buf_rrftag_alu2),                           ///CTRL_HC DISPATCH
			 .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),   ///CTRL_HC+CTRL_CL DISPATCH
			 .exrslt3(result_ldst),                              ///DATA_HC DISPATCH
			 .exdst3(wrrftag_ldst),                              ///CTRL_HC DISPATCH
			 .kill_spec3(kill_speculative_ldst | ~robwe_ldst),   ///CTRL_HC+CTRL_CL DISPATCH
			 .exrslt4(result_branch),                            ///DATA_HC DISPATCH
			 .exdst4(buf_rrftag_branch),                         ///CTRL_HC DISPATCH
			 .kill_spec4(~robwe_branch),                         ///CTRL_HC+CTRL_CL DISPATCH
			 .exrslt5(result_mul),                               ///DATA_HC DISPATCH
			 .exdst5(buf_rrftag_mul),                            ///CTRL_HC DISPATCH
			 .kill_spec5(kill_speculative_mul | ~robwe_mul),     ///CTRL_HC+CTRL_CL DISPATCH
			 .src(src1_1),                                       ///DATA_HC DISPATCH
			 .resolved(resolved1_1)                              ///CTRL_HC DISPATCH
			 );

   src_manager srcmng2_1(                                       ///DC
			 .opr(opr2_1),                                      ///DC
			 .opr_rdy(rdy2_1),                                  ///DC
			 .exrslt1(result_alu1),                             ///DC
			 .exdst1(buf_rrftag_alu1),                          ///DC
			 .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),  ///DC
			 .exrslt2(result_alu2),                             ///DC
			 .exdst2(buf_rrftag_alu2),                          ///DC
			 .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),  ///DC
			 .exrslt3(result_ldst),                             ///DC
			 .exdst3(wrrftag_ldst),                             ///DC
			 .kill_spec3(kill_speculative_ldst | ~robwe_ldst),  ///DC
			 .exrslt4(result_branch),                           ///DC
			 .exdst4(buf_rrftag_branch),                        ///DC
			 .kill_spec4(~robwe_branch),                        ///DC
			 .exrslt5(result_mul),                              ///DC
			 .exdst5(buf_rrftag_mul),                           ///DC
			 .kill_spec5(kill_speculative_mul | ~robwe_mul),    ///DC
			 .src(src2_1),                                      ///DC
			 .resolved(resolved2_1)                             ///DC
			 );                                                 ///DC

   src_manager srcmng1_2(                                       ///DC
			 .opr(opr1_2),                                      ///DC
			 .opr_rdy(rdy1_2),                                  ///DC
			 .exrslt1(result_alu1),                             ///DC
			 .exdst1(buf_rrftag_alu1),                          ///DC
			 .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),  ///DC
			 .exrslt2(result_alu2),                             ///DC
			 .exdst2(buf_rrftag_alu2),                          ///DC
			 .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),  ///DC
			 .exrslt3(result_ldst),                             ///DC
			 .exdst3(wrrftag_ldst),                             ///DC
			 .kill_spec3(kill_speculative_ldst | ~robwe_ldst),  ///DC
			 .exrslt4(result_branch),                           ///DC
			 .exdst4(buf_rrftag_branch),                        ///DC
			 .kill_spec4(~robwe_branch),                        ///DC
			 .exrslt5(result_mul),                              ///DC
			 .exdst5(buf_rrftag_mul),                           ///DC
			 .kill_spec5(kill_speculative_mul | ~robwe_mul),    ///DC
			 .src(src1_2),                                      ///DC
			 .resolved(resolved1_2)                             ///DC
			 );                                                 ///DC

   src_manager srcmng2_2(                                       ///DC
			 .opr(opr2_2),                                      ///DC
			 .opr_rdy(rdy2_2),                                  ///DC
			 .exrslt1(result_alu1),                             ///DC
			 .exdst1(buf_rrftag_alu1),                          ///DC
			 .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),  ///DC
			 .exrslt2(result_alu2),                             ///DC
			 .exdst2(buf_rrftag_alu2),                          ///DC
			 .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),  ///DC
			 .exrslt3(result_ldst),                             ///DC
			 .exdst3(wrrftag_ldst),                             ///DC
			 .kill_spec3(kill_speculative_ldst | ~robwe_ldst),  ///DC
			 .exrslt4(result_branch),                           ///DC
			 .exdst4(buf_rrftag_branch),                        ///DC
			 .kill_spec4(~robwe_branch),                        ///DC
			 .exrslt5(result_mul),                              ///DC
			 .exdst5(buf_rrftag_mul),                           ///DC
			 .kill_spec5(kill_speculative_mul | ~robwe_mul),    ///DC
			 .src(src2_2),                                      ///DC
			 .resolved(resolved2_2)                             ///DC
			 );                                                 ///DC

   imm_gen immgen1(                    ///MD DISPATCH
		   .inst(inst1_id),            ///DATA_HC DISPATCH
		   .imm_type(imm_type_1_id),   ///DATA_HC DISPATCH
		   .imm(imm1)                  ///DATA_HC DISPATCH
		   );

   imm_gen immgen2(                    ///MD DISPATCH
		   .inst(inst2_id),            ///DATA_HC DISPATCH
		   .imm_type(imm_type_2_id),   ///DATA_HC DISPATCH
		   .imm(imm2)                  ///DATA_HC DISPATCH
		   );

   brimm_gen brimmgen1(         ///MD DISPATCH
		       .inst(inst1_id), ///DATA_HC DISPATCH
		       .brimm(brimm1)   ///DATA_HC DISPATCH
		       );

   brimm_gen brimmgen2(         ///MD DISPATCH
		       .inst(inst2_id), ///DATA_HC DISPATCH
		       .brimm(brimm2)   ///DATA_HC DISPATCH
		       );

   rs_requestgenerator rs_reqgen(                 ///MD DISPATCH
				 .rsent_1(rs_ent_1_id),           ///DATA_HC DISPATCH
				 .rsent_2(rs_ent_2_id),           ///DATA_HC DISPATCH
				 .req1_alu(req1_alu),             ///CTRL_HC DISPATCH
				 .req2_alu(req2_alu),             ///CTRL_HC DISPATCH
				 .req_alunum(req_alunum),         ///CTRL_HC DISPATCH
				 .req1_branch(req1_branch),       ///CTRL_HC DISPATCH
				 .req2_branch(req2_branch),       ///CTRL_HC DISPATCH
				 .req_branchnum(req_branchnum),   ///CTRL_HC DISPATCH
				 .req1_mul(req1_mul),             ///CTRL_HC DISPATCH
				 .req2_mul(req2_mul),             ///CTRL_HC DISPATCH
				 .req_mulnum(req_mulnum),         ///CTRL_HC DISPATCH
				 .req1_ldst(req1_ldst),           ///CTRL_HC DISPATCH
				 .req2_ldst(req2_ldst),           ///CTRL_HC DISPATCH
				 .req_ldstnum(req_ldstnum)        ///CTRL_HC DISPATCH
				 );

   
   //Reservation Station(with Allocate unit, Issue unit)
   //lowest bit of allocent is the selector of RS_alu1/2
   assign 		 rsalu1_we1 = ~allocent1_alu[0];      ///CTRL_CL RSV_ALU
   assign 		 rsalu1_we2 = req1_alu ?              ///CTRL_CL RSV_ALU
			 ~allocent2_alu[0] : ~allocent1_alu[0];   ///CTRL_CL RSV_ALU
   assign 		 rsalu2_we1 = allocent1_alu[0];       ///CTRL_CL RSV_ALU
   assign 		 rsalu2_we2 = req1_alu ?              ///CTRL_CL RSV_ALU
			 allocent2_alu[0] : allocent1_alu[0];     ///CTRL_CL RSV_ALU
   
   assign busyvec_alu =                                                         ///CTRL_CL RSV_ALU
			{                                                                   ///CTRL_CL RSV_ALU
			 busyvec_alu2[7],busyvec_alu1[7],busyvec_alu2[6],busyvec_alu1[6],   ///CTRL_CL RSV_ALU
			 busyvec_alu2[5],busyvec_alu1[5],busyvec_alu2[4],busyvec_alu1[4],   ///CTRL_CL RSV_ALU
			 busyvec_alu2[3],busyvec_alu1[3],busyvec_alu2[2],busyvec_alu1[2],   ///CTRL_CL RSV_ALU
			 busyvec_alu2[1],busyvec_alu1[1],busyvec_alu2[0],busyvec_alu1[0]    ///CTRL_CL RSV_ALU
			 };   ///CTRL_CL RSV_ALU

//    assign ready_alu = 
// 		      {
// 		       ready_alu2[7],ready_alu1[7],ready_alu2[6],ready_alu1[6],
// 		       ready_alu2[5],ready_alu1[5],ready_alu2[4],ready_alu1[4],
// 		       ready_alu2[3],ready_alu1[3],ready_alu2[2],ready_alu1[2],
// 		       ready_alu2[1],ready_alu1[1],ready_alu2[0],ready_alu1[0]
// 		       };

   assign 		   issue_alu1 = ~prmiss & issuevalid_alu1;       ///CTRL_CL RSV_ALU
   assign 		   issue_alu2 = ~prmiss & issuevalid_alu2;       ///CTRL_CL RSV_ALU
   
   allocateunit #(2*`ALU_ENT_NUM, `ALU_ENT_SEL+1) alloc_alu(     ///MD RSV_ALU
							    .busy(busyvec_alu), //RS_BUSY    ///CTRL_HC RSV_ALU
							          .en1(),                    ///CTRL_HC RSV_ALU
							          .en2(),                    ///CTRL_HC RSV_ALU
							    .free_ent1(allocent1_alu),       ///CTRL_HC RSV_ALU
							    .free_ent2(allocent2_alu),       ///CTRL_HC RSV_ALU
							    .reqnum(req_alunum),             ///CTRL_HC RSV_ALU
							    .allocatable(allocatable_alu)    ///CTRL_HC RSV_ALU
							    );

   /*
    prioenc #(2*`ALU_ENT_NUM, `ALU_ENT_SEL+1) issue_alu
    (
    .in(~ready_alu),
    .out(issueent_alu),
    .en(issuevalid_alu)
    );
    */
/*
   prioenc #(`ALU_ENT_NUM, `ALU_ENT_SEL) isunt_alu1(
						    .in(~ready_alu1),
						    .out(issueentidx_alu1),
						    .en(issuevalid_alu1)
						    );

   prioenc #(`ALU_ENT_NUM, `ALU_ENT_SEL) isunt_alu2(
						    .in(~ready_alu2),
						    .out(issueentidx_alu2),
						    .en(issuevalid_alu2)
						    );
*/
   assign issuevalid_alu1 = ~entval_alu1[`RRF_SEL+1];   ///CTRL_CL RSV_ALU
   assign issuevalid_alu2 = ~entval_alu2[`RRF_SEL+1];   ///CTRL_CL RSV_ALU
   
   oldest_finder8 isunt_alu1   ///MD RSV_ALU
     (
      .entvec({`ALU_ENT_SEL'h7, `ALU_ENT_SEL'h6, `ALU_ENT_SEL'h5, `ALU_ENT_SEL'h4, ///CTRL_HC+CTRL_CL RSV_ALU
	       `ALU_ENT_SEL'h3, `ALU_ENT_SEL'h2, `ALU_ENT_SEL'h1, `ALU_ENT_SEL'h0}),   ///CTRL_HC+CTRL_CL RSV_ALU
      .valvec(histvect1),                                                          ///CTRL_HC RSV_ALU
      .oldent(issueent_alu1),                                                      ///CTRL_HC RSV_ALU
      .oldval(entval_alu1)                                                         ///CTRL_HC RSV_ALU
      );

   oldest_finder8 isunt_alu2   ///MD RSV_ALU
     (
      .entvec({`ALU_ENT_SEL'h7, `ALU_ENT_SEL'h6, `ALU_ENT_SEL'h5, `ALU_ENT_SEL'h4,   ///CTRL_HC+CTRL_CL RSV_ALU
	       `ALU_ENT_SEL'h3, `ALU_ENT_SEL'h2, `ALU_ENT_SEL'h1, `ALU_ENT_SEL'h0}),     ///CTRL_HC+CTRL_CL RSV_ALU
      .valvec(histvect2),                                                            ///CTRL_HC RSV_ALU
      .oldent(issueent_alu2),                                                        ///CTRL_HC RSV_ALU
      .oldval(entval_alu2)                                                           ///CTRL_HC RSV_ALU
      );
   
   
   rs_alu reserv_alu1(                                                               ///MD RSV_ALU
		      //System
		      .clk(clk),                                                             ///CTRL_HC RSV_ALU
		      .reset(reset),                                                         ///CTRL_HC RSV_ALU
		      .busyvec(busyvec_alu1),                                                ///CTRL_HC RSV_ALU
		      .prmiss(prmiss),                                                       ///CTRL_HC RSV_ALU
		      .prsuccess(prsuccess),                                                 ///CTRL_HC RSV_ALU
		      .prtag(buf_spectag_branch),                                            ///CTRL_HC RSV_ALU
		      .specfixtag(spectagfix),                                               ///CTRL_HC RSV_ALU
		      .histvect(histvect1),                                                  ///CTRL_HC RSV_ALU
		      .nextrrfcyc(nextrrfcyc),                                               ///CTRL_HC RSV_ALU
		      //WriteSignal
		      .clearbusy(issue_alu1), //Issue                                        ///CTRL_HC RSV_ALU
		      .issueaddr(issueent_alu1), //= raddr, clsbsyadr                        ///CTRL_HC RSV_ALU
		      .we1(~stall_DP & ~kill_DP & req1_alu & rsalu1_we1), //alloc1           ///CTRL_HC+CTRL_CL RSV_ALU
		      .we2(~stall_DP & ~kill_DP & req2_alu & rsalu1_we2), //alloc2           ///CTRL_HC+CTRL_CL RSV_ALU
		      .waddr1(allocent1_alu[`ALU_ENT_SEL:1]), //allocent1                    ///CTRL_HC+CTRL_CL RSV_ALU
		      .waddr2(req1_alu ?                                                     ///CTRL_HC+CTRL_CL RSV_ALU
			      allocent2_alu[`ALU_ENT_SEL:1] :                                    ///CTRL_HC RSV_ALU
			      allocent1_alu[`ALU_ENT_SEL:1]), //allocent2                        ///CTRL_HC RSV_ALU
		      //WriteSignal1
		      .wpc_1(pc_id),                              ///DATA_HC RSV_ALU
		      .wsrc1_1(src1_1),                           ///DATA_HC RSV_ALU
		      .wsrc2_1(src2_1),                           ///DATA_HC RSV_ALU
		      .wvalid1_1(~uses_rs1_1_id | resolved1_1),   ///CTRL_HC+CTRL_CL RSV_ALU
		      .wvalid2_1(~uses_rs2_1_id | resolved2_1),   ///CTRL_HC+CTRL_CL RSV_ALU
		      .wimm_1(imm1),   ///DATA_HC RSV_ALU
		      .wrrftag_1(dst1_renamed),                   ///CTRL_HC RSV_ALU
		      .wdstval_1(wr_reg_1_id),                    ///CTRL_HC RSV_ALU
		      .wsrc_a_1(src_a_sel_1_id),                  ///DATA_HC RSV_ALU
		      .wsrc_b_1(src_b_sel_1_id),                  ///DATA_HC RSV_ALU
		      .walu_op_1(alu_op_1_id),                    ///DATA_HC RSV_ALU
		      .wspectag_1(sptag1_id),                     ///CTRL_HC RSV_ALU
		      .wspecbit_1(spec1_id),                      ///CTRL_HC RSV_ALU
		      //WriteSignal2
		      .wpc_2(pc_id + 4),                          ///DC
		      .wsrc1_2(src1_2),                           ///DC
		      .wsrc2_2(src2_2),                           ///DC
		      .wvalid1_2(~uses_rs1_2_id | resolved1_2),   ///DC
		      .wvalid2_2(~uses_rs2_2_id | resolved2_2),   ///DC
		      .wimm_2(imm2),                              ///DC
		      .wrrftag_2(dst2_renamed),                   ///DC
		      .wdstval_2(wr_reg_2_id),                    ///DC
		      .wsrc_a_2(src_a_sel_2_id),                  ///DC
		      .wsrc_b_2(src_b_sel_2_id),                  ///DC
		      .walu_op_2(alu_op_2_id),                    ///DC
		      .wspectag_2(sptag2_id),                     ///DC
		      .wspecbit_2(spec2_id),                      ///DC
		      //ReadSignal
		      .ex_src1(ex_src1_alu1),                     ///DATA_HC RSV_ALU
		      .ex_src2(ex_src2_alu1),                     ///DATA_HC RSV_ALU
		      .ready(ready_alu1),                         ///CTRL_HC RSV_ALU
		      .pc(pc_alu1),                               ///DATA_HC RSV_ALU
		      .imm(imm_alu1),                             ///DATA_HC RSV_ALU
		      .rrftag(rrftag_alu1),                       ///CTRL_HC RSV_ALU
		      .dstval(dstval_alu1),                       ///CTRL_HC RSV_ALU
		      .src_a(src_a_alu1),                         ///DATA_HC RSV_ALU
		      .src_b(src_b_alu1),                         ///DATA_HC RSV_ALU
		      .alu_op(alu_op_alu1),                       ///DATA_HC RSV_ALU
		      .spectag(spectag_alu1),                     ///CTRL_HC RSV_ALU
		      .specbit(specbit_alu1),                     ///CTRL_HC RSV_ALU
		      //EXRSLT
		      .exrslt1(result_alu1),                              ///DATA_HC RSV_ALU
		      .exdst1(buf_rrftag_alu1),                           ///CTRL_HC RSV_ALU
		      .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),   ///CTRL_HC+CTRL_CL RSV_ALU
		      .exrslt2(result_alu2),                              ///DATA_HC RSV_ALU
		      .exdst2(buf_rrftag_alu2),                           ///CTRL_HC RSV_ALU
		      .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),   ///CTRL_HC+CTRL_CL RSV_ALU
		      .exrslt3(result_ldst),                              ///DATA_HC RSV_ALU
		      .exdst3(wrrftag_ldst),                              ///CTRL_HC RSV_ALU
		      .kill_spec3(kill_speculative_ldst | ~robwe_ldst),   ///CTRL_HC+CTRL_CL RSV_ALU
		      .exrslt4(result_branch),                            ///DATA_HC RSV_ALU
		      .exdst4(buf_rrftag_branch),                         ///CTRL_HC RSV_ALU
		      .kill_spec4(~robwe_branch),                         ///CTRL_HC+CTRL_CL RSV_ALU
		      .exrslt5(result_mul),                               ///DATA_HC RSV_ALU
		      .exdst5(buf_rrftag_mul),                            ///CTRL_HC RSV_ALU
		      .kill_spec5(kill_speculative_mul | ~robwe_mul)      ///CTRL_HC+CTRL_CL RSV_ALU
		      );

   rs_alu reserv_alu2(                                                      ///DC
		      //System                                                      ///DC
		      .clk(clk),                                                    ///DC
		      .reset(reset),                                                ///DC
		      .busyvec(busyvec_alu2),                                       ///DC
		      .prmiss(prmiss),                                              ///DC
		      .prsuccess(prsuccess),                                        ///DC
		      .prtag(buf_spectag_branch),                                   ///DC
		      .specfixtag(spectagfix),                                      ///DC
		      .histvect(histvect2),                                         ///DC
		      .nextrrfcyc(nextrrfcyc),                                      ///DC
		      //WriteSignal                                                 ///DC
		      .clearbusy(issue_alu2), //Issue                               ///DC
		      .issueaddr(issueent_alu2), //= raddr, clsbsyadr               ///DC
		      .we1(~stall_DP & ~kill_DP & req1_alu & rsalu2_we1), //alloc1  ///DC
		      .we2(~stall_DP & ~kill_DP & req2_alu & rsalu2_we2), //alloc2  ///DC
		      .waddr1(allocent1_alu[`ALU_ENT_SEL:1]), //allocent1           ///DC
		      .waddr2(req1_alu ?                                            ///DC
			      allocent2_alu[`ALU_ENT_SEL:1] :                           ///DC
			      allocent1_alu[`ALU_ENT_SEL:1]), //allocent2               ///DC
		      //WriteSignal1                                                ///DC
		      .wpc_1(pc_id),                                                ///DC
		      .wsrc1_1(src1_1),                                             ///DC
		      .wsrc2_1(src2_1),                                             ///DC
		      .wvalid1_1(~uses_rs1_1_id | resolved1_1),                     ///DC
		      .wvalid2_1(~uses_rs2_1_id | resolved2_1),                     ///DC
		      .wimm_1(imm1),                                                ///DC
		      .wrrftag_1(dst1_renamed),                                     ///DC
		      .wdstval_1(wr_reg_1_id),                                      ///DC
		      .wsrc_a_1(src_a_sel_1_id),                                    ///DC
		      .wsrc_b_1(src_b_sel_1_id),                                    ///DC
		      .walu_op_1(alu_op_1_id),                                      ///DC
		      .wspectag_1(sptag1_id),                                       ///DC
		      .wspecbit_1(spec1_id),                                        ///DC
		      //WriteSignal2                                                ///DC
		      .wpc_2(pc_id + 4),                                            ///DC
		      .wsrc1_2(src1_2),                                             ///DC
		      .wsrc2_2(src2_2),                                             ///DC
		      .wvalid1_2(~uses_rs1_2_id | resolved1_2),                     ///DC
		      .wvalid2_2(~uses_rs2_2_id | resolved2_2),                     ///DC
		      .wimm_2(imm2),                                                ///DC
		      .wrrftag_2(dst2_renamed),                                     ///DC
		      .wdstval_2(wr_reg_2_id),                                      ///DC
		      .wsrc_a_2(src_a_sel_2_id),                                    ///DC
		      .wsrc_b_2(src_b_sel_2_id),                                    ///DC
		      .walu_op_2(alu_op_2_id),                                      ///DC
		      .wspectag_2(sptag2_id),                                       ///DC
		      .wspecbit_2(spec2_id),                                        ///DC
		      //ReadSignal                                                  ///DC
		      .ex_src1(ex_src1_alu2),                                       ///DC
		      .ex_src2(ex_src2_alu2),                                       ///DC
		      .ready(ready_alu2),                                           ///DC
		      .pc(pc_alu2),                                                 ///DC
		      .imm(imm_alu2),                                               ///DC
		      .rrftag(rrftag_alu2),                                         ///DC
		      .dstval(dstval_alu2),                                         ///DC
		      .src_a(src_a_alu2),                                           ///DC
		      .src_b(src_b_alu2),                                           ///DC
		      .alu_op(alu_op_alu2),                                         ///DC
		      .spectag(spectag_alu2),                                       ///DC
		      .specbit(specbit_alu2),                                       ///DC
		      //EXRSLT                                                      ///DC
		      .exrslt1(result_alu1),                                        ///DC
		      .exdst1(buf_rrftag_alu1),                                     ///DC
		      .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),             ///DC
		      .exrslt2(result_alu2),                                        ///DC
		      .exdst2(buf_rrftag_alu2),                                     ///DC
		      .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),             ///DC
		      .exrslt3(result_ldst),                                        ///DC
		      .exdst3(wrrftag_ldst),                                        ///DC
		      .kill_spec3(kill_speculative_ldst | ~robwe_ldst),             ///DC
		      .exrslt4(result_branch),                                      ///DC
		      .exdst4(buf_rrftag_branch),                                   ///DC
		      .kill_spec4(~robwe_branch),                                   ///DC
		      .exrslt5(result_mul),                                         ///DC
		      .exdst5(buf_rrftag_mul),                                      ///DC
		      .kill_spec5(kill_speculative_mul | ~robwe_mul)                ///DC
		      );                                                            ///DC


   assign allocent2_ldst = allocent1_ldst + 1;               ///CTRL_CL RSV_LDST
   assign issue_ldst = ~prmiss & issuevalid_ldst;            ///CTRL_CL RSV_LDST

   alloc_issue_ino #(`LDST_ENT_SEL, `LDST_ENT_NUM) ai_ldst   ///MD RSV_LDST
     (
      .clk(clk),                              ///CTRL_HC RSV_LDST
      .reset(reset),                          ///CTRL_HC RSV_LDST
      .reqnum(req_ldstnum),                   ///CTRL_HC RSV_LDST
      .busyvec(busyvec_ldst),                 ///CTRL_HC RSV_LDST
      .prbusyvec_next(prbusyvec_next_ldst),   ///CTRL_HC RSV_LDST
      .readyvec(ready_ldst),                  ///CTRL_HC RSV_LDST
      .prmiss(prmiss),                        ///CTRL_HC RSV_LDST
      .exunit_busynext(busy_next_ldst),       ///CTRL_HC RSV_LDST
      .stall_DP(stall_DP),                    ///CTRL_HC RSV_LDST
      .kill_DP(kill_DP),                      ///CTRL_HC RSV_LDST
      .allocptr(allocent1_ldst),              ///CTRL_HC RSV_LDST
      .allocatable(allocatable_ldst),         ///CTRL_HC RSV_LDST
      .issueptr(issueent_ldst),               ///CTRL_HC RSV_LDST
      .issuevalid(issuevalid_ldst)            ///CTRL_HC RSV_LDST
      );
   
   rs_ldst reserv_ldst(                                ///MD RSV_LDST
		       //System
		       .clk(clk),                              ///CTRL_HC RSV_LDST
		       .reset(reset),                          ///CTRL_HC RSV_LDST
		       .busyvec(busyvec_ldst),                 ///CTRL_HC RSV_LDST
		       .prmiss(prmiss),                        ///CTRL_HC RSV_LDST
		       .prsuccess(prsuccess),                  ///CTRL_HC RSV_LDST
		       .prtag(buf_spectag_branch),             ///CTRL_HC RSV_LDST
		       .specfixtag(spectagfix),                ///CTRL_HC RSV_LDST
		       .prbusyvec_next(prbusyvec_next_ldst),   ///CTRL_HC RSV_LDST
		       //WriteSignal
		       .clearbusy(issue_ldst), //Issue                     ///CTRL_HC RSV_LDST
		       .issueaddr(issueent_ldst), //= raddr, clsbsyadr     ///CTRL_HC RSV_LDST
		       .we1(~stall_DP & ~kill_DP & req1_ldst), //alloc1    ///CTRL_HC+CTRL_CL RSV_LDST
		       .we2(~stall_DP & ~kill_DP & req2_ldst), //alloc2    ///CTRL_HC+CTRL_CL RSV_LDST
		       .waddr1(allocent1_ldst), //allocent1                ///CTRL_HC RSV_LDST
		       .waddr2(req1_ldst ?                                 ///CTRL_HC+CTRL_CL RSV_LDST
			       allocent2_ldst : allocent1_ldst), //allocent2   ///CTRL_HC RSV_LDST
		       //WriteSignal1
		       .wpc_1(pc_id),                                      ///DATA_HC RSV_LDST
		       .wsrc1_1(src1_1),                                   ///DATA_HC RSV_LDST
		       .wsrc2_1(src2_1),                                   ///DATA_HC RSV_LDST
		       .wvalid1_1(~uses_rs1_1_id | resolved1_1),           ///CTRL_HC+CTRL_CL RSV_LDST
		       .wvalid2_1(~uses_rs2_1_id | resolved2_1),           ///CTRL_HC+CTRL_CL RSV_LDST
		       .wimm_1(imm1),                                      ///DATA_HC RSV_LDST
		       .wrrftag_1(dst1_renamed),                           ///CTRL_HC RSV_LDST
		       .wdstval_1(wr_reg_1_id),                            ///CTRL_HC RSV_LDST
		       .wspectag_1(sptag1_id),                             ///CTRL_HC RSV_LDST
		       .wspecbit_1(spec1_id),                              ///CTRL_HC RSV_LDST
		       //WriteSignal2
		       .wpc_2(pc_id + 4),                                  ///DC
		       .wsrc1_2(src1_2),                                   ///DC
		       .wsrc2_2(src2_2),                                   ///DC
		       .wvalid1_2(~uses_rs1_2_id | resolved1_2),           ///DC
		       .wvalid2_2(~uses_rs2_2_id | resolved2_2),           ///DC
		       .wimm_2(imm2),                                      ///DC
		       .wrrftag_2(dst2_renamed),                           ///DC
		       .wdstval_2(wr_reg_2_id),                            ///DC
		       .wspectag_2(sptag2_id),                             ///DC
		       .wspecbit_2(spec2_id),                              ///DC
		       //ReadSignal
		       .ex_src1(ex_src1_ldst),                             ///DATA_HC RSV_LDST
		       .ex_src2(ex_src2_ldst),                             ///DATA_HC RSV_LDST
		       .ready(ready_ldst),                                 ///CTRL_HC RSV_LDST
		       .pc(pc_ldst),                                       ///DATA_HC RSV_LDST
		       .imm(imm_ldst),                                     ///DATA_HC RSV_LDST
		       .rrftag(rrftag_ldst),                               ///CTRL_HC RSV_LDST
		       .dstval(dstval_ldst),                               ///CTRL_HC RSV_LDST
		       .spectag(spectag_ldst),                             ///CTRL_HC RSV_LDST
		       .specbit(specbit_ldst),                             ///CTRL_HC RSV_LDST
		       //EXRSLT
		       .exrslt1(result_alu1),                              ///DATA_HC RSV_LDST
		       .exdst1(buf_rrftag_alu1),                           ///CTRL_HC RSV_LDST
		       .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),   ///CTRL_HC+CTRL_CL RSV_LDST
		       .exrslt2(result_alu2),                              ///DATA_HC RSV_LDST
		       .exdst2(buf_rrftag_alu2),                           ///CTRL_HC RSV_LDST
		       .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),   ///CTRL_HC+CTRL_CL RSV_LDST
		       .exrslt3(result_ldst),                              ///DATA_HC RSV_LDST
		       .exdst3(wrrftag_ldst),                              ///CTRL_HC RSV_LDST
		       .kill_spec3(kill_speculative_ldst | ~robwe_ldst),   ///CTRL_HC+CTRL_CL RSV_LDST
		       .exrslt4(result_branch),                            ///DATA_HC RSV_LDST
		       .exdst4(buf_rrftag_branch),                         ///CTRL_HC RSV_LDST
		       .kill_spec4(~robwe_branch),                         ///CTRL_HC+CTRL_CL RSV_LDST
		       .exrslt5(result_mul),                               ///DATA_HC RSV_LDST
		       .exdst5(buf_rrftag_mul),                            ///CTRL_HC RSV_LDST
		       .kill_spec5(kill_speculative_mul | ~robwe_mul)      ///CTRL_HC+CTRL_CL RSV_LDST
		       );


   assign allocent2_branch = allocent1_branch + 1;         ///CTRL_CL RSV_BRANCH
   assign issue_branch = ~prmiss & issuevalid_branch;      ///CTRL_CL RSV_BRANCH
   
   alloc_issue_ino ai_branch(                              ///MD RSV_BRANCH
			     .clk(clk),                                ///CTRL_HC RSV_BRANCH
			     .reset(reset),                            ///CTRL_HC RSV_BRANCH
			     .reqnum(req_branchnum),                   ///CTRL_HC RSV_BRANCH
			     .busyvec(busyvec_branch),                 ///CTRL_HC RSV_BRANCH
			     .prbusyvec_next(prbusyvec_next_branch),   ///CTRL_HC RSV_BRANCH
			     .readyvec(ready_branch),                  ///CTRL_HC RSV_BRANCH
			     .prmiss(prmiss),                          ///CTRL_HC RSV_BRANCH
			     .exunit_busynext(1'b0),                   ///CTRL_HC RSV_BRANCH
			     .stall_DP(stall_DP),                      ///CTRL_HC RSV_BRANCH
			     .kill_DP(kill_DP),                        ///CTRL_HC RSV_BRANCH
			     .allocptr(allocent1_branch),              ///CTRL_HC RSV_BRANCH
			     .allocatable(allocatable_branch),         ///CTRL_HC RSV_BRANCH
			     .issueptr(issueent_branch),               ///CTRL_HC RSV_BRANCH
			     .issuevalid(issuevalid_branch)            ///CTRL_HC RSV_BRANCH
			     );
   
   rs_branch reserv_branch(                                            ///MD RSV_BRANCH
			   //System
			   .clk(clk),                                              ///CTRL_HC RSV_BRANCH
			   .reset(reset),                                          ///CTRL_HC RSV_BRANCH
			   .busyvec(busyvec_branch),                               ///CTRL_HC RSV_BRANCH
			   .prmiss(prmiss),                                        ///CTRL_HC RSV_BRANCH
			   .prsuccess(prsuccess),                                  ///CTRL_HC RSV_BRANCH
			   .prtag(buf_spectag_branch),                             ///CTRL_HC RSV_BRANCH
			   .specfixtag(spectagfix),                                ///CTRL_HC RSV_BRANCH
			   .prbusyvec_next(prbusyvec_next_branch),                 ///CTRL_HC RSV_BRANCH
			   //WriteSignal
			   .clearbusy(issue_branch), //Issue                       ///CTRL_HC RSV_BRANCH
			   .issueaddr(issueent_branch), //= raddr, clsbsyadr       ///CTRL_HC RSV_BRANCH
			   .we1(~stall_DP & ~kill_DP & req1_branch), //alloc1      ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .we2(~stall_DP & ~kill_DP & req2_branch), //alloc2      ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .waddr1(allocent1_branch), //allocent1                  ///CTRL_HC RSV_BRANCH
			   .waddr2(req1_branch ?                                   ///CTRL_HC+CTRL_CL RSV_BRANCH
				   allocent2_branch : allocent1_branch), //allocent2   ///CTRL_HC RSV_BRANCH
			   //WriteSignal1
			   .wpc_1(pc_id),                                          ///DATA_HC RSV_BRANCH
			   .wsrc1_1(src1_1),                                       ///DATA_HC RSV_BRANCH
			   .wsrc2_1(src2_1),                                       ///DATA_HC RSV_BRANCH
			   .wvalid1_1(~uses_rs1_1_id | resolved1_1),               ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .wvalid2_1(~uses_rs2_1_id | resolved2_1),               ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .wimm_1(brimm1),                                        ///DATA_HC RSV_BRANCH
               .wrrftag_1(dst1_renamed),                               ///CTRL_HC RSV_BRANCH
               .wdstval_1(wr_reg_1_id),                                ///CTRL_HC RSV_BRANCH
               .walu_op_1(alu_op_1_id),                                ///DATA_HC RSV_BRANCH
               .wspectag_1(sptag1_id),                                 ///CTRL_HC RSV_BRANCH
               .wspecbit_1(spec1_id),                                  ///CTRL_HC RSV_BRANCH
			   .wbhr_1(bhr_id),                                        ///DC
			   .wprcond_1(prcond1_id),                                 ///DC
			   .wpraddr_1(praddr1_id),                                 ///DATA_HC RSV_BRANCH
			   .wopcode_1(inst1_id[6:0]),                              ///DATA_HC+DATA_CL RSV_BRANCH
			   //WriteSignal2
			   .wpc_2(pc_id + 4),                                      ///DC
			   .wsrc1_2(src1_2),                                       ///DC
			   .wsrc2_2(src2_2),                                       ///DC
			   .wvalid1_2(~uses_rs1_2_id | resolved1_2),               ///DC
			   .wvalid2_2(~uses_rs2_2_id | resolved2_2),               ///DC
			   .wimm_2(brimm2),                                        ///DC
			   .wrrftag_2(dst2_renamed),                               ///DC
			   .wdstval_2(wr_reg_2_id),                                ///DC
			   .walu_op_2(alu_op_2_id),                                ///DC
			   .wspectag_2(sptag2_id),                                 ///DC
			   .wspecbit_2(spec2_id),                                  ///DC
			   .wbhr_2(bhr_id),                                        ///DC
			   .wprcond_2(prcond2_id),                                 ///DC
			   .wpraddr_2(praddr2_id),                                 ///DC
			   .wopcode_2(inst2_id[6:0]),                              ///DC
			   //ReadSignal
			   .ex_src1(ex_src1_branch),                               ///DATA_HC RSV_BRANCH
			   .ex_src2(ex_src2_branch),                               ///DATA_HC RSV_BRANCH
			   .ready(ready_branch),                                   ///CTRL_HC RSV_BRANCH
			   .pc(pc_branch),                                         ///DATA_HC RSV_BRANCH
			   .imm(imm_branch),                                       ///DATA_HC RSV_BRANCH
			   .rrftag(rrftag_branch),                                 ///CTRL_HC RSV_BRANCH
			   .dstval(dstval_branch),                                 ///CTRL_HC RSV_BRANCH
			   .alu_op(alu_op_branch),                                 ///DATA_HC RSV_BRANCH
			   .spectag(spectag_branch),                               ///CTRL_HC RSV_BRANCH
			   .specbit(specbit_branch),                               ///CTRL_HC RSV_BRANCH
			   .bhr(bhr_branch),                                       ///DC
			   .prcond(prcond_branch),                                 ///DC
			   .praddr(praddr_branch),                                 ///DATA_HC RSV_BRANCH
			   .opcode(opcode_branch),                                 ///DATA_HC RSV_BRANCH
			   //EXRSLT
			   .exrslt1(result_alu1),                                  ///DATA_HC RSV_BRANCH
			   .exdst1(buf_rrftag_alu1),                               ///CTRL_HC RSV_BRANCH
			   .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),       ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .exrslt2(result_alu2),                                  ///DATA_HC RSV_BRANCH
			   .exdst2(buf_rrftag_alu2),                               ///CTRL_HC RSV_BRANCH
			   .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),       ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .exrslt3(result_ldst),                                  ///DATA_HC RSV_BRANCH
			   .exdst3(wrrftag_ldst),                                  ///CTRL_HC RSV_BRANCH
			   .kill_spec3(kill_speculative_ldst | ~robwe_ldst),       ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .exrslt4(result_branch),                                ///DATA_HC RSV_BRANCH
			   .exdst4(buf_rrftag_branch),                             ///CTRL_HC RSV_BRANCH
			   .kill_spec4(~robwe_branch),                             ///CTRL_HC+CTRL_CL RSV_BRANCH
			   .exrslt5(result_mul),                                   ///DATA_HC RSV_BRANCH
			   .exdst5(buf_rrftag_mul),                                ///CTRL_HC RSV_BRANCH
			   .kill_spec5(kill_speculative_mul | ~robwe_mul)          ///CTRL_HC+CTRL_CL RSV_BRANCH
			   );

   assign issue_mul = ~prmiss & issuevalid_mul;                     ///CTRL_CL RSV_MUL

   allocateunit #(`MUL_ENT_NUM, `MUL_ENT_SEL) alloc_mul(            ///MD RSV_MUL
							.busy(busyvec_mul), //RS_BUSY           ///CTRL_HC RSV_MUL
							      .en1(),                           ///CTRL_HC RSV_MUL
							      .en2(),                           ///CTRL_HC RSV_MUL
							.free_ent1(allocent1_mul),              ///CTRL_HC RSV_MUL
							.free_ent2(allocent2_mul),              ///CTRL_HC RSV_MUL
							.reqnum(req_mulnum),                    ///CTRL_HC RSV_MUL
							.allocatable(allocatable_mul)           ///CTRL_HC RSV_MUL
							);

   prioenc #(`MUL_ENT_NUM, `MUL_ENT_SEL) isunt_mul(                 ///MD RSV_MUL
						   .in(~ready_mul),                         ///CTRL_HC+CTRL_CL RSV_MUL
						   .out(issueent_mul),                      ///CTRL_HC RSV_MUL
						   .en(issuevalid_mul)                      ///CTRL_HC RSV_MUL
						   );
   
   rs_mul reserv_mul(                                                ///MD RSV_MUL
		     //System
		     .clk(clk),                                              ///CTRL_HC RSV_MUL
		     .reset(reset),                                          ///CTRL_HC RSV_MUL
		     .busyvec(busyvec_mul),                                  ///CTRL_HC RSV_MUL
		     .prmiss(prmiss),                                        ///CTRL_HC RSV_MUL
		     .prsuccess(prsuccess),                                  ///CTRL_HC RSV_MUL
		     .prtag(buf_spectag_branch),                             ///CTRL_HC RSV_MUL
		     .specfixtag(spectagfix),                                ///CTRL_HC RSV_MUL
		     //WriteSignal
		     .clearbusy(issue_mul), //Issue                          ///CTRL_HC RSV_MUL
		     .issueaddr(issueent_mul), //= raddr, clsbsyadr          ///CTRL_HC RSV_MUL
		     .we1(~stall_DP & ~kill_DP & req1_mul), //alloc1         ///CTRL_HC+CTRL_CL RSV_MUL
		     .we2(~stall_DP & ~kill_DP & req2_mul), //alloc2         ///CTRL_HC+CTRL_CL RSV_MUL
		     .waddr1(allocent1_mul), //allocent1                     ///CTRL_HC RSV_MUL
		     .waddr2(req1_mul ?                                      ///CTRL_HC+CTRL_CL RSV_MUL
			     allocent2_mul : allocent1_mul), //allocent2         ///CTRL_HC RSV_MUL
		     //WriteSignal1
		     .wsrc1_1(src1_1),                                       ///DATA_HC RSV_MUL
		     .wsrc2_1(src2_1),                                       ///DATA_HC RSV_MUL
		     .wvalid1_1(~uses_rs1_1_id | resolved1_1),               ///CTRL_HC+CTRL_CL RSV_MUL
		     .wvalid2_1(~uses_rs2_1_id | resolved2_1),               ///CTRL_HC+CTRL_CL RSV_MUL
		     .wrrftag_1(dst1_renamed),                               ///CTRL_HC RSV_MUL
		     .wdstval_1(wr_reg_1_id),                                ///CTRL_HC RSV_MUL
		     .wspectag_1(sptag1_id),                                 ///CTRL_HC RSV_MUL
		     .wspecbit_1(spec1_id),                                  ///CTRL_HC RSV_MUL
		     .wsrc1_signed_1(md_req_in_1_signed_1_id),               ///DATA_HC RSV_MUL
		     .wsrc2_signed_1(md_req_in_2_signed_1_id),               ///DATA_HC RSV_MUL
		     .wsel_lohi_1(md_req_out_sel_1_id[0]),                   ///DATA_HC RSV_MUL
		     //WriteSignal2
		     .wsrc1_2(src1_2),                          ///DC
		     .wsrc2_2(src2_2),                          ///DC
		     .wvalid1_2(~uses_rs1_2_id | resolved1_2),  ///DC
		     .wvalid2_2(~uses_rs2_2_id | resolved2_2),  ///DC
		     .wrrftag_2(dst2_renamed),                  ///DC
		     .wdstval_2(wr_reg_2_id),                   ///DC
		     .wspectag_2(sptag2_id),                    ///DC
		     .wspecbit_2(spec2_id),                     ///DC
		     .wsrc1_signed_2(md_req_in_1_signed_2_id),  ///DC
		     .wsrc2_signed_2(md_req_in_2_signed_2_id),  ///DC
		     .wsel_lohi_2(md_req_out_sel_2_id[0]),      ///DC
		     //ReadSignal
		     .ex_src1(ex_src1_mul),                            ///DATA_HC RSV_MUL
		     .ex_src2(ex_src2_mul),                            ///DATA_HC RSV_MUL
		     .ready(ready_mul),                                ///CTRL_HC RSV_MUL
		     .rrftag(rrftag_mul),                              ///CTRL_HC RSV_MUL
		     .dstval(dstval_mul),                              ///CTRL_HC RSV_MUL
		     .spectag(spectag_mul),                            ///CTRL_HC RSV_MUL
		     .specbit(specbit_mul),                            ///CTRL_HC RSV_MUL
		     .src1_signed(src1_signed_mul),                    ///DATA_HC RSV_MUL
		     .src2_signed(src2_signed_mul),                    ///DATA_HC RSV_MUL
		     .sel_lohi(sel_lohi_mul),                          ///DATA_HC RSV_MUL
		     //EXRSLT
		     .exrslt1(result_alu1),                              ///DATA_HC RSV_MUL
		     .exdst1(buf_rrftag_alu1),                           ///CTRL_HC RSV_MUL
		     .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),   ///CTRL_HC+CTRL_CL RSV_MUL
		     .exrslt2(result_alu2),                              ///DATA_HC RSV_MUL
		     .exdst2(buf_rrftag_alu2),                           ///CTRL_HC RSV_MUL
		     .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),   ///CTRL_HC+CTRL_CL RSV_MUL
		     .exrslt3(result_ldst),                              ///DATA_HC RSV_MUL
		     .exdst3(wrrftag_ldst),                              ///CTRL_HC RSV_MUL
		     .kill_spec3(kill_speculative_ldst | ~robwe_ldst),   ///CTRL_HC+CTRL_CL RSV_MUL
		     .exrslt4(result_branch),                            ///DATA_HC RSV_MUL
		     .exdst4(buf_rrftag_branch),                         ///CTRL_HC RSV_MUL
		     .kill_spec4(~robwe_branch),                         ///CTRL_HC+CTRL_CL RSV_MUL
		     .exrslt5(result_mul),                               ///DATA_HC RSV_MUL
		     .exdst5(buf_rrftag_mul),                            ///CTRL_HC RSV_MUL
		     .kill_spec5(kill_speculative_mul | ~robwe_mul)      ///CTRL_HC+CTRL_CL RSV_MUL
		     );
   
   //EX Stage********************************************************

   always @ (posedge clk) begin          ///CTRL_CL EXEC_ALU
      if (reset) begin                   ///CTRL_CL EXEC_ALU
	 buf_ex_src1_alu1 <= 0;              ///DATA_DT EXEC_ALU
	 buf_ex_src2_alu1 <= 0;              ///DATA_DT EXEC_ALU
	 buf_pc_alu1 <= 0;                   ///DATA_DT EXEC_ALU
	 buf_imm_alu1 <= 0;                  ///DATA_DT EXEC_ALU
	 buf_rrftag_alu1 <= 0;               ///CTRL_DT EXEC_ALU
	 buf_dstval_alu1 <= 0;               ///CTRL_DT EXEC_ALU
	 buf_src_a_alu1 <= 0;                ///DATA_DT EXEC_ALU
	 buf_src_b_alu1 <= 0;                ///DATA_DT EXEC_ALU
	 buf_alu_op_alu1 <= 0;               ///DATA_DT EXEC_ALU
	 buf_spectag_alu1 <= 0;              ///CTRL_DT EXEC_ALU
	 buf_specbit_alu1 <= 0;              ///CTRL_DT EXEC_ALU
      end else if (issue_alu1) begin     ///CTRL_CL EXEC_ALU
	 buf_ex_src1_alu1 <= ex_src1_alu1;   ///DATA_DT EXEC_ALU
	 buf_ex_src2_alu1 <= ex_src2_alu1;   ///DATA_DT EXEC_ALU
	 buf_pc_alu1 <= pc_alu1;             ///DATA_DT EXEC_ALU
	 buf_imm_alu1 <= imm_alu1;           ///DATA_DT EXEC_ALU
	 buf_rrftag_alu1 <= rrftag_alu1;     ///CTRL_DT EXEC_ALU
	 buf_dstval_alu1 <= dstval_alu1;     ///CTRL_DT EXEC_ALU
	 buf_src_a_alu1 <= src_a_alu1;       ///DATA_DT EXEC_ALU
	 buf_src_b_alu1 <= src_b_alu1;       ///DATA_DT EXEC_ALU
	 buf_alu_op_alu1 <= alu_op_alu1;     ///DATA_DT EXEC_ALU
	 buf_spectag_alu1 <= spectag_alu1;   ///CTRL_DT EXEC_ALU
	 buf_specbit_alu1 <= specbit_alu1;   ///CTRL_DT EXEC_ALU
      end
   end
   
   exunit_alu byakko(                                   ///MD EXEC_ALU
		     .clk(clk),                                 ///CTRL_HC EXEC_ALU
		     .reset(reset),                             ///CTRL_HC EXEC_ALU
		     .ex_src1(buf_ex_src1_alu1),                ///DATA_HC EXEC_ALU
		     .ex_src2(buf_ex_src2_alu1),                ///DATA_HC EXEC_ALU
		     .pc(buf_pc_alu1),                          ///DATA_HC EXEC_ALU
		     .imm(buf_imm_alu1),                        ///DATA_HC EXEC_ALU
		     .dstval(buf_dstval_alu1),                  ///CTRL_HC EXEC_ALU
		     .src_a(buf_src_a_alu1),                    ///DATA_HC EXEC_ALU
		     .src_b(buf_src_b_alu1),                    ///DATA_HC EXEC_ALU
		     .alu_op(buf_alu_op_alu1),                  ///DATA_HC EXEC_ALU
		     .spectag(buf_spectag_alu1),                ///CTRL_HC EXEC_ALU
		     .specbit(buf_specbit_alu1),                ///CTRL_HC EXEC_ALU
		     .issue(issue_alu1),                        ///CTRL_HC EXEC_ALU
		     .prmiss(prmiss),                           ///CTRL_HC EXEC_ALU
		     .spectagfix(spectagfix),                   ///CTRL_HC EXEC_ALU
		     .result(result_alu1),                      ///DATA_HC EXEC_ALU
		     .rrf_we(rrfwe_alu1),                       ///CTRL_HC EXEC_ALU
		     .rob_we(robwe_alu1),                       ///CTRL_HC EXEC_ALU
		     .kill_speculative(kill_speculative_alu1)   ///CTRL_HC EXEC_ALU
		     );

   always @ (posedge clk) begin             ///DC
      if (reset) begin                      ///DC
	 buf_ex_src1_alu2 <= 0;                 ///DC
	 buf_ex_src2_alu2 <= 0;                 ///DC
	 buf_pc_alu2 <= 0;                      ///DC
	 buf_imm_alu2 <= 0;                     ///DC
	 buf_rrftag_alu2 <= 0;                  ///DC
	 buf_dstval_alu2 <= 0;                  ///DC
	 buf_src_a_alu2 <= 0;                   ///DC
	 buf_src_b_alu2 <= 0;                   ///DC
	 buf_alu_op_alu2 <= 0;                  ///DC
	 buf_spectag_alu2 <= 0;                 ///DC
	 buf_specbit_alu2 <= 0;                 ///DC
      end else if (issue_alu2) begin        ///DC
	 buf_ex_src1_alu2 <= ex_src1_alu2;      ///DC
	 buf_ex_src2_alu2 <= ex_src2_alu2;      ///DC
	 buf_pc_alu2 <= pc_alu2;                ///DC
	 buf_imm_alu2 <= imm_alu2;              ///DC
	 buf_rrftag_alu2 <= rrftag_alu2;        ///DC
	 buf_dstval_alu2 <= dstval_alu2;        ///DC
	 buf_src_a_alu2 <= src_a_alu2;          ///DC
	 buf_src_b_alu2 <= src_b_alu2;          ///DC
	 buf_alu_op_alu2 <= alu_op_alu2;        ///DC
	 buf_spectag_alu2 <= spectag_alu2;      ///DC
	 buf_specbit_alu2 <= specbit_alu2;      ///DC
      end                                   ///DC
   end                                      ///DC
   
   exunit_alu suzaku(                                    ///DC
		     .clk(clk),                                  ///DC
		     .reset(reset),                              ///DC
		     .ex_src1(buf_ex_src1_alu2),                 ///DC
		     .ex_src2(buf_ex_src2_alu2),                 ///DC
		     .pc(buf_pc_alu2),                           ///DC
		     .imm(buf_imm_alu2),                         ///DC
		     .dstval(buf_dstval_alu2),                   ///DC
		     .src_a(buf_src_a_alu2),                     ///DC
		     .src_b(buf_src_b_alu2),                     ///DC
		     .alu_op(buf_alu_op_alu2),                   ///DC
		     .spectag(buf_spectag_alu2),                 ///DC
		     .specbit(buf_specbit_alu2),                 ///DC
		     .issue(issue_alu2),                         ///DC
		     .prmiss(prmiss),                            ///DC
		     .spectagfix(spectagfix),                    ///DC
		     .result(result_alu2),                       ///DC
		     .rrf_we(rrfwe_alu2),                        ///DC
		     .rob_we(robwe_alu2),                        ///DC
		     .kill_speculative(kill_speculative_alu2)    ///DC
		     );                                          ///DC

   always @ (posedge clk) begin          ///CTRL_CL EXEC_LDST
      if (reset) begin                   ///CTRL_CL EXEC_LDST
	 buf_ex_src1_ldst <= 0;              ///DATA_DT EXEC_LDST
	 buf_ex_src2_ldst <= 0;              ///DATA_DT EXEC_LDST
	 buf_pc_ldst <= 0;                   ///DATA_DT EXEC_LDST
	 buf_imm_ldst <= 0;                  ///DATA_DT EXEC_LDST
	 buf_rrftag_ldst <= 0;               ///CTRL_DT EXEC_LDST
	 buf_dstval_ldst <= 0;               ///CTRL_DT EXEC_LDST
	 buf_spectag_ldst <= 0;              ///CTRL_DT EXEC_LDST
	 buf_specbit_ldst <= 0;              ///CTRL_DT EXEC_LDST
      end else if (issue_ldst) begin     ///CTRL_CL EXEC_LDST
	 buf_ex_src1_ldst <= ex_src1_ldst;   ///DATA_DT EXEC_LDST
	 buf_ex_src2_ldst <= ex_src2_ldst;   ///DATA_DT EXEC_LDST
	 buf_pc_ldst <= pc_ldst;             ///DATA_DT EXEC_LDST
	 buf_imm_ldst <= imm_ldst;           ///DATA_DT EXEC_LDST
	 buf_rrftag_ldst <= rrftag_ldst;     ///CTRL_DT EXEC_LDST
	 buf_dstval_ldst <= dstval_ldst;     ///CTRL_DT EXEC_LDST
	 buf_spectag_ldst <= spectag_ldst;   ///CTRL_DT EXEC_LDST
	 buf_specbit_ldst <= specbit_ldst;   ///CTRL_DT EXEC_LDST
      end                                       
   end // always @ (posedge clk)                

   assign dmem_addr = (memoccupy_ld) ? ldaddr : retaddr;   ///DATA_CL EXEC_LDST

/*   
   dmem datamemory(
		   .clk(clk),
		   .addr({2'b0, dmem_addr[`ADDR_LEN-1:2]}),
		   .wdata(dmem_wdata),
		   .we(dmem_we),
		   .rdata(dmem_data)
		   );
*/
   storebuf sb   ///MD STOREBUF
     (
      .clk(clk),                    ///CTRL_HC STOREBUF
      .reset(reset),                ///CTRL_HC STOREBUF
      .prsuccess(prsuccess),        ///CTRL_HC STOREBUF
      .prmiss(prmiss),              ///CTRL_HC STOREBUF
      .prtag(buf_spectag_branch),   ///CTRL_HC STOREBUF
      .spectagfix(spectagfix),      ///CTRL_HC STOREBUF
      .stfin(stfin),                ///CTRL_HC STOREBUF
      .stspecbit(buf_specbit_ldst), ///CTRL_HC STOREBUF
      .stspectag(buf_spectag_ldst), ///CTRL_HC STOREBUF
      .stdata(storedata),           ///DATA_HC STOREBUF
      .staddr(storeaddr),           ///DATA_HC STOREBUF
      .stcom(stcommit),             ///CTRL_HC STOREBUF
      .stretire(dmem_we),           ///CTRL_HC STOREBUF
      .retdata(dmem_wdata),         ///DATA_HC STOREBUF
      .retaddr(retaddr),            ///DATA_HC STOREBUF
      .memoccupy_ld(memoccupy_ld),  ///CTRL_HC STOREBUF
      .sb_full(sb_full),            ///CTRL_HC STOREBUF
      .ldaddr(ldaddr),              ///DATA_HC STOREBUF
      .lddata(lddatasb),            ///DATA_HC STOREBUF
      .hit(hitsb)                   ///CTRL_HC STOREBUF
      );

   exunit_ldst seiryu(                                  ///MD EXEC_LDST
		      .clk(clk),                                ///CTRL_HC EXEC_LDST
		      .reset(reset),                            ///CTRL_HC EXEC_LDST
		      .ex_src1(buf_ex_src1_ldst),               ///DATA_HC EXEC_LDST
		      .ex_src2(buf_ex_src2_ldst),               ///DATA_HC EXEC_LDST
		      .pc(buf_pc_ldst),                         ///DATA_HC EXEC_LDST
		      .imm(buf_imm_ldst),                       ///DATA_HC EXEC_LDST
		      .dstval(buf_dstval_ldst),                 ///CTRL_HC EXEC_LDST
		      .spectag(buf_spectag_ldst),               ///CTRL_HC EXEC_LDST
		      .specbit(buf_specbit_ldst),               ///CTRL_HC EXEC_LDST
		      .rrftag(buf_rrftag_ldst),                 ///CTRL_HC EXEC_LDST
		      .issue(issue_ldst),                       ///CTRL_HC EXEC_LDST
		      .prmiss(prmiss),                          ///CTRL_HC EXEC_LDST
		      .spectagfix(spectagfix),                  ///CTRL_HC EXEC_LDST
		      .result(result_ldst),                     ///DATA_HC EXEC_LDST
		      .rrf_we(rrfwe_ldst),                      ///CTRL_HC EXEC_LDST
		      .rob_we(robwe_ldst),                      ///CTRL_HC EXEC_LDST
		      .wrrftag(wrrftag_ldst),                   ///CTRL_HC EXEC_LDST
		      .kill_speculative(kill_speculative_ldst), ///CTRL_HC EXEC_LDST
		      .busy_next(busy_next_ldst),               ///CTRL_HC EXEC_LDST
		      .stfin(stfin),                            ///CTRL_HC EXEC_LDST
		      .memoccupy_ld(memoccupy_ld),              ///CTRL_HC EXEC_LDST
		      .fullsb(sb_full),                         ///CTRL_HC EXEC_LDST
		      .storedata(storedata),                    ///DATA_HC EXEC_LDST
		      .storeaddr(storeaddr),                    ///DATA_HC EXEC_LDST
		      .hitsb(hitsb),                            ///CTRL_HC EXEC_LDST
		      .ldaddr(ldaddr),                          ///DATA_HC EXEC_LDST
		      .lddatasb(lddatasb),                      ///DATA_HC EXEC_LDST
		      .lddatamem(dmem_data)                     ///DATA_HC EXEC_LDST
		      );

   always @ (posedge clk) begin                         ///CTRL_CL EXEC_MUL
      if (reset) begin                                  ///CTRL_CL EXEC_MUL
	 buf_ex_src1_mul <= 0;                              ///DATA_DT EXEC_MUL
	 buf_ex_src2_mul <= 0;                              ///DATA_DT EXEC_MUL
	 buf_pc_mul <= 0;                                   ///DATA_DT EXEC_MUL
	 buf_rrftag_mul <= 0;                               ///CTRL_DT EXEC_MUL
	 buf_dstval_mul <= 0;                               ///CTRL_DT EXEC_MUL
	 buf_spectag_mul <= 0;                              ///CTRL_DT EXEC_MUL
	 buf_specbit_mul <= 0;                              ///CTRL_DT EXEC_MUL
	 buf_src1_signed_mul <= 0;                          ///DATA_DT EXEC_MUL
	 buf_src2_signed_mul <= 0;                          ///DATA_DT EXEC_MUL
	 buf_sel_lohi_mul <= 0;                             ///DATA_DT EXEC_MUL
      end else if (issue_mul) begin                     ///CTRL_CL EXEC_MUL
	 buf_ex_src1_mul <= ex_src1_mul;                    ///DATA_DT EXEC_MUL
	 buf_ex_src2_mul <= ex_src2_mul;                    ///DATA_DT EXEC_MUL
	 buf_pc_mul <= pc_mul;                              ///DATA_DT EXEC_MUL
	 buf_rrftag_mul <= rrftag_mul;                      ///CTRL_DT EXEC_MUL
	 buf_dstval_mul <= dstval_mul;                      ///CTRL_DT EXEC_MUL
	 buf_spectag_mul <= spectag_mul;                    ///CTRL_DT EXEC_MUL
	 buf_specbit_mul <= specbit_mul;                    ///CTRL_DT EXEC_MUL
	 buf_src1_signed_mul <= src1_signed_mul;            ///DATA_DT EXEC_MUL
	 buf_src2_signed_mul <= src2_signed_mul;            ///DATA_DT EXEC_MUL
	 buf_sel_lohi_mul <= sel_lohi_mul;                  ///DATA_DT EXEC_MUL
      end
   end
   
   exunit_mul genbu (                                  ///MD EXEC_MUL
		     .clk(clk),                                ///CTRL_HC EXEC_MUL
		     .reset(reset),                            ///CTRL_HC EXEC_MUL
		     .ex_src1(buf_ex_src1_mul),                ///DATA_HC EXEC_MUL
		     .ex_src2(buf_ex_src2_mul),                ///DATA_HC EXEC_MUL
		     .dstval(buf_dstval_mul),                  ///CTRL_HC EXEC_MUL
		     .spectag(buf_spectag_mul),                ///CTRL_HC EXEC_MUL
		     .specbit(buf_specbit_mul),                ///CTRL_HC EXEC_MUL
		     .src1_signed(buf_src1_signed_mul),        ///DATA_HC EXEC_MUL
		     .src2_signed(buf_src2_signed_mul),        ///DATA_HC EXEC_MUL
		     .sel_lohi(buf_sel_lohi_mul),              ///DATA_HC EXEC_MUL
		     .issue(issue_mul),                        ///CTRL_HC EXEC_MUL
		     .prmiss(prmiss),                          ///CTRL_HC EXEC_MUL
		     .spectagfix(spectagfix),                  ///CTRL_HC EXEC_MUL
		     .result(result_mul),                      ///DATA_HC EXEC_MUL
		     .rrf_we(rrfwe_mul),                       ///CTRL_HC EXEC_MUL
		     .rob_we(robwe_mul),                       ///CTRL_HC EXEC_MUL
		     .kill_speculative(kill_speculative_mul)   ///CTRL_HC EXEC_MUL
		     );


   always @ (posedge clk) begin              ///CTRL_CL EXEC_BRANCH
      if (reset) begin                       ///CTRL_CL EXEC_BRANCH
	 buf_ex_src1_branch <= 0;                ///DATA_DT EXEC_BRANCH
	 buf_ex_src2_branch <= 0;                ///DATA_DT EXEC_BRANCH
	 buf_pc_branch <= 0;                     ///DATA_DT EXEC_BRANCH
	 buf_imm_branch <= 0;                    ///DATA_DT EXEC_BRANCH
	 buf_rrftag_branch <= 0;                 ///CTRL_DT EXEC_BRANCH
	 buf_dstval_branch <= 0;                 ///CTRL_DT EXEC_BRANCH
	 buf_alu_op_branch <= 0;                 ///DATA_DT EXEC_BRANCH
	 buf_spectag_branch <= 0;                ///CTRL_DT EXEC_BRANCH
	 buf_specbit_branch <= 0;                ///CTRL_DT EXEC_BRANCH
	 buf_praddr_branch <= 0;                 ///DATA_DT EXEC_BRANCH
	 buf_opcode_branch <= 0;                 ///DATA_DT EXEC_BRANCH
      end else if (issue_branch) begin       ///CTRL_CL EXEC_BRANCH
	 buf_ex_src1_branch <= ex_src1_branch;   ///DATA_DT EXEC_BRANCH
	 buf_ex_src2_branch <= ex_src2_branch;   ///DATA_DT EXEC_BRANCH
	 buf_pc_branch <= pc_branch;             ///DATA_DT EXEC_BRANCH
	 buf_imm_branch <= imm_branch;           ///DATA_DT EXEC_BRANCH
	 buf_rrftag_branch <= rrftag_branch;     ///CTRL_DT EXEC_BRANCH
	 buf_dstval_branch <= dstval_branch;     ///CTRL_DT EXEC_BRANCH
	 buf_alu_op_branch <= alu_op_branch;     ///DATA_DT EXEC_BRANCH
	 buf_spectag_branch <= spectag_branch;   ///CTRL_DT EXEC_BRANCH
	 buf_specbit_branch <= specbit_branch;   ///CTRL_DT EXEC_BRANCH
	 buf_praddr_branch <= praddr_branch;     ///DATA_DT EXEC_BRANCH
	 buf_opcode_branch <= opcode_branch;     ///DATA_DT EXEC_BRANCH
      end
   end
   
   exunit_branch kirin(                        ///MD EXEC_BRANCH
		       .clk(clk),                      ///CTRL_HC EXEC_BRANCH
		       .reset(reset),                  ///CTRL_HC EXEC_BRANCH
		       .ex_src1(buf_ex_src1_branch),   ///DATA_HC EXEC_BRANCH
		       .ex_src2(buf_ex_src2_branch),   ///DATA_HC EXEC_BRANCH
		       .pc(buf_pc_branch),             ///DATA_HC EXEC_BRANCH
		       .imm(buf_imm_branch),           ///DATA_HC EXEC_BRANCH
		       .dstval(buf_dstval_branch),     ///CTRL_HC EXEC_BRANCH
		       .alu_op(buf_alu_op_branch),     ///DATA_HC EXEC_BRANCH
		       .spectag(buf_spectag_branch),   ///CTRL_HC EXEC_BRANCH
		       .specbit(buf_specbit_branch),   ///CTRL_HC EXEC_BRANCH
		       .praddr(buf_praddr_branch),     ///DATA_HC EXEC_BRANCH
		       .opcode(buf_opcode_branch),     ///DATA_HC EXEC_BRANCH
		       .issue(issue_branch),           ///CTRL_HC EXEC_BRANCH
		       .result(result_branch),         ///DATA_HC EXEC_BRANCH
		       .rrf_we(rrfwe_branch),          ///CTRL_HC EXEC_BRANCH
		       .rob_we(robwe_branch),          ///CTRL_HC EXEC_BRANCH
		       .prsuccess(prsuccess),          ///CTRL_HC EXEC_BRANCH
		       .prmiss(prmiss),                ///CTRL_HC EXEC_BRANCH
		       .jmpaddr(jmpaddr),              ///DATA_HC EXEC_BRANCH
		       .jmpaddr_taken(jmpaddr_taken),  ///DC
		       .brcond(brcond),                ///DC
		       .tagregfix(tagregfix)           ///CTRL_HC TAG
		       );

   
   miss_prediction_fix_table mpft(                                   ///MD MPFT
				  .clk(clk),                                         ///CTRL_HC MPFT
				  .reset(reset),                                     ///CTRL_HC MPFT
				  .mpft_valid(mpft_valid),                           ///CTRL_HC MPFT
				  .value_addr(buf_spectag_branch),                   ///DATA_HC MPFT
				  .mpft_value(spectagfix),                           ///CTRL_HC MPFT
				  .prmiss(prmiss),                                   ///CTRL_HC MPFT
				  .prsuccess(prsuccess),                             ///CTRL_HC MPFT
				  .prsuccess_tag(buf_spectag_branch),                ///CTRL_HC MPFT
				  .setspec1_tag(sptag1),                             ///CTRL_HC MPFT
				  .setspec1_en(isbranch1 & ~stall_ID & ~stall_DP),   ///CTRL_HC+CTRL_CL MPFT
				  .setspec2_tag(sptag2),                             ///CTRL_HC MPFT
				  .setspec2_en(branchvalid2 & ~stall_ID & ~stall_DP) ///CTRL_HC+CTRL_CL MPFT
				  );
   
   //COM Stage*******************************************************
   reorderbuf rob(                                                     ///MD ROB
		  .clk(clk),                                                   ///CTRL_HC ROB
		  .reset(reset),                                               ///CTRL_HC ROB
		  .dp1(~stall_DP & ~kill_DP & ~inv1_id),                       ///CTRL_HC+CTRL_CL ROB
		  .dp1_addr(dst1_renamed),                                     ///CTRL_HC ROB
		  .pc_dp1(pc_id),                                              ///DATA_HC ROB
		  .storebit_dp1(inst1_id[6:0] == `RV32_STORE ? 1'b1 : 1'b0),   ///CTRL_HC+CTRL_CL ROB
		  .dstvalid_dp1(wr_reg_1_id),                                  ///CTRL_HC ROB
		  .dst_dp1(rd_1_id),                                           ///DATA_HC ROB
		  .bhr_dp1(bhr_id),                                            ///DC
		  .isbranch_dp1(req1_branch),                                  ///CTRL_HC ROB
		  .dp2(~stall_DP & ~kill_DP & ~inv2_id),                       ///CTRL_HC+CTRL_CL ROB
		  .dp2_addr(dst2_renamed),                                     ///CTRL_HC ROB
		  .pc_dp2(pc_id + 4),                                          ///DATA_HC+DATA_CL ROB
		  .storebit_dp2(inst2_id[6:0] == `RV32_STORE ? 1'b1 : 1'b0),   ///CTRL_HC+CTRL_CL ROB
		  .dstvalid_dp2(wr_reg_2_id),                                  ///CTRL_HC ROB
		  .dst_dp2(rd_2_id),                                           ///DATA_HC ROB
		  .bhr_dp2(bhr_id),                                            ///DC
		  .isbranch_dp2(req2_branch),                                  ///CTRL_HC ROB
		  .exfin_alu1(robwe_alu1),                                     ///CTRL_HC ROB
		  .exfin_alu1_addr(buf_rrftag_alu1),                           ///CTRL_HC ROB
		  .exfin_alu2(robwe_alu2),                                     ///CTRL_HC ROB
		  .exfin_alu2_addr(buf_rrftag_alu2),                           ///CTRL_HC ROB
		  .exfin_mul(robwe_mul),                                       ///CTRL_HC ROB
		  .exfin_mul_addr(buf_rrftag_mul),                             ///CTRL_HC ROB
		  .exfin_ldst(robwe_ldst),                                     ///CTRL_HC ROB
		  .exfin_ldst_addr(wrrftag_ldst),                              ///CTRL_HC ROB
		  .exfin_branch(robwe_branch),                                 ///CTRL_HC ROB
		  .exfin_branch_addr(buf_rrftag_branch),                       ///CTRL_HC ROB
		  .exfin_branch_brcond(brcond),                                ///DC
		  .exfin_branch_jmpaddr(jmpaddr_taken),                        ///DC

		  .comptr(comptr),                                             ///CTRL_HC ROB
		  .comptr2(comptr2),                                           ///CTRL_HC ROB
		  .comnum(comnum),                                             ///CTRL_HC ROB
		  .stcommit(stcommit),                                         ///CTRL_HC ROB
		  .arfwe1(arfwe1),                                             ///CTRL_HC ROB
		  .arfwe2(arfwe2),                                             ///CTRL_HC ROB
		  .dstarf1(dstarf1),                                           ///DATA_HC ROB
		  .dstarf2(dstarf2),                                           ///DATA_HC ROB
		  .pc_combranch(pc_combranch),                                 ///DC
		  .bhr_combranch(bhr_combranch),                               ///DC
		  .brcond_combranch(brcond_combranch),                         ///DC
		  .jmpaddr_combranch(jmpaddr_combranch),                       ///DC
		  .combranch(combranch),                                       ///DC
		  .dispatchptr(rrfptr),                                        ///CTRL_HC ROB
		  .rrf_freenum(freenum),                                       ///CTRL_HC ROB
		  .prmiss(prmiss)                                              ///CTRL_HC ROB
		  );
   
endmodule // pipeline

`default_nettype wire
