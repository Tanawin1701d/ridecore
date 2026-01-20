`include "constants.vh"
`include "alu_ops.vh"
//`default_nettype none

module exunit_ldst
  (
   input wire 			 clk,
   input wire 			 reset,
   input wire [`DATA_LEN-1:0] 	 ex_src1,
   input wire [`DATA_LEN-1:0] 	 ex_src2,
   input wire [`ADDR_LEN-1:0] 	 pc,
   input wire [`DATA_LEN-1:0] 	 imm,
   input wire 			 dstval,
   input wire [`SPECTAG_LEN-1:0] spectag,
   input wire 			 specbit,
   input wire 			 issue,
   input wire 			 prmiss,
   input wire [`SPECTAG_LEN-1:0] spectagfix,
   input wire [`RRF_SEL-1:0] 	 rrftag,
   output wire [`DATA_LEN-1:0] 	 result,
   output wire 			 rrf_we,
   output wire 			 rob_we, //set finish
   output wire [`RRF_SEL-1:0] 	 wrrftag,
   output wire 			 kill_speculative,
   output wire 			 busy_next,
   //Signal StoreBuf
   output wire 			 stfin,
   //Store
   output wire 			 memoccupy_ld,
   input wire 			 fullsb,
   output wire [`DATA_LEN-1:0] 	 storedata,
   output wire [`ADDR_LEN-1:0] 	 storeaddr,
   //Load
   input wire 			 hitsb,
   output wire [`ADDR_LEN-1:0] 	 ldaddr,
   input wire [`DATA_LEN-1:0] 	 lddatasb,
   input wire [`DATA_LEN-1:0] 	 lddatamem /* verilator public */
   );

   reg 				 busy /* verilator public */; ///CTRL EXEC_LDST   //// it act as state machine of second load stage
   wire 			 clearbusy;                      ///CTRL EXEC_LDST
   wire [`ADDR_LEN-1:0] 	 effaddr /* verilator public */;
   wire 			 killspec1/* verilator public */;
   
   //LATCH
   reg 				 dstval_latch /* verilator public */;
   reg [`RRF_SEL-1:0] 		 rrftag_latch /* verilator public */;
   reg 				 specbit_latch /* verilator public */;
   reg [`SPECTAG_LEN-1:0] 	 spectag_latch /* verilator public */;
   reg [`DATA_LEN-1:0] 		 lddatasb_latch /* verilator public */;
   reg 				 hitsb_latch /* verilator public */;
   reg 				 insnvalid_latch /* verilator public */;     ///CTRL EXEC_LDST    //// it act as state machine of second load stage

   assign clearbusy = (killspec1 || dstval || (~dstval && ~fullsb)) ? 1'b1 : 1'b0;               ///CTRL EXEC_LDST
   assign killspec1 = ((spectag & spectagfix) != 0) && specbit && prmiss;                        ///CTRL EXEC_LDST
   assign kill_speculative = ((spectag_latch & spectagfix) != 0) && specbit_latch && prmiss;     ///CTRL EXEC_LDST
   assign result = hitsb_latch ? lddatasb_latch : lddatamem;
   assign rrf_we = dstval_latch & insnvalid_latch; ///CTRL EXEC_LDST
   assign rob_we = insnvalid_latch;                ///CTRL EXEC_LDST
   assign wrrftag = rrftag_latch;
   assign busy_next = clearbusy ? 1'b0 : busy;  ///CTRL EXEC_LDST
   assign stfin = ~killspec1 & busy & ~dstval;  ///CTRL EXEC_LDST
   assign memoccupy_ld = ~killspec1 & busy & dstval;
   assign storedata = ex_src2;
   assign storeaddr = effaddr;
   assign ldaddr = effaddr;
   assign effaddr = ex_src1 + imm;
   
   always @ (posedge clk) begin  ///CTRL EXEC_LDST
      if (reset | killspec1 | ~busy | (~dstval & fullsb)) begin ///CTRL EXEC_LDST
	 dstval_latch <= 0;
	 rrftag_latch <= 0;
	 specbit_latch <= 0;
	 spectag_latch <= 0;
	 lddatasb_latch <= 0;
	 hitsb_latch <= 0;
	 insnvalid_latch <= 0; ///CTRL EXEC_LDST
      end else begin
	 dstval_latch <= dstval;
	 rrftag_latch <= rrftag;
	 specbit_latch <= specbit;
	 spectag_latch <= spectag;
	 lddatasb_latch <= lddatasb;
	 hitsb_latch <= hitsb;
	 insnvalid_latch <= ~killspec1 & ((busy & dstval) | ///CTRL EXEC_LDST
					  (busy & ~dstval & ~fullsb));
      end
   end // always @ (posedge clk)

   always @ (posedge clk) begin          ///CTRL EXEC_LDST
      if (reset | killspec1) begin       ///CTRL EXEC_LDST
	 busy <= 0;                           ///CTRL EXEC_LDST
      end else begin
	 busy <= issue | busy_next;          ///CTRL EXEC_LDST
      end
   end
endmodule // exunit_ldst

//`default_nettype none
