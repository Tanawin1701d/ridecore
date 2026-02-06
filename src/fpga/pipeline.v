`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"

`default_nettype none

module pipeline
  (
   input wire 			clk,          ///CTRL GROB
   input wire 			reset,        ///CTRL GROB
   output reg [`ADDR_LEN-1:0] 	pc,
   input wire [4*`INSN_LEN-1:0] idata,
   output wire [`DATA_LEN-1:0] 	dmem_wdata,
   output wire 			dmem_we,      ///CTRL GROB
   output wire [`ADDR_LEN-1:0] 	dmem_addr,
   input wire [`DATA_LEN-1:0] 	dmem_data
   );

   
   wire  stall_IF /* verilator public */;  ///CTRL FETCH
   wire  kill_IF  /* verilator public */;  ///CTRL FETCH
   wire  stall_ID /* verilator public */;  ///CTRL DECODE
   wire  kill_ID  /* verilator public */;  ///CTRL DECODE
   wire  stall_DP /* verilator public */;  ///CTRL DISPATCH
   wire  kill_DP  /* verilator public */;  ///CTRL DISPATCH
//   reg [`ADDR_LEN-1:0] pc;

   //IF
   // Signal from pipe_if
   wire     	        prcond = 0; ///DC
   wire [`ADDR_LEN-1:0] npc;
   wire [`INSN_LEN-1:0] inst1;
   wire [`INSN_LEN-1:0] inst2;
   wire 		invalid2_pipe;
   wire [`GSH_BHR_LEN-1:0] bhr = 0; ///DC
   
   //Instruction Buffer
   reg 			   prcond_if /* verilator public */;            ///DC
   reg [`ADDR_LEN-1:0] 	   npc_if /* verilator public */ ;
   reg [`ADDR_LEN-1:0] 	   pc_if /* verilator public */  ; 
   reg [`INSN_LEN-1:0] 	   inst1_if /* verilator public */  ;
   reg [`INSN_LEN-1:0] 	   inst2_if /* verilator public */   ;
   reg 			           inv1_if /* verilator public */  ;
   reg 			           inv2_if /* verilator public */   ;
   reg [`GSH_BHR_LEN-1:0]  bhr_if /* verilator public */  ; ///DC
   wire 		           attachable /* verilator public */;

   //ID
   //Decode Info1
   wire [`IMM_TYPE_WIDTH-1:0] imm_type_1;
   wire [`REG_SEL-1:0] 	      rs1_1;
   wire [`REG_SEL-1:0] 	      rs2_1;
   wire [`REG_SEL-1:0] 	      rd_1;
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel_1;
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel_1;
   wire 		       wr_reg_1;
   wire 		       uses_rs1_1;
   wire 		       uses_rs2_1;
   wire 		       illegal_instruction_1;
   wire [`ALU_OP_WIDTH-1:0]    alu_op_1;
   wire [`RS_ENT_SEL-1:0]      rs_ent_1;
   wire [2:0] 		       dmem_size_1;
   wire [`MEM_TYPE_WIDTH-1:0]  dmem_type_1;			  
   wire [`MD_OP_WIDTH-1:0]     md_req_op_1;
   wire 		       md_req_in_1_signed_1;
   wire 		       md_req_in_2_signed_1;
   wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1;
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
   wire [`SPECTAG_LEN-1:0] 	sptag1;
   wire [`SPECTAG_LEN-1:0] 	sptag2;
   wire [`SPECTAG_LEN-1:0] 	tagreg;
   wire 			spec1;
   wire 			spec2;
   wire 			isbranch1;
   wire 			isbranch2;
   wire 			branchvalid1;
   wire 			branchvalid2;
   
   //Latch
   //Decode Info1
   reg [`IMM_TYPE_WIDTH-1:0] 	imm_type_1_id /* verilator public */;                         
   reg [`REG_SEL-1:0] 		    rs1_1_id /* verilator public */;                         
   reg [`REG_SEL-1:0] 		    rs2_1_id /* verilator public */;                         
   reg [`REG_SEL-1:0] 		    rd_1_id /* verilator public */;                         
   reg [`SRC_A_SEL_WIDTH-1:0] 	src_a_sel_1_id /* verilator public */;                         
   reg [`SRC_B_SEL_WIDTH-1:0] 	src_b_sel_1_id /* verilator public */;                         
   reg 				            wr_reg_1_id /* verilator public */;                         
   reg 				            uses_rs1_1_id /* verilator public */;                         
   reg 				            uses_rs2_1_id /* verilator public */;                         
   reg 				            illegal_instruction_1_id /* verilator public */;                         
   reg [`ALU_OP_WIDTH-1:0] 	    alu_op_1_id /* verilator public */;                         
   reg [`RS_ENT_SEL-1:0] 	    rs_ent_1_id /* verilator public */;                         
   reg [2:0] 			        dmem_size_1_id /* verilator public */;                         
   reg [`MEM_TYPE_WIDTH-1:0] 	dmem_type_1_id /* verilator public */;			                           
   reg [`MD_OP_WIDTH-1:0] 	    md_req_op_1_id /* verilator public */;                         
   reg 				            md_req_in_1_signed_1_id /* verilator public */;                         
   reg 				            md_req_in_2_signed_1_id /* verilator public */;                         
   reg [`MD_OUT_SEL_WIDTH-1:0] 	md_req_out_sel_1_id /* verilator public */;                         
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
   reg 				            rs1_2_eq_dst1_id   /* verilator public */;
   reg 				            rs2_2_eq_dst1_id   /* verilator public */;
   reg [`SPECTAG_LEN-1:0] 	    sptag1_id   /* verilator public */;
   reg [`SPECTAG_LEN-1:0] 	    sptag2_id   /* verilator public */;
   reg [`SPECTAG_LEN-1:0] 	    tagreg_id   /* verilator public */;
   reg 				            spec1_id   /* verilator public */;
   reg 				            spec2_id   /* verilator public */;
   reg [`INSN_LEN-1:0] 		    inst1_id   /* verilator public */;
   reg [`INSN_LEN-1:0] 		    inst2_id   /* verilator public */;
   reg 				            prcond1_id   /* verilator public */; ///DC
   reg 				            prcond2_id   /* verilator public */; ///DC
   reg 				            inv1_id   /* verilator public */;
   reg 				            inv2_id   /* verilator public */;
   reg [`ADDR_LEN-1:0] 		    praddr1_id   /* verilator public */;
   reg [`ADDR_LEN-1:0] 		    praddr2_id   /* verilator public */;
   reg [`ADDR_LEN-1:0] 		    pc_id   /* verilator public */;
   reg [`GSH_BHR_LEN-1:0] 	    bhr_id   /* verilator public */; ///DC
   reg 				            isbranch1_id   /* verilator public */;
   reg 				            isbranch2_id   /* verilator public */;

   //DP
   //Source Operand Manager wire
   wire [`DATA_LEN-1:0] opr1_1;
   wire [`DATA_LEN-1:0] opr2_1;
   wire [`DATA_LEN-1:0] opr1_2;
   wire [`DATA_LEN-1:0] opr2_2;
   wire 		rdy1_1;
   wire 		rdy2_1;
   wire 		rdy1_2;
   wire 		rdy2_2;

   //rrf_FL wire
   wire 		alloc_rrf /* verilator public */;
   wire [`RRF_SEL-1:0] 	dst1_renamed;
   wire [`RRF_SEL-1:0] 	dst2_renamed;
   wire [`RRF_SEL:0] 	freenum;
   wire [`RRF_SEL-1:0] 	rrfptr;
   wire [`RRF_SEL-1:0] 	rrftagfix;

   //arf wire 
   wire [`RRF_SEL-1:0] 	rs1_1tag;
   wire [`RRF_SEL-1:0] 	rs2_1tag;
   wire [`RRF_SEL-1:0] 	rs1_2tag;
   wire [`RRF_SEL-1:0] 	rs2_2tag;
   wire [`DATA_LEN-1:0] adat1_1;
   wire [`DATA_LEN-1:0] adat2_1;
   wire [`DATA_LEN-1:0] adat1_2;
   wire [`DATA_LEN-1:0] adat2_2;
   wire 		abusy1_1;
   wire 		abusy2_1;
   wire 		abusy1_2;
   wire 		abusy2_2;

   //rrf wire
   wire [`DATA_LEN-1:0] rdat1_1;
   wire [`DATA_LEN-1:0] rdat2_1;
   wire [`DATA_LEN-1:0] rdat1_2;
   wire [`DATA_LEN-1:0] rdat2_2;
   wire 		rvalid1_1;
   wire 		rvalid2_1;
   wire 		rvalid1_2;
   wire 		rvalid2_2;
   wire [`DATA_LEN-1:0] com1data;
   wire [`DATA_LEN-1:0] com2data;
   
   //Src Manager wire
   wire [`DATA_LEN-1:0] src1_1; //To reservation station
   wire [`DATA_LEN-1:0] src2_1; 
   wire [`DATA_LEN-1:0] src1_2;
   wire [`DATA_LEN-1:0] src2_2;
   wire 		resolved1_1;
   wire 		resolved2_1;
   wire 		resolved1_2;
   wire 		resolved2_2;

   //Immgen wire
   wire [`DATA_LEN-1:0] imm1; // To reservation station
   wire [`DATA_LEN-1:0] imm2;
   //BrImmgen wire
   wire [`DATA_LEN-1:0] brimm1; //To reservation station
   wire [`DATA_LEN-1:0] brimm2;
   
   //RS Request Generator wire
   wire 		req1_alu;
   wire 		req2_alu;
   wire [1:0] 		req_alunum;
   wire 		req1_branch;
   wire 		req2_branch;
   wire [1:0] 		req_branchnum;
   wire 		req1_mul;
   wire 		req2_mul;
   wire [1:0] 		req_mulnum;
   wire 		req1_ldst;
   wire 		req2_ldst;
   wire [1:0] 		req_ldstnum;

   wire [`ALU_ENT_SEL:0] allocent1_alu;
   wire [`ALU_ENT_SEL:0] allocent2_alu;
   wire 		 rsalu1_we1;
   wire 		 rsalu1_we2;
   wire 		 rsalu2_we1;
   wire 		 rsalu2_we2;
   wire [`ALU_ENT_NUM-1:0]   busyvec_alu1;
   wire [`ALU_ENT_NUM-1:0]   busyvec_alu2;
   wire [2*`ALU_ENT_NUM-1:0] busyvec_alu;
   wire [`ALU_ENT_NUM:0]     ready_alu;

   wire 		   issuevalid_alu1;
   wire [`ALU_ENT_SEL-1:0] issueent_alu1 /* verilator public */;
   wire 		   issue_alu1 /* verilator public */;  ///CTRL RSV_ALU
   wire 		   issuevalid_alu2;
   wire [`ALU_ENT_SEL-1:0] issueent_alu2 /* verilator public */;
   wire 		   issue_alu2 /* verilator public */; ///CTRL RSV_ALU
   wire 		   allocatable_alu /* verilator public */;
   wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect1;
   wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect2;
   wire [`RRF_SEL+1:0] 			entval_alu1;
   wire [`RRF_SEL+1:0] 			entval_alu2;
   
   wire 				nextrrfcyc;

   wire [`DATA_LEN-1:0]    ex_src1_alu1;
   wire [`DATA_LEN-1:0]    ex_src2_alu1;
   wire [`ALU_ENT_NUM-1:0] ready_alu1;
   wire [`ADDR_LEN-1:0]    pc_alu1;
   wire [`DATA_LEN-1:0]    imm_alu1;
   wire [`RRF_SEL-1:0] 	   rrftag_alu1;
   wire 		   dstval_alu1;
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_alu1;
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_alu1;
   wire [`ALU_OP_WIDTH-1:0]    alu_op_alu1;
   wire [`SPECTAG_LEN-1:0]     spectag_alu1;
   wire 		       specbit_alu1;

   wire [`DATA_LEN-1:0]        ex_src1_alu2;               ///DC
   wire [`DATA_LEN-1:0]        ex_src2_alu2;               ///DC
   wire [`ALU_ENT_NUM-1:0]     ready_alu2;               ///DC
   wire [`ADDR_LEN-1:0]        pc_alu2;               ///DC
   wire [`DATA_LEN-1:0]        imm_alu2;               ///DC
   wire [`RRF_SEL-1:0] 	       rrftag_alu2;               ///DC
   wire 		       dstval_alu2;               ///DC
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_alu2;               ///DC
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_alu2;               ///DC
   wire [`ALU_OP_WIDTH-1:0]    alu_op_alu2;               ///DC
   wire [`SPECTAG_LEN-1:0]     spectag_alu2;               ///DC
   wire 		       specbit_alu2;               ///DC
   
   wire [`LDST_ENT_SEL-1:0]    allocent1_ldst;
   wire [`LDST_ENT_SEL-1:0]    allocent2_ldst;
   wire [`LDST_ENT_NUM-1:0]    busyvec_ldst;
   wire [`LDST_ENT_NUM-1:0]    prbusyvec_next_ldst;
   wire [`LDST_ENT_NUM-1:0]    ready_ldst;
   wire 		       issuevalid_ldst;
   wire [`LDST_ENT_SEL-1:0]    issueent_ldst /* verilator public */;
   wire 		       issue_ldst /* verilator public */; ///CTRL RSV_LDST
   wire 		       allocatable_ldst;

   wire [`DATA_LEN-1:0]        ex_src1_ldst;
   wire [`DATA_LEN-1:0]        ex_src2_ldst;
   wire [`ADDR_LEN-1:0]        pc_ldst;
   wire [`DATA_LEN-1:0]        imm_ldst;
   wire [`RRF_SEL-1:0] 	       rrftag_ldst;
   wire 		       dstval_ldst;
   wire [`SPECTAG_LEN-1:0]     spectag_ldst;
   wire 		       specbit_ldst;

   wire [`BRANCH_ENT_SEL-1:0]  allocent1_branch;
   wire [`BRANCH_ENT_SEL-1:0]  allocent2_branch;
   wire [`BRANCH_ENT_NUM-1:0]  busyvec_branch;
   wire [`BRANCH_ENT_NUM-1:0]  prbusyvec_next_branch;
   wire [`BRANCH_ENT_NUM-1:0]  ready_branch;
   wire 		       issuevalid_branch;
   wire [`BRANCH_ENT_SEL-1:0]  issueent_branch /* verilator public */;
   wire 		       issue_branch /* verilator public */; ///CTRL RSV_BRANCH
   wire 		       allocatable_branch /* verilator public */;

   wire [`DATA_LEN-1:0]        ex_src1_branch;
   wire [`DATA_LEN-1:0]        ex_src2_branch;
   wire [`ADDR_LEN-1:0]        pc_branch;
   wire [`DATA_LEN-1:0]        imm_branch;
   wire [`RRF_SEL-1:0] 	       rrftag_branch;
   wire 		       dstval_branch;
   wire [`ALU_OP_WIDTH-1:0]    alu_op_branch;
   wire [`SPECTAG_LEN-1:0]     spectag_branch;
   wire 		       specbit_branch;
   wire [`GSH_BHR_LEN-1:0]     bhr_branch; ///DC
   wire 		       prcond_branch;      ///DC
   wire [`ADDR_LEN-1:0]        praddr_branch;
   wire [6:0] 		       opcode_branch;  

   wire [`MUL_ENT_SEL-1:0]       allocent1_mul;
   wire [`MUL_ENT_SEL-1:0]       allocent2_mul;
   wire [`MUL_ENT_NUM-1:0]     busyvec_mul;
   wire [`MUL_ENT_NUM-1:0]     ready_mul;
   wire 		       issuevalid_mul;
   wire [`MUL_ENT_SEL-1:0]     issueent_mul /* verilator public */;
   wire 		       issue_mul /* verilator public */; ///CTRL RSV_MUL
   wire 		       allocatable_mul;

   wire [`DATA_LEN-1:0]        ex_src1_mul;
   wire [`DATA_LEN-1:0]        ex_src2_mul;
   wire [`ADDR_LEN-1:0]        pc_mul;
   wire [`RRF_SEL-1:0] 	       rrftag_mul;
   wire 		       dstval_mul;
   wire [`SPECTAG_LEN-1:0]     spectag_mul;
   wire 		       specbit_mul;
   wire 		       src1_signed_mul;
   wire 		       src2_signed_mul;
   wire 		       sel_lohi_mul;

   //EX
   //ALU1
   wire [`DATA_LEN-1:0]        result_alu1;
   wire 		       rrfwe_alu1;  ///CTRL EXEC_ALU
   wire 		       robwe_alu1;  ///CTRL EXEC_ALU
   wire 		       kill_speculative_alu1; ///CTRL EXEC_ALU

   reg [`DATA_LEN-1:0] 	       buf_ex_src1_alu1     /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_alu1     /* verilator public */;
   reg [`ADDR_LEN-1:0] 	       buf_pc_alu1     /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_imm_alu1     /* verilator public */;
   reg [`RRF_SEL-1:0] 	       buf_rrftag_alu1     /* verilator public */;
   reg 			       buf_dstval_alu1     /* verilator public */;
   reg [`SRC_A_SEL_WIDTH-1:0]  buf_src_a_alu1     /* verilator public */;
   reg [`SRC_B_SEL_WIDTH-1:0]  buf_src_b_alu1     /* verilator public */;
   reg [`ALU_OP_WIDTH-1:0]     buf_alu_op_alu1     /* verilator public */;
   reg [`SPECTAG_LEN-1:0]      buf_spectag_alu1     /* verilator public */;
   reg 			       buf_specbit_alu1     /* verilator public */;
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
   wire [`DATA_LEN-1:0]        result_ldst;
   wire 		       rrfwe_ldst;     ///CTRL EXEC_LDST
   wire 		       robwe_ldst;     ///CTRL EXEC_LDST
   wire [`RRF_SEL-1:0] 	       wrrftag_ldst;
   wire 		       kill_speculative_ldst; ///CTRL EXEC_LDST
   wire 		       busy_next_ldst;

   //wire [`DATA_LEN-1:0]        dmem_data;
   /*
   wire [`DATA_LEN-1:0]        dmem_wdata;
   wire 		       dmem_we;
   wire [`ADDR_LEN-1:0]        dmem_addr;
    */
   wire 		       sb_full;
   wire 		       hitsb;
   wire 		       memoccupy_ld;
   wire [`ADDR_LEN-1:0]        ldaddr;
   wire [`DATA_LEN-1:0]        lddatasb;
   wire [`ADDR_LEN-1:0]        retaddr;
   wire [`DATA_LEN-1:0]        storedata;
   wire [`ADDR_LEN-1:0]        storeaddr; 
   wire 		       stfin; ///CTRL EXEC_LDST
   
   reg [`DATA_LEN-1:0] 	       buf_ex_src1_ldst /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_ldst /* verilator public */;
   reg [`ADDR_LEN-1:0] 	       buf_pc_ldst /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_imm_ldst /* verilator public */;
   reg [`RRF_SEL-1:0] 	       buf_rrftag_ldst /* verilator public */;
   reg 			       buf_dstval_ldst /* verilator public */;
   reg [`SPECTAG_LEN-1:0]      buf_spectag_ldst /* verilator public */;
   reg 			       buf_specbit_ldst /* verilator public */;

   //MUL
   wire [`DATA_LEN-1:0]        result_mul;
   wire 		       rrfwe_mul; ///CTRL EXEC_MUL
   wire 		       robwe_mul; ///CTRL EXEC_MUL
   wire 		       kill_speculative_mul; ///CTRL EXEC_MUL

   reg [`DATA_LEN-1:0] 	       buf_ex_src1_mul /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_mul /* verilator public */;
   reg [`ADDR_LEN-1:0] 	       buf_pc_mul /* verilator public */;
   reg [`RRF_SEL-1:0] 	       buf_rrftag_mul /* verilator public */;
   reg 			       buf_dstval_mul /* verilator public */;
   reg [`SPECTAG_LEN-1:0]      buf_spectag_mul /* verilator public */;
   reg 			       buf_specbit_mul /* verilator public */;
   reg 			       buf_src1_signed_mul /* verilator public */;
   reg 			       buf_src2_signed_mul /* verilator public */;
   reg 			       buf_sel_lohi_mul /* verilator public */;
   
   //BRANCH
   wire 		       prmiss /* verilator public */;      ///CTRL EXEC_BRANCH
   wire 		       prsuccess /* verilator public */;   ///CTRL EXEC_BRANCH
   wire [`ADDR_LEN-1:0]        jmpaddr;
   wire [`ADDR_LEN-1:0]        jmpaddr_taken;
   wire 		       brcond; ///DC
   wire [`SPECTAG_LEN-1:0]     tagregfix;
   
   wire [`DATA_LEN-1:0]        result_branch;
   wire 		       rrfwe_branch; ///CTRL EXEC_BRANCH
   wire 		       robwe_branch; ///CTRL EXEC_BRANCH
   
   reg [`DATA_LEN-1:0] 	       buf_ex_src1_branch /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_ex_src2_branch /* verilator public */;
   reg [`ADDR_LEN-1:0] 	       buf_pc_branch /* verilator public */;
   reg [`DATA_LEN-1:0] 	       buf_imm_branch /* verilator public */;
   reg [`RRF_SEL-1:0] 	       buf_rrftag_branch /* verilator public */;
   reg 			       buf_dstval_branch /* verilator public */;
   reg [`ALU_OP_WIDTH-1:0]     buf_alu_op_branch /* verilator public */;
   reg [`SPECTAG_LEN-1:0]      buf_spectag_branch /* verilator public */;
   reg 			       buf_specbit_branch /* verilator public */;
   reg [`ADDR_LEN-1:0] 	       buf_praddr_branch /* verilator public */;
   reg [6:0] 		       buf_opcode_branch /* verilator public */;
   
   //miss prediction fix table
   wire [`SPECTAG_LEN-1:0] mpft_valid;
   wire [`SPECTAG_LEN-1:0] spectagfix;

   //COM
   wire [`RRF_SEL-1:0] 	   comptr;
   wire [`RRF_SEL-1:0] 	   comptr2;
   wire [1:0] 		   comnum;
   wire 		   stcommit;///CTRL ROB
   wire 		   arfwe1;  ///CTRL ROB
   wire 		   arfwe2;  ///CTRL ROB
   wire [`REG_SEL-1:0] 	   dstarf1;
   wire [`REG_SEL-1:0] 	   dstarf2;
   wire [`ADDR_LEN-1:0]    pc_combranch;      ///DC
   wire [`GSH_BHR_LEN-1:0] bhr_combranch;     ///DC
   wire 		   brcond_combranch;          ///DC
   wire 		   combranch;                 ///DC
   wire [`ADDR_LEN-1:0]    jmpaddr_combranch; ///DC
   
   //IF Stage********************************************************
//   assign stall_IF = stall_ID;
//   assign kill_IF = prmiss;
   assign stall_IF = stall_ID | stall_DP;    ///CTRL FETCH
   assign kill_IF = prmiss;                  ///CTRL FETCH
   
   always @ (posedge clk) begin    ///CTRL FETCH
      if (reset) begin             ///CTRL FETCH
	 pc <= `ENTRY_POINT;
      end else if (prmiss) begin   ///CTRL FETCH
	 pc <= jmpaddr;
      end else if (stall_IF) begin ///CTRL FETCH
	 pc <= pc;
      end else begin
	 pc <= npc;
      end
   end

   
   pipeline_if pipe_if(
		       .clk(clk),
		       .reset(reset),
		       .pc(pc),
		       //.predict_cond(prcond),
		       .npc(npc),
		       .inst1(inst1),
		       .inst2(inst2),
		       .invalid2(invalid2_pipe),
		       // .btbpht_we(combranch),         
		       // .btbpht_pc(pc_combranch),      
		       // .btb_jmpdst(jmpaddr_combranch),
		       // .pht_wcond(brcond_combranch),  
		       // .mpft_valid(mpft_valid),       
		       // .pht_bhr(bhr_combranch), //when PHT write
		       .prmiss(prmiss),
		       .prsuccess(prsuccess),
		       //.prtag(buf_spectag_branch),
		       //.bhr(bhr),                 
		       //.spectagnow(tagreg),       
		       .idata(idata)
		       );

   always @ (posedge clk) begin   ///CTRL FETCH
      if (reset | kill_IF) begin  ///CTRL FETCH
	 prcond_if <= 0; ///DC
	 npc_if <= 0;
	 pc_if <= 0;
	 inst1_if <= 0;
	 inst2_if <= 0;
	 inv1_if <= 1;    ///CTRL FETCH
	 inv2_if <= 1;
	 bhr_if <= 0; ///DC
	 
      end else if (~stall_IF) begin ///CTRL FETCH
	 prcond_if <= prcond; ///DC
	 npc_if <= npc;
	 pc_if <= pc;
	 inst1_if <= inst1;
	 inst2_if <= inst2;
	 inv1_if <= 0;                   ///CTRL FETCH
	 inv2_if <= invalid2_pipe;
	 bhr_if <= bhr; ///DC
	 
      end
   end // always @ (posedge clk)

   //ID Stage********************************************************
//   assign stall_ID = stall_DP | ~attachable | (prsuccess & (isbranch1 | isbranch2));
//   assign kill_ID = prmiss;
   assign stall_ID = ~attachable | prsuccess;            ///CTRL DECODE
   assign kill_ID = (stall_ID & ~stall_DP) | prmiss;     ///CTRL DECODE
   
   assign isbranch1 = (~inv1_if && (rs_ent_1 == `RS_ENT_BRANCH)) ?
		      1'b1 : 1'b0;
   assign isbranch2 = (~inv2_if && (rs_ent_2 == `RS_ENT_BRANCH)) ?
		      1'b1 : 1'b0;
   assign branchvalid1 = isbranch1 & prcond_if;
   assign branchvalid2 = isbranch2 & ~branchvalid1;
   
   tag_generator taggen(
			.clk(clk),
			.reset(reset),
			.branchvalid1(isbranch1),
			.branchvalid2(branchvalid2),
			.prmiss(prmiss),
			.prsuccess(prsuccess),
			.enable(~stall_ID & ~stall_DP),  
			.tagregfix(tagregfix),
			.sptag1(sptag1),
			.sptag2(sptag2),
			.speculative1(spec1),
			.speculative2(spec2),
			.attachable(attachable),
			.tagreg(tagreg)
			);
   
   decoder dec1(
		.inst(inst1_if),
		.imm_type(imm_type_1),
		.rs1(rs1_1),
		.rs2(rs2_1),
		.rd(rd_1),
		.src_a_sel(src_a_sel_1),
		.src_b_sel(src_b_sel_1),
		.wr_reg(wr_reg_1),
		.uses_rs1(uses_rs1_1),
		.uses_rs2(uses_rs2_1),
		.illegal_instruction(illegal_instruction_1),
		.alu_op(alu_op_1),
		.rs_ent(rs_ent_1),
		.dmem_size(dmem_size_1),
		.dmem_type(dmem_type_1),
		.md_req_op(md_req_op_1),
		.md_req_in_1_signed(md_req_in_1_signed_1),
		.md_req_in_2_signed(md_req_in_2_signed_1),
		.md_req_out_sel(md_req_out_sel_1)
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

   always @ (posedge clk) begin     ///CTRL DECODE
      if (reset | kill_ID) begin    ///CTRL DECODE
	 imm_type_1_id <= 0;
	 rs1_1_id <= 0;
	 rs2_1_id <= 0;
	 rd_1_id <= 0;
	 src_a_sel_1_id <= 0;
	 src_b_sel_1_id <= 0;
	 wr_reg_1_id <= 0;
	 uses_rs1_1_id <= 0;
	 uses_rs2_1_id <= 0;
	 illegal_instruction_1_id <= 0;
	 alu_op_1_id <= 0;
	 rs_ent_1_id <= 0;
	 dmem_size_1_id <= 0;
	 dmem_type_1_id <= 0;			  
	 md_req_op_1_id <= 0;
	 md_req_in_1_signed_1_id <= 0;
	 md_req_in_2_signed_1_id <= 0;
	 md_req_out_sel_1_id <= 0;

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

	 rs1_2_eq_dst1_id <= 0;
  	 rs2_2_eq_dst1_id <= 0;
	 sptag1_id <= 0;
	 sptag2_id <= 0;
	 tagreg_id <= 0;
//	 spec1_id <= 0;
//	 spec2_id <= 0;
	 inst1_id <= 0;
	 inst2_id <= 0;
	 prcond1_id <= 0; ///DC
	 prcond2_id <= 0; ///DC
	 inv1_id <= 1;             ///CTRL DECODE
	 inv2_id <= 1;
	 praddr1_id <= 0;
	 praddr2_id <= 0;
	 pc_id <= 0;
	 bhr_id <= 0; ///DC
	 isbranch1_id <= 0;
	 isbranch2_id <= 0;
	 
      end else if (~stall_DP) begin           ///CTRL DECODE
	 imm_type_1_id <= imm_type_1;
	 rs1_1_id <= rs1_1;
	 rs2_1_id <= rs2_1;
	 rd_1_id <= rd_1;
	 src_a_sel_1_id <= src_a_sel_1;
	 src_b_sel_1_id <= src_b_sel_1;
	 wr_reg_1_id <= wr_reg_1;
	 uses_rs1_1_id <= uses_rs1_1;
	 uses_rs2_1_id <= uses_rs2_1;
	 illegal_instruction_1_id <= illegal_instruction_1;
	 alu_op_1_id <= alu_op_1;
	 rs_ent_1_id <= inv1_if ? 0 : rs_ent_1;
	 dmem_size_1_id <= dmem_size_1;
	 dmem_type_1_id <= dmem_type_1;			  
	 md_req_op_1_id <= md_req_op_1;
	 md_req_in_1_signed_1_id <= md_req_in_1_signed_1;
	 md_req_in_2_signed_1_id <= md_req_in_2_signed_1;
	 md_req_out_sel_1_id <= md_req_out_sel_1;

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
	 
	 rs1_2_eq_dst1_id <= (rs1_2 == rd_1 && wr_reg_1) ? 1'b1 : 1'b0;
  	 rs2_2_eq_dst1_id <= (rs2_2 == rd_1 && wr_reg_1) ? 1'b1 : 1'b0;
	 sptag1_id <= sptag1;
	 sptag2_id <= sptag2;
	 tagreg_id <= tagreg;
//	 spec1_id <= spec1;
//	 spec2_id <= spec2;
	 inst1_id <= inst1_if;
	 inst2_id <= inst2_if;
	 prcond1_id <= prcond_if & isbranch1; ///DC
	 prcond2_id <= isbranch2 & prcond_if & ~isbranch1; ///DC
	 inv1_id <= inv1_if;        ///CTRL DECODE
	 inv2_id <= inv2_if | (prcond_if & isbranch1);
	 /*
	 praddr1_id <= prcond_if & isbranch1 ? npc_if : pc_if + 4;
	 praddr2_id <= prcond_if & ~isbranch1 & isbranch2 ?
		       npc_if : pc_if + 8;
	  */
	 praddr1_id <= (prcond_if & isbranch1) ? npc_if : (pc_if + 4);
	 praddr2_id <= npc_if;
	 pc_id <= pc_if;
	 bhr_id <= bhr_if; ///DC
	 isbranch1_id <= isbranch1;
	 isbranch2_id <= isbranch2;
	 
      end
   end

   //Invalidation of specbit when prsuccess(stall)
   always @ (posedge clk) begin     ///CTRL DISPATCH
      if (reset | kill_ID) begin    ///CTRL DISPATCH
	 spec1_id <= 0;
	 spec2_id <= 0;
      end else if (prsuccess) begin ///CTRL DISPATCH
	 spec1_id <= (spec1_id && (buf_spectag_branch == sptag1_id)) ?
		     1'b0 : spec1_id;
	 spec2_id <= (spec2_id && (buf_spectag_branch == sptag2_id)) ?
		     1'b0 : spec2_id;
      end else if ( (~stall_ID) && (~stall_DP)) begin   ///CTRL DISPATCH
	 spec1_id <= spec1;
	 spec2_id <= spec2;
      end
   end
   
   //DP & SW Stage***************************************************
   assign stall_DP = ~allocatable_alu | ~allocatable_ldst |
		     ~allocatable_mul | ~allocatable_branch | ~alloc_rrf | prsuccess; ///CTRL DISPATCH

   assign kill_DP = prmiss; ///CTRL DISPATCH
   
   
   sourceoperand_manager sopm1_1(
				 .arfdata(adat1_1),
				 .arf_busy(abusy1_1),
				 .rrf_valid(rvalid1_1),
				 .rrftag(rs1_1tag),
				 .rrfdata(rdat1_1),
				 .dst1_renamed(dst1_renamed),
				 .src_eq_dst1(1'b0),
				 .src_eq_0((rs1_1_id == 0) ? 1'b1 : 1'b0),
				 .src(opr1_1),
				 .rdy(rdy1_1)
				 );

   sourceoperand_manager sopm2_1(
				 .arfdata(adat2_1),
				 .arf_busy(abusy2_1),
				 .rrf_valid(rvalid2_1),
				 .rrftag(rs2_1tag),
				 .rrfdata(rdat2_1),
				 .dst1_renamed(dst1_renamed),
				 .src_eq_dst1(1'b0),
				 .src_eq_0((rs2_1_id == 0) ? 1'b1 : 1'b0),
				 .src(opr2_1),
				 .rdy(rdy2_1)
				 );

   sourceoperand_manager sopm1_2(
				 .arfdata(adat1_2),
				 .arf_busy(abusy1_2),
				 .rrf_valid(rvalid1_2),
				 .rrftag(rs1_2tag),
				 .rrfdata(rdat1_2),
				 .dst1_renamed(dst1_renamed),
				 .src_eq_dst1(rs1_2_eq_dst1_id),
				 .src_eq_0((rs1_2_id == 0) ? 1'b1 : 1'b0),
				 .src(opr1_2),
				 .rdy(rdy1_2)
				 );

   sourceoperand_manager sopm2_2(
				 .arfdata(adat2_2),
				 .arf_busy(abusy2_2),
				 .rrf_valid(rvalid2_2),
				 .rrftag(rs2_2tag),
				 .rrfdata(rdat2_2),
				 .dst1_renamed(dst1_renamed),
				 .src_eq_dst1(rs2_2_eq_dst1_id),
				 .src_eq_0((rs2_2_id == 0) ? 1'b1 : 1'b0),
				 .src(opr2_2),
				 .rdy(rdy2_2)
				 );

   
   rrf_freelistmanager rrf_fl(
			      .clk(clk),
			      .reset(reset),
			      .invalid1(inv1_id),
			      .invalid2(inv2_id),
			      .comnum(comnum),
			      .prmiss(prmiss),
			      .rrftagfix(rrftagfix),
			      .rename_dst1(dst1_renamed),
			      .rename_dst2(dst2_renamed),
			      .allocatable(alloc_rrf),
			      .stall_DP(stall_DP),
			      .freenum(freenum),
			      .rrfptr(rrfptr),
			      .comptr(comptr),
			      .nextrrfcyc(nextrrfcyc)
			      );

   arf aregfile(
		.clk(clk),
		.reset(reset),
		.rs1_1(rs1_1_id),
		.rs2_1(rs2_1_id),
		.rs1_2(rs1_2_id),
		.rs2_2(rs2_2_id),
		.rs1_1data(adat1_1),
		.rs2_1data(adat2_1),
		.rs1_2data(adat1_2),
		.rs2_2data(adat2_2),
		.wreg1(dstarf1),
		.wreg2(dstarf2),
		.wdata1(com1data),
		.wdata2(com2data),
		.we1(arfwe1),
		.we2(arfwe2),
		.wrrfent1(comptr),
		.wrrfent2(comptr2),
		.rs1_1tag(rs1_1tag),
		.rs2_1tag(rs2_1tag),
		.rs1_2tag(rs1_2tag),
		.rs2_2tag(rs2_2tag),
		.tagbusy1_addr(rd_1_id),
		.tagbusy2_addr(rd_2_id),
		.tagbusy1_we(~inv1_id & ~stall_DP & wr_reg_1_id), ///CTRL ARF
		.tagbusy2_we(~inv2_id & ~stall_DP & wr_reg_2_id), ///CTRL ARF
		.settag1(dst1_renamed),
		.settag2(dst2_renamed),
		.tagbusy1_spectag(sptag1_id),
		.tagbusy2_spectag(sptag2_id),
		.rs1_1busy(abusy1_1),
		.rs2_1busy(abusy2_1),
		.rs1_2busy(abusy1_2),
		.rs2_2busy(abusy2_2),
		.prmiss(prmiss),
		.prsuccess(prsuccess),
		.prtag(buf_spectag_branch),
//		.mpft_valid1(mpft_valid1_id), //PRsuccess & stall Bug
//		.mpft_valid2(mpft_valid2_id)
		.mpft_valid1(mpft_valid & 
			     (isbranch1_id ? ~sptag1_id : ~(`SPECTAG_LEN'b0)) &
			     (isbranch2_id ? ~sptag2_id : ~(`SPECTAG_LEN'b0))),
		.mpft_valid2(mpft_valid & 
			     (isbranch2_id ? ~sptag2_id : ~(`SPECTAG_LEN'b0)))
		);
   
   assign	rrftagfix = buf_rrftag_branch + 1;
   rrf rregfile(
		.clk(clk),
		.reset(reset),
		.rs1_1tag(rs1_1tag),
		.rs2_1tag(rs2_1tag),
		.rs1_2tag(rs1_2tag),
		.rs2_2tag(rs2_2tag),
		.com1tag(comptr),
		.com2tag(comptr2),
		.rs1_1valid(rvalid1_1),
		.rs2_1valid(rvalid2_1),
		.rs1_2valid(rvalid1_2),
		.rs2_2valid(rvalid2_2),
		.rs1_1data(rdat1_1),
		.rs2_1data(rdat2_1),
		.rs1_2data(rdat1_2),
		.rs2_2data(rdat2_2),
		.com1data(com1data),
		.com2data(com2data),
		.wrrfaddr1(buf_rrftag_alu1),
		.wrrfaddr2(buf_rrftag_alu2),
		.wrrfaddr3(wrrftag_ldst),
		.wrrfaddr4(buf_rrftag_branch),      
		.wrrfaddr5(buf_rrftag_mul),
		.wrrfdata1(result_alu1),
		.wrrfdata2(result_alu2),
		.wrrfdata3(result_ldst),
		.wrrfdata4(result_branch),
		.wrrfdata5(result_mul),
		.wrrfen1(rrfwe_alu1),
		.wrrfen2(rrfwe_alu2),
		.wrrfen3(rrfwe_ldst),
		.wrrfen4(rrfwe_branch),
		.wrrfen5(rrfwe_mul),
		.dpaddr1(dst1_renamed),
		.dpaddr2(dst2_renamed),
		.dpen1(~stall_DP & ~kill_DP & ~inv1_id), // hoge
		.dpen2(~stall_DP & ~kill_DP & ~inv2_id)  // hoge
		);


   src_manager srcmng1_1(
			 .opr(opr1_1),
			 .opr_rdy(rdy1_1),
			 .exrslt1(result_alu1),
			 .exdst1(buf_rrftag_alu1),
			 .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),
			 .exrslt2(result_alu2),
			 .exdst2(buf_rrftag_alu2),
			 .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),
			 .exrslt3(result_ldst),
			 .exdst3(wrrftag_ldst),
			 .kill_spec3(kill_speculative_ldst | ~robwe_ldst),
			 .exrslt4(result_branch),
			 .exdst4(buf_rrftag_branch),
			 .kill_spec4(~robwe_branch),
			 .exrslt5(result_mul),
			 .exdst5(buf_rrftag_mul),
			 .kill_spec5(kill_speculative_mul | ~robwe_mul),
			 .src(src1_1),
			 .resolved(resolved1_1)
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

   imm_gen immgen1(
		   .inst(inst1_id),
		   .imm_type(imm_type_1_id),
		   .imm(imm1)
		   );

   imm_gen immgen2(
		   .inst(inst2_id),
		   .imm_type(imm_type_2_id),
		   .imm(imm2)
		   );

   brimm_gen brimmgen1(
		       .inst(inst1_id),
		       .brimm(brimm1)
		       );

   brimm_gen brimmgen2(
		       .inst(inst2_id),
		       .brimm(brimm2)
		       );

   rs_requestgenerator rs_reqgen(
				 .rsent_1(rs_ent_1_id),
				 .rsent_2(rs_ent_2_id),
				 .req1_alu(req1_alu),
				 .req2_alu(req2_alu),
				 .req_alunum(req_alunum),
				 .req1_branch(req1_branch),
				 .req2_branch(req2_branch),
				 .req_branchnum(req_branchnum),
				 .req1_mul(req1_mul),
				 .req2_mul(req2_mul),
				 .req_mulnum(req_mulnum),
				 .req1_ldst(req1_ldst),
				 .req2_ldst(req2_ldst),
				 .req_ldstnum(req_ldstnum)
				 );

   
   //Reservation Station(with Allocate unit, Issue unit)
   //lowest bit of allocent is the selector of RS_alu1/2
   assign 		 rsalu1_we1 = ~allocent1_alu[0];      
   assign 		 rsalu1_we2 = req1_alu ? 
			 ~allocent2_alu[0] : ~allocent1_alu[0];   
   assign 		 rsalu2_we1 = allocent1_alu[0];       
   assign 		 rsalu2_we2 = req1_alu ?              
			 allocent2_alu[0] : allocent1_alu[0];
   
   assign busyvec_alu = 
			{
			 busyvec_alu2[7],busyvec_alu1[7],busyvec_alu2[6],busyvec_alu1[6],
			 busyvec_alu2[5],busyvec_alu1[5],busyvec_alu2[4],busyvec_alu1[4],
			 busyvec_alu2[3],busyvec_alu1[3],busyvec_alu2[2],busyvec_alu1[2],
			 busyvec_alu2[1],busyvec_alu1[1],busyvec_alu2[0],busyvec_alu1[0]
			 };

//    assign ready_alu = 
// 		      {
// 		       ready_alu2[7],ready_alu1[7],ready_alu2[6],ready_alu1[6],
// 		       ready_alu2[5],ready_alu1[5],ready_alu2[4],ready_alu1[4],
// 		       ready_alu2[3],ready_alu1[3],ready_alu2[2],ready_alu1[2],
// 		       ready_alu2[1],ready_alu1[1],ready_alu2[0],ready_alu1[0]
// 		       };

   assign 		   issue_alu1 = ~prmiss & issuevalid_alu1; ///CTRL RSV_ALU
   assign 		   issue_alu2 = ~prmiss & issuevalid_alu2; ///CTRL RSV_ALU
   
   allocateunit #(2*`ALU_ENT_NUM, `ALU_ENT_SEL+1) alloc_alu(
							    .busy(busyvec_alu), //RS_BUSY
							          .en1(),
							          .en2(),
							    .free_ent1(allocent1_alu),
							    .free_ent2(allocent2_alu),
							    .reqnum(req_alunum),
							    .allocatable(allocatable_alu)
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
   assign issuevalid_alu1 = ~entval_alu1[`RRF_SEL+1];
   assign issuevalid_alu2 = ~entval_alu2[`RRF_SEL+1];
   
   oldest_finder8 isunt_alu1
     (
      .entvec({`ALU_ENT_SEL'h7, `ALU_ENT_SEL'h6, `ALU_ENT_SEL'h5, `ALU_ENT_SEL'h4,
	       `ALU_ENT_SEL'h3, `ALU_ENT_SEL'h2, `ALU_ENT_SEL'h1, `ALU_ENT_SEL'h0}),
      .valvec(histvect1),
      .oldent(issueent_alu1),
      .oldval(entval_alu1)
      );

   oldest_finder8 isunt_alu2
     (
      .entvec({`ALU_ENT_SEL'h7, `ALU_ENT_SEL'h6, `ALU_ENT_SEL'h5, `ALU_ENT_SEL'h4,
	       `ALU_ENT_SEL'h3, `ALU_ENT_SEL'h2, `ALU_ENT_SEL'h1, `ALU_ENT_SEL'h0}),
      .valvec(histvect2),
      .oldent(issueent_alu2),
      .oldval(entval_alu2)
      );
   
   
   rs_alu reserv_alu1(
		      //System
		      .clk(clk),
		      .reset(reset),
		      .busyvec(busyvec_alu1),
		      .prmiss(prmiss),
		      .prsuccess(prsuccess),
		      .prtag(buf_spectag_branch),
		      .specfixtag(spectagfix),
		      .histvect(histvect1),
		      .nextrrfcyc(nextrrfcyc),
		      //WriteSignal
		      .clearbusy(issue_alu1), //Issue 
		      .issueaddr(issueent_alu1), //= raddr, clsbsyadr
		      .we1(~stall_DP & ~kill_DP & req1_alu & rsalu1_we1), //alloc1  ///CTRL RSV_ALU
		      .we2(~stall_DP & ~kill_DP & req2_alu & rsalu1_we2), //alloc2  ///CTRL RSV_ALU
		      .waddr1(allocent1_alu[`ALU_ENT_SEL:1]), //allocent1
		      .waddr2(req1_alu ? 
			      allocent2_alu[`ALU_ENT_SEL:1] : 
			      allocent1_alu[`ALU_ENT_SEL:1]), //allocent2
		      //WriteSignal1
		      .wpc_1(pc_id),                                       
		      .wsrc1_1(src1_1),                                       
		      .wsrc2_1(src2_1),                                       
		      .wvalid1_1(~uses_rs1_1_id | resolved1_1),                                       
		      .wvalid2_1(~uses_rs2_1_id | resolved2_1),                                       
		      .wimm_1(imm1),                                       
		      .wrrftag_1(dst1_renamed),                                       
		      .wdstval_1(wr_reg_1_id),                                       
		      .wsrc_a_1(src_a_sel_1_id),                                       
		      .wsrc_b_1(src_b_sel_1_id),                                       
		      .walu_op_1(alu_op_1_id),                                       
		      .wspectag_1(sptag1_id),                                       
		      .wspecbit_1(spec1_id),                                       
		      //WriteSignal2
		      .wpc_2(pc_id + 4),                        ///DC
		      .wsrc1_2(src1_2),                         ///DC
		      .wsrc2_2(src2_2),                         ///DC
		      .wvalid1_2(~uses_rs1_2_id | resolved1_2), ///DC
		      .wvalid2_2(~uses_rs2_2_id | resolved2_2), ///DC
		      .wimm_2(imm2),                            ///DC
		      .wrrftag_2(dst2_renamed),                 ///DC
		      .wdstval_2(wr_reg_2_id),                  ///DC
		      .wsrc_a_2(src_a_sel_2_id),                ///DC
		      .wsrc_b_2(src_b_sel_2_id),                ///DC
		      .walu_op_2(alu_op_2_id),                  ///DC
		      .wspectag_2(sptag2_id),                   ///DC
		      .wspecbit_2(spec2_id),                    ///DC
		      //ReadSignal
		      .ex_src1(ex_src1_alu1),
		      .ex_src2(ex_src2_alu1),
		      .ready(ready_alu1),
		      .pc(pc_alu1),
		      .imm(imm_alu1),
		      .rrftag(rrftag_alu1),
		      .dstval(dstval_alu1),
		      .src_a(src_a_alu1),
		      .src_b(src_b_alu1),
		      .alu_op(alu_op_alu1),
		      .spectag(spectag_alu1),
		      .specbit(specbit_alu1),
		      //EXRSLT
		      .exrslt1(result_alu1),
		      .exdst1(buf_rrftag_alu1),
		      .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),
		      .exrslt2(result_alu2),
		      .exdst2(buf_rrftag_alu2),
		      .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),
		      .exrslt3(result_ldst),
		      .exdst3(wrrftag_ldst),
		      .kill_spec3(kill_speculative_ldst | ~robwe_ldst),
		      .exrslt4(result_branch),
		      .exdst4(buf_rrftag_branch),
		      .kill_spec4(~robwe_branch),
		      .exrslt5(result_mul),
		      .exdst5(buf_rrftag_mul),
		      .kill_spec5(kill_speculative_mul | ~robwe_mul)
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


   assign allocent2_ldst = allocent1_ldst + 1;
   assign issue_ldst = ~prmiss & issuevalid_ldst;  ///CTRL RSV_LDST

   alloc_issue_ino #(`LDST_ENT_SEL, `LDST_ENT_NUM) ai_ldst
     (
      .clk(clk),
      .reset(reset),
      .reqnum(req_ldstnum),
      .busyvec(busyvec_ldst),
      .prbusyvec_next(prbusyvec_next_ldst),
      .readyvec(ready_ldst),
      .prmiss(prmiss),
      .exunit_busynext(busy_next_ldst),
      .stall_DP(stall_DP),
      .kill_DP(kill_DP),
      .allocptr(allocent1_ldst),
      .allocatable(allocatable_ldst),
      .issueptr(issueent_ldst),
      .issuevalid(issuevalid_ldst)
      );
   
   rs_ldst reserv_ldst(
		       //System
		       .clk(clk),
		       .reset(reset),
		       .busyvec(busyvec_ldst),
		       .prmiss(prmiss),
		       .prsuccess(prsuccess),
		       .prtag(buf_spectag_branch),
		       .specfixtag(spectagfix),
		       .prbusyvec_next(prbusyvec_next_ldst),
		       //WriteSignal
		       .clearbusy(issue_ldst), //Issue 
		       .issueaddr(issueent_ldst), //= raddr, clsbsyadr
		       .we1(~stall_DP & ~kill_DP & req1_ldst), //alloc1 ///CTRL RSV_LDST
		       .we2(~stall_DP & ~kill_DP & req2_ldst), //alloc2 ///CTRL RSV_LDST
		       .waddr1(allocent1_ldst), //allocent1
		       .waddr2(req1_ldst ? 
			       allocent2_ldst : allocent1_ldst), //allocent2
		       //WriteSignal1
		       .wpc_1(pc_id),
		       .wsrc1_1(src1_1),
		       .wsrc2_1(src2_1),
		       .wvalid1_1(~uses_rs1_1_id | resolved1_1),
		       .wvalid2_1(~uses_rs2_1_id | resolved2_1),
		       .wimm_1(imm1),
		       .wrrftag_1(dst1_renamed),
		       .wdstval_1(wr_reg_1_id),
		       .wspectag_1(sptag1_id),
		       .wspecbit_1(spec1_id),
		       //WriteSignal2
		       .wpc_2(pc_id + 4),                         ///DC
		       .wsrc1_2(src1_2),                          ///DC
		       .wsrc2_2(src2_2),                          ///DC
		       .wvalid1_2(~uses_rs1_2_id | resolved1_2),  ///DC
		       .wvalid2_2(~uses_rs2_2_id | resolved2_2),  ///DC
		       .wimm_2(imm2),                             ///DC
		       .wrrftag_2(dst2_renamed),                  ///DC
		       .wdstval_2(wr_reg_2_id),                   ///DC
		       .wspectag_2(sptag2_id),                    ///DC
		       .wspecbit_2(spec2_id),                     ///DC
		       //ReadSignal
		       .ex_src1(ex_src1_ldst),
		       .ex_src2(ex_src2_ldst),
		       .ready(ready_ldst),
		       .pc(pc_ldst),
		       .imm(imm_ldst),
		       .rrftag(rrftag_ldst),
		       .dstval(dstval_ldst),
		       .spectag(spectag_ldst),
		       .specbit(specbit_ldst),
		       //EXRSLT
		       .exrslt1(result_alu1),
		       .exdst1(buf_rrftag_alu1),
		       .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),
		       .exrslt2(result_alu2),
		       .exdst2(buf_rrftag_alu2),
		       .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),
		       .exrslt3(result_ldst),
		       .exdst3(wrrftag_ldst),
		       .kill_spec3(kill_speculative_ldst | ~robwe_ldst),
		       .exrslt4(result_branch),
		       .exdst4(buf_rrftag_branch),
		       .kill_spec4(~robwe_branch),
		       .exrslt5(result_mul),
		       .exdst5(buf_rrftag_mul),
		       .kill_spec5(kill_speculative_mul | ~robwe_mul)
		       );


   assign allocent2_branch = allocent1_branch + 1;
   assign issue_branch = ~prmiss & issuevalid_branch; ///CTRL RSV_BRANCH
   
   alloc_issue_ino ai_branch(
			     .clk(clk),
			     .reset(reset),
			     .reqnum(req_branchnum),
			     .busyvec(busyvec_branch),
			     .prbusyvec_next(prbusyvec_next_branch),
			     .readyvec(ready_branch),
			     .prmiss(prmiss),
			     .exunit_busynext(1'b0),
			     .stall_DP(stall_DP),
			     .kill_DP(kill_DP),
			     .allocptr(allocent1_branch),
			     .allocatable(allocatable_branch),
			     .issueptr(issueent_branch),
			     .issuevalid(issuevalid_branch)
			     );
   
   rs_branch reserv_branch(
			   //System
			   .clk(clk),
			   .reset(reset),
			   .busyvec(busyvec_branch),
			   .prmiss(prmiss),
			   .prsuccess(prsuccess),
			   .prtag(buf_spectag_branch),
			   .specfixtag(spectagfix),
			   .prbusyvec_next(prbusyvec_next_branch),
			   //WriteSignal
			   .clearbusy(issue_branch), //Issue 
			   .issueaddr(issueent_branch), //= raddr, clsbsyadr
			   .we1(~stall_DP & ~kill_DP & req1_branch), //alloc1 ///CTRL RSV_BRANCH
			   .we2(~stall_DP & ~kill_DP & req2_branch), //alloc2 ///CTRL RSV_BRANCH
			   .waddr1(allocent1_branch), //allocent1
			   .waddr2(req1_branch ? 
				   allocent2_branch : allocent1_branch), //allocent2
			   //WriteSignal1
			   .wpc_1(pc_id),
			   .wsrc1_1(src1_1),
			   .wsrc2_1(src2_1),
			   .wvalid1_1(~uses_rs1_1_id | resolved1_1),
			   .wvalid2_1(~uses_rs2_1_id | resolved2_1),
			   .wimm_1(brimm1),
			   .wrrftag_1(dst1_renamed),
			   .wdstval_1(wr_reg_1_id),
			   .walu_op_1(alu_op_1_id),
			   .wspectag_1(sptag1_id),
			   .wspecbit_1(spec1_id),
			   .wbhr_1(bhr_id),        ///DC
			   .wprcond_1(prcond1_id), ///DC
			   .wpraddr_1(praddr1_id), 
			   .wopcode_1(inst1_id[6:0]),
			   //WriteSignal2
			   .wpc_2(pc_id + 4),                        ///DC
			   .wsrc1_2(src1_2),                         ///DC
			   .wsrc2_2(src2_2),                         ///DC
			   .wvalid1_2(~uses_rs1_2_id | resolved1_2), ///DC
			   .wvalid2_2(~uses_rs2_2_id | resolved2_2), ///DC
			   .wimm_2(brimm2),                          ///DC
			   .wrrftag_2(dst2_renamed),                 ///DC
			   .wdstval_2(wr_reg_2_id),                  ///DC
			   .walu_op_2(alu_op_2_id),                  ///DC
			   .wspectag_2(sptag2_id),                   ///DC
			   .wspecbit_2(spec2_id),                    ///DC
			   .wbhr_2(bhr_id),                          ///DC
			   .wprcond_2(prcond2_id),                   ///DC
			   .wpraddr_2(praddr2_id),                   ///DC
			   .wopcode_2(inst2_id[6:0]),                ///DC
			   //ReadSignal
			   .ex_src1(ex_src1_branch),
			   .ex_src2(ex_src2_branch),
			   .ready(ready_branch),
			   .pc(pc_branch),
			   .imm(imm_branch),
			   .rrftag(rrftag_branch),
			   .dstval(dstval_branch),
			   .alu_op(alu_op_branch),
			   .spectag(spectag_branch),
			   .specbit(specbit_branch),
			   .bhr(bhr_branch),        ///DC
			   .prcond(prcond_branch),  ///DC
			   .praddr(praddr_branch),
			   .opcode(opcode_branch),
			   //EXRSLT
			   .exrslt1(result_alu1),
			   .exdst1(buf_rrftag_alu1),
			   .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),
			   .exrslt2(result_alu2),
			   .exdst2(buf_rrftag_alu2),
			   .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),
			   .exrslt3(result_ldst),
			   .exdst3(wrrftag_ldst),
			   .kill_spec3(kill_speculative_ldst | ~robwe_ldst),
			   .exrslt4(result_branch),
			   .exdst4(buf_rrftag_branch),
			   .kill_spec4(~robwe_branch),
			   .exrslt5(result_mul),
			   .exdst5(buf_rrftag_mul),
			   .kill_spec5(kill_speculative_mul | ~robwe_mul)
			   );

   assign issue_mul = ~prmiss & issuevalid_mul;  ///CTRL RSV_MUL

   allocateunit #(`MUL_ENT_NUM, `MUL_ENT_SEL) alloc_mul(
							.busy(busyvec_mul), //RS_BUSY
							      .en1(),
							      .en2(),
							.free_ent1(allocent1_mul),
							.free_ent2(allocent2_mul),
							.reqnum(req_mulnum),
							.allocatable(allocatable_mul)
							);

   prioenc #(`MUL_ENT_NUM, `MUL_ENT_SEL) isunt_mul(
						   .in(~ready_mul),
						   .out(issueent_mul),
						   .en(issuevalid_mul)
						   );
   
   rs_mul reserv_mul(
		     //System
		     .clk(clk),
		     .reset(reset),
		     .busyvec(busyvec_mul),
		     .prmiss(prmiss),
		     .prsuccess(prsuccess),
		     .prtag(buf_spectag_branch),
		     .specfixtag(spectagfix),
		     //WriteSignal
		     .clearbusy(issue_mul), //Issue 
		     .issueaddr(issueent_mul), //= raddr, clsbsyadr
		     .we1(~stall_DP & ~kill_DP & req1_mul), //alloc1 ///CTRL RSV_MUL
		     .we2(~stall_DP & ~kill_DP & req2_mul), //alloc2 ///CTRL RSV_MUL
		     .waddr1(allocent1_mul), //allocent1
		     .waddr2(req1_mul ? 
			     allocent2_mul : allocent1_mul), //allocent2
		     //WriteSignal1
		     .wsrc1_1(src1_1),
		     .wsrc2_1(src2_1),
		     .wvalid1_1(~uses_rs1_1_id | resolved1_1),
		     .wvalid2_1(~uses_rs2_1_id | resolved2_1),
		     .wrrftag_1(dst1_renamed),
		     .wdstval_1(wr_reg_1_id),
		     .wspectag_1(sptag1_id),
		     .wspecbit_1(spec1_id),
		     .wsrc1_signed_1(md_req_in_1_signed_1_id),
		     .wsrc2_signed_1(md_req_in_2_signed_1_id),
		     .wsel_lohi_1(md_req_out_sel_1_id[0]),
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
		     .ex_src1(ex_src1_mul),
		     .ex_src2(ex_src2_mul),
		     .ready(ready_mul),
		     .rrftag(rrftag_mul),
		     .dstval(dstval_mul),
		     .spectag(spectag_mul),
		     .specbit(specbit_mul),
		     .src1_signed(src1_signed_mul),
		     .src2_signed(src2_signed_mul),
		     .sel_lohi(sel_lohi_mul),
		     //EXRSLT
		     .exrslt1(result_alu1),
		     .exdst1(buf_rrftag_alu1),
		     .kill_spec1(kill_speculative_alu1 | ~robwe_alu1),
		     .exrslt2(result_alu2),
		     .exdst2(buf_rrftag_alu2),
		     .kill_spec2(kill_speculative_alu2 | ~robwe_alu2),
		     .exrslt3(result_ldst),
		     .exdst3(wrrftag_ldst),
		     .kill_spec3(kill_speculative_ldst | ~robwe_ldst),
		     .exrslt4(result_branch),
		     .exdst4(buf_rrftag_branch),
		     .kill_spec4(~robwe_branch),
		     .exrslt5(result_mul),
		     .exdst5(buf_rrftag_mul),
		     .kill_spec5(kill_speculative_mul | ~robwe_mul)
		     );
   
   //EX Stage********************************************************

   always @ (posedge clk) begin ///CTRL EXEC_ALU
      if (reset) begin          ///CTRL EXEC_ALU
	 buf_ex_src1_alu1 <= 0;
	 buf_ex_src2_alu1 <= 0;
	 buf_pc_alu1 <= 0;
	 buf_imm_alu1 <= 0;
	 buf_rrftag_alu1 <= 0;
	 buf_dstval_alu1 <= 0;
	 buf_src_a_alu1 <= 0;
	 buf_src_b_alu1 <= 0;
	 buf_alu_op_alu1 <= 0;
	 buf_spectag_alu1 <= 0;
	 buf_specbit_alu1 <= 0;
      end else if (issue_alu1) begin   ///CTRL EXEC_ALU
	 buf_ex_src1_alu1 <= ex_src1_alu1;
	 buf_ex_src2_alu1 <= ex_src2_alu1;
	 buf_pc_alu1 <= pc_alu1;
	 buf_imm_alu1 <= imm_alu1;
	 buf_rrftag_alu1 <= rrftag_alu1;
	 buf_dstval_alu1 <= dstval_alu1;
	 buf_src_a_alu1 <= src_a_alu1;
	 buf_src_b_alu1 <= src_b_alu1;
	 buf_alu_op_alu1 <= alu_op_alu1;
	 buf_spectag_alu1 <= spectag_alu1;
	 buf_specbit_alu1 <= specbit_alu1;
      end
   end
   
   exunit_alu byakko(
		     .clk(clk),
		     .reset(reset),
		     .ex_src1(buf_ex_src1_alu1),
		     .ex_src2(buf_ex_src2_alu1),
		     .pc(buf_pc_alu1),
		     .imm(buf_imm_alu1),
		     .dstval(buf_dstval_alu1),
		     .src_a(buf_src_a_alu1),
		     .src_b(buf_src_b_alu1),
		     .alu_op(buf_alu_op_alu1),
		     .spectag(buf_spectag_alu1),
		     .specbit(buf_specbit_alu1),
		     .issue(issue_alu1),
		     .prmiss(prmiss),
		     .spectagfix(spectagfix),
		     .result(result_alu1),
		     .rrf_we(rrfwe_alu1),
		     .rob_we(robwe_alu1),
		     .kill_speculative(kill_speculative_alu1)
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

   always @ (posedge clk) begin   ///CTRL EXEC_LDST               
      if (reset) begin            ///CTRL EXEC_LDST            
	 buf_ex_src1_ldst <= 0;                     
	 buf_ex_src2_ldst <= 0;                     
	 buf_pc_ldst <= 0;                          
	 buf_imm_ldst <= 0;                         
	 buf_rrftag_ldst <= 0;                      
	 buf_dstval_ldst <= 0;                      
	 buf_spectag_ldst <= 0;                     
	 buf_specbit_ldst <= 0;                     
      end else if (issue_ldst) begin  ///CTRL EXEC_LDST
	 buf_ex_src1_ldst <= ex_src1_ldst;          
	 buf_ex_src2_ldst <= ex_src2_ldst;          
	 buf_pc_ldst <= pc_ldst;                    
	 buf_imm_ldst <= imm_ldst;                  
	 buf_rrftag_ldst <= rrftag_ldst;            
	 buf_dstval_ldst <= dstval_ldst;            
	 buf_spectag_ldst <= spectag_ldst;          
	 buf_specbit_ldst <= specbit_ldst;          
      end                                       
   end // always @ (posedge clk)                

   assign dmem_addr = (memoccupy_ld) ? ldaddr : retaddr;

/*   
   dmem datamemory(
		   .clk(clk),
		   .addr({2'b0, dmem_addr[`ADDR_LEN-1:2]}),
		   .wdata(dmem_wdata),
		   .we(dmem_we),
		   .rdata(dmem_data)
		   );
*/
   storebuf sb
     (
      .clk(clk),
      .reset(reset),
      .prsuccess(prsuccess),
      .prmiss(prmiss),
      .prtag(buf_spectag_branch),
      .spectagfix(spectagfix),
      .stfin(stfin),
      .stspecbit(buf_specbit_ldst),
      .stspectag(buf_spectag_ldst),
      .stdata(storedata),
      .staddr(storeaddr),
      .stcom(stcommit),
      .stretire(dmem_we),
      .retdata(dmem_wdata),
      .retaddr(retaddr),
      .memoccupy_ld(memoccupy_ld),
      .sb_full(sb_full),
      .ldaddr(ldaddr),
      .lddata(lddatasb),
      .hit(hitsb)
      );

   exunit_ldst seiryu(
		      .clk(clk),
		      .reset(reset),
		      .ex_src1(buf_ex_src1_ldst),
		      .ex_src2(buf_ex_src2_ldst),
		      .pc(buf_pc_ldst),
		      .imm(buf_imm_ldst),
		      .dstval(buf_dstval_ldst),
		      .spectag(buf_spectag_ldst),
		      .specbit(buf_specbit_ldst),
		      .rrftag(buf_rrftag_ldst),
		      .issue(issue_ldst),
		      .prmiss(prmiss),
		      .spectagfix(spectagfix),
		      .result(result_ldst),
		      .rrf_we(rrfwe_ldst),
		      .rob_we(robwe_ldst),
		      .wrrftag(wrrftag_ldst),
		      .kill_speculative(kill_speculative_ldst),
		      .busy_next(busy_next_ldst),
		      .stfin(stfin),
		      .memoccupy_ld(memoccupy_ld),
		      .fullsb(sb_full),
		      .storedata(storedata),
		      .storeaddr(storeaddr),
		      .hitsb(hitsb),
		      .ldaddr(ldaddr),
		      .lddatasb(lddatasb),
		      .lddatamem(dmem_data)
		      );

   always @ (posedge clk) begin    ///CTRL EXEC_MUL
      if (reset) begin             ///CTRL EXEC_MUL
	 buf_ex_src1_mul <= 0;
	 buf_ex_src2_mul <= 0;
	 buf_pc_mul <= 0;
	 buf_rrftag_mul <= 0;
	 buf_dstval_mul <= 0;
	 buf_spectag_mul <= 0;
	 buf_specbit_mul <= 0;
	 buf_src1_signed_mul <= 0;
	 buf_src2_signed_mul <= 0;
	 buf_sel_lohi_mul <= 0;
      end else if (issue_mul) begin  ///CTRL EXEC_MUL
	 buf_ex_src1_mul <= ex_src1_mul;
	 buf_ex_src2_mul <= ex_src2_mul;
	 buf_pc_mul <= pc_mul;
	 buf_rrftag_mul <= rrftag_mul;
	 buf_dstval_mul <= dstval_mul;
	 buf_spectag_mul <= spectag_mul;
	 buf_specbit_mul <= specbit_mul;
	 buf_src1_signed_mul <= src1_signed_mul;
	 buf_src2_signed_mul <= src2_signed_mul;
	 buf_sel_lohi_mul <= sel_lohi_mul;
      end
   end
   
   exunit_mul genbu (
		     .clk(clk),
		     .reset(reset),
		     .ex_src1(buf_ex_src1_mul),
		     .ex_src2(buf_ex_src2_mul),
		     .dstval(buf_dstval_mul),
		     .spectag(buf_spectag_mul),
		     .specbit(buf_specbit_mul),
		     .src1_signed(buf_src1_signed_mul),
		     .src2_signed(buf_src2_signed_mul),
		     .sel_lohi(buf_sel_lohi_mul),
		     .issue(issue_mul),
		     .prmiss(prmiss),
		     .spectagfix(spectagfix),
		     .result(result_mul),
		     .rrf_we(rrfwe_mul),
		     .rob_we(robwe_mul),
		     .kill_speculative(kill_speculative_mul)
		     );


   always @ (posedge clk) begin   ///CTRL EXEC_BRANCH
      if (reset) begin            ///CTRL EXEC_BRANCH
	 buf_ex_src1_branch <= 0;
	 buf_ex_src2_branch <= 0;
	 buf_pc_branch <= 0;
	 buf_imm_branch <= 0;
	 buf_rrftag_branch <= 0;
	 buf_dstval_branch <= 0;
	 buf_alu_op_branch <= 0;
	 buf_spectag_branch <= 0;
	 buf_specbit_branch <= 0;
	 buf_praddr_branch <= 0;
	 buf_opcode_branch <= 0;
      end else if (issue_branch) begin      ///CTRL EXEC_BRANCH
	 buf_ex_src1_branch <= ex_src1_branch;
	 buf_ex_src2_branch <= ex_src2_branch;
	 buf_pc_branch <= pc_branch;
	 buf_imm_branch <= imm_branch;
	 buf_rrftag_branch <= rrftag_branch;
	 buf_dstval_branch <= dstval_branch;
	 buf_alu_op_branch <= alu_op_branch;
	 buf_spectag_branch <= spectag_branch;
	 buf_specbit_branch <= specbit_branch;
	 buf_praddr_branch <= praddr_branch;
	 buf_opcode_branch <= opcode_branch;
      end
   end
   
   exunit_branch kirin(
		       .clk(clk),
		       .reset(reset),
		       .ex_src1(buf_ex_src1_branch),
		       .ex_src2(buf_ex_src2_branch),
		       .pc(buf_pc_branch),
		       .imm(buf_imm_branch),
		       .dstval(buf_dstval_branch),
		       .alu_op(buf_alu_op_branch),
		       .spectag(buf_spectag_branch),
		       .specbit(buf_specbit_branch),
		       .praddr(buf_praddr_branch),
		       .opcode(buf_opcode_branch),
		       .issue(issue_branch),
		       .result(result_branch),
		       .rrf_we(rrfwe_branch),
		       .rob_we(robwe_branch),
		       .prsuccess(prsuccess),
		       .prmiss(prmiss),
		       .jmpaddr(jmpaddr), 
		       .jmpaddr_taken(jmpaddr_taken),  ///DC
		       .brcond(brcond), ///DC
		       .tagregfix(tagregfix)
		       );

   
   miss_prediction_fix_table mpft(
				  .clk(clk),
				  .reset(reset),
				  .mpft_valid(mpft_valid),
				  .value_addr(buf_spectag_branch),
				  .mpft_value(spectagfix),
				  .prmiss(prmiss),
				  .prsuccess(prsuccess),
				  .prsuccess_tag(buf_spectag_branch),
				  .setspec1_tag(sptag1),
				  .setspec1_en(isbranch1 & ~stall_ID & ~stall_DP), ///CTRL MPFT
				  .setspec2_tag(sptag2),
				  .setspec2_en(branchvalid2 & ~stall_ID & ~stall_DP) ///CTRL MPFT
				  );
   
   //COM Stage*******************************************************
   reorderbuf rob(
		  .clk(clk),
		  .reset(reset),
		  .dp1(~stall_DP & ~kill_DP & ~inv1_id), ///CTRL ROB
		  .dp1_addr(dst1_renamed),
		  .pc_dp1(pc_id),
		  .storebit_dp1(inst1_id[6:0] == `RV32_STORE ? 1'b1 : 1'b0),
		  .dstvalid_dp1(wr_reg_1_id),
		  .dst_dp1(rd_1_id),
		  .bhr_dp1(bhr_id), ///DC
		  .isbranch_dp1(req1_branch),
		  .dp2(~stall_DP & ~kill_DP & ~inv2_id), ///CTRL ROB
		  .dp2_addr(dst2_renamed),
		  .pc_dp2(pc_id + 4),
		  .storebit_dp2(inst2_id[6:0] == `RV32_STORE ? 1'b1 : 1'b0),
		  .dstvalid_dp2(wr_reg_2_id),
		  .dst_dp2(rd_2_id),
		  .bhr_dp2(bhr_id), ///DC
		  .isbranch_dp2(req2_branch),
		  .exfin_alu1(robwe_alu1),
		  .exfin_alu1_addr(buf_rrftag_alu1),
		  .exfin_alu2(robwe_alu2),
		  .exfin_alu2_addr(buf_rrftag_alu2),
		  .exfin_mul(robwe_mul),
		  .exfin_mul_addr(buf_rrftag_mul),
		  .exfin_ldst(robwe_ldst),
		  .exfin_ldst_addr(wrrftag_ldst),
		  .exfin_branch(robwe_branch),
		  .exfin_branch_addr(buf_rrftag_branch),
		  .exfin_branch_brcond(brcond),          ///DC
		  .exfin_branch_jmpaddr(jmpaddr_taken), ///DC

		  .comptr(comptr),
		  .comptr2(comptr2),
		  .comnum(comnum),
		  .stcommit(stcommit),
		  .arfwe1(arfwe1),
		  .arfwe2(arfwe2),
		  .dstarf1(dstarf1),
		  .dstarf2(dstarf2),
		  .pc_combranch(pc_combranch), ///DC
		  .bhr_combranch(bhr_combranch), ///DC
		  .brcond_combranch(brcond_combranch),   ///DC
		  .jmpaddr_combranch(jmpaddr_combranch), ///DC
		  .combranch(combranch), ///DC
		  .dispatchptr(rrfptr),
		  .rrf_freenum(freenum),
		  .prmiss(prmiss)
		  );
   
endmodule // pipeline

`default_nettype wire
