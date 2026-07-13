`include "constants.vh"
`include "rv32_opcodes.vh"
`include "alu_ops.vh"

`default_nettype none
module decoder(                                                ///MD DECODE
	       input wire [31:0] 		  inst,                    ///DATA_HC DECODE
	       output reg [`IMM_TYPE_WIDTH-1:0]   imm_type,        ///DATA_HC DECODE
	       output wire [`REG_SEL-1:0] 	  rs1,                 ///DATA_HC DECODE
	       output wire [`REG_SEL-1:0] 	  rs2,                 ///DATA_HC DECODE
	       output wire [`REG_SEL-1:0] 	  rd,                  ///DATA_HC DECODE
	       output reg [`SRC_A_SEL_WIDTH-1:0]  src_a_sel,       ///DATA_HC DECODE
               output reg [`SRC_B_SEL_WIDTH-1:0]  src_b_sel,   ///DATA_HC DECODE
	       output reg 			  wr_reg,                      ///DATA_HC DECODE
	       
	       output reg 			  uses_rs1,                    ///DATA_HC DECODE
	       output reg 			  uses_rs2,                    ///DATA_HC DECODE
	       output reg 			  illegal_instruction,         ///CTRL_HC DECODE
	       output reg [`ALU_OP_WIDTH-1:0] 	  alu_op,          ///DATA_HC DECODE
	       output reg [`RS_ENT_SEL-1:0] 	  rs_ent,          ///DATA_HC DECODE
//	       output reg 			  dmem_use,
//	       output reg 			  dmem_write,
	       output wire [2:0] 		  dmem_size,               ///DATA_HC DECODE
	       output wire [`MEM_TYPE_WIDTH-1:0]  dmem_type,       ///DATA_HC DECODE
	       output reg [`MD_OP_WIDTH-1:0] 	  md_req_op,       ///DATA_HC DECODE
	       output reg 			  md_req_in_1_signed,          ///DATA_HC DECODE
	       output reg 			  md_req_in_2_signed,          ///DATA_HC DECODE
	       output reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel   ///DATA_HC DECODE

	       );

   wire [`ALU_OP_WIDTH-1:0] 			  srl_or_sra;   ///DATA_HWD DECODE
   wire [`ALU_OP_WIDTH-1:0] 			  add_or_sub;   ///DATA_HWD DECODE
   wire [`RS_ENT_SEL-1:0] 			  rs_ent_md;        ///DATA_HWD DECODE
   
   wire [6:0] 		    opcode = inst[6:0];     ///DATA_CL DECODE
   wire [6:0] 		    funct7 = inst[31:25];   ///DATA_CL DECODE
   wire [11:0] 		    funct12 = inst[31:20];  ///DATA_CL DECODE
   wire [2:0] 		    funct3 = inst[14:12];   ///DATA_CL DECODE
// reg [`MD_OP_WIDTH-1:0]   md_req_op;
   reg [`ALU_OP_WIDTH-1:0]  alu_op_arith;       ///DATA_HWD DECODE
   
   assign rd = inst[11:7];                      ///DATA_CL DECODE
   assign rs1 = inst[19:15];                    ///DATA_CL DECODE
   assign rs2 = inst[24:20];                    ///DATA_CL DECODE

   assign dmem_size = {1'b0,funct3[1:0]};       ///DATA_CL DECODE
   assign dmem_type = funct3;                   ///DATA_DT DECODE
   
   always @ (*) begin                           ///DATA_CL DECODE
      imm_type = `IMM_I;                        ///DATA_DT DECODE
      src_a_sel = `SRC_A_RS1;                   ///DATA_DT DECODE
      src_b_sel = `SRC_B_IMM;                   ///DATA_DT DECODE
      wr_reg = 1'b0;                            ///DATA_DT DECODE
      uses_rs1 = 1'b1;                          ///DATA_DT DECODE
      uses_rs2 = 1'b0;                          ///DATA_DT DECODE
      illegal_instruction = 1'b0;               ///CTRL_DT DECODE
      //      dmem_use = 1'b0;
      //     dmem_write = 1'b0;
      rs_ent = `RS_ENT_ALU;                     ///DATA_DT DECODE
      alu_op = `ALU_OP_ADD;                     ///DATA_DT DECODE
      
      case (opcode)                             ///DATA_CL DECODE
	`RV32_LOAD : begin                          ///DATA_CL DECODE
//           dmem_use = 1'b1;
           wr_reg = 1'b1;                       ///DATA_DT DECODE
	   rs_ent = `RS_ENT_LDST;                   ///DATA_DT DECODE
//           wb_src_sel_DX = `WB_SRC_MEM;
        end
        `RV32_STORE : begin                    ///DATA_CL DECODE
           uses_rs2 = 1'b1;                    ///DATA_DT DECODE
           imm_type = `IMM_S;                  ///DATA_DT DECODE
//           dmem_use = 1'b1;
 //          dmem_write = 1'b1;
	   rs_ent = `RS_ENT_LDST;                  ///DATA_DT DECODE
        end
        `RV32_BRANCH : begin                   ///DATA_CL DECODE
           uses_rs2 = 1'b1;                    ///DATA_DT DECODE
           //branch_taken_unkilled = cmp_true;
           src_b_sel = `SRC_B_RS2;             ///DATA_DT DECODE
           case (funct3)   ///DATA_CL DECODE
             `RV32_FUNCT3_BEQ : alu_op = `ALU_OP_SEQ;     ///DATA_DT DECODE
             `RV32_FUNCT3_BNE : alu_op = `ALU_OP_SNE;     ///DATA_DT DECODE
             `RV32_FUNCT3_BLT : alu_op = `ALU_OP_SLT;     ///DATA_DT DECODE
             `RV32_FUNCT3_BLTU : alu_op = `ALU_OP_SLTU;   ///DATA_DT DECODE
             `RV32_FUNCT3_BGE : alu_op = `ALU_OP_SGE;     ///DATA_DT DECODE
             `RV32_FUNCT3_BGEU : alu_op = `ALU_OP_SGEU;   ///DATA_DT DECODE
             default : illegal_instruction = 1'b1;        ///CTRL_DT DECODE
           endcase // case (funct3)
	   rs_ent = `RS_ENT_BRANCH;                           ///DATA_DT DECODE
        end
        `RV32_JAL : begin                                 ///DATA_CL DECODE
	   //           jal_unkilled = 1'b1;
           uses_rs1 = 1'b0;                               ///DATA_DT DECODE
           src_a_sel = `SRC_A_PC;                         ///DATA_DT DECODE
           src_b_sel = `SRC_B_FOUR;                       ///DATA_DT DECODE
           wr_reg = 1'b1;                                 ///DATA_DT DECODE
	   rs_ent = `RS_ENT_JAL;                              ///DATA_DT DECODE
        end
        `RV32_JALR : begin                        ///DATA_CL DECODE
           illegal_instruction = (funct3 != 0);   ///CTRL_CL DECODE
	   //           jalr_unkilled = 1'b1;
           src_a_sel = `SRC_A_PC;                 ///DATA_DT DECODE
           src_b_sel = `SRC_B_FOUR;               ///DATA_DT DECODE
           wr_reg = 1'b1;                         ///DATA_DT DECODE
	   rs_ent = `RS_ENT_JALR;                     ///DATA_DT DECODE
        end
	/*
        `RV32_MISC_MEM : begin
           case (funct3)
             `RV32_FUNCT3_FENCE : begin
                if ((inst[31:28] == 0) && (rs1 == 0) && (reg_to_wr_DX == 0))
                  ; // most fences are no-ops
                else
                  illegal_instruction = 1'b1;
             end
             `RV32_FUNCT3_FENCE_I : begin
                if ((inst[31:20] == 0) && (rs1 == 0) && (reg_to_wr_DX == 0))
                  fence_i = 1'b1;
                else
                  illegal_instruction = 1'b1;
             end
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
	 */
        `RV32_OP_IMM : begin                           ///DATA_CL DECODE
           alu_op = alu_op_arith;                      ///DATA_DT DECODE
           wr_reg = 1'b1;                              ///DATA_DT DECODE
        end
        `RV32_OP  : begin                              ///DATA_CL DECODE
           uses_rs2 = 1'b1;                            ///DATA_DT DECODE
           src_b_sel = `SRC_B_RS2;                     ///DATA_DT DECODE
           alu_op = alu_op_arith;                      ///DATA_DT DECODE
           wr_reg = 1'b1;                              ///DATA_DT DECODE
           if (funct7 == `RV32_FUNCT7_MUL_DIV) begin   ///CTRL_CL DECODE
