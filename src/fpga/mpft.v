`include "constants.vh"
`default_nettype none
module tag_decoder   ///MD MPFT
  (
   input wire [`SPECTAG_LEN-1:0] in,   ///CTRL_HC MPFT
   output reg [2:0] 		 out       ///CTRL_HC MPFT
   );

   always @ (*) begin    ///CTRL_CL MPFT
      out = 0;           ///CTRL_DT MPFT
      case (in)          ///CTRL_CL MPFT
	5'b00001: out = 0;   ///CTRL_DT MPFT
	5'b00010: out = 1;   ///CTRL_DT MPFT
	5'b00100: out = 2;   ///CTRL_DT MPFT
	5'b01000: out = 3;   ///CTRL_DT MPFT
	5'b10000: out = 4;   ///CTRL_DT MPFT
	default: out = 0;    ///CTRL_DT MPFT
      endcase // case (in)
   end
endmodule // tag_decoder

module miss_prediction_fix_table   ///MD MPFT
  (
   input wire 			  clk,                                         ///CTRL_HC MPFT
   input wire 			  reset,                                       ///CTRL_HC MPFT
   output reg [`SPECTAG_LEN-1:0]  mpft_valid /* verilator public */,   ///CTRL_HC MPFT
   input wire [`SPECTAG_LEN-1:0]  value_addr,                          ///CTRL_HC MPFT
   output wire [`SPECTAG_LEN-1:0] mpft_value,                          ///CTRL_HC MPFT
   input wire 			  prmiss,                                      ///CTRL_HC MPFT
   input wire 			  prsuccess,                                   ///CTRL_HC MPFT
   input wire [`SPECTAG_LEN-1:0]  prsuccess_tag,                       ///CTRL_HC MPFT
   input wire [`SPECTAG_LEN-1:0]  setspec1_tag, //inst1_spectag        ///CTRL_HC MPFT
   input wire 			  setspec1_en, //inst1_isbranch & ~inst1_inv   ///CTRL_HC MPFT
   input wire [`SPECTAG_LEN-1:0]  setspec2_tag,                        ///CTRL_HC MPFT
   input wire 			  setspec2_en                                  ///CTRL_HC MPFT
   );

   reg [`SPECTAG_LEN-1:0] 	  value0 /* verilator public */;   ///CTRL_HWD MPFT
   reg [`SPECTAG_LEN-1:0] 	  value1 /* verilator public */;   ///CTRL_HWD MPFT
   reg [`SPECTAG_LEN-1:0] 	  value2 /* verilator public */;   ///CTRL_HWD MPFT
   reg [`SPECTAG_LEN-1:0] 	  value3 /* verilator public */;   ///CTRL_HWD MPFT
   reg [`SPECTAG_LEN-1:0] 	  value4 /* verilator public */;   ///CTRL_HWD MPFT

   wire [2:0] 			  val_idx;                             ///CTRL_HWD MPFT
   
   tag_decoder td(           ///MD MPFT
		  .in(value_addr),   ///CTRL_HC MPFT
		  .out(val_idx)      ///CTRL_HC MPFT
		  );
   
   
   assign mpft_value = {   ///CTRL_CL MPFT
			value4[val_idx],   ///CTRL_CL MPFT
			value3[val_idx],   ///CTRL_CL MPFT
			value2[val_idx],   ///CTRL_CL MPFT
			value1[val_idx],   ///CTRL_CL MPFT
			value0[val_idx]   ///CTRL_CL MPFT
			};   ///CTRL_CL MPFT

   /*
    wire [`SPECTAG_LEN-1:0] value0_wdec =
    (~setspec1_tag[0] || ~setspec1_en ? 5'b0 :
    (setspec1_tag |
    ((setspec1_tag == 5'b00001) ? mpft_valid : 5'b0))) |
    (~setspec2_tag[0] || ~setspec2_en ? 5'b0 :
    (setspec2_tag |
    ((setspec2_tag == 5'b00001) ? mpft_valid : 5'b0)));
    */
   wire [`SPECTAG_LEN-1:0] 	  wdecdata = mpft_valid | (setspec1_en ? setspec1_tag : 0);   ///CTRL_CL MPFT

   wire [`SPECTAG_LEN-1:0] 	  value0_wdec =   ///CTRL_CL MPFT
				  (~setspec1_tag[0] || ~setspec1_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec1_tag |   ///CTRL_CL MPFT
				    ((setspec1_tag == 5'b00001) ? mpft_valid : 5'b0))) |   ///CTRL_CL MPFT
				  (~setspec2_tag[0] || ~setspec2_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec2_tag |   ///CTRL_CL MPFT
				    ((setspec2_tag == 5'b00001) ? wdecdata : 5'b0)));   ///CTRL_CL MPFT
   
   wire [`SPECTAG_LEN-1:0] 	  value1_wdec =   ///CTRL_CL MPFT
				  (~setspec1_tag[1] || ~setspec1_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec1_tag |   ///CTRL_CL MPFT
				    ((setspec1_tag == 5'b00010) ? mpft_valid : 5'b0))) |   ///CTRL_CL MPFT
				  (~setspec2_tag[1] || ~setspec2_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec2_tag |   ///CTRL_CL MPFT
				    ((setspec2_tag == 5'b00010) ? wdecdata : 5'b0)));   ///CTRL_CL MPFT
   
   wire [`SPECTAG_LEN-1:0] 	  value2_wdec =   ///CTRL_CL MPFT
				  (~setspec1_tag[2] || ~setspec1_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec1_tag |   ///CTRL_CL MPFT
				    ((setspec1_tag == 5'b00100) ? mpft_valid : 5'b0))) |   ///CTRL_CL MPFT
				  (~setspec2_tag[2] || ~setspec2_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec2_tag |   ///CTRL_CL MPFT
				    ((setspec2_tag == 5'b00100) ? wdecdata : 5'b0)));   ///CTRL_CL MPFT
   
   wire [`SPECTAG_LEN-1:0] 	  value3_wdec =   ///CTRL_CL MPFT
				  (~setspec1_tag[3] || ~setspec1_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec1_tag |   ///CTRL_CL MPFT
				    ((setspec1_tag == 5'b01000) ? mpft_valid : 5'b0))) |   ///CTRL_CL MPFT
				  (~setspec2_tag[3] || ~setspec2_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec2_tag |   ///CTRL_CL MPFT
				    ((setspec2_tag == 5'b01000) ? wdecdata : 5'b0)));   ///CTRL_CL MPFT
   
   wire [`SPECTAG_LEN-1:0] 	  value4_wdec =   ///CTRL_CL MPFT
				  (~setspec1_tag[4] || ~setspec1_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec1_tag |   ///CTRL_CL MPFT
				    ((setspec1_tag == 5'b10000) ? mpft_valid : 5'b0))) |   ///CTRL_CL MPFT
				  (~setspec2_tag[4] || ~setspec2_en ? 5'b0 :   ///CTRL_CL MPFT
				   (setspec2_tag |   ///CTRL_CL MPFT
				    ((setspec2_tag == 5'b10000) ? wdecdata : 5'b0)));   ///CTRL_CL MPFT
   
   wire [`SPECTAG_LEN-1:0] 	  value0_wprs =
				  (prsuccess_tag[0] ? 5'b0 : ~prsuccess_tag);   ///CTRL_CL MPFT
   wire [`SPECTAG_LEN-1:0] 	  value1_wprs =
				  (prsuccess_tag[1] ? 5'b0 : ~prsuccess_tag);   ///CTRL_CL MPFT
   wire [`SPECTAG_LEN-1:0] 	  value2_wprs =
				  (prsuccess_tag[2] ? 5'b0 : ~prsuccess_tag);   ///CTRL_CL MPFT
   wire [`SPECTAG_LEN-1:0] 	  value3_wprs =
				  (prsuccess_tag[3] ? 5'b0 : ~prsuccess_tag);   ///CTRL_CL MPFT
   wire [`SPECTAG_LEN-1:0] 	  value4_wprs =
				  (prsuccess_tag[4] ? 5'b0 : ~prsuccess_tag);   ///CTRL_CL MPFT
   
   always @ (posedge clk) begin   ///CTRL_CL MPFT
      if (reset | prmiss) begin   ///CTRL_CL MPFT
	 mpft_valid <= 0;   ///CTRL_DT MPFT
      end else if (prsuccess) begin   ///CTRL_CL MPFT
	 mpft_valid <= mpft_valid & ~prsuccess_tag;   ///CTRL_CL MPFT
      end else begin
	 mpft_valid <= mpft_valid |   ///CTRL_CL MPFT
		       (setspec1_en ? setspec1_tag : 0) |   ///CTRL_CL MPFT
		       (setspec2_en ? setspec2_tag : 0);   ///CTRL_CL MPFT
      end
   end

   always @ (posedge clk) begin   ///CTRL_CL MPFT
      if (reset | prmiss) begin   ///CTRL_CL MPFT
	 value0 <= 0;   ///CTRL_DT MPFT
	 value1 <= 0;   ///CTRL_DT MPFT
	 value2 <= 0;   ///CTRL_DT MPFT
	 value3 <= 0;   ///CTRL_DT MPFT
	 value4 <= 0;   ///CTRL_DT MPFT
      end else begin
	 value0 <= prsuccess ? (value0 & value0_wprs) : (value0 | value0_wdec);   ///CTRL_CL MPFT
	 value1 <= prsuccess ? (value1 & value1_wprs) : (value1 | value1_wdec);   ///CTRL_CL MPFT
	 value2 <= prsuccess ? (value2 & value2_wprs) : (value2 | value2_wdec);   ///CTRL_CL MPFT
	 value3 <= prsuccess ? (value3 & value3_wprs) : (value3 | value3_wdec);   ///CTRL_CL MPFT
	 value4 <= prsuccess ? (value4 & value4_wprs) : (value4 | value4_wdec);   ///CTRL_CL MPFT
      end
   end
   
endmodule // miss_prediction_fix_table
`default_nettype wire
