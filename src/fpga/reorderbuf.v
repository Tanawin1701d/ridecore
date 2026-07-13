`include "constants.vh"
`default_nettype none
module reorderbuf   ///MD ROB
  (
   input wire 			  clk,                ///CTRL_HC ROB
   input wire 			  reset,              ///CTRL_HC ROB
   //Write Signal
   input wire 			  dp1,                         ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  dp1_addr,            ///CTRL_HC ROB
   input wire [`INSN_LEN-1:0] 	  pc_dp1,              ///DATA_HC ROB
   input wire 			  storebit_dp1,                ///CTRL_HC ROB
   input wire 			  dstvalid_dp1,                ///CTRL_HC ROB
   input wire [`REG_SEL-1:0] 	  dst_dp1,             ///DATA_HC ROB
   input wire [`GSH_BHR_LEN-1:0]  bhr_dp1,             ///DC
   input wire 			  isbranch_dp1,                ///CTRL_HC ROB
   input wire 			  dp2,                         ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  dp2_addr,            ///CTRL_HC ROB
   input wire [`INSN_LEN-1:0] 	  pc_dp2,              ///DATA_HC ROB
   input wire 			  storebit_dp2,                ///CTRL_HC ROB
   input wire 			  dstvalid_dp2,                ///CTRL_HC ROB
   input wire [`REG_SEL-1:0] 	  dst_dp2,             ///DATA_HC ROB
   input wire [`GSH_BHR_LEN-1:0]  bhr_dp2,             ///DC
   input wire 			  isbranch_dp2,                ///CTRL_HC ROB
   input wire 			  exfin_alu1,                  ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  exfin_alu1_addr,     ///CTRL_HC ROB
   input wire 			  exfin_alu2,                  ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  exfin_alu2_addr,     ///CTRL_HC ROB
   input wire 			  exfin_mul,                   ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  exfin_mul_addr,      ///CTRL_HC ROB
   input wire 			  exfin_ldst,                  ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  exfin_ldst_addr,     ///CTRL_HC ROB
   input wire 			  exfin_branch,                ///CTRL_HC ROB
   input wire [`RRF_SEL-1:0] 	  exfin_branch_addr,   ///CTRL_HC ROB
   input wire 			  exfin_branch_brcond,         ///DC
   input wire [`ADDR_LEN-1:0] 	  exfin_branch_jmpaddr,///DC
  
   output reg [`RRF_SEL-1:0] 	  comptr /* verilator public */,   ///CTRL_HC ROB
   output wire [`RRF_SEL-1:0] 	  comptr2,                         ///CTRL_HC ROB
   output wire [1:0] 		  comnum,                              ///CTRL_HC ROB
   output wire 			  stcommit,                                ///CTRL_HC ROB
   output wire 			  arfwe1,                                  ///CTRL_HC ROB
   output wire 			  arfwe2,                                  ///CTRL_HC ROB
   output wire [`REG_SEL-1:0] 	  dstarf1,                         ///DATA_HC ROB
   output wire [`REG_SEL-1:0] 	  dstarf2,                         ///DATA_HC ROB
   output wire [`ADDR_LEN-1:0] 	  pc_combranch,                    ///DC
   output wire [`GSH_BHR_LEN-1:0] bhr_combranch,                   ///DC
   output wire 			  brcond_combranch,                        ///DC
   output wire [`ADDR_LEN-1:0] 	  jmpaddr_combranch,               ///DC
   output wire 			  combranch,                               ///DC
   input wire [`RRF_SEL-1:0] 	  dispatchptr,                     ///CTRL_HC ROB
   input wire [`RRF_SEL:0] 	  rrf_freenum,                         ///CTRL_HC ROB
   input wire 			  prmiss                                   ///CTRL_HC ROB
   );

   reg [`RRF_NUM-1:0] 		  finish    /* verilator public */;       ///CTRL_HWD ROB
   reg [`RRF_NUM-1:0] 		  storebit    /* verilator public */;     ///CTRL_HWD ROB
   reg [`RRF_NUM-1:0] 		  dstvalid    /* verilator public */;     ///CTRL_HWD ROB
   reg [`RRF_NUM-1:0] 		  brcond    /* verilator public */;       ///DC
   reg [`RRF_NUM-1:0] 		  isbranch    /* verilator public */;     ///DC
   
   reg [`ADDR_LEN-1:0] 		  inst_pc [0:`RRF_NUM-1] /* verilator public */; ///DC           
   reg [`ADDR_LEN-1:0] 		  jmpaddr [0:`RRF_NUM-1] /* verilator public */; ///DC
   reg [`REG_SEL-1:0] 		  dst [0:`RRF_NUM-1] /* verilator public */;     ///DATA_HWD ROB
   reg [`GSH_BHR_LEN-1:0] 	  bhr [0:`RRF_NUM-1] /* verilator public */;     ///DC
   
   assign comptr2 = comptr+1;                                                               ///CTRL_CL ROB
   
   wire 			  hidp = (comptr > dispatchptr) || (rrf_freenum == 0) ?  1'b1 : 1'b0;   ///CTRL_CL ROB
   wire 			  com_en1 = ({hidp, dispatchptr} - {1'b0, comptr}) > 0 ? 1'b1 : 1'b0;   ///CTRL_CL ROB
   wire 			  com_en2 = ({hidp, dispatchptr} - {1'b0, comptr}) > 1 ? 1'b1 : 1'b0;   ///CTRL_CL ROB
   wire 			  commit1 /* verilator public */ ;
   assign       commit1 = com_en1 & finish[comptr];   ///CTRL_CL ROB
   //   wire commit2 = commit1 & com_en2 & finish[comptr2];

   wire 			  commit2/* verilator public */;
   assign 	    commit2 =   ///CTRL_CL ROB
				  ~(~prmiss & commit1 & isbranch[comptr]) &   ///CTRL_CL ROB
				  ~(commit1 & storebit[comptr] & ~prmiss) &   ///CTRL_CL ROB
				  commit1 & com_en2 & finish[comptr2];   ///CTRL_CL ROB

   assign comnum = {1'b0, commit1} + {1'b0, commit2};           ///CTRL_CL ROB
   assign stcommit = (commit1 & storebit[comptr] & ~prmiss) |   ///CTRL_CL ROB
		     (commit2 & storebit[comptr2] & ~prmiss);           ///CTRL_CL ROB
   assign arfwe1 = ~prmiss & commit1 & dstvalid[comptr];        ///CTRL_CL ROB
   assign arfwe2 = ~prmiss & commit2 & dstvalid[comptr2];       ///CTRL_CL ROB
   assign dstarf1 = dst[comptr];                                ///DATA_DT ROB
   assign dstarf2 = dst[comptr2];                               ///DATA_DT ROB
   assign combranch = (~prmiss & commit1 & isbranch[comptr]) |         ///DC
		      (~prmiss & commit2 & isbranch[comptr2]);                 ///DC
   assign pc_combranch = (~prmiss & commit1 & isbranch[comptr]) ?      ///DC
			 inst_pc[comptr] : inst_pc[comptr2];                       ///DC
   assign bhr_combranch = (~prmiss & commit1 & isbranch[comptr]) ?     ///DC
			  bhr[comptr] : bhr[comptr2];                              ///DC
   assign brcond_combranch = (~prmiss & commit1 & isbranch[comptr]) ?  ///DC
			     brcond[comptr] : brcond[comptr2];                     ///DC
   assign jmpaddr_combranch = (~prmiss & commit1 & isbranch[comptr]) ? ///DC
			      jmpaddr[comptr] : jmpaddr[comptr2];                  ///DC
   

   always @ (posedge clk) begin                   ///CTRL_CL ROB
      if (reset) begin                            ///CTRL_CL ROB
	 comptr <= 0;                                 ///CTRL_DT ROB
      end else if (~prmiss) begin                 ///CTRL_CL ROB
	 comptr <= comptr + {{(`RRF_SEL-1){1'b0}}, commit1} + {{(`RRF_SEL-1){1'b0}}, commit2};   ///CTRL_CL ROB
   //comptr <= comptr + commit1 + commit2;
      end
   end
   
   always @ (posedge clk) begin   ///CTRL_CL ROB
      if (reset) begin            ///CTRL_CL ROB
	 finish <= 0;                 ///CTRL_DT ROB
	 brcond <= 0;                 ///DC
      end else begin
	 if (dp1)                                                ///CTRL_CL ROB
	   finish[dp1_addr] <= 1'b0;                             ///CTRL_DT ROB
	 if (dp2)                                                ///CTRL_CL ROB
	   finish[dp2_addr] <= 1'b0;                             ///CTRL_DT ROB
	 if (exfin_alu1)                                         ///CTRL_CL ROB
	   finish[exfin_alu1_addr] <= 1'b1;                      ///CTRL_DT ROB
	 if (exfin_alu2)                                         ///CTRL_CL ROB
	   finish[exfin_alu2_addr] <= 1'b1;                      ///CTRL_DT ROB
	 if (exfin_mul)                                          ///CTRL_CL ROB
	   finish[exfin_mul_addr] <= 1'b1;                       ///CTRL_DT ROB
	 if (exfin_ldst)                                         ///CTRL_CL ROB
	   finish[exfin_ldst_addr] <= 1'b1;                      ///CTRL_DT ROB
	 if (exfin_branch) begin                                 ///CTRL_CL ROB
	    finish[exfin_branch_addr] <= 1'b1;                   ///CTRL_DT ROB
	    brcond[exfin_branch_addr] <= exfin_branch_brcond;    ///DC
	    jmpaddr[exfin_branch_addr] <= exfin_branch_jmpaddr;  ///DC
	 end
      end
   end // always @ (posedge clk)

   always @ (posedge clk) begin            ///CTRL_CL ROB
      if (dp1) begin                       ///CTRL_CL ROB
	 isbranch[dp1_addr] <= isbranch_dp1;   ///DC
	 storebit[dp1_addr] <= storebit_dp1;   ///CTRL_DT ROB
	 dstvalid[dp1_addr] <= dstvalid_dp1;   ///CTRL_DT ROB
	 dst[dp1_addr] <= dst_dp1;             ///DATA_DT ROB
	 bhr[dp1_addr] <= bhr_dp1;             ///DC
	 inst_pc[dp1_addr] <= pc_dp1;          ///DC
      end
      if (dp2) begin                       ///CTRL_CL ROB
	 isbranch[dp2_addr] <= isbranch_dp2;   ///DC
	 storebit[dp2_addr] <= storebit_dp2;   ///CTRL_DT ROB
	 dstvalid[dp2_addr] <= dstvalid_dp2;   ///CTRL_DT ROB
	 dst[dp2_addr] <= dst_dp2;             ///DATA_DT ROB
	 bhr[dp2_addr] <= bhr_dp2;             ///DC
	 inst_pc[dp2_addr] <= pc_dp2;          ///DC
      end
   end
endmodule // reorderbuf
`default_nettype wire
