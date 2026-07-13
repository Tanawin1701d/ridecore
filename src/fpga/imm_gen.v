`include "constants.vh"
`default_nettype none
module imm_gen(   ///MD DECODE
               input wire [`INSN_LEN-1:0] 	inst,           ///DATA_HC DECODE
               input wire [`IMM_TYPE_WIDTH-1:0] imm_type,   ///DATA_HC DECODE
               output reg [`DATA_LEN-1:0] 	imm             ///DATA_HC DECODE
               );

   always @(*) begin   ///DATA_CL DECODE
      case (imm_type)   ///DATA_CL DECODE
        `IMM_I : imm = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };                      ///DATA_CL DECODE
        `IMM_S : imm = { {21{inst[31]}}, inst[30:25], inst[11:8], inst[7] };                        ///DATA_CL DECODE
        `IMM_U : imm = { inst[31], inst[30:20], inst[19:12], 12'b0 };                               ///DATA_CL DECODE
        `IMM_J : imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };   ///DATA_CL DECODE
        default : imm = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };                     ///DATA_CL DECODE
      endcase // case (imm_type)
   end

endmodule // imm_gen




`default_nettype wire
