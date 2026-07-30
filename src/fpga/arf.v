`include "constants.vh"
`default_nettype none
module arf   ///MD ARF
  (
   input wire 			 clk,                            ///CTRL_HC ARF
   input wire 			 reset,                          ///CTRL_HC ARF
   input wire [`REG_SEL-1:0] 	 rs1_1, //DP from here   ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 rs2_1,                  ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 rs1_2,                  ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 rs2_2,                  ///DATA_HC ARF
   output wire [`DATA_LEN-1:0] 	 rs1_1data,              ///DATA_HC ARF
   output wire [`DATA_LEN-1:0] 	 rs2_1data,              ///DATA_HC ARF
   output wire [`DATA_LEN-1:0] 	 rs1_2data,              ///DATA_HC ARF
   output wire [`DATA_LEN-1:0] 	 rs2_2data, //DP end     ///DATA_HC ARF

   input wire [`REG_SEL-1:0] 	 wreg1, //com_dst1       ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 wreg2, //com_dst2       ///DATA_HC ARF
   input wire [`DATA_LEN-1:0] 	 wdata1, //com_data1     ///DATA_HC ARF
   input wire [`DATA_LEN-1:0] 	 wdata2, //com_data2     ///DATA_HC ARF
   input wire 			 we1, //com_en1                  ///CTRL_HC ARF
   input wire 			 we2, //com_en2                  ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 wrrfent1, //comtag1     ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 wrrfent2, //comtag2     ///CTRL_HC ARF


   output wire [`RRF_SEL-1:0] 	 rs1_1tag, // DP from here   ///CTRL_HC ARF
   output wire [`RRF_SEL-1:0] 	 rs2_1tag,                   ///CTRL_HC ARF
   output wire [`RRF_SEL-1:0] 	 rs1_2tag,                   ///CTRL_HC ARF
   output wire [`RRF_SEL-1:0] 	 rs2_2tag,                   ///CTRL_HC ARF

   input wire [`REG_SEL-1:0] 	 tagbusy1_addr,              ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 tagbusy2_addr,              ///DATA_HC ARF
   input wire 			 tagbusy1_we,                        ///CTRL_HC ARF
   input wire 			 tagbusy2_we,                        ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 settag1,                    ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 settag2,                    ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] tagbusy1_spectag,           ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] tagbusy2_spectag,           ///CTRL_HC ARF
   output wire 			 rs1_1busy,                          ///CTRL_HC ARF
   output wire 			 rs2_1busy,                          ///CTRL_HC ARF
   output wire 			 rs1_2busy,                          ///CTRL_HC ARF
   output wire 			 rs2_2busy,                          ///CTRL_HC ARF


   input wire 			 prmiss,                             ///CTRL_HC ARF
   input wire 			 prsuccess,                          ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] prtag,                      ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] mpft_valid1,                ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] mpft_valid2                 ///CTRL_HC ARF
   );

   // Set priority on instruction2 WriteBack
   // wrrfent = comtag
   wire [`RRF_SEL-1:0] 		 comreg1_tag;                  ///CTRL_HWD ARF
   wire [`RRF_SEL-1:0] 		 comreg2_tag;                  ///CTRL_HWD ARF
   wire 			 clearbusy1 = we1;                     ///CTRL_CL ARF
   wire 			 clearbusy2 = we2;                     ///CTRL_CL ARF

   wire 			 we1_0reg = we1 &&                     ///CTRL_CL ARF
				 (wreg1 != `REG_SEL'b0);                   ///CTRL_CL ARF
   
   wire 			 we2_0reg = we2 &&                     ///CTRL_CL ARF
				 (wreg2 != `REG_SEL'b0);                   ///CTRL_CL ARF
   
   wire 			 we1_prior2 = ((wreg1 == wreg2) &&     ///CTRL_CL ARF
					       we1_0reg && we2_0reg) ?         ///CTRL_CL ARF
				 1'b0 : we1_0reg;                          ///CTRL_CL ARF
   
   // Set priority on instruction2 WriteBack
   // we when wrrfent1 == comreg1_tag
   ram_sync_nolatch_4r2w                ///MD ARF
     #(`REG_SEL, `DATA_LEN, `REG_NUM)   ///MD ARF
   regfile(                             ///MD ARF
	   .clk(clk),                       ///CTRL_HC ARF
	   .raddr1(rs1_1),                  ///DATA_HC ARF
	   .raddr2(rs2_1),                  ///DATA_HC ARF
	   .raddr3(rs1_2),                  ///DATA_HC ARF
	   .raddr4(rs2_2),                  ///DATA_HC ARF
	   .rdata1(rs1_1data),              ///DATA_HC ARF
	   .rdata2(rs2_1data),              ///DATA_HC ARF
	   .rdata3(rs1_2data),              ///DATA_HC ARF
	   .rdata4(rs2_2data),              ///DATA_HC ARF
	   .waddr1(wreg1),                  ///DATA_HC ARF
	   .waddr2(wreg2),                  ///DATA_HC ARF
	   .wdata1(wdata1),                 ///DATA_HC ARF
	   .wdata2(wdata2),                 ///DATA_HC ARF
	   //	   .we1(we1_prior2),
	   .we1(we1_0reg),                  ///CTRL_HC ARF
	   .we2(we2_0reg)                   ///CTRL_HC ARF
	   );

   
   renaming_table rt(                               ///MD ARF
		     .clk(clk),                             ///CTRL_HC ARF
		     .reset(reset),                         ///CTRL_HC ARF
		     .rs1_1(rs1_1),                         ///DATA_HC ARF
		     .rs2_1(rs2_1),                         ///DATA_HC ARF
		     .rs1_2(rs1_2),                         ///DATA_HC ARF
		     .rs2_2(rs2_2),                         ///DATA_HC ARF
		     .comreg1(wreg1),                       ///DATA_HC ARF
		     .comreg2(wreg2),                       ///DATA_HC ARF
		     .rs1_1tag(rs1_1tag),                   ///CTRL_HC ARF
		     .rs2_1tag(rs2_1tag),                   ///CTRL_HC ARF
		     .rs1_2tag(rs1_2tag),                   ///CTRL_HC ARF
		     .rs2_2tag(rs2_2tag),                   ///CTRL_HC ARF
		     .rs1_1busy(rs1_1busy),                 ///CTRL_HC ARF
		     .rs2_1busy(rs2_1busy),                 ///CTRL_HC ARF
		     .rs1_2busy(rs1_2busy),                 ///CTRL_HC ARF
		     .rs2_2busy(rs2_2busy),                 ///CTRL_HC ARF
		     .settagbusy1_addr(tagbusy1_addr),      ///DATA_HC ARF
		     .settagbusy2_addr(tagbusy2_addr),      ///DATA_HC ARF
		     .settagbusy1(tagbusy1_we),             ///CTRL_HC ARF
		     .settagbusy2(tagbusy2_we),             ///CTRL_HC ARF
		     .settag1(settag1),                     ///CTRL_HC ARF
		     .settag2(settag2),                     ///CTRL_HC ARF
		     .setbusy1_spectag(tagbusy1_spectag),   ///CTRL_HC ARF
		     .setbusy2_spectag(tagbusy2_spectag),   ///CTRL_HC ARF
		     .clearbusy1(clearbusy1),               ///CTRL_HC ARF
		     .clearbusy2(clearbusy2),               ///CTRL_HC ARF
		     .wrrfent1(wrrfent1),                   ///CTRL_HC ARF
		     .wrrfent2(wrrfent2),                   ///CTRL_HC ARF
		     .prmiss(prmiss),                       ///CTRL_HC ARF
		     .prsuccess(prsuccess),                 ///CTRL_HC ARF
		     .prtag(prtag),                         ///CTRL_HC ARF
		     .mpft_valid1(mpft_valid1),             ///CTRL_HC ARF
		     .mpft_valid2(mpft_valid2)              ///CTRL_HC ARF
		     );
   

endmodule // arf

// Set priority on instruction2 WriteBack
/*
 clear busy when comtag = rt_tag[comreg]
 */

module select_vector(                                 ///MD ARF
		     input wire [`SPECTAG_LEN-1:0] spectag,   ///CTRL_HC ARF
		     input wire [`REG_NUM-1:0] 	   dat0,      ///DATA_HC ARF
		     input wire [`REG_NUM-1:0] 	   dat1,      ///DATA_HC ARF
		     input wire [`REG_NUM-1:0] 	   dat2,      ///DATA_HC ARF
		     input wire [`REG_NUM-1:0] 	   dat3,      ///DATA_HC ARF
		     input wire [`REG_NUM-1:0] 	   dat4,      ///DATA_HC ARF
		     output reg [`REG_NUM-1:0] 	   out        ///DATA_HC ARF
		     );

   always @ (*) begin        ///DATA_CL ARF
      out = 0;               ///DATA_DT ARF
      case (spectag)         ///DATA_CL ARF
	5'b00001 : out = dat1;   ///DATA_DT ARF
	5'b00010 : out = dat2;   ///DATA_DT ARF
	5'b00100 : out = dat3;   ///DATA_DT ARF
	5'b01000 : out = dat4;   ///DATA_DT ARF
	5'b10000 : out = dat0;   ///DATA_DT ARF
	default : out = 0;       ///DATA_DT ARF
      endcase // case (spectag) 
   end
endmodule // select_vector

module onehot_to_index #(   ///MD ARF
    parameter integer N = 8,   ///PARAM ARF
    parameter integer B = $clog2(N)   ///PARAM ARF
)(
    input  wire [N-1:0] onehot,   ///CTRL_HC ARF
    output reg  [B-1:0] index   ///CTRL_HC ARF
);

integer i;                                ///HLH ARF
always @(*) begin                         ///CTRL_CL ARF
    index = {B{1'b0}};                    ///CTRL_CL ARF
    for (i = 0; i < N; i = i + 1) begin   ///HLH ARF
        if (onehot[i])                    ///CTRL_CL ARF
            index = i[B-1:0];             ///CTRL_CL ARF
    end
end

endmodule



module renaming_table                                                  ///MD ARF
  (
   input wire 			 clk,                                          ///CTRL_HC ARF
   input wire 			 reset,                                        ///CTRL_HC ARF
   
   input wire [`REG_SEL-1:0] 	 rs1_1,    ///// req tag from arf      ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 rs2_1,    ///// req tag from arf      ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 rs1_2,    ///// req tag from arf      ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 rs2_2,    ///// req tag from arf      ///DATA_HC ARF

   output wire [`RRF_SEL-1:0] 	 rs1_1tag,     ///// req tag result    ///CTRL_HC ARF
   output wire [`RRF_SEL-1:0] 	 rs2_1tag,     ///// req tag result    ///CTRL_HC ARF
   output wire [`RRF_SEL-1:0] 	 rs1_2tag,     ///// req tag result    ///CTRL_HC ARF
   output wire [`RRF_SEL-1:0] 	 rs2_2tag,     ///// req tag result    ///CTRL_HC ARF
   output wire 			         rs1_1busy,     ///// req tag result   ///CTRL_HC ARF
   output wire 			         rs2_1busy,     ///// req tag result   ///CTRL_HC ARF
   output wire 			         rs1_2busy,     ///// req tag result   ///CTRL_HC ARF
   output wire 			         rs2_2busy,     ///// req tag result   ///CTRL_HC ARF


   input wire [`REG_SEL-1:0] 	 comreg1,  ///// commit architect ID       ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 comreg2,  ///// commit architect ID       ///DATA_HC ARF
   input wire 			         clearbusy1,       ///// commit enable 1   ///CTRL_HC ARF
   input wire 			         clearbusy2,       ///// commit enable 2   ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 wrrfent1, ///// commit rrf idx            ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 wrrfent2, ///// commit rrf idx            ///CTRL_HC ARF
   

   ///////////////// req renameing
   input wire [`REG_SEL-1:0] 	 settagbusy1_addr,                         ///DATA_HC ARF
   input wire [`REG_SEL-1:0] 	 settagbusy2_addr,                         ///DATA_HC ARF
   input wire 			 settagbusy1,                                      ///CTRL_HC ARF
   input wire 			 settagbusy2,                                      ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 settag1,                                  ///CTRL_HC ARF
   input wire [`RRF_SEL-1:0] 	 settag2,                                  ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] setbusy1_spectag,                         ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] setbusy2_spectag,                         ///CTRL_HC ARF

   input wire 			 prmiss,                                           ///CTRL_HC ARF
   input wire 			 prsuccess,                                        ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] prtag,                                    ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] mpft_valid1,                              ///CTRL_HC ARF
   input wire [`SPECTAG_LEN-1:0] mpft_valid2                               ///CTRL_HC ARF
   );

   reg               busy [0: `SPECTAG_LEN][0: `REG_NUM-1] /* verilator public */; //// the last is master   ///CTRL_HWD ARF
   reg[`RRF_SEL-1:0] rem  [0: `SPECTAG_LEN][0: `REG_NUM-1] /* verilator public */;                           ///CTRL_HWD ARF

   reg                preBusy[0: `SPECTAG_LEN][0: `REG_NUM-1];                                               ///CTRL_HWD ARF
   reg [`RRF_SEL-1:0] preRem [0: `SPECTAG_LEN][0: `REG_NUM-1];                                               ///CTRL_HWD ARF


   wire[2: 0] binPrTag;                                             ///CTRL_HWD ARF
   onehot_to_index #(`SPECTAG_LEN, 3) indexer (prtag, binPrTag);    ///MD ARF



   assign rs1_1tag     = rem [`SPECTAG_LEN][rs1_1];   ///CTRL_DT ARF
   assign rs2_1tag     = rem [`SPECTAG_LEN][rs2_1];   ///CTRL_DT ARF
   assign rs1_2tag     = rem [`SPECTAG_LEN][rs1_2];   ///CTRL_DT ARF
   assign rs2_2tag     = rem [`SPECTAG_LEN][rs2_2];   ///CTRL_DT ARF
   assign rs1_1busy    = busy[`SPECTAG_LEN][rs1_1];   ///CTRL_DT ARF
   assign rs2_1busy    = busy[`SPECTAG_LEN][rs2_1];   ///CTRL_DT ARF
   assign rs1_2busy    = busy[`SPECTAG_LEN][rs1_2];   ///CTRL_DT ARF
   assign rs2_2busy    = busy[`SPECTAG_LEN][rs2_2];   ///CTRL_DT ARF


