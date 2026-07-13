`include "constants.vh"
`default_nettype none
module exunit_mul   ///MD EXEC_MUL
  (
   input  wire 			         clk,           ///CTRL_HC EXEC_MUL
   input  wire 			         reset,         ///CTRL_HC EXEC_MUL
   input  wire [`DATA_LEN-1:0] 	 ex_src1,       ///DATA_HC EXEC_MUL
   input  wire [`DATA_LEN-1:0] 	 ex_src2,       ///DATA_HC EXEC_MUL
   input  wire 			 dstval,                ///CTRL_HC EXEC_MUL
   input  wire [`SPECTAG_LEN-1:0] spectag,      ///CTRL_HC EXEC_MUL
   input  wire 			 specbit,               ///CTRL_HC EXEC_MUL
   input  wire 			 src1_signed,           ///DATA_HC EXEC_MUL
   input  wire 			 src2_signed,           ///DATA_HC EXEC_MUL
   input  wire 			 sel_lohi,              ///DATA_HC EXEC_MUL
   input  wire 			 issue,                 ///CTRL_HC EXEC_MUL
   input  wire 			 prmiss,                ///CTRL_HC EXEC_MUL
   input  wire [`SPECTAG_LEN-1:0] spectagfix,   ///CTRL_HC EXEC_MUL
   output wire [`DATA_LEN-1:0] 	 result,        ///DATA_HC EXEC_MUL
   output wire 			 rrf_we,                ///CTRL_HC EXEC_MUL
   output wire 			 rob_we, //set finish   ///CTRL_HC EXEC_MUL
   output wire 			 kill_speculative       ///CTRL_HC EXEC_MUL
   );

   reg 			       busy /* verilator public */;                                ///CTRL_HWD EXEC_MUL
   
   assign rob_we = busy;                                                           ///CTRL_DT EXEC_MUL
   assign rrf_we = busy & dstval;                                                  ///CTRL_CL EXEC_MUL
   assign kill_speculative = ((spectag & spectagfix) != 0) && specbit && prmiss;   ///CTRL_CL EXEC_MUL
   
   always @ (posedge clk) begin   ///CTRL_CL EXEC_MUL
      if (reset) begin            ///CTRL_CL EXEC_MUL
	 busy <= 0;                   ///CTRL_DT EXEC_MUL
      end else begin
	 busy <= issue;               ///CTRL_DT EXEC_MUL
      end
   end
   
   multiplier bob                  ///MD EXEC_MUL
     (
      .src1(ex_src1),              ///DATA_HC EXEC_MUL
      .src2(ex_src2),              ///DATA_HC EXEC_MUL
      .src1_signed(src1_signed),   ///DATA_HC EXEC_MUL
      .src2_signed(src2_signed),   ///DATA_HC EXEC_MUL
      .sel_lohi(sel_lohi),         ///DATA_HC EXEC_MUL
      .result(result)              ///DATA_HC EXEC_MUL
      );
   
endmodule // exunit_mul

   
`default_nettype wire
