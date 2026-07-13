`include "rv32_opcodes.vh"
`include "constants.vh"
`default_nettype none
module src_a_mux(   ///MD SHARED_COMP
                 input wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel,   ///DATA_HC SHARED_COMP
                 input wire [`ADDR_LEN-1:0] 	   pc,   ///DATA_HC SHARED_COMP
                 input wire [`DATA_LEN-1:0] 	   rs1,   ///DATA_HC SHARED_COMP
                 output reg [`DATA_LEN-1:0] 	   alu_src_a   ///DATA_HC SHARED_COMP
                 );


   always @(*) begin   ///DATA_CL SHARED_COMP
      case (src_a_sel)   ///DATA_CL SHARED_COMP
        `SRC_A_RS1 : alu_src_a = rs1;   ///DATA_DT SHARED_COMP
        `SRC_A_PC : alu_src_a = pc;   ///DATA_DT SHARED_COMP
        default : alu_src_a = 0;   ///DATA_DT SHARED_COMP
      endcase // case (src_a_sel)
   end

endmodule // src_a_mux


module src_b_mux(   ///MD SHARED_COMP
                 input wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel,   ///DATA_HC SHARED_COMP
                 input wire [`DATA_LEN-1:0] 	   imm,   ///DATA_HC SHARED_COMP
                 input wire [`DATA_LEN-1:0] 	   rs2,   ///DATA_HC SHARED_COMP
                 output reg [`DATA_LEN-1:0] 	   alu_src_b   ///DATA_HC SHARED_COMP
                 );


   always @(*) begin   ///DATA_CL SHARED_COMP
      case (src_b_sel)   ///DATA_CL SHARED_COMP
        `SRC_B_RS2 : alu_src_b = rs2;   ///DATA_DT SHARED_COMP
        `SRC_B_IMM : alu_src_b = imm;   ///DATA_DT SHARED_COMP
        `SRC_B_FOUR : alu_src_b = 4;   ///DATA_DT SHARED_COMP
        default : alu_src_b = 0;   ///DATA_DT SHARED_COMP
      endcase // case (src_b_sel)
   end

endmodule // src_b_mux
`default_nettype wire
