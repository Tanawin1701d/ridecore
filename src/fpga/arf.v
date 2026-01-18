`include "constants.vh"
`default_nettype none
module arf
  (
   input wire 			 clk,
   input wire 			 reset,
   input wire [`REG_SEL-1:0] 	 rs1_1, //DP from here
   input wire [`REG_SEL-1:0] 	 rs2_1,
   input wire [`REG_SEL-1:0] 	 rs1_2,
   input wire [`REG_SEL-1:0] 	 rs2_2,
   output wire [`DATA_LEN-1:0] 	 rs1_1data,
   output wire [`DATA_LEN-1:0] 	 rs2_1data,
   output wire [`DATA_LEN-1:0] 	 rs1_2data,
   output wire [`DATA_LEN-1:0] 	 rs2_2data, //DP end 
   input wire [`REG_SEL-1:0] 	 wreg1, //com_dst1
   input wire [`REG_SEL-1:0] 	 wreg2, //com_dst2
   input wire [`DATA_LEN-1:0] 	 wdata1, //com_data1
   input wire [`DATA_LEN-1:0] 	 wdata2, //com_data2
   input wire 			 we1, //com_en1
   input wire 			 we2, //com_en2
   input wire [`RRF_SEL-1:0] 	 wrrfent1, //comtag1
   input wire [`RRF_SEL-1:0] 	 wrrfent2, //comtag2
   output wire [`RRF_SEL-1:0] 	 rs1_1tag, // DP from here
   output wire [`RRF_SEL-1:0] 	 rs2_1tag,
   output wire [`RRF_SEL-1:0] 	 rs1_2tag,
   output wire [`RRF_SEL-1:0] 	 rs2_2tag,
   input wire [`REG_SEL-1:0] 	 tagbusy1_addr,
   input wire [`REG_SEL-1:0] 	 tagbusy2_addr,
   input wire 			 tagbusy1_we,
   input wire 			 tagbusy2_we,
   input wire [`RRF_SEL-1:0] 	 settag1,
   input wire [`RRF_SEL-1:0] 	 settag2,
   input wire [`SPECTAG_LEN-1:0] tagbusy1_spectag,
   input wire [`SPECTAG_LEN-1:0] tagbusy2_spectag,
   output wire 			 rs1_1busy,
   output wire 			 rs2_1busy,
   output wire 			 rs1_2busy,
   output wire 			 rs2_2busy,
   input wire 			 prmiss,
   input wire 			 prsuccess,
   input wire [`SPECTAG_LEN-1:0] prtag,
   input wire [`SPECTAG_LEN-1:0] mpft_valid1,
   input wire [`SPECTAG_LEN-1:0] mpft_valid2
   );

   // Set priority on instruction2 WriteBack
   // wrrfent = comtag
   wire [`RRF_SEL-1:0] 		 comreg1_tag;
   wire [`RRF_SEL-1:0] 		 comreg2_tag;
   wire 			 clearbusy1 = we1;
   wire 			 clearbusy2 = we2;

   wire 			 we1_0reg = we1 && 
				 (wreg1 != `REG_SEL'b0);
   
   wire 			 we2_0reg = we2 && 
				 (wreg2 != `REG_SEL'b0);
   
   wire 			 we1_prior2 = ((wreg1 == wreg2) &&
					       we1_0reg && we2_0reg) ? 
				 1'b0 : we1_0reg;
   
   // Set priority on instruction2 WriteBack
   // we when wrrfent1 == comreg1_tag
   ram_sync_nolatch_4r2w
     #(`REG_SEL, `DATA_LEN, `REG_NUM)
   regfile(
	   .clk(clk),
	   .raddr1(rs1_1),
	   .raddr2(rs2_1),
	   .raddr3(rs1_2),
	   .raddr4(rs2_2),
	   .rdata1(rs1_1data),
	   .rdata2(rs2_1data),
	   .rdata3(rs1_2data),
	   .rdata4(rs2_2data),
	   .waddr1(wreg1),
	   .waddr2(wreg2),
	   .wdata1(wdata1),
	   .wdata2(wdata2),
	   //	   .we1(we1_prior2),
	   .we1(we1_0reg),
	   .we2(we2_0reg)
	   );

   
   renaming_table rt(
		     .clk(clk),
		     .reset(reset),
		     .rs1_1(rs1_1),
		     .rs2_1(rs2_1),
		     .rs1_2(rs1_2),
		     .rs2_2(rs2_2),
		     .comreg1(wreg1),
		     .comreg2(wreg2),
		     .rs1_1tag(rs1_1tag),
		     .rs2_1tag(rs2_1tag),
		     .rs1_2tag(rs1_2tag),
		     .rs2_2tag(rs2_2tag),
		     .rs1_1busy(rs1_1busy),
		     .rs2_1busy(rs2_1busy),
		     .rs1_2busy(rs1_2busy),
		     .rs2_2busy(rs2_2busy),
		     .settagbusy1_addr(tagbusy1_addr),
		     .settagbusy2_addr(tagbusy2_addr),
		     .settagbusy1(tagbusy1_we),
		     .settagbusy2(tagbusy2_we),
		     .settag1(settag1),
		     .settag2(settag2),
		     .setbusy1_spectag(tagbusy1_spectag),
		     .setbusy2_spectag(tagbusy2_spectag),
		     .clearbusy1(clearbusy1),
		     .clearbusy2(clearbusy2),
		     .wrrfent1(wrrfent1),
		     .wrrfent2(wrrfent2),
		     .prmiss(prmiss),
		     .prsuccess(prsuccess),
		     .prtag(prtag),
		     .mpft_valid1(mpft_valid1),
		     .mpft_valid2(mpft_valid2)
		     );
   

endmodule // arf

// Set priority on instruction2 WriteBack
/*
 clear busy when comtag = rt_tag[comreg]
 */

module select_vector(
		     input wire [`SPECTAG_LEN-1:0] spectag,
		     input wire [`REG_NUM-1:0] 	   dat0,
		     input wire [`REG_NUM-1:0] 	   dat1,
		     input wire [`REG_NUM-1:0] 	   dat2,
		     input wire [`REG_NUM-1:0] 	   dat3,
		     input wire [`REG_NUM-1:0] 	   dat4,
		     output reg [`REG_NUM-1:0] 	   out
		     );

   always @ (*) begin
      out = 0;
      case (spectag)
	5'b00001 : out = dat1;
	5'b00010 : out = dat2;
	5'b00100 : out = dat3;
	5'b01000 : out = dat4;
	5'b10000 : out = dat0;
	default : out = 0;
      endcase // case (spectag) 
   end
endmodule // select_vector

module onehot_to_index #(
    parameter integer N = 8,
    parameter integer B = $clog2(N)
)(
    input  wire [N-1:0] onehot,
    output reg  [B-1:0] index
);

integer i;
always @(*) begin
    index = {B{1'b0}};
    for (i = 0; i < N; i = i + 1) begin
        if (onehot[i])
            index = i[B-1:0];
    end
end

endmodule



module renaming_table
  (
   input wire 			 clk,
   input wire 			 reset,
   
   input wire [`REG_SEL-1:0] 	 rs1_1,    ///// req tag from arf   
   input wire [`REG_SEL-1:0] 	 rs2_1,    ///// req tag from arf
   input wire [`REG_SEL-1:0] 	 rs1_2,    ///// req tag from arf
   input wire [`REG_SEL-1:0] 	 rs2_2,    ///// req tag from arf

   output wire [`RRF_SEL-1:0] 	 rs1_1tag,     ///// req tag result
   output wire [`RRF_SEL-1:0] 	 rs2_1tag,     ///// req tag result
   output wire [`RRF_SEL-1:0] 	 rs1_2tag,     ///// req tag result
   output wire [`RRF_SEL-1:0] 	 rs2_2tag,     ///// req tag result
   output wire 			         rs1_1busy,     ///// req tag result
   output wire 			         rs2_1busy,     ///// req tag result
   output wire 			         rs1_2busy,     ///// req tag result
   output wire 			         rs2_2busy,     ///// req tag result


   input wire [`REG_SEL-1:0] 	 comreg1,  ///// commit architect ID
   input wire [`REG_SEL-1:0] 	 comreg2,  ///// commit architect ID
   input wire 			         clearbusy1,       ///// commit enable 1
   input wire 			         clearbusy2,       ///// commit enable 2
   input wire [`RRF_SEL-1:0] 	 wrrfent1, ///// commit rrf idx
   input wire [`RRF_SEL-1:0] 	 wrrfent2, ///// commit rrf idx
   

   ///////////////// req renameing
   input wire [`REG_SEL-1:0] 	 settagbusy1_addr,
   input wire [`REG_SEL-1:0] 	 settagbusy2_addr,
   input wire 			 settagbusy1,
   input wire 			 settagbusy2,
   input wire [`RRF_SEL-1:0] 	 settag1,
   input wire [`RRF_SEL-1:0] 	 settag2,
   input wire [`SPECTAG_LEN-1:0] setbusy1_spectag,
   input wire [`SPECTAG_LEN-1:0] setbusy2_spectag,

   input wire 			 prmiss,
   input wire 			 prsuccess,
   input wire [`SPECTAG_LEN-1:0] prtag,
   input wire [`SPECTAG_LEN-1:0] mpft_valid1,
   input wire [`SPECTAG_LEN-1:0] mpft_valid2
   );

   reg               busy [0: `SPECTAG_LEN][0: `REG_NUM-1] /* verilator public */; //// the last is master
   reg[`RRF_SEL-1:0] rem  [0: `SPECTAG_LEN][0: `REG_NUM-1] /* verilator public */;

   reg                preBusy[0: `SPECTAG_LEN][0: `REG_NUM-1];
   reg [`RRF_SEL-1:0] preRem [0: `SPECTAG_LEN][0: `REG_NUM-1];


   wire[2: 0] binPrTag;
   onehot_to_index #(`SPECTAG_LEN, 3) indexer (prtag, binPrTag);



   assign rs1_1tag     = rem [`SPECTAG_LEN][rs1_1];
   assign rs2_1tag     = rem [`SPECTAG_LEN][rs2_1];
   assign rs1_2tag     = rem [`SPECTAG_LEN][rs1_2];
   assign rs2_2tag     = rem [`SPECTAG_LEN][rs2_2];
   assign rs1_1busy    = busy[`SPECTAG_LEN][rs1_1];
   assign rs2_1busy    = busy[`SPECTAG_LEN][rs2_1];
   assign rs1_2busy    = busy[`SPECTAG_LEN][rs1_2];
   assign rs2_2busy    = busy[`SPECTAG_LEN][rs2_2];


integer tabIdx, archIdx;

   always @(*) begin

		/////// default value
		//integer tabIdx, archIdx;
		for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
			for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin
				preBusy[tabIdx][archIdx]  = busy[tabIdx][archIdx];
				preRem [tabIdx][archIdx]  = rem [tabIdx][archIdx];
			end
		end

		/////// commit    /////// do it to all table

		for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
			if (clearbusy1 &&  (rem[tabIdx][comreg1] == wrrfent1))begin
				preBusy[tabIdx][comreg1] = 0;
			end
			if (clearbusy2 && (rem[tabIdx][comreg2] == wrrfent2))begin
				preBusy[tabIdx][comreg2] = 0;
			end
		end

		/////// rename    //////// do it to all table except mpft_valid
		if (settagbusy1)begin
			for(tabIdx = 0; tabIdx < `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
				if (!mpft_valid1[tabIdx])begin
					preBusy[tabIdx][settagbusy1_addr] = 1;
					preRem [tabIdx][settagbusy1_addr] = settag1;	
				end
			end
			preBusy[`SPECTAG_LEN][settagbusy1_addr] = 1;
			preRem [`SPECTAG_LEN][settagbusy1_addr] = settag1;	
		end

		if (settagbusy2)begin
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
				if (!mpft_valid2[tabIdx])begin
					preBusy[tabIdx][settagbusy2_addr] = 1;
					preRem [tabIdx][settagbusy2_addr] = settag2;	
				end
			end
			preBusy[`SPECTAG_LEN][settagbusy2_addr] = 1;
			preRem [`SPECTAG_LEN][settagbusy2_addr] = settag2;	
		end

		//////// success //////// do it to all table except master table

		if (prsuccess)begin
			//integer tabIdx;
			for(tabIdx = 0; tabIdx < `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin
					if (prtag[tabIdx])begin
						preBusy[tabIdx][archIdx] = preBusy[`SPECTAG_LEN][archIdx];
						preRem [tabIdx][archIdx] = preRem [`SPECTAG_LEN][archIdx];
					end
				end
			end
		end

		if (prmiss)begin
			//integer tabIdx, archIdx;
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin
					preBusy[tabIdx][archIdx] = busy [binPrTag][archIdx];
					preRem [tabIdx][archIdx] = rem  [binPrTag][archIdx];
				end
			end
		end

   end


   always @(posedge clk ) begin

		if (reset) begin

			//integer tabIdx, archIdx;
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin
					busy[tabIdx][archIdx] <= 0;
					rem [tabIdx][archIdx] <= 0;
				end
			end
			
		end else begin

			//integer tabIdx, archIdx;
			for(tabIdx = 0; tabIdx <= `SPECTAG_LEN; tabIdx = tabIdx + 1) begin
				for (archIdx = 0; archIdx < `REG_NUM; archIdx = archIdx + 1) begin
					busy[tabIdx][archIdx] <= preBusy[tabIdx][archIdx];
					rem [tabIdx][archIdx] <= preRem [tabIdx][archIdx];
				end
			end

		end
	
   end



   
   
endmodule // renaming_table
`default_nettype wire
