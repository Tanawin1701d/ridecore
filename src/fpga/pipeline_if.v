`include "constants.vh"
`default_nettype none
module pipeline_if   ///MD FETCH
  (
   input wire 			  clk,             ///CTRL_HC FETCH
   input wire 			  reset,           ///CTRL_HC FETCH
   input wire [`ADDR_LEN-1:0] 	  pc,      ///DATA_HC FETCH
//   output wire 			  predict_cond,
   output wire [`ADDR_LEN-1:0] 	  npc,     ///DATA_HC FETCH
   output wire [`INSN_LEN-1:0] 	  inst1,   ///DATA_HC FETCH
   output wire [`INSN_LEN-1:0] 	  inst2,   ///DATA_HC FETCH
   output wire 			  invalid2,        ///CTRL_HC FETCH
//   input wire 			  btbpht_we,
//   input wire [`ADDR_LEN-1:0] 	  btbpht_pc,
//   input wire [`ADDR_LEN-1:0] 	  btb_jmpdst,
//   input wire 			  pht_wcond,
//   input wire [`SPECTAG_LEN-1:0]  mpft_valid,
//   input wire [`GSH_BHR_LEN-1:0]  pht_bhr,
   input wire 			  prmiss,              ///CTRL_HC FETCH
   input wire 			  prsuccess,           ///CTRL_HC FETCH
//   input wire [`SPECTAG_LEN-1:0]  prtag,
//   output wire [`GSH_BHR_LEN-1:0] bhr,
//   input wire [`SPECTAG_LEN-1:0]  spectagnow,
   input wire [4*`INSN_LEN-1:0]   idata        ///DATA_HC FETCH
   );

   wire 			  hit;               ///DC
   wire [`ADDR_LEN-1:0] 	  pred_pc;   ///DC

   // assign npc = (hit && predict_cond) ? pred_pc :
	// 	invalid2 ? pc + 4 :
	// 	pc + 8;

   assign npc = invalid2 ? pc + 4 :    ///DATA_CL FETCH
		                     pc + 8;   ///DATA_CL FETCH
   
   //assign predict_cond = 0;

/*   
   imem instmem(
		.clk(~clk),
		.addr(pc[12:4]),
		.data(idata)
		);
*/
   /*
   imem_outa instmem(
		     .pc(pc[31:4]),
		     .idata(idata)
		     );
   */
   select_logic sellog(   ///MD FETCH
		       .sel(pc[3:2]),   ///DATA_HC+DATA_CL FETCH
		       .idata(idata),   ///DATA_HC FETCH
		       .inst1(inst1),   ///DATA_HC FETCH
		       .inst2(inst2),   ///DATA_HC FETCH
		       .invalid(invalid2)   ///CTRL_HC FETCH
		       );

   // btb brtbl(
	//      .clk(clk),
	//      .reset(reset),
	//      .pc(pc),
	//      .hit(hit),
	//      .jmpaddr(pred_pc),
	//      .we(btbpht_we),
	//      .jmpsrc(btbpht_pc),
	//      .jmpdst(btb_jmpdst),
	//      .invalid2(invalid2)
	//      );

   // wire predict_cond_dummy;
   // gshare_predictor gsh
   //   (
   //    .clk(clk),
   //    .reset(reset),
   //    .pc(pc),
   //    .hit_bht(hit),
   //    .predict_cond(predict_cond_dummy),
   //    .we(btbpht_we),
   //    .wcond(pht_wcond),
   //    .went(btbpht_pc[2+:`GSH_BHR_LEN] ^ pht_bhr),
   //    .mpft_valid(mpft_valid),
   //    .prmiss(prmiss),
   //    .prsuccess(prsuccess),
   //    .prtag(prtag),
   //    .bhr_master(bhr),
   //    .spectagnow(spectagnow)
   //    );
   
endmodule // pipeline_pc


module select_logic   ///MD FETCH
  (
   input wire [1:0] 		sel,         ///DATA_HC FETCH
   input wire [4*`INSN_LEN-1:0] idata,   ///DATA_HC FETCH
   output reg [`INSN_LEN-1:0] 	inst1,   ///DATA_HC FETCH
   output reg [`INSN_LEN-1:0] 	inst2,   ///DATA_HC FETCH
   output wire 			invalid          ///CTRL_HC FETCH
   );

   assign invalid = (sel[0] == 1'b1);   ///CTRL_CL FETCH
   
   always @ (*) begin   ///DATA_CL FETCH
      inst1 = `INSN_LEN'h0;   ///DATA_DT FETCH
      inst2 = `INSN_LEN'h0;   ///DATA_DT FETCH
      
      case(sel)   ///DATA_CL FETCH
	2'b00 : begin   ///DATA_CL FETCH
	   inst1 = idata[31:0];   ///DATA_CL FETCH
	   inst2 = idata[63:32];   ///DATA_CL FETCH
	end
	2'b01 : begin   ///DATA_CL FETCH
	   inst1 = idata[63:32];   ///DATA_CL FETCH
	   inst2 = idata[95:64];   ///DATA_CL FETCH
	end
	2'b10 : begin   ///DATA_CL FETCH
	   inst1 = idata[95:64];   ///DATA_CL FETCH
	   inst2 = idata[127:96];   ///DATA_CL FETCH
	end
	2'b11 : begin   ///DATA_CL FETCH
	   inst1 = idata[127:96];   ///DATA_CL FETCH
	   inst2 = idata[31:0];   ///DATA_CL FETCH
	end
      endcase // case (sel)
   end
   
endmodule // select_logic

`default_nettype wire
