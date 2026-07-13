`include "constants.vh"
`include "alu_ops.vh"
//`default_nettype none

module exunit_ldst                             ///MD EXEC_LDST
  (
   input wire 			 clk,                  ///CTRL_HC EXEC_LDST
   input wire 			 reset,                ///CTRL_HC EXEC_LDST
   input wire [`DATA_LEN-1:0] 	 ex_src1,      ///DATA_HC EXEC_LDST
   input wire [`DATA_LEN-1:0] 	 ex_src2,      ///DATA_HC EXEC_LDST
   input wire [`ADDR_LEN-1:0] 	 pc,           ///DATA_HC EXEC_LDST
   input wire [`DATA_LEN-1:0] 	 imm,          ///DATA_HC EXEC_LDST
   input wire 			 dstval,               ///CTRL_HC EXEC_LDST
   input wire [`SPECTAG_LEN-1:0] spectag,      ///CTRL_HC EXEC_LDST
   input wire 			 specbit,              ///CTRL_HC EXEC_LDST
   input wire 			 issue,                ///CTRL_HC EXEC_LDST
   input wire 			 prmiss,               ///CTRL_HC EXEC_LDST
   input wire [`SPECTAG_LEN-1:0] spectagfix,   ///CTRL_HC EXEC_LDST
   input wire [`RRF_SEL-1:0] 	 rrftag,       ///CTRL_HC EXEC_LDST
   output wire [`DATA_LEN-1:0] 	 result,       ///DATA_HC EXEC_LDST
   output wire 			 rrf_we,               ///CTRL_HC EXEC_LDST
   output wire 			 rob_we, //set finish  ///CTRL_HC EXEC_LDST
   output wire [`RRF_SEL-1:0] 	 wrrftag,      ///CTRL_HC EXEC_LDST
   output wire 			 kill_speculative,     ///CTRL_HC EXEC_LDST
   output wire 			 busy_next,            ///CTRL_HC EXEC_LDST
   //Signal StoreBuf
   output wire 			 stfin,                ///CTRL_HC EXEC_LDST
   //Store
   output wire 			 memoccupy_ld,         ///CTRL_HC EXEC_LDST
   input wire 			 fullsb,               ///CTRL_HC EXEC_LDST
   output wire [`DATA_LEN-1:0] 	 storedata,    ///DATA_HC EXEC_LDST
   output wire [`ADDR_LEN-1:0] 	 storeaddr,    ///DATA_HC EXEC_LDST
   //Load
   input wire 			 hitsb,                                     ///CTRL_HC EXEC_LDST
   output wire [`ADDR_LEN-1:0] 	 ldaddr,                            ///DATA_HC EXEC_LDST
   input wire [`DATA_LEN-1:0] 	 lddatasb,                          ///DATA_HC EXEC_LDST
   input wire [`DATA_LEN-1:0] 	 lddatamem /* verilator public */   ///DATA_HC EXEC_LDST
   );

   reg 				 busy /* verilator public */;              ///CTRL_HWD EXEC_LDST
   wire 			 clearbusy;                                ///CTRL_HWD EXEC_LDST
   wire [`ADDR_LEN-1:0] 	 effaddr /* verilator public */;   ///DATA_HWD EXEC_LDST
   wire 			 killspec1/* verilator public */;          ///CTRL_HWD EXEC_LDST
   
   //LATCH
   reg 				 dstval_latch /* verilator public */;           ///CTRL_HWD EXEC_LDST
   reg [`RRF_SEL-1:0] 		 rrftag_latch /* verilator public */;   ///CTRL_HWD EXEC_LDST
   reg 				 specbit_latch /* verilator public */;          ///CTRL_HWD EXEC_LDST
   reg [`SPECTAG_LEN-1:0] 	 spectag_latch /* verilator public */;  ///CTRL_HWD EXEC_LDST
   reg [`DATA_LEN-1:0] 		 lddatasb_latch /* verilator public */; ///DATA_HWD EXEC_LDST
   reg 				 hitsb_latch /* verilator public */;            ///CTRL_HWD EXEC_LDST
   reg 				 insnvalid_latch /* verilator public */;        ///CTRL_HWD EXEC_LDST

   assign clearbusy = (killspec1 || dstval || (~dstval && ~fullsb)) ? 1'b1 : 1'b0;          ///CTRL_CL EXEC_LDST
   assign killspec1 = ((spectag & spectagfix) != 0) && specbit && prmiss;                   ///CTRL_CL EXEC_LDST
   assign kill_speculative = ((spectag_latch & spectagfix) != 0) && specbit_latch && prmiss;///CTRL_CL EXEC_LDST
   assign result = hitsb_latch ? lddatasb_latch : lddatamem;                                ///DATA_CL EXEC_LDST
   assign rrf_we = dstval_latch & insnvalid_latch;                                          ///CTRL_CL EXEC_LDST
   assign rob_we = insnvalid_latch;                                                         ///CTRL_DT EXEC_LDST
   assign wrrftag = rrftag_latch;                                                           ///CTRL_DT EXEC_LDST
   assign busy_next = clearbusy ? 1'b0 : busy;                                              ///CTRL_CL EXEC_LDST
   assign stfin = ~killspec1 & busy & ~dstval;                                              ///CTRL_CL EXEC_LDST
   assign memoccupy_ld = ~killspec1 & busy & dstval;                                        ///CTRL_CL EXEC_LDST
   assign storedata = ex_src2;                                                              ///DATA_DT EXEC_LDST
   assign storeaddr = effaddr;                                                              ///DATA_DT EXEC_LDST
   assign ldaddr = effaddr;                                                                 ///DATA_DT EXEC_LDST
   assign effaddr = ex_src1 + imm;                                                          ///DATA_CL EXEC_LDST
   
   always @ (posedge clk) begin                                   ///CTRL_CL EXEC_LDST
      if (reset | killspec1 | ~busy | (~dstval & fullsb)) begin   ///CTRL_CL EXEC_LDST
	 dstval_latch <= 0;                                           ///CTRL_DT EXEC_LDST
	 rrftag_latch <= 0;                                           ///CTRL_DT EXEC_LDST
	 specbit_latch <= 0;                                          ///CTRL_DT EXEC_LDST
	 spectag_latch <= 0;                                          ///CTRL_DT EXEC_LDST
	 lddatasb_latch <= 0;                                         ///DATA_DT EXEC_LDST
	 hitsb_latch <= 0;                                            ///CTRL_DT EXEC_LDST
	 insnvalid_latch <= 0;                                        ///CTRL_DT EXEC_LDST
      end else begin
	 dstval_latch <= dstval;                                      ///CTRL_DT EXEC_LDST
	 rrftag_latch <= rrftag;                                      ///CTRL_DT EXEC_LDST
	 specbit_latch <= specbit;                                    ///CTRL_DT EXEC_LDST
	 spectag_latch <= spectag;                                    ///CTRL_DT EXEC_LDST
	 lddatasb_latch <= lddatasb;                                  ///DATA_DT EXEC_LDST
	 hitsb_latch <= hitsb;                                        ///CTRL_DT EXEC_LDST
	 insnvalid_latch <= ~killspec1 & ((busy & dstval) |           ///CTRL_CL EXEC_LDST
					  (busy & ~dstval & ~fullsb));                ///CTRL_CL EXEC_LDST
      end
   end // always @ (posedge clk)

   always @ (posedge clk) begin      ///CTRL_CL EXEC_LDST
      if (reset | killspec1) begin   ///CTRL_CL EXEC_LDST
	 busy <= 0;                      ///CTRL_DT EXEC_LDST
      end else begin
	 busy <= issue | busy_next;      ///CTRL_CL EXEC_LDST
      end
   end
endmodule // exunit_ldst

//`default_nettype none
