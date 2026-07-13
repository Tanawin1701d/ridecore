`include "constants.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module brimm_gen                                                                      ///MD DECODE
  (
   input wire [`INSN_LEN-1:0]  inst,                                                  ///DATA_HC DECODE
   output wire [`DATA_LEN-1:0] brimm                                                  ///DATA_HC DECODE
   );

   wire [`DATA_LEN-1:0]        br_offset = { {20{inst[31]}}, inst[7],                 ///DATA_CL DECODE
					     inst[30:25], inst[11:8], 1'b0 };                             ///DATA_CL DECODE
   wire [`DATA_LEN-1:0]        jal_offset = { {12{inst[31]}}, inst[19:12],            ///DATA_CL DECODE
					      inst[20], inst[30:25], inst[24:21], 1'b0 };                 ///DATA_CL DECODE
   wire [`DATA_LEN-1:0]        jalr_offset = { {21{inst[31]}}, inst[30:21], 1'b0 };   ///DATA_CL DECODE

   wire [6:0] 		       opcode = inst[6:0];                                        ///DATA_CL DECODE
   
   assign brimm = (opcode == `RV32_BRANCH) ? br_offset :                              ///DATA_CL DECODE
		  (opcode == `RV32_JAL) ? jal_offset :                                        ///DATA_CL DECODE
		  (opcode == `RV32_JALR) ? jalr_offset :                                      ///DATA_CL DECODE
		  `DATA_LEN'b0;                                                               ///DATA_CL DECODE

endmodule // brimm_gen
`default_nettype wire  
