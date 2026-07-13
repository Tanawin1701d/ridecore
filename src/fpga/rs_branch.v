`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module rs_branch_ent   ///MD RSV_BRANCH
  (
   //Memory
   input wire 			  clk,                                            ///CTRL_HC RSV_BRANCH
   input wire 			  reset,                                          ///CTRL_HC RSV_BRANCH
   input wire 			  busy,                                           ///CTRL_HC RSV_BRANCH
   input wire [`ADDR_LEN-1:0] 	  wpc,                                    ///DATA_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  wsrc1,                                  ///DATA_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  wsrc2,                                  ///DATA_HC RSV_BRANCH
   input wire 			  wvalid1,                                        ///CTRL_HC RSV_BRANCH
   input wire 			  wvalid2,                                        ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  wimm,                                   ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	  wrrftag,                                ///CTRL_HC RSV_BRANCH
   input wire 			  wdstval,                                        ///CTRL_HC RSV_BRANCH
   input wire [`ALU_OP_WIDTH-1:0] walu_op,                                ///DATA_HC RSV_BRANCH
   input wire [`SPECTAG_LEN-1:0]  wspectag,                               ///CTRL_HC RSV_BRANCH
   input wire [`GSH_BHR_LEN-1:0]  wbhr,                                   ///DC
   input wire 			  wprcond,                                        ///DC
   input wire [`ADDR_LEN-1:0] 	  wpraddr,                                ///DATA_HC RSV_BRANCH
   input wire [6:0] 		  wopcode,                                    ///DATA_HC RSV_BRANCH
   input wire 			  we,                                             ///CTRL_HC RSV_BRANCH
   output wire [`DATA_LEN-1:0] 	  ex_src1,                                ///DATA_HC RSV_BRANCH
   output wire [`DATA_LEN-1:0] 	  ex_src2,                                ///DATA_HC RSV_BRANCH
   output wire 			  ready                 /* verilator public */,   ///CTRL_HC RSV_BRANCH
   output reg [`ADDR_LEN-1:0] 	  pc            /* verilator public */,   ///DATA_HC RSV_BRANCH
   output reg [`DATA_LEN-1:0] 	  imm           /* verilator public */,   ///DATA_HC RSV_BRANCH
   output reg [`RRF_SEL-1:0] 	  rrftag        /* verilator public */,   ///CTRL_HC RSV_BRANCH
   output reg 			  dstval                /* verilator public */,   ///CTRL_HC RSV_BRANCH
   output reg [`ALU_OP_WIDTH-1:0] alu_op        /* verilator public */,   ///DATA_HC RSV_BRANCH
   output reg [`SPECTAG_LEN-1:0]  spectag       /* verilator public */,   ///CTRL_HC RSV_BRANCH
   output reg [`GSH_BHR_LEN-1:0]  bhr           /* verilator public */,   ///DC
   output reg 			  prcond                /* verilator public */,   ///DC
   output reg [`ADDR_LEN-1:0] 	  praddr        /* verilator public */,   ///DATA_HC RSV_BRANCH
   output reg [6:0] 		  opcode            /* verilator public */,   ///DATA_HC RSV_BRANCH
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	  exrslt1,   ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	  exdst1,    ///CTRL_HC RSV_BRANCH
   input wire 			  kill_spec1,        ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  exrslt2,   ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	  exdst2,    ///CTRL_HC RSV_BRANCH
   input wire 			  kill_spec2,        ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  exrslt3,   ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	  exdst3,    ///CTRL_HC RSV_BRANCH
   input wire 			  kill_spec3,        ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  exrslt4,   ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	  exdst4,    ///CTRL_HC RSV_BRANCH
   input wire 			  kill_spec4,        ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	  exrslt5,   ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	  exdst5,    ///CTRL_HC RSV_BRANCH
   input wire 			  kill_spec5         ///CTRL_HC RSV_BRANCH
   );

   reg [`DATA_LEN-1:0] 		  src1 /* verilator public */;   ///DATA_HWD RSV_BRANCH
   reg [`DATA_LEN-1:0] 		  src2 /* verilator public */;   ///DATA_HWD RSV_BRANCH
   reg 				  valid1 /* verilator public */;         ///CTRL_HWD RSV_BRANCH
   reg 				  valid2 /* verilator public */;         ///CTRL_HWD RSV_BRANCH

   wire [`DATA_LEN-1:0] 	  nextsrc1;                      ///DATA_HWD RSV_BRANCH
   wire [`DATA_LEN-1:0] 	  nextsrc2;                      ///DATA_HWD RSV_BRANCH
   wire 			  nextvalid1;                            ///CTRL_HWD RSV_BRANCH
   wire 			  nextvalid2;                            ///CTRL_HWD RSV_BRANCH
   
   assign ready = busy & valid1 & valid2;    ///CTRL_CL RSV_BRANCH
   assign ex_src1 = ~valid1 & nextvalid1 ?   nextsrc1 : src1;    ///DATA_CL RSV_BRANCH
   assign ex_src2 = ~valid2 & nextvalid2 ?   nextsrc2 : src2;    ///DATA_CL RSV_BRANCH
   
   always @ (posedge clk) begin  ///CTRL_CL RSV_BRANCH
      if (reset) begin           ///CTRL_CL RSV_BRANCH
	 pc <= 0;                    ///DATA_DT RSV_BRANCH
	 imm <= 0;                   ///DATA_DT RSV_BRANCH
	 rrftag <= 0;                ///CTRL_DT RSV_BRANCH
	 dstval <= 0;                ///CTRL_DT RSV_BRANCH
	 alu_op <= 0;                ///DATA_DT RSV_BRANCH
	 spectag <= 0;               ///CTRL_DT RSV_BRANCH
	 bhr <= 0;                   ///DC
	 prcond <= 0;                ///DC
	 praddr <= 0;                ///DATA_DT RSV_BRANCH
	 opcode <= 0;                ///DATA_DT RSV_BRANCH
	 
	 src1 <= 0;               ///DATA_DT RSV_BRANCH
	 src2 <= 0;               ///DATA_DT RSV_BRANCH
	 valid1 <= 0;             ///CTRL_DT RSV_BRANCH
	 valid2 <= 0;             ///CTRL_DT RSV_BRANCH
      end else if (we) begin  ///CTRL_CL RSV_BRANCH
	 pc <= wpc;               ///DATA_DT RSV_BRANCH
	 imm <= wimm;             ///DATA_DT RSV_BRANCH
	 rrftag <= wrrftag;       ///CTRL_DT RSV_BRANCH
	 dstval <= wdstval;       ///CTRL_DT RSV_BRANCH
	 alu_op <= walu_op;       ///DATA_DT RSV_BRANCH
	 spectag <= wspectag;     ///CTRL_DT RSV_BRANCH
	 bhr <= wbhr;             ///DC
	 prcond <= wprcond;       ///DC
	 praddr <= wpraddr;       ///DATA_DT RSV_BRANCH
	 opcode <= wopcode;       ///DATA_DT RSV_BRANCH

	 src1 <= wsrc1;           ///DATA_DT RSV_BRANCH
	 src2 <= wsrc2;           ///DATA_DT RSV_BRANCH
	 valid1 <= wvalid1;       ///CTRL_DT RSV_BRANCH
	 valid2 <= wvalid2;       ///CTRL_DT RSV_BRANCH
      end else begin // if (we)
	 src1 <= nextsrc1;        ///DATA_DT RSV_BRANCH
	 src2 <= nextsrc2;        ///DATA_DT RSV_BRANCH
	 valid1 <= nextvalid1;    ///CTRL_DT RSV_BRANCH
	 valid2 <= nextvalid2;    ///CTRL_DT RSV_BRANCH
      end
   end
   
   src_manager srcmng1(                 ///MD RSV_BRANCH
		       .opr(src1),              ///DATA_HC RSV_BRANCH
		       .opr_rdy(valid1),        ///CTRL_HC RSV_BRANCH
		       .exrslt1(exrslt1),       ///DATA_HC RSV_BRANCH
		       .exdst1(exdst1),         ///CTRL_HC RSV_BRANCH
		       .kill_spec1(kill_spec1), ///CTRL_HC RSV_BRANCH
		       .exrslt2(exrslt2),       ///DATA_HC RSV_BRANCH
		       .exdst2(exdst2),         ///CTRL_HC RSV_BRANCH
		       .kill_spec2(kill_spec2), ///CTRL_HC RSV_BRANCH
		       .exrslt3(exrslt3),       ///DATA_HC RSV_BRANCH
		       .exdst3(exdst3),         ///CTRL_HC RSV_BRANCH
		       .kill_spec3(kill_spec3), ///CTRL_HC RSV_BRANCH
		       .exrslt4(exrslt4),       ///DATA_HC RSV_BRANCH
		       .exdst4(exdst4),         ///CTRL_HC RSV_BRANCH
		       .kill_spec4(kill_spec4), ///CTRL_HC RSV_BRANCH
		       .exrslt5(exrslt5),       ///DATA_HC RSV_BRANCH
		       .exdst5(exdst5),         ///CTRL_HC RSV_BRANCH
		       .kill_spec5(kill_spec5), ///CTRL_HC RSV_BRANCH
		       .src(nextsrc1),          ///DATA_HC RSV_BRANCH
		       .resolved(nextvalid1)    ///CTRL_HC RSV_BRANCH
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
   
endmodule // rs_branch



module rs_branch   ///MD RSV_BRANCH
  (
   //System
   input wire 			     clk,                                       ///CTRL_HC RSV_BRANCH
   input wire 			     reset,                                     ///CTRL_HC RSV_BRANCH
   output reg [`BRANCH_ENT_NUM-1:0]  busyvec /* verilator public */,    ///CTRL_HC RSV_BRANCH
   input wire 			     prmiss,                                    ///CTRL_HC RSV_BRANCH
   input wire 			     prsuccess,                                 ///CTRL_HC RSV_BRANCH
   input wire [`SPECTAG_LEN-1:0]     prtag,                             ///CTRL_HC RSV_BRANCH
   input wire [`SPECTAG_LEN-1:0]     specfixtag,                        ///CTRL_HC RSV_BRANCH
   output wire [`BRANCH_ENT_NUM-1:0] prbusyvec_next,                    ///CTRL_HC RSV_BRANCH
   //WriteSignal
   input wire 			     clearbusy, //Issue                         ///CTRL_HC RSV_BRANCH
   input wire [`BRANCH_ENT_SEL-1:0]  issueaddr, //= raddr, clsbsyadr    ///CTRL_HC RSV_BRANCH
   input wire 			     we1, //alloc1                              ///CTRL_HC RSV_BRANCH
   input wire 			     we2, //alloc2                              ///CTRL_HC RSV_BRANCH
   input wire [`BRANCH_ENT_SEL-1:0]  waddr1, //allocent1                ///CTRL_HC RSV_BRANCH
   input wire [`BRANCH_ENT_SEL-1:0]  waddr2, //allocent2                ///CTRL_HC RSV_BRANCH
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 	     wpc_1,                             ///DATA_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     wsrc1_1,                           ///DATA_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     wsrc2_1,                           ///DATA_HC RSV_BRANCH
   input wire 			     wvalid1_1,                                 ///CTRL_HC RSV_BRANCH
   input wire 			     wvalid2_1,                                 ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     wimm_1,                            ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	     wrrftag_1,                         ///CTRL_HC RSV_BRANCH
   input wire 			     wdstval_1,                                 ///CTRL_HC RSV_BRANCH
   input wire [`ALU_OP_WIDTH-1:0]    walu_op_1,                         ///DATA_HC RSV_BRANCH
   input wire [`SPECTAG_LEN-1:0]     wspectag_1,                        ///CTRL_HC RSV_BRANCH
   input wire 			     wspecbit_1,                                ///CTRL_HC RSV_BRANCH
   input wire [`GSH_BHR_LEN-1:0]     wbhr_1,                            ///DC
   input wire 			     wprcond_1,                                 ///DC
   input wire [`ADDR_LEN-1:0] 	     wpraddr_1,                         ///DATA_HC RSV_BRANCH
   input wire [6:0] 		     wopcode_1,                             ///DATA_HC RSV_BRANCH

   //WriteSignal2
   input wire [`ADDR_LEN-1:0] 	     wpc_2,       ///DC
   input wire [`DATA_LEN-1:0] 	     wsrc1_2,     ///DC
   input wire [`DATA_LEN-1:0] 	     wsrc2_2,     ///DC
   input wire 			     wvalid1_2,           ///DC
   input wire 			     wvalid2_2,           ///DC
   input wire [`DATA_LEN-1:0] 	     wimm_2,      ///DC
   input wire [`RRF_SEL-1:0] 	     wrrftag_2,   ///DC
   input wire 			     wdstval_2,           ///DC
   input wire [`ALU_OP_WIDTH-1:0]    walu_op_2,   ///DC
   input wire [`SPECTAG_LEN-1:0]     wspectag_2,  ///DC
   input wire 			     wspecbit_2,          ///DC
   input wire [`GSH_BHR_LEN-1:0]     wbhr_2,      ///DC
   input wire 			     wprcond_2,           ///DC
   input wire [`ADDR_LEN-1:0] 	     wpraddr_2,   ///DC
   input wire [6:0] 		     wopcode_2,       ///DC

   //ReadSignal
   output wire [`DATA_LEN-1:0] 	     ex_src1,   ///DATA_HC RSV_BRANCH
   output wire [`DATA_LEN-1:0] 	     ex_src2,   ///DATA_HC RSV_BRANCH
   output wire [`BRANCH_ENT_NUM-1:0] ready,     ///CTRL_HC RSV_BRANCH
   output wire [`ADDR_LEN-1:0] 	     pc,        ///DATA_HC RSV_BRANCH
   output wire [`DATA_LEN-1:0] 	     imm,       ///DATA_HC RSV_BRANCH
   output wire [`RRF_SEL-1:0] 	     rrftag,    ///CTRL_HC RSV_BRANCH
   output wire 			     dstval,            ///CTRL_HC RSV_BRANCH
   output wire [`ALU_OP_WIDTH-1:0]   alu_op,    ///DATA_HC RSV_BRANCH
   output wire [`SPECTAG_LEN-1:0]    spectag,   ///CTRL_HC RSV_BRANCH
   output wire 			     specbit,           ///CTRL_HC RSV_BRANCH
   output wire [`GSH_BHR_LEN-1:0]    bhr,       ///DC
   output wire 			     prcond,            ///DC
   output wire [`ADDR_LEN-1:0] 	     praddr,    ///DATA_HC RSV_BRANCH
   output wire [6:0] 		     opcode,        ///DATA_HC RSV_BRANCH
  
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	     exrslt1, ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	     exdst1,  ///CTRL_HC RSV_BRANCH
   input wire 			     kill_spec1,      ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     exrslt2, ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	     exdst2,  ///CTRL_HC RSV_BRANCH
   input wire 			     kill_spec2,      ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     exrslt3, ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	     exdst3,  ///CTRL_HC RSV_BRANCH
   input wire 			     kill_spec3,      ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     exrslt4, ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	     exdst4,  ///CTRL_HC RSV_BRANCH
   input wire 			     kill_spec4,      ///CTRL_HC RSV_BRANCH
   input wire [`DATA_LEN-1:0] 	     exrslt5, ///DATA_HC RSV_BRANCH
   input wire [`RRF_SEL-1:0] 	     exdst5,  ///CTRL_HC RSV_BRANCH
   input wire 			     kill_spec5       ///CTRL_HC RSV_BRANCH
   );

   //_0
   wire [`DATA_LEN-1:0] 	     ex_src1_0;       ///DATA_HWD RSV_BRANCH
   wire [`DATA_LEN-1:0] 	     ex_src2_0;       ///DATA_HWD RSV_BRANCH
   wire 			     ready_0;                 ///CTRL_HWD RSV_BRANCH
   wire [`ADDR_LEN-1:0] 	     pc_0;            ///DATA_HWD RSV_BRANCH
   wire [`DATA_LEN-1:0] 	     imm_0;           ///DATA_HWD RSV_BRANCH
   wire [`RRF_SEL-1:0] 		     rrftag_0;        ///CTRL_HWD RSV_BRANCH
   wire 			     dstval_0;                ///CTRL_HWD RSV_BRANCH
   wire [`ALU_OP_WIDTH-1:0] 	     alu_op_0;    ///DATA_HWD RSV_BRANCH
   wire [`SPECTAG_LEN-1:0] 	     spectag_0;       ///CTRL_HWD RSV_BRANCH
   wire [`GSH_BHR_LEN-1:0] 	     bhr_0;           ///DC
   wire 			     prcond_0;                ///DC
   wire [`ADDR_LEN-1:0] 	     praddr_0;        ///DATA_HWD RSV_BRANCH
   wire [6:0] 			     opcode_0;            ///DATA_HWD RSV_BRANCH
   //_1
   wire [`DATA_LEN-1:0] 	     ex_src1_1;     ///DC
   wire [`DATA_LEN-1:0] 	     ex_src2_1;     ///DC
   wire 			     ready_1;               ///DC
   wire [`ADDR_LEN-1:0] 	     pc_1;          ///DC
   wire [`DATA_LEN-1:0] 	     imm_1;         ///DC
   wire [`RRF_SEL-1:0] 		     rrftag_1;      ///DC
   wire 			     dstval_1;              ///DC
   wire [`ALU_OP_WIDTH-1:0] 	     alu_op_1;  ///DC
   wire [`SPECTAG_LEN-1:0] 	     spectag_1;     ///DC
   wire [`GSH_BHR_LEN-1:0] 	     bhr_1;         ///DC
   wire 			     prcond_1;              ///DC
   wire [`ADDR_LEN-1:0] 	     praddr_1;      ///DC
   wire [6:0] 			     opcode_1;          ///DC
   //_2
   wire [`DATA_LEN-1:0] 	     ex_src1_2;     ///DC
   wire [`DATA_LEN-1:0] 	     ex_src2_2;     ///DC
   wire 			     ready_2;               ///DC
   wire [`ADDR_LEN-1:0] 	     pc_2;          ///DC
   wire [`DATA_LEN-1:0] 	     imm_2;         ///DC
   wire [`RRF_SEL-1:0] 		     rrftag_2;      ///DC
   wire 			     dstval_2;              ///DC
   wire [`ALU_OP_WIDTH-1:0] 	     alu_op_2;  ///DC
   wire [`SPECTAG_LEN-1:0] 	     spectag_2;     ///DC
   wire [`GSH_BHR_LEN-1:0] 	     bhr_2;         ///DC
   wire 			     prcond_2;              ///DC
   wire [`ADDR_LEN-1:0] 	     praddr_2;      ///DC
   wire [6:0] 			     opcode_2;          ///DC
   //_3
   wire [`DATA_LEN-1:0] 	     ex_src1_3;     ///DC
   wire [`DATA_LEN-1:0] 	     ex_src2_3;     ///DC
   wire 			     ready_3;               ///DC
   wire [`ADDR_LEN-1:0] 	     pc_3;          ///DC
   wire [`DATA_LEN-1:0] 	     imm_3;         ///DC
   wire [`RRF_SEL-1:0] 		     rrftag_3;      ///DC
   wire 			     dstval_3;              ///DC
   wire [`ALU_OP_WIDTH-1:0] 	     alu_op_3;  ///DC
   wire [`SPECTAG_LEN-1:0] 	     spectag_3;     ///DC
   wire [`GSH_BHR_LEN-1:0] 	     bhr_3;         ///DC
   wire 			     prcond_3;              ///DC
   wire [`ADDR_LEN-1:0] 	     praddr_3;      ///DC
   wire [6:0] 			     opcode_3;          ///DC
   
   reg [`BRANCH_ENT_NUM-1:0] 	     specbitvec /* verilator public */;   ///CTRL_HWD RSV_BRANCH

   wire [`BRANCH_ENT_NUM-1:0] 	     inv_vector =                         ///CTRL_CL RSV_BRANCH
				     {(spectag_3 & specfixtag) == 0 ? 1'b1 : 1'b0,        ///CTRL_CL RSV_BRANCH
				      (spectag_2 & specfixtag) == 0 ? 1'b1 : 1'b0,        ///CTRL_CL RSV_BRANCH
				      (spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,        ///CTRL_CL RSV_BRANCH
				      (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};       ///CTRL_CL RSV_BRANCH

   wire [`BRANCH_ENT_NUM-1:0] 	     inv_vector_spec =                    ///CTRL_CL RSV_BRANCH
				     {(spectag_3 == prtag) ? 1'b0 : 1'b1,                 ///CTRL_CL RSV_BRANCH
				      (spectag_2 == prtag) ? 1'b0 : 1'b1,                 ///CTRL_CL RSV_BRANCH
				      (spectag_1 == prtag) ? 1'b0 : 1'b1,                 ///CTRL_CL RSV_BRANCH
				      (spectag_0 == prtag) ? 1'b0 : 1'b1};                ///CTRL_CL RSV_BRANCH

   wire [`BRANCH_ENT_NUM-1:0] 	     specbitvec_next = (inv_vector_spec & specbitvec);     ///CTRL_CL RSV_BRANCH
   /* |
    (we1 & wspecbit_1 ? (`BRANCH_ENT_SEL'b1 << waddr1) : 0) |
    (we2 & wspecbit_2 ? (`BRANCH_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? specbitvec_next[issueaddr] : specbitvec[issueaddr];   ///CTRL_CL RSV_BRANCH
   
   assign ready = {ready_3, ready_2, ready_1, ready_0};   ///CTRL_CL RSV_BRANCH
   assign prbusyvec_next = inv_vector & busyvec;   ///CTRL_CL RSV_BRANCH
   
   always @ (posedge clk) begin        ///CTRL_CL RSV_BRANCH
      if (reset) begin                 ///CTRL_CL RSV_BRANCH
	 busyvec <= 0;                     ///CTRL_DT RSV_BRANCH
	 specbitvec <= 0;                  ///CTRL_DT RSV_BRANCH
      end else begin
	 if (prmiss) begin                 ///CTRL_CL RSV_BRANCH
	    busyvec <= prbusyvec_next;     ///CTRL_DT RSV_BRANCH
	    specbitvec <= 0;               ///CTRL_DT RSV_BRANCH
	 end else if (prsuccess) begin     ///CTRL_CL RSV_BRANCH
	    specbitvec <= specbitvec_next; ///CTRL_DT RSV_BRANCH
	    /*
	     if (we1) begin
	     busyvec[waddr1] <= 1'b1;
	    end
	     if (we2) begin
	     busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin             ///CTRL_CL RSV_BRANCH
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_BRANCH
	    end
	 end else begin
	    if (we1) begin                         ///CTRL_CL RSV_BRANCH
	       busyvec[waddr1] <= 1'b1;            ///CTRL_DT RSV_BRANCH
	       specbitvec[waddr1] <= wspecbit_1;   ///CTRL_DT RSV_BRANCH
	    end
	    if (we2) begin                         ///CTRL_CL RSV_BRANCH
	       busyvec[waddr2] <= 1'b1;            ///CTRL_DT RSV_BRANCH
	       specbitvec[waddr2] <= wspecbit_2;   ///CTRL_DT RSV_BRANCH
	    end
	    if (clearbusy) begin   ///CTRL_CL RSV_BRANCH
	       busyvec[issueaddr] <= 1'b0;   ///CTRL_DT RSV_BRANCH
	    end
	 end
      end
   end

   rs_branch_ent ent0(                                                    ///MD RSV_BRANCH
		      .clk(clk),                                                  ///CTRL_HC RSV_BRANCH
		      .reset(reset),                                              ///CTRL_HC RSV_BRANCH
		      .busy(busyvec[0]),                                          ///CTRL_HC RSV_BRANCH
		      .wpc((we1 && (waddr1 == 0)) ? wpc_1 : wpc_2),               ///DATA_HC+DATA_CL RSV_BRANCH
		      .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),         ///DATA_HC+DATA_CL RSV_BRANCH
		      .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),         ///DATA_HC+DATA_CL RSV_BRANCH
		      .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),   ///CTRL_HC+CTRL_CL RSV_BRANCH
		      .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),   ///CTRL_HC+CTRL_CL RSV_BRANCH
		      .wimm((we1 && (waddr1 == 0)) ? wimm_1 : wimm_2),            ///DATA_HC+DATA_CL RSV_BRANCH
		      .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),   ///CTRL_HC+CTRL_CL RSV_BRANCH
		      .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),   ///CTRL_HC+CTRL_CL RSV_BRANCH
		      .walu_op((we1 && (waddr1 == 0)) ? walu_op_1 : walu_op_2),   ///DATA_HC+DATA_CL RSV_BRANCH
		      .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),///CTRL_HC+CTRL_CL RSV_BRANCH
		      .wbhr((we1 && (waddr1 == 0)) ? wbhr_1 : wbhr_2),            ///DC
		      .wpraddr((we1 && (waddr1 == 0)) ? wpraddr_1 : wpraddr_2),   ///DATA_HC+DATA_CL RSV_BRANCH
		      .wprcond((we1 && (waddr1 == 0)) ? wprcond_1 : wprcond_2),   ///DC
		      .wopcode((we1 && (waddr1 == 0)) ? wopcode_1 : wopcode_2),   ///DATA_HC+DATA_CL RSV_BRANCH
		      .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),      ///CTRL_HC+CTRL_CL RSV_BRANCH
		      .ex_src1(ex_src1_0),                                        ///DATA_HC RSV_BRANCH
		      .ex_src2(ex_src2_0),                                        ///DATA_HC RSV_BRANCH
		      .ready(ready_0),                                            ///CTRL_HC RSV_BRANCH
		      .pc(pc_0),                                                  ///DATA_HC RSV_BRANCH
		      .imm(imm_0),                                                ///DATA_HC RSV_BRANCH
		      .rrftag(rrftag_0),                                          ///CTRL_HC RSV_BRANCH
		      .dstval(dstval_0),                                          ///CTRL_HC RSV_BRANCH
		      .alu_op(alu_op_0),                                          ///DATA_HC RSV_BRANCH
		      .spectag(spectag_0),                                        ///CTRL_HC RSV_BRANCH
		      .bhr(bhr_0),                                                ///DC
		      .prcond(prcond_0),                                          ///DC
		      .praddr(praddr_0),                                          ///DATA_HC RSV_BRANCH
		      .opcode(opcode_0),                                          ///DATA_HC RSV_BRANCH
		      .exrslt1(exrslt1),                                          ///DATA_HC RSV_BRANCH
		      .exdst1(exdst1),                                            ///CTRL_HC RSV_BRANCH
		      .kill_spec1(kill_spec1),                                    ///CTRL_HC RSV_BRANCH
		      .exrslt2(exrslt2),                                          ///DATA_HC RSV_BRANCH
		      .exdst2(exdst2),                                            ///CTRL_HC RSV_BRANCH
		      .kill_spec2(kill_spec2),                                    ///CTRL_HC RSV_BRANCH
		      .exrslt3(exrslt3),                                          ///DATA_HC RSV_BRANCH
		      .exdst3(exdst3),                                            ///CTRL_HC RSV_BRANCH
		      .kill_spec3(kill_spec3),                                    ///CTRL_HC RSV_BRANCH
		      .exrslt4(exrslt4),                                          ///DATA_HC RSV_BRANCH
		      .exdst4(exdst4),                                            ///CTRL_HC RSV_BRANCH
		      .kill_spec4(kill_spec4),                                    ///CTRL_HC RSV_BRANCH
		      .exrslt5(exrslt5),                                          ///DATA_HC RSV_BRANCH
		      .exdst5(exdst5),                                            ///CTRL_HC RSV_BRANCH
		      .kill_spec5(kill_spec5)                                     ///CTRL_HC RSV_BRANCH
		      );

   rs_branch_ent ent1(                                                      ///DC
		      .clk(clk),                                                    ///DC
		      .reset(reset),		      		                            ///DC
		      .busy(busyvec[1]),                                            ///DC
		      .wpc((we1 && (waddr1 == 1)) ? wpc_1 : wpc_2),                 ///DC
		      .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),           ///DC
		      .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),           ///DC
		      .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),     ///DC
		      .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),     ///DC
		      .wimm((we1 && (waddr1 == 1)) ? wimm_1 : wimm_2),              ///DC
		      .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),     ///DC
		      .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),     ///DC
		      .walu_op((we1 && (waddr1 == 1)) ? walu_op_1 : walu_op_2),     ///DC
		      .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),  ///DC
		      .wbhr((we1 && (waddr1 == 1)) ? wbhr_1 : wbhr_2),              ///DC
		      .wpraddr((we1 && (waddr1 == 1)) ? wpraddr_1 : wpraddr_2),     ///DC
		      .wprcond((we1 && (waddr1 == 1)) ? wprcond_1 : wprcond_2),     ///DC
		      .wopcode((we1 && (waddr1 == 1)) ? wopcode_1 : wopcode_2),     ///DC
		      .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),        ///DC
		      .ex_src1(ex_src1_1),                                          ///DC
		      .ex_src2(ex_src2_1),                                          ///DC
		      .ready(ready_1),                                              ///DC
		      .pc(pc_1),                                                    ///DC
		      .imm(imm_1),                                                  ///DC
		      .rrftag(rrftag_1),                                            ///DC
		      .dstval(dstval_1),                                            ///DC
		      .alu_op(alu_op_1),                                            ///DC
		      .spectag(spectag_1),                                          ///DC
		      .bhr(bhr_1),                                                  ///DC
		      .prcond(prcond_1),                                            ///DC
		      .praddr(praddr_1),                                            ///DC
		      .opcode(opcode_1),                                            ///DC
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

   rs_branch_ent ent2(                                                      ///DC            
		      .clk(clk),                                                    ///DC            
		      .reset(reset),		      		                            ///DC            
		      .busy(busyvec[2]),                                            ///DC            
		      .wpc((we1 && (waddr1 == 2)) ? wpc_1 : wpc_2),                 ///DC            
		      .wsrc1((we1 && (waddr1 == 2)) ? wsrc1_1 : wsrc1_2),           ///DC            
		      .wsrc2((we1 && (waddr1 == 2)) ? wsrc2_1 : wsrc2_2),           ///DC            
		      .wvalid1((we1 && (waddr1 == 2)) ? wvalid1_1 : wvalid1_2),     ///DC            
		      .wvalid2((we1 && (waddr1 == 2)) ? wvalid2_1 : wvalid2_2),     ///DC            
		      .wimm((we1 && (waddr1 == 2)) ? wimm_1 : wimm_2),              ///DC            
		      .wrrftag((we1 && (waddr1 == 2)) ? wrrftag_1 : wrrftag_2),     ///DC            
		      .wdstval((we1 && (waddr1 == 2)) ? wdstval_1 : wdstval_2),     ///DC            
		      .walu_op((we1 && (waddr1 == 2)) ? walu_op_1 : walu_op_2),     ///DC            
		      .wspectag((we1 && (waddr1 == 2)) ? wspectag_1 : wspectag_2),  ///DC            
		      .wbhr((we1 && (waddr1 == 2)) ? wbhr_1 : wbhr_2),              ///DC            
		      .wpraddr((we1 && (waddr1 == 2)) ? wpraddr_1 : wpraddr_2),     ///DC            
		      .wprcond((we1 && (waddr1 == 2)) ? wprcond_1 : wprcond_2),     ///DC            
		      .wopcode((we1 && (waddr1 == 2)) ? wopcode_1 : wopcode_2),     ///DC            
		      .we((we1 && (waddr1 == 2)) || (we2 && (waddr2 == 2))),        ///DC            
		      .ex_src1(ex_src1_2),                                          ///DC            
		      .ex_src2(ex_src2_2),                                          ///DC            
		      .ready(ready_2),                                              ///DC            
		      .pc(pc_2),                                                    ///DC            
		      .imm(imm_2),                                                  ///DC            
		      .rrftag(rrftag_2),                                            ///DC            
		      .dstval(dstval_2),                                            ///DC            
		      .alu_op(alu_op_2),                                            ///DC            
		      .spectag(spectag_2),                                          ///DC            
		      .bhr(bhr_2),                                                  ///DC            
		      .prcond(prcond_2),                                            ///DC            
		      .praddr(praddr_2),                                            ///DC            
		      .opcode(opcode_2),                                            ///DC            
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

   rs_branch_ent ent3(                                                      ///DC
		      .clk(clk),                                                    ///DC
		      .reset(reset),		      		                            ///DC
		      .busy(busyvec[3]),                                            ///DC
		      .wpc((we1 && (waddr1 == 3)) ? wpc_1 : wpc_2),                 ///DC
		      .wsrc1((we1 && (waddr1 == 3)) ? wsrc1_1 : wsrc1_2),           ///DC
		      .wsrc2((we1 && (waddr1 == 3)) ? wsrc2_1 : wsrc2_2),           ///DC
		      .wvalid1((we1 && (waddr1 == 3)) ? wvalid1_1 : wvalid1_2),     ///DC
		      .wvalid2((we1 && (waddr1 == 3)) ? wvalid2_1 : wvalid2_2),     ///DC
		      .wimm((we1 && (waddr1 == 3)) ? wimm_1 : wimm_2),              ///DC
		      .wrrftag((we1 && (waddr1 == 3)) ? wrrftag_1 : wrrftag_2),     ///DC
		      .wdstval((we1 && (waddr1 == 3)) ? wdstval_1 : wdstval_2),     ///DC
		      .walu_op((we1 && (waddr1 == 3)) ? walu_op_1 : walu_op_2),     ///DC
		      .wspectag((we1 && (waddr1 == 3)) ? wspectag_1 : wspectag_2),  ///DC
		      .wbhr((we1 && (waddr1 == 3)) ? wbhr_1 : wbhr_2),              ///DC
		      .wpraddr((we1 && (waddr1 == 3)) ? wpraddr_1 : wpraddr_2),     ///DC
		      .wprcond((we1 && (waddr1 == 3)) ? wprcond_1 : wprcond_2),     ///DC
		      .wopcode((we1 && (waddr1 == 3)) ? wopcode_1 : wopcode_2),     ///DC
		      .we((we1 && (waddr1 == 3)) || (we2 && (waddr2 == 3))),        ///DC
		      .ex_src1(ex_src1_3),                                          ///DC
		      .ex_src2(ex_src2_3),                                          ///DC
		      .ready(ready_3),                                              ///DC
		      .pc(pc_3),                                                    ///DC
		      .imm(imm_3),                                                  ///DC
		      .rrftag(rrftag_3),                                            ///DC
		      .dstval(dstval_3),                                            ///DC
		      .alu_op(alu_op_3),                                            ///DC
		      .spectag(spectag_3),                                          ///DC
		      .bhr(bhr_3),                                                  ///DC
		      .prcond(prcond_3),                                            ///DC
		      .praddr(praddr_3),                                            ///DC
		      .opcode(opcode_3),                                            ///DC
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
   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 :   ///DATA_CL RSV_BRANCH
		    (issueaddr == 1) ? ex_src1_1 :                             ///DC
		    (issueaddr == 2) ? ex_src1_2 : ex_src1_3;                             ///DC
   
   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 :   ///DATA_CL RSV_BRANCH
		    (issueaddr == 1) ? ex_src2_1 :                            ///DC
		    (issueaddr == 2) ? ex_src2_2 : ex_src2_3;                            ///DC
   
   assign pc = (issueaddr == 0) ? pc_0 :   ///DATA_CL RSV_BRANCH
	       (issueaddr == 1) ? pc_1 :                                 ///DC
	       (issueaddr == 2) ? pc_2 : pc_3;                                 ///DC
   
   assign imm = (issueaddr == 0) ? imm_0 :   ///DATA_CL RSV_BRANCH
		(issueaddr == 1) ? imm_1 :                                     ///DC
		(issueaddr == 2) ? imm_2 : imm_3;                                     ///DC
   
   assign rrftag = (issueaddr == 0) ? rrftag_0 :   ///CTRL_CL RSV_BRANCH
		   (issueaddr == 1) ? rrftag_1 :                            ///DC
		   (issueaddr == 2) ? rrftag_2 : rrftag_3;                            ///DC
   
   assign dstval = (issueaddr == 0) ? dstval_0 :   ///CTRL_CL RSV_BRANCH
		   (issueaddr == 1) ? dstval_1 :                            ///DC
		   (issueaddr == 2) ? dstval_2 : dstval_3;                            ///DC

   assign alu_op = (issueaddr == 0) ? alu_op_0 :   ///DATA_CL RSV_BRANCH
		   (issueaddr == 1) ? alu_op_1 :                             ///DC
		   (issueaddr == 2) ? alu_op_2 : alu_op_3;                             ///DC

   assign spectag = (issueaddr == 0) ? spectag_0 :   ///CTRL_CL RSV_BRANCH
		    (issueaddr == 1) ? spectag_1 :                           ///DC
		    (issueaddr == 2) ? spectag_2 : spectag_3;                           ///DC
   
   assign bhr = (issueaddr == 0) ? bhr_0 :                             ///DC
		(issueaddr == 1) ? bhr_1 :                                     ///DC
		(issueaddr == 2) ? bhr_2 : bhr_3;                                     ///DC
   
   assign prcond = (issueaddr == 0) ? prcond_0 :                        ///DC 
		   (issueaddr == 1) ? prcond_1 :                                ///DC
		   (issueaddr == 2) ? prcond_2 : prcond_3;                                ///DC
   
   assign praddr = (issueaddr == 0) ? praddr_0 :   ///DATA_CL RSV_BRANCH
		   (issueaddr == 1) ? praddr_1 :                               ///DC
		   (issueaddr == 2) ? praddr_2 : praddr_3;                               ///DC
   
   assign opcode = (issueaddr == 0) ? opcode_0 :   ///DATA_CL RSV_BRANCH
		   (issueaddr == 1) ? opcode_1 :                             ///DC
		   (issueaddr == 2) ? opcode_2 : opcode_3;                             ///DC
   
   
endmodule // rs_branch
`default_nettype wire