//              uses_md_unkilled = 1'b1;
	      rs_ent = rs_ent_md;   ///DATA_DT DECODE
//              wb_src_sel_DX = `WB_SRC_MD;
           end
        end
	/*
        `RV32_SYSTEM : begin
           wb_src_sel_DX = `WB_SRC_CSR;
           wr_reg = (funct3 != `RV32_FUNCT3_PRIV);
           case (funct3)
             `RV32_FUNCT3_PRIV : begin
                if ((rs1 == 0) && (reg_to_wr_DX == 0)) begin
                   case (funct12)
                     `RV32_FUNCT12_ECALL : ecall = 1'b1;
                     `RV32_FUNCT12_EBREAK : ebreak = 1'b1;
                     `RV32_FUNCT12_ERET : begin
                        if (prv == 0)
                          illegal_instruction = 1'b1;
                        else
                          eret_unkilled = 1'b1;
                     end
                     default : illegal_instruction = 1'b1;
                   endcase // case (funct12)
                end // if ((rs1 == 0) && (reg_to_wr_DX == 0))
             end // case: `RV32_FUNCT3_PRIV
             `RV32_FUNCT3_CSRRW : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_WRITE;
             `RV32_FUNCT3_CSRRS : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_SET;
             `RV32_FUNCT3_CSRRC : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_CLEAR;
             `RV32_FUNCT3_CSRRWI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_WRITE;
             `RV32_FUNCT3_CSRRSI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_SET;
             `RV32_FUNCT3_CSRRCI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_CLEAR;
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
	 */
        `RV32_AUIPC : begin         ///DATA_CL DECODE
           uses_rs1 = 1'b0;         ///DATA_DT DECODE
           src_a_sel = `SRC_A_PC;   ///DATA_DT DECODE
           imm_type = `IMM_U;       ///DATA_DT DECODE
           wr_reg = 1'b1;           ///DATA_DT DECODE
        end
        `RV32_LUI : begin             ///DATA_CL DECODE
           uses_rs1 = 1'b0;           ///DATA_DT DECODE
           src_a_sel = `SRC_A_ZERO;   ///DATA_DT DECODE
           imm_type = `IMM_U;         ///DATA_DT DECODE
           wr_reg = 1'b1;             ///DATA_DT DECODE
        end
        default : begin                  ///DATA_CL DECODE
           illegal_instruction = 1'b1;   ///CTRL_DT DECODE
        end
      endcase // case (opcode)
   end // always @ (*)

   assign add_or_sub = ((opcode == `RV32_OP) && (funct7[5])) ? `ALU_OP_SUB : `ALU_OP_ADD;   ///DATA_CL DECODE
   assign srl_or_sra = (funct7[5]) ? `ALU_OP_SRA : `ALU_OP_SRL;                             ///DATA_CL DECODE

   always @(*) begin   ///DATA_CL DECODE
      case (funct3)   ///DATA_CL DECODE
        `RV32_FUNCT3_ADD_SUB : alu_op_arith = add_or_sub; ///DATA_DT DECODE
        `RV32_FUNCT3_SLL : alu_op_arith = `ALU_OP_SLL;    ///DATA_DT DECODE
        `RV32_FUNCT3_SLT : alu_op_arith = `ALU_OP_SLT;    ///DATA_DT DECODE
        `RV32_FUNCT3_SLTU : alu_op_arith = `ALU_OP_SLTU;  ///DATA_DT DECODE
        `RV32_FUNCT3_XOR : alu_op_arith = `ALU_OP_XOR;    ///DATA_DT DECODE
        `RV32_FUNCT3_SRA_SRL : alu_op_arith = srl_or_sra; ///DATA_DT DECODE
        `RV32_FUNCT3_OR : alu_op_arith = `ALU_OP_OR;      ///DATA_DT DECODE
        `RV32_FUNCT3_AND : alu_op_arith = `ALU_OP_AND;    ///DATA_DT DECODE
        default : alu_op_arith = `ALU_OP_ADD;             ///DATA_DT DECODE
      endcase // case (funct3)
   end // always @ begin


   //assign md_req_valid = uses_md;
   assign rs_ent_md = (   ///DATA_CL DECODE
		       (funct3 == `RV32_FUNCT3_MUL) ||      ///DATA_CL DECODE
		       (funct3 == `RV32_FUNCT3_MULH) ||     ///DATA_CL DECODE
		       (funct3 == `RV32_FUNCT3_MULHSU) ||   ///DATA_CL DECODE
		       (funct3 == `RV32_FUNCT3_MULHU)       ///DATA_CL DECODE
		       ) ? `RS_ENT_MUL : `RS_ENT_DIV;       ///DATA_CL DECODE
   
   always @(*) begin   ///DATA_CL DECODE
      md_req_op = `MD_OP_MUL;                       ///DATA_DT DECODE
      md_req_in_1_signed = 0;                       ///DATA_DT DECODE
      md_req_in_2_signed = 0;                       ///DATA_DT DECODE
      md_req_out_sel = `MD_OUT_LO;                  ///DATA_DT DECODE
      case (funct3)                                 ///DATA_CL DECODE
        `RV32_FUNCT3_MUL : begin                    ///DATA_CL DECODE
        end
        `RV32_FUNCT3_MULH : begin                   ///DATA_CL DECODE
           md_req_in_1_signed = 1;                  ///DATA_DT DECODE
           md_req_in_2_signed = 1;                  ///DATA_DT DECODE
           md_req_out_sel = `MD_OUT_HI;             ///DATA_DT DECODE
        end
        `RV32_FUNCT3_MULHSU : begin                 ///DATA_CL DECODE
           md_req_in_1_signed = 1;                  ///DATA_DT DECODE
           md_req_out_sel = `MD_OUT_HI;             ///DATA_DT DECODE
        end
        `RV32_FUNCT3_MULHU : begin                  ///DATA_CL DECODE
           md_req_out_sel = `MD_OUT_HI;             ///DATA_DT DECODE
        end
        `RV32_FUNCT3_DIV : begin                    ///DATA_CL DECODE
           md_req_op = `MD_OP_DIV;                  ///DATA_DT DECODE
           md_req_in_1_signed = 1;                  ///DATA_DT DECODE
           md_req_in_2_signed = 1;                  ///DATA_DT DECODE
        end
        `RV32_FUNCT3_DIVU : begin                   ///DATA_CL DECODE
           md_req_op = `MD_OP_DIV;                  ///DATA_DT DECODE
        end
        `RV32_FUNCT3_REM : begin                    ///DATA_CL DECODE
           md_req_op = `MD_OP_REM;                  ///DATA_DT DECODE
           md_req_in_1_signed = 1;                  ///DATA_DT DECODE
           md_req_in_2_signed = 1;                  ///DATA_DT DECODE
           md_req_out_sel = `MD_OUT_REM;            ///DATA_DT DECODE
        end
        `RV32_FUNCT3_REMU : begin          ///DATA_CL DECODE
           md_req_op = `MD_OP_REM;         ///DATA_DT DECODE
           md_req_out_sel = `MD_OUT_REM;   ///DATA_DT DECODE
        end
      endcase
   end

   
endmodule // decoder
`default_nettype wire
