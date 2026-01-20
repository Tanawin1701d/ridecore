`include "constants.vh"
`default_nettype none
module exunit_mul
  (
   input wire 			 clk,
   input wire 			 reset,
   input wire [`DATA_LEN-1:0] 	 ex_src1,
   input wire [`DATA_LEN-1:0] 	 ex_src2,
   input wire 			 dstval,
   input wire [`SPECTAG_LEN-1:0] spectag,
   input wire 			 specbit,
   input wire 			 src1_signed,
   input wire 			 src2_signed,
   input wire 			 sel_lohi,
   input wire 			 issue,
   input wire 			 prmiss,
   input wire [`SPECTAG_LEN-1:0] spectagfix,
   output wire [`DATA_LEN-1:0] 	 result,
   output wire 			 rrf_we,
   output wire 			 rob_we, //set finish
   output wire 			 kill_speculative
   );

   reg 			       busy /* verilator public */;
   
   assign rob_we = busy;              ///CTRL EXEC_MUL
   assign rrf_we = busy & dstval;     ///CTRL EXEC_MUL
   assign kill_speculative = ((spectag & spectagfix) != 0) && specbit && prmiss;
   
   always @ (posedge clk) begin ///CTRL EXEC_MUL
      if (reset) begin ///CTRL EXEC_MUL
	 busy <= 0;          ///CTRL EXEC_MUL
      end else begin
	 busy <= issue;       ///CTRL EXEC_MUL
      end
   end
   
   multiplier bob
     (
      .src1(ex_src1),
      .src2(ex_src2),
      .src1_signed(src1_signed),
      .src2_signed(src2_signed),
      .sel_lohi(sel_lohi),
      .result(result)
      );
   
endmodule // exunit_mul

   
`default_nettype wire
