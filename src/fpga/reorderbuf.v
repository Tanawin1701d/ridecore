`include "constants.vh"
`default_nettype none
module reorderbuf
  (
   input wire 			  clk,
   input wire 			  reset,
   //Write Signal
   input wire 			  dp1,
   input wire [`RRF_SEL-1:0] 	  dp1_addr,
   input wire [`INSN_LEN-1:0] 	  pc_dp1,
   input wire 			  storebit_dp1,
   input wire 			  dstvalid_dp1,
   input wire [`REG_SEL-1:0] 	  dst_dp1,
   input wire [`GSH_BHR_LEN-1:0]  bhr_dp1, ///DC
   input wire 			  isbranch_dp1,
   input wire 			  dp2,
   input wire [`RRF_SEL-1:0] 	  dp2_addr,
   input wire [`INSN_LEN-1:0] 	  pc_dp2,
   input wire 			  storebit_dp2,
   input wire 			  dstvalid_dp2,
   input wire [`REG_SEL-1:0] 	  dst_dp2,
   input wire [`GSH_BHR_LEN-1:0]  bhr_dp2, ///DC
   input wire 			  isbranch_dp2,
   input wire 			  exfin_alu1,
   input wire [`RRF_SEL-1:0] 	  exfin_alu1_addr,
   input wire 			  exfin_alu2,
   input wire [`RRF_SEL-1:0] 	  exfin_alu2_addr,
   input wire 			  exfin_mul,
   input wire [`RRF_SEL-1:0] 	  exfin_mul_addr,
   input wire 			  exfin_ldst,
   input wire [`RRF_SEL-1:0] 	  exfin_ldst_addr,
   input wire 			  exfin_branch,                      
   input wire [`RRF_SEL-1:0] 	  exfin_branch_addr,       
   input wire 			  exfin_branch_brcond,               ///DC
   input wire [`ADDR_LEN-1:0] 	  exfin_branch_jmpaddr,  ///DC
  
   output reg [`RRF_SEL-1:0] 	  comptr /* verilator public */,
   output wire [`RRF_SEL-1:0] 	  comptr2,
   output wire [1:0] 		  comnum,
   output wire 			  stcommit,
   output wire 			  arfwe1,
   output wire 			  arfwe2,
   output wire [`REG_SEL-1:0] 	  dstarf1,
   output wire [`REG_SEL-1:0] 	  dstarf2,
   output wire [`ADDR_LEN-1:0] 	  pc_combranch,      ///DC
   output wire [`GSH_BHR_LEN-1:0] bhr_combranch,     ///DC
   output wire 			  brcond_combranch,              ///DC
   output wire [`ADDR_LEN-1:0] 	  jmpaddr_combranch, ///DC
   output wire 			  combranch,                     ///DC
   input wire [`RRF_SEL-1:0] 	  dispatchptr,
   input wire [`RRF_SEL:0] 	  rrf_freenum,
   input wire 			  prmiss
   );

   reg [`RRF_NUM-1:0] 		  finish    /* verilator public */;
   reg [`RRF_NUM-1:0] 		  storebit    /* verilator public */;
   reg [`RRF_NUM-1:0] 		  dstvalid    /* verilator public */;
   reg [`RRF_NUM-1:0] 		  brcond    /* verilator public */;       ///DC
   reg [`RRF_NUM-1:0] 		  isbranch    /* verilator public */;     ///DC
   
   reg [`ADDR_LEN-1:0] 		  inst_pc [0:`RRF_NUM-1] /* verilator public */; ///DC           
   reg [`ADDR_LEN-1:0] 		  jmpaddr [0:`RRF_NUM-1] /* verilator public */; ///DC
   reg [`REG_SEL-1:0] 		  dst [0:`RRF_NUM-1] /* verilator public */;                 
   reg [`GSH_BHR_LEN-1:0] 	  bhr [0:`RRF_NUM-1] /* verilator public */;   ///DC         
   
   assign comptr2 = comptr+1;
   
   wire 			  hidp = (comptr > dispatchptr) || (rrf_freenum == 0) ?
				  1'b1 : 1'b0;
   wire 			  com_en1 = ({hidp, dispatchptr} - {1'b0, comptr}) > 0 ? 1'b1 : 1'b0;
   wire 			  com_en2 = ({hidp, dispatchptr} - {1'b0, comptr}) > 1 ? 1'b1 : 1'b0;
   wire 			  commit1 /* verilator public */ ;
   assign       commit1 = com_en1 & finish[comptr];
   //   wire commit2 = commit1 & com_en2 & finish[comptr2];

   wire 			  commit2/* verilator public */;
   assign 	    commit2 = 
				  ~(~prmiss & commit1 & isbranch[comptr]) &
				  ~(commit1 & storebit[comptr] & ~prmiss) &
				  commit1 & com_en2 & finish[comptr2];

   assign comnum = {1'b0, commit1} + {1'b0, commit2};
   assign stcommit = (commit1 & storebit[comptr] & ~prmiss) |
		     (commit2 & storebit[comptr2] & ~prmiss);
   assign arfwe1 = ~prmiss & commit1 & dstvalid[comptr];
   assign arfwe2 = ~prmiss & commit2 & dstvalid[comptr2];
   assign dstarf1 = dst[comptr];
   assign dstarf2 = dst[comptr2];
   assign combranch = (~prmiss & commit1 & isbranch[comptr]) |         ///DC
		      (~prmiss & commit2 & isbranch[comptr2]);                     ///DC
   assign pc_combranch = (~prmiss & commit1 & isbranch[comptr]) ?      ///DC
			 inst_pc[comptr] : inst_pc[comptr2];                             ///DC
   assign bhr_combranch = (~prmiss & commit1 & isbranch[comptr]) ?     ///DC
			  bhr[comptr] : bhr[comptr2];                                    ///DC
   assign brcond_combranch = (~prmiss & commit1 & isbranch[comptr]) ?  ///DC
			     brcond[comptr] : brcond[comptr2];                           ///DC
   assign jmpaddr_combranch = (~prmiss & commit1 & isbranch[comptr]) ? ///DC
			      jmpaddr[comptr] : jmpaddr[comptr2];                        ///DC
   

   always @ (posedge clk) begin
      if (reset) begin
	 comptr <= 0;
      end else if (~prmiss) begin
	 comptr <= comptr + {{(`RRF_SEL-1){1'b0}}, commit1} + {{(`RRF_SEL-1){1'b0}}, commit2};
   //comptr <= comptr + commit1 + commit2;
      end
   end
   
   always @ (posedge clk) begin
      if (reset) begin
	 finish <= 0;
	 brcond <= 0; ///DC
      end else begin
	 if (dp1)
	   finish[dp1_addr] <= 1'b0;
	 if (dp2)
	   finish[dp2_addr] <= 1'b0;
	 if (exfin_alu1)
	   finish[exfin_alu1_addr] <= 1'b1;
	 if (exfin_alu2)
	   finish[exfin_alu2_addr] <= 1'b1;
	 if (exfin_mul)
	   finish[exfin_mul_addr] <= 1'b1;
	 if (exfin_ldst)
	   finish[exfin_ldst_addr] <= 1'b1;
	 if (exfin_branch) begin
	    finish[exfin_branch_addr] <= 1'b1;
	    brcond[exfin_branch_addr] <= exfin_branch_brcond;    ///DC
	    jmpaddr[exfin_branch_addr] <= exfin_branch_jmpaddr;    ///DC
	 end
      end
   end // always @ (posedge clk)

   always @ (posedge clk) begin
      if (dp1) begin
	 isbranch[dp1_addr] <= isbranch_dp1; ///DC
	 storebit[dp1_addr] <= storebit_dp1;
	 dstvalid[dp1_addr] <= dstvalid_dp1;
	 dst[dp1_addr] <= dst_dp1;
	 bhr[dp1_addr] <= bhr_dp1;     ///DC
	 inst_pc[dp1_addr] <= pc_dp1;  ///DC
      end
      if (dp2) begin
	 isbranch[dp2_addr] <= isbranch_dp2; ///DC
	 storebit[dp2_addr] <= storebit_dp2;
	 dstvalid[dp2_addr] <= dstvalid_dp2;
	 dst[dp2_addr] <= dst_dp2;
	 bhr[dp2_addr] <= bhr_dp2;     ///DC
	 inst_pc[dp2_addr] <= pc_dp2;  ///DC
      end
   end
endmodule // reorderbuf
`default_nettype wire
