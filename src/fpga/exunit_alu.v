`include "constants.vh"
`include "alu_ops.vh"
`default_nettype none
module exunit_alu   ///MD EXEC_ALU
  (
   input wire 			     clk,                   ///CTRL_HC EXEC_ALU
   input wire 			     reset,                 ///CTRL_HC EXEC_ALU
   input wire [`DATA_LEN-1:0] 	     ex_src1,       ///DATA_HC EXEC_ALU
   input wire [`DATA_LEN-1:0] 	     ex_src2,       ///DATA_HC EXEC_ALU
   input wire [`ADDR_LEN-1:0] 	     pc,            ///DATA_HC EXEC_ALU
   input wire [`DATA_LEN-1:0] 	     imm,           ///DATA_HC EXEC_ALU
   input wire 			     dstval,                ///CTRL_HC EXEC_ALU
   input wire [`SRC_A_SEL_WIDTH-1:0] src_a,         ///DATA_HC EXEC_ALU
   input wire [`SRC_B_SEL_WIDTH-1:0] src_b,         ///DATA_HC EXEC_ALU
   input wire [`ALU_OP_WIDTH-1:0]    alu_op,        ///DATA_HC EXEC_ALU
   input wire [`SPECTAG_LEN-1:0]     spectag,       ///CTRL_HC EXEC_ALU
   input wire 			     specbit,               ///CTRL_HC EXEC_ALU
   input wire 			     issue,                 ///CTRL_HC EXEC_ALU
   input wire 			     prmiss,                ///CTRL_HC EXEC_ALU
   input wire [`SPECTAG_LEN-1:0]     spectagfix,    ///CTRL_HC EXEC_ALU
   output wire [`DATA_LEN-1:0] 	     result,        ///DATA_HC EXEC_ALU
   output wire 			     rrf_we,                ///CTRL_HC EXEC_ALU
   output wire 			     rob_we, //set finish   ///CTRL_HC EXEC_ALU
   output wire 			     kill_speculative       ///CTRL_HC EXEC_ALU
   );

   wire [`DATA_LEN-1:0] 	alusrc1;               ///DATA_HWD EXEC_ALU
   wire [`DATA_LEN-1:0] 	alusrc2;               ///DATA_HWD EXEC_ALU

   reg 				busy /* verilator public */;   ///CTRL_HWD EXEC_ALU

   assign rob_we = busy;                                                           ///CTRL_DT EXEC_ALU
   assign rrf_we = busy & dstval;                                                  ///CTRL_CL EXEC_ALU
   assign kill_speculative = ((spectag & spectagfix) != 0) && specbit && prmiss;   ///CTRL_CL EXEC_ALU
   
   always @ (posedge clk) begin   ///CTRL_CL EXEC_ALU
      if (reset) begin            ///CTRL_CL EXEC_ALU
	 busy <= 0;                   ///CTRL_DT EXEC_ALU
      end else begin
	 busy <= issue;               ///CTRL_DT EXEC_ALU
      end
   end
   
   src_a_mux samx           ///MD EXEC_ALU
     (
      .src_a_sel(src_a),    ///DATA_HC EXEC_ALU
      .pc(pc),              ///DATA_HC EXEC_ALU
      .rs1(ex_src1),        ///DATA_HC EXEC_ALU
      .alu_src_a(alusrc1)   ///DATA_HC EXEC_ALU
      );

   src_b_mux sbmx          ///MD EXEC_ALU
     (
      .src_b_sel(src_b),   ///DATA_HC EXEC_ALU
      .imm(imm),           ///DATA_HC EXEC_ALU
      .rs2(ex_src2),       ///DATA_HC EXEC_ALU
      .alu_src_b(alusrc2)  ///DATA_HC EXEC_ALU
      );

   alu alice   ///MD EXEC_ALU
     (
      .op(alu_op),     ///DATA_HC EXEC_ALU
      .in1(alusrc1),   ///DATA_HC EXEC_ALU
      .in2(alusrc2),   ///DATA_HC EXEC_ALU
      .out(result)     ///DATA_HC EXEC_ALU
      );
endmodule // exunit_alu
`default_nettype wire
   
