`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module rs_branch_ent
  (
   //Memory
   input wire 			  clk,
   input wire 			  reset,
   input wire 			  busy,
   input wire [`ADDR_LEN-1:0] 	  wpc,
   input wire [`DATA_LEN-1:0] 	  wsrc1,
   input wire [`DATA_LEN-1:0] 	  wsrc2,
   input wire 			  wvalid1,
   input wire 			  wvalid2,
   input wire [`DATA_LEN-1:0] 	  wimm,
   input wire [`RRF_SEL-1:0] 	  wrrftag,
   input wire 			  wdstval,
   input wire [`ALU_OP_WIDTH-1:0] walu_op,
   input wire [`SPECTAG_LEN-1:0]  wspectag,
   input wire [`GSH_BHR_LEN-1:0]  wbhr,
   input wire 			  wprcond,
   input wire [`ADDR_LEN-1:0] 	  wpraddr,
   input wire [6:0] 		  wopcode,
   input wire 			  we,
   output wire [`DATA_LEN-1:0] 	  ex_src1,
   output wire [`DATA_LEN-1:0] 	  ex_src2,
   output wire 			  ready                 /* verilator public */,
   output reg [`ADDR_LEN-1:0] 	  pc            /* verilator public */,
   output reg [`DATA_LEN-1:0] 	  imm           /* verilator public */,
   output reg [`RRF_SEL-1:0] 	  rrftag        /* verilator public */,
   output reg 			  dstval                /* verilator public */,
   output reg [`ALU_OP_WIDTH-1:0] alu_op        /* verilator public */,
   output reg [`SPECTAG_LEN-1:0]  spectag       /* verilator public */,
   output reg [`GSH_BHR_LEN-1:0]  bhr           /* verilator public */,
   output reg 			  prcond                /* verilator public */,
   output reg [`ADDR_LEN-1:0] 	  praddr        /* verilator public */,
   output reg [6:0] 		  opcode            /* verilator public */,
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	  exrslt1,
   input wire [`RRF_SEL-1:0] 	  exdst1,
   input wire 			  kill_spec1,
   input wire [`DATA_LEN-1:0] 	  exrslt2,
   input wire [`RRF_SEL-1:0] 	  exdst2,
   input wire 			  kill_spec2,
   input wire [`DATA_LEN-1:0] 	  exrslt3,
   input wire [`RRF_SEL-1:0] 	  exdst3,
   input wire 			  kill_spec3,
   input wire [`DATA_LEN-1:0] 	  exrslt4,
   input wire [`RRF_SEL-1:0] 	  exdst4,
   input wire 			  kill_spec4,
   input wire [`DATA_LEN-1:0] 	  exrslt5,
   input wire [`RRF_SEL-1:0] 	  exdst5,
   input wire 			  kill_spec5
   );

   reg [`DATA_LEN-1:0] 		  src1 /* verilator public */;
   reg [`DATA_LEN-1:0] 		  src2 /* verilator public */;
   reg 				  valid1 /* verilator public */;
   reg 				  valid2 /* verilator public */;

   wire [`DATA_LEN-1:0] 	  nextsrc1;
   wire [`DATA_LEN-1:0] 	  nextsrc2;   
   wire 			  nextvalid1;
   wire 			  nextvalid2;
   
   assign ready = busy & valid1 & valid2;
   assign ex_src1 = ~valid1 & nextvalid1 ?
		    nextsrc1 : src1;
   assign ex_src2 = ~valid2 & nextvalid2 ?
		    nextsrc2 : src2;
   
   always @ (posedge clk) begin
      if (reset) begin
	 pc <= 0;
	 imm <= 0;
	 rrftag <= 0;
	 dstval <= 0;
	 alu_op <= 0;
	 spectag <= 0;
	 bhr <= 0;
	 prcond <= 0;
	 praddr <= 0;
	 opcode <= 0;
	 
	 src1 <= 0;
	 src2 <= 0;
	 valid1 <= 0;
	 valid2 <= 0;
      end else if (we) begin
	 pc <= wpc;
	 imm <= wimm;
	 rrftag <= wrrftag;
	 dstval <= wdstval;
	 alu_op <= walu_op;
	 spectag <= wspectag;
	 bhr <= wbhr;
	 prcond <= wprcond;
	 praddr <= wpraddr;
	 opcode <= wopcode;

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



