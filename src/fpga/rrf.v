`include "constants.vh"

/*
 clear valid when dpen
 set valid when wrrfen
 */
`default_nettype none
module rrf(   ///MD RRF
	   input wire 		       clk,     ///CTRL_HC RRF
	   input wire 		       reset,   ///CTRL_HC RRF

	   input wire [`RRF_SEL-1:0]   rs1_1tag,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   rs2_1tag,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   rs1_2tag,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   rs2_2tag,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   com1tag,    ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   com2tag,    ///CTRL_HC RRF

	   output wire 		       rs1_1valid,     ///CTRL_HC RRF
	   output wire 		       rs2_1valid,     ///CTRL_HC RRF
	   output wire 		       rs1_2valid,     ///CTRL_HC RRF
	   output wire 		       rs2_2valid,     ///CTRL_HC RRF
	   output wire [`DATA_LEN-1:0] rs1_1data,  ///DATA_HC RRF
	   output wire [`DATA_LEN-1:0] rs2_1data,  ///DATA_HC RRF
	   output wire [`DATA_LEN-1:0] rs1_2data,  ///DATA_HC RRF
	   output wire [`DATA_LEN-1:0] rs2_2data,  ///DATA_HC RRF
	   output wire [`DATA_LEN-1:0] com1data,   ///DATA_HC RRF
	   output wire [`DATA_LEN-1:0] com2data,   ///DATA_HC RRF

	   input wire [`RRF_SEL-1:0]   wrrfaddr1,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   wrrfaddr2,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   wrrfaddr3,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   wrrfaddr4,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   wrrfaddr5,   ///CTRL_HC RRF
	   input wire [`DATA_LEN-1:0]  wrrfdata1,   ///DATA_HC RRF
	   input wire [`DATA_LEN-1:0]  wrrfdata2,   ///DATA_HC RRF
	   input wire [`DATA_LEN-1:0]  wrrfdata3,   ///DATA_HC RRF
	   input wire [`DATA_LEN-1:0]  wrrfdata4,   ///DATA_HC RRF
	   input wire [`DATA_LEN-1:0]  wrrfdata5,   ///DATA_HC RRF

	   input wire 		       wrrfen1,   ///CTRL_HC RRF
	   input wire 		       wrrfen2,   ///CTRL_HC RRF
	   input wire 		       wrrfen3,   ///CTRL_HC RRF
	   input wire 		       wrrfen4,   ///CTRL_HC RRF
	   input wire 		       wrrfen5,   ///CTRL_HC RRF

	   input wire [`RRF_SEL-1:0]   dpaddr1,   ///CTRL_HC RRF
	   input wire [`RRF_SEL-1:0]   dpaddr2,   ///CTRL_HC RRF
	   input wire 		       dpen1,         ///CTRL_HC RRF
	   input wire 		       dpen2          ///CTRL_HC RRF
	   );

   reg [`RRF_NUM-1:0] 		       valid /* verilator public */;                   ///CTRL_HWD RRF
   reg [`DATA_LEN-1:0] 		       datarr [0:`RRF_NUM-1] /* verilator public */;   ///DATA_HWD RRF

   assign rs1_1data = datarr[rs1_1tag];   ///DATA_DT RRF
   assign rs2_1data = datarr[rs2_1tag];   ///DATA_DT RRF
   assign rs1_2data = datarr[rs1_2tag];   ///DATA_DT RRF
   assign rs2_2data = datarr[rs2_2tag];   ///DATA_DT RRF
   assign com1data = datarr[com1tag];     ///DATA_DT RRF
   assign com2data = datarr[com2tag];     ///DATA_DT RRF

   assign rs1_1valid = valid[rs1_1tag];   ///CTRL_DT RRF
   assign rs2_1valid = valid[rs2_1tag];   ///CTRL_DT RRF
   assign rs1_2valid = valid[rs1_2tag];   ///CTRL_DT RRF
   assign rs2_2valid = valid[rs2_2tag];   ///CTRL_DT RRF

   wire [`RRF_NUM-1:0] 		       or_valid =      ///CTRL_CL RRF
				       (~wrrfen1 ? `RRF_NUM'b0 :   ///CTRL_CL RRF
					(`RRF_NUM'b1 << wrrfaddr1)) |  ///CTRL_CL RRF
				       (~wrrfen2 ? `RRF_NUM'b0 :   ///CTRL_CL RRF
					(`RRF_NUM'b1 << wrrfaddr2)) |  ///CTRL_CL RRF
 				       (~wrrfen3 ? `RRF_NUM'b0 :   ///CTRL_CL RRF
					(`RRF_NUM'b1 << wrrfaddr3)) |  ///CTRL_CL RRF
				       (~wrrfen4 ? `RRF_NUM'b0 :   ///CTRL_CL RRF
					(`RRF_NUM'b1 << wrrfaddr4)) |  ///CTRL_CL RRF
				       (~wrrfen5 ? `RRF_NUM'b0 :   ///CTRL_CL RRF
					(`RRF_NUM'b1 << wrrfaddr5));   ///CTRL_CL RRF
   
   wire [`RRF_NUM-1:0] 		       and_valid =      ///CTRL_CL RRF
				       (~dpen1 ? ~(`RRF_NUM'b0) :   ///CTRL_CL RRF
					~(`RRF_NUM'b1 << dpaddr1)) &    ///CTRL_CL RRF
				       (~dpen2 ? ~(`RRF_NUM'b0) :   ///CTRL_CL RRF
					~(`RRF_NUM'b1 << dpaddr2));     ///CTRL_CL RRF

   always @ (posedge clk) begin                 ///CTRL_CL RRF
      if (reset) begin                          ///CTRL_CL RRF
	 valid <= 0;                                ///CTRL_DT RRF
      end else begin
	 valid <= (valid | or_valid) & and_valid;   ///CTRL_CL RRF
      end
   end

   always @ (posedge clk) begin           ///CTRL_CL RRF
      if (~reset) begin                   ///CTRL_CL RRF
	 if (wrrfen1)                         ///CTRL_CL RRF
	   datarr[wrrfaddr1] <= wrrfdata1;    ///DATA_DT RRF
	 if (wrrfen2)                         ///CTRL_CL RRF
	   datarr[wrrfaddr2] <= wrrfdata2;    ///DATA_DT RRF
	 if (wrrfen3)                         ///CTRL_CL RRF
	   datarr[wrrfaddr3] <= wrrfdata3;    ///DATA_DT RRF
	 if (wrrfen4)                         ///CTRL_CL RRF
	   datarr[wrrfaddr4] <= wrrfdata4;    ///DATA_DT RRF
	 if (wrrfen5)                         ///CTRL_CL RRF
	   datarr[wrrfaddr5] <= wrrfdata5;    ///DATA_DT RRF
      end
   end
endmodule // rrf
`default_nettype wire
