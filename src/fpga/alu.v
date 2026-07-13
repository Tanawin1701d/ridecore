`include "alu_ops.vh"
`include "rv32_opcodes.vh"

`default_nettype none
  
module alu(   ///MD SHARED_COMP
           input wire [`ALU_OP_WIDTH-1:0] op,    ///DATA_HC SHARED_COMP
           input wire [`XPR_LEN-1:0] 	  in1,   ///DATA_HC SHARED_COMP
           input wire [`XPR_LEN-1:0] 	  in2,   ///DATA_HC SHARED_COMP
           output reg [`XPR_LEN-1:0] 	  out    ///DATA_HC SHARED_COMP
           );

   wire [`SHAMT_WIDTH-1:0] 	     shamt;    ///DATA_HWD SHARED_COMP

   assign shamt = in2[`SHAMT_WIDTH-1:0];   ///DATA_CL SHARED_COMP

   always @(*) begin                                                ///DATA_CL SHARED_COMP
      case (op)                                                     ///DATA_CL SHARED_COMP
        `ALU_OP_ADD : out = in1 + in2;                              ///DATA_CL SHARED_COMP
        `ALU_OP_SLL : out = in1 << shamt;                           ///DATA_CL SHARED_COMP
        `ALU_OP_XOR : out = in1 ^ in2;                              ///DATA_CL SHARED_COMP
        `ALU_OP_OR : out = in1 | in2;                               ///DATA_CL SHARED_COMP
        `ALU_OP_AND : out = in1 & in2;                              ///DATA_CL SHARED_COMP
        `ALU_OP_SRL : out = in1 >> shamt;                           ///DATA_CL SHARED_COMP
        `ALU_OP_SEQ : out = {31'b0, in1 == in2};                    ///DATA_CL SHARED_COMP
        `ALU_OP_SNE : out = {31'b0, in1 != in2};                    ///DATA_CL SHARED_COMP
        `ALU_OP_SUB : out = in1 - in2;                              ///DATA_CL SHARED_COMP
        `ALU_OP_SRA : out = $signed(in1) >>> shamt;                 ///DATA_CL SHARED_COMP
        `ALU_OP_SLT : out = {31'b0, $signed(in1) < $signed(in2)};   ///DATA_CL SHARED_COMP
        `ALU_OP_SGE : out = {31'b0, $signed(in1) >= $signed(in2)};  ///DATA_CL SHARED_COMP
        `ALU_OP_SLTU : out = {31'b0, in1 < in2};                    ///DATA_CL SHARED_COMP
        `ALU_OP_SGEU : out = {31'b0, in1 >= in2};                   ///DATA_CL SHARED_COMP
        default : out = 0;                                          ///DATA_CL SHARED_COMP
      endcase // case op
   end


endmodule // alu

`default_nettype wire
