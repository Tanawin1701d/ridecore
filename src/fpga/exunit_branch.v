`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module exunit_branch                             ///MD EXEC_BRANCH
  (
   input wire 			  clk,                   ///CTRL_HC EXEC_BRANCH
   input wire 			  reset,                 ///CTRL_HC EXEC_BRANCH
   input wire [`DATA_LEN-1:0] 	  ex_src1,       ///DATA_HC EXEC_BRANCH
   input wire [`DATA_LEN-1:0] 	  ex_src2,       ///DATA_HC EXEC_BRANCH
   input wire [`ADDR_LEN-1:0] 	  pc,            ///DATA_HC EXEC_BRANCH
   input wire [`DATA_LEN-1:0] 	  imm,           ///DATA_HC EXEC_BRANCH
   input wire 			  dstval,                ///CTRL_HC EXEC_BRANCH
   input wire [`ALU_OP_WIDTH-1:0] alu_op,        ///DATA_HC EXEC_BRANCH
   input wire [`SPECTAG_LEN-1:0]  spectag,       ///CTRL_HC EXEC_BRANCH
   input wire 			  specbit,               ///CTRL_HC EXEC_BRANCH
   input wire [`ADDR_LEN-1:0] 	  praddr,        ///DATA_HC EXEC_BRANCH
   input wire [6:0] 		  opcode,            ///DATA_HC EXEC_BRANCH
   input wire 			  issue,                 ///CTRL_HC EXEC_BRANCH
   output wire [`DATA_LEN-1:0] 	  result,        ///DATA_HC EXEC_BRANCH
   output wire 			  rrf_we,                ///CTRL_HC EXEC_BRANCH
   output wire 			  rob_we, //set finish   ///CTRL_HC EXEC_BRANCH
   output wire 			  prsuccess,             ///CTRL_HC EXEC_BRANCH
   output wire 			  prmiss,                ///CTRL_HC EXEC_BRANCH
   output wire [`ADDR_LEN-1:0] 	  jmpaddr,       ///DATA_HC EXEC_BRANCH
   output wire [`ADDR_LEN-1:0] 	  jmpaddr_taken, ///DC
   output wire 			  brcond,                ///DC
   output wire [`SPECTAG_LEN-1:0] tagregfix      ///CTRL_HC EXEC_BRANCH
   );

   reg 			       busy /* verilator public */;                     ///CTRL_HWD EXEC_BRANCH
   
   wire [`DATA_LEN-1:0]        comprslt;                                ///DATA_HWD EXEC_BRANCH
   wire 		       addrmatch = (jmpaddr == praddr) ? 1'b1 : 1'b0;   ///CTRL_CL EXEC_BRANCH

   
   assign rob_we = busy;                                                     ///CTRL_DT EXEC_BRANCH
   assign rrf_we = busy & dstval;                                            ///CTRL_CL EXEC_BRANCH
   assign result = pc + 4;                                                   ///DATA_CL EXEC_BRANCH
   assign prsuccess = busy & addrmatch;                                      ///CTRL_CL EXEC_BRANCH
   assign prmiss = busy & ~addrmatch;                                        ///CTRL_CL EXEC_BRANCH
   assign jmpaddr = brcond ? jmpaddr_taken : (pc + 4);                       ///DATA_CL EXEC_BRANCH
   assign jmpaddr_taken = (((opcode == `RV32_JALR) ? ex_src1 : pc) + imm);   ///DATA_CL EXEC_BRANCH
   
   assign brcond = ((opcode == `RV32_JAL) || (opcode == `RV32_JALR)) ?       ///CTRL_CL EXEC_BRANCH
			       1'b1 : comprslt[0];                                       ///CTRL_CL EXEC_BRANCH
   assign tagregfix = {spectag[0], spectag[`SPECTAG_LEN-1:1]};               ///CTRL_CL EXEC_BRANCH
   
   always @ (posedge clk) begin   ///CTRL_CL EXEC_BRANCH
      if (reset) begin            ///CTRL_CL EXEC_BRANCH
	 busy <= 0;                   ///CTRL_DT EXEC_BRANCH
      end else begin
	 busy <= issue;               ///CTRL_DT EXEC_BRANCH
      end
   end
		  
   alu comparator      ///MD EXEC_BRANCH
     (
      .op(alu_op),     ///DATA_HC EXEC_BRANCH
      .in1(ex_src1),   ///DATA_HC EXEC_BRANCH
      .in2(ex_src2),   ///DATA_HC EXEC_BRANCH
      .out(comprslt)   ///DATA_HC EXEC_BRANCH
      );
   
endmodule // exunit_branch

`default_nettype wire