integer tabIdx, archIdx;                                                         ///HLH ARF

   always @(*) begin                                                             ///CTRL_CL ARF

		/////// default value
		//integer tabIdx, archIdx;
		for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin       ///HLH ARF
			for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin   ///HLH ARF
				preBusy[tabIdx][archIdx]  = busy[tabIdx][archIdx];               ///CTRL_DT ARF
				preRem [tabIdx][archIdx]  = rem [tabIdx][archIdx];               ///CTRL_DT ARF
			end
		end

		/////// commit    /////// do it to all table

		for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin   ///HLH ARF
			if (clearbusy1 &&  (rem[tabIdx][comreg1] == wrrfent1))begin      ///CTRL_CL ARF
				preBusy[tabIdx][comreg1] = 0;                                ///CTRL_DT ARF
			end
			if (clearbusy2 && (rem[tabIdx][comreg2] == wrrfent2))begin       ///CTRL_CL ARF
				preBusy[tabIdx][comreg2] = 0;                                ///CTRL_DT ARF
			end
		end

		/////// rename    //////// do it to all table except mpft_valid
		if (settagbusy1)begin         //// DTRL we dont count because it match with kathryn's pattern  Give the benefit of the doubt to the defendant.   ///CTRL_CL ARF
			for(tabIdx = 0; tabIdx < `SPECTAG_LEN; tabIdx = tabIdx + 1) begin   ///HLH ARF
				if (!mpft_valid1[tabIdx])begin                     ///CTRL_CL ARF
					preBusy[tabIdx][settagbusy1_addr] = 1;         ///CTRL_DT ARF
					preRem [tabIdx][settagbusy1_addr] = settag1;   ///CTRL_DT ARF
				end
			end
			preBusy[`SPECTAG_LEN][settagbusy1_addr] = 1;           ///CTRL_DT ARF
			preRem [`SPECTAG_LEN][settagbusy1_addr] = settag1;     ///CTRL_DT ARF
		end

		if (settagbusy2)begin //// DTRL we dont count because it match with kathryn's pattern  Give the benefit of the doubt to the defendant.   ///CTRL_CL ARF
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin   ///HLH ARF
				if (!mpft_valid2[tabIdx])begin                     ///CTRL_CL ARF
					preBusy[tabIdx][settagbusy2_addr] = 1;         ///CTRL_DT ARF
					preRem [tabIdx][settagbusy2_addr] = settag2;   ///CTRL_DT ARF
				end
			end
			preBusy[`SPECTAG_LEN][settagbusy2_addr] = 1;         ///CTRL_DT ARF
			preRem [`SPECTAG_LEN][settagbusy2_addr] = settag2;   ///CTRL_DT ARF
		end

		//////// success //////// do it to all table except master table

		if (prsuccess)begin   ///CTRL_CL ARF
			//integer tabIdx;
			for(tabIdx = 0; tabIdx < `SPECTAG_LEN; tabIdx = tabIdx + 1) begin        ///HLH ARF
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin   ///HLH ARF
					if (prtag[tabIdx])begin   ///CTRL_CL ARF
						preBusy[tabIdx][archIdx] = preBusy[`SPECTAG_LEN][archIdx];   ///CTRL_DT ARF
						preRem [tabIdx][archIdx] = preRem [`SPECTAG_LEN][archIdx];   ///CTRL_DT ARF
					end
				end
			end
		end

		if (prmiss)begin                                                             ///CTRL_CL ARF
			//integer tabIdx, archIdx;
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin       ///HLH ARF
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin   ///HLH ARF
					preBusy[tabIdx][archIdx] = busy [binPrTag][archIdx];             ///CTRL_DT ARF
					preRem [tabIdx][archIdx] = rem  [binPrTag][archIdx];             ///CTRL_DT ARF
				end
			end
		end

   end


   always @(posedge clk ) begin                                                      ///CTRL_CL ARF

		if (reset) begin                                                             ///CTRL_CL ARF

			//integer tabIdx, archIdx;
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin       ///HLH ARF
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin   ///HLH ARF
					busy[tabIdx][archIdx] <= 0;                                      ///CTRL_DT ARF
					rem [tabIdx][archIdx] <= 0;                                      ///CTRL_DT ARF
				end
			end
			
		end else begin

			//integer tabIdx, archIdx;
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin       ///HLH ARF
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin   ///HLH ARF
					busy[tabIdx][archIdx] <= preBusy[tabIdx][archIdx];               ///CTRL_DT ARF
					rem [tabIdx][archIdx] <= preRem [tabIdx][archIdx];               ///CTRL_DT ARF
				end
			end

		end
	
   end



   
   
endmodule // renaming_table
`default_nettype wire