module rs_branch
  (
   //System
   input wire 			     clk,
   input wire 			     reset,
   output reg [`BRANCH_ENT_NUM-1:0]  busyvec /* verilator public */,
   input wire 			     prmiss,
   input wire 			     prsuccess,
   input wire [`SPECTAG_LEN-1:0]     prtag,
   input wire [`SPECTAG_LEN-1:0]     specfixtag,
   output wire [`BRANCH_ENT_NUM-1:0] prbusyvec_next,
   //WriteSignal
   input wire 			     clearbusy, //Issue 
   input wire [`BRANCH_ENT_SEL-1:0]  issueaddr, //= raddr, clsbsyadr
   input wire 			     we1, //alloc1
   input wire 			     we2, //alloc2
   input wire [`BRANCH_ENT_SEL-1:0]  waddr1, //allocent1
   input wire [`BRANCH_ENT_SEL-1:0]  waddr2, //allocent2
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 	     wpc_1,
   input wire [`DATA_LEN-1:0] 	     wsrc1_1,
   input wire [`DATA_LEN-1:0] 	     wsrc2_1,
   input wire 			     wvalid1_1,
   input wire 			     wvalid2_1,
   input wire [`DATA_LEN-1:0] 	     wimm_1,
   input wire [`RRF_SEL-1:0] 	     wrrftag_1,
   input wire 			     wdstval_1,
   input wire [`ALU_OP_WIDTH-1:0]    walu_op_1,
   input wire [`SPECTAG_LEN-1:0]     wspectag_1,
   input wire 			     wspecbit_1,
   input wire [`GSH_BHR_LEN-1:0]     wbhr_1,
   input wire 			     wprcond_1,
   input wire [`ADDR_LEN-1:0] 	     wpraddr_1,
   input wire [6:0] 		     wopcode_1,

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
   output wire [`DATA_LEN-1:0] 	     ex_src1,
   output wire [`DATA_LEN-1:0] 	     ex_src2,
   output wire [`BRANCH_ENT_NUM-1:0] ready,
   output wire [`ADDR_LEN-1:0] 	     pc,
   output wire [`DATA_LEN-1:0] 	     imm,
   output wire [`RRF_SEL-1:0] 	     rrftag,
   output wire 			     dstval,
   output wire [`ALU_OP_WIDTH-1:0]   alu_op,
   output wire [`SPECTAG_LEN-1:0]    spectag,
   output wire 			     specbit,
   output wire [`GSH_BHR_LEN-1:0]    bhr,
   output wire 			     prcond,
   output wire [`ADDR_LEN-1:0] 	     praddr,
   output wire [6:0] 		     opcode,
  
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

   //_0
   wire [`DATA_LEN-1:0] 	     ex_src1_0;
   wire [`DATA_LEN-1:0] 	     ex_src2_0;
   wire 			     ready_0;
   wire [`ADDR_LEN-1:0] 	     pc_0;
   wire [`DATA_LEN-1:0] 	     imm_0;
   wire [`RRF_SEL-1:0] 		     rrftag_0;
   wire 			     dstval_0;
   wire [`ALU_OP_WIDTH-1:0] 	     alu_op_0;
   wire [`SPECTAG_LEN-1:0] 	     spectag_0;
   wire [`GSH_BHR_LEN-1:0] 	     bhr_0;
   wire 			     prcond_0;
   wire [`ADDR_LEN-1:0] 	     praddr_0;
   wire [6:0] 			     opcode_0;
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
   
   reg [`BRANCH_ENT_NUM-1:0] 	     specbitvec /* verilator public */;

   wire [`BRANCH_ENT_NUM-1:0] 	     inv_vector =
				     {(spectag_3 & specfixtag) == 0 ? 1'b1 : 1'b0,
				      (spectag_2 & specfixtag) == 0 ? 1'b1 : 1'b0,
				      (spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,
				      (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};

   wire [`BRANCH_ENT_NUM-1:0] 	     inv_vector_spec =
				     {(spectag_3 == prtag) ? 1'b0 : 1'b1,
				      (spectag_2 == prtag) ? 1'b0 : 1'b1,
				      (spectag_1 == prtag) ? 1'b0 : 1'b1,
				      (spectag_0 == prtag) ? 1'b0 : 1'b1};

   wire [`BRANCH_ENT_NUM-1:0] 	     specbitvec_next =
				     (inv_vector_spec & specbitvec);
   /* |
    (we1 & wspecbit_1 ? (`BRANCH_ENT_SEL'b1 << waddr1) : 0) |
    (we2 & wspecbit_2 ? (`BRANCH_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? 
		    specbitvec_next[issueaddr] : specbitvec[issueaddr];
   
   assign ready = {ready_3, ready_2, ready_1, ready_0};
   assign prbusyvec_next = inv_vector & busyvec;
   
   always @ (posedge clk) begin
      if (reset) begin
	 busyvec <= 0;
	 specbitvec <= 0;
      end else begin
	 if (prmiss) begin
	    busyvec <= prbusyvec_next;
	    specbitvec <= 0;
	 end else if (prsuccess) begin
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
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	       specbitvec[waddr1] <= wspecbit_1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	       specbitvec[waddr2] <= wspecbit_2;
	    end
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end
      end
   end

   rs_branch_ent ent0(
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
		      .walu_op((we1 && (waddr1 == 0)) ? walu_op_1 : walu_op_2),
		      .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),
		      .wbhr((we1 && (waddr1 == 0)) ? wbhr_1 : wbhr_2),
		      .wpraddr((we1 && (waddr1 == 0)) ? wpraddr_1 : wpraddr_2),
		      .wprcond((we1 && (waddr1 == 0)) ? wprcond_1 : wprcond_2),
		      .wopcode((we1 && (waddr1 == 0)) ? wopcode_1 : wopcode_2),
		      .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),
		      .ex_src1(ex_src1_0),
		      .ex_src2(ex_src2_0),
		      .ready(ready_0),
		      .pc(pc_0),
		      .imm(imm_0),
		      .rrftag(rrftag_0),
		      .dstval(dstval_0),
		      .alu_op(alu_op_0),
		      .spectag(spectag_0),
		      .bhr(bhr_0),
		      .prcond(prcond_0),
		      .praddr(praddr_0),
		      .opcode(opcode_0),
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
   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 :
		    (issueaddr == 1) ? ex_src1_1 :                             ///DC
		    (issueaddr == 2) ? ex_src1_2 : ex_src1_3;                             ///DC
   
   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 :
		    (issueaddr == 1) ? ex_src2_1 :                            ///DC
		    (issueaddr == 2) ? ex_src2_2 : ex_src2_3;                            ///DC
   
   assign pc = (issueaddr == 0) ? pc_0 :
	       (issueaddr == 1) ? pc_1 :                                 ///DC
	       (issueaddr == 2) ? pc_2 : pc_3;                                 ///DC
   
   assign imm = (issueaddr == 0) ? imm_0 :
		(issueaddr == 1) ? imm_1 :                                     ///DC
		(issueaddr == 2) ? imm_2 : imm_3;                                     ///DC
   
   assign rrftag = (issueaddr == 0) ? rrftag_0 :
		   (issueaddr == 1) ? rrftag_1 :                            ///DC
		   (issueaddr == 2) ? rrftag_2 : rrftag_3;                            ///DC
   
   assign dstval = (issueaddr == 0) ? dstval_0 :
		   (issueaddr == 1) ? dstval_1 :                            ///DC
		   (issueaddr == 2) ? dstval_2 : dstval_3;                            ///DC

   assign alu_op = (issueaddr == 0) ? alu_op_0 :
		   (issueaddr == 1) ? alu_op_1 :                             ///DC
		   (issueaddr == 2) ? alu_op_2 : alu_op_3;                             ///DC

   assign spectag = (issueaddr == 0) ? spectag_0 :
		    (issueaddr == 1) ? spectag_1 :                           ///DC
		    (issueaddr == 2) ? spectag_2 : spectag_3;                           ///DC
   
   assign bhr = (issueaddr == 0) ? bhr_0 :                             ///DC
		(issueaddr == 1) ? bhr_1 :                                     ///DC
		(issueaddr == 2) ? bhr_2 : bhr_3;                                     ///DC
   
   assign prcond = (issueaddr == 0) ? prcond_0 :                        ///DC 
		   (issueaddr == 1) ? prcond_1 :                                ///DC
		   (issueaddr == 2) ? prcond_2 : prcond_3;                                ///DC
   
   assign praddr = (issueaddr == 0) ? praddr_0 :
		   (issueaddr == 1) ? praddr_1 :                               ///DC
		   (issueaddr == 2) ? praddr_2 : praddr_3;                               ///DC
   
   assign opcode = (issueaddr == 0) ? opcode_0 :
		   (issueaddr == 1) ? opcode_1 :                             ///DC
		   (issueaddr == 2) ? opcode_2 : opcode_3;                             ///DC
   
   
endmodule // rs_branch
`default_nettype wire
