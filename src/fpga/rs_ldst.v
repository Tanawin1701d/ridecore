`include "constants.vh"
`default_nettype none
module rs_ldst_ent
  (
   //Memory
   input wire 			 clk,
   input wire 			 reset,
   input wire 			 busy,
   input wire [`ADDR_LEN-1:0] 	 wpc,
   input wire [`DATA_LEN-1:0] 	 wsrc1,
   input wire [`DATA_LEN-1:0] 	 wsrc2,
   input wire 			 wvalid1,
   input wire 			 wvalid2,
   input wire [`DATA_LEN-1:0] 	 wimm,
   input wire [`RRF_SEL-1:0] 	 wrrftag,
   input wire 			 wdstval,
   input wire [`SPECTAG_LEN-1:0] 	 wspectag,
   input wire 			 we,
   output wire [`DATA_LEN-1:0] 	 ex_src1,
   output wire [`DATA_LEN-1:0] 	 ex_src2,
   output wire 			 ready /* verilator public */,
   output reg [`ADDR_LEN-1:0] 	 pc /* verilator public */,
   output reg [`DATA_LEN-1:0] 	 imm /* verilator public */,
   output reg [`RRF_SEL-1:0] 	 rrftag /* verilator public */,
   output reg 			 dstval /* verilator public */,
   output reg [`SPECTAG_LEN-1:0] spectag /* verilator public */,
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	 exrslt1,
   input wire [`RRF_SEL-1:0] 	 exdst1,
   input wire 			 kill_spec1,
   input wire [`DATA_LEN-1:0] 	 exrslt2,
   input wire [`RRF_SEL-1:0] 	 exdst2,
   input wire 			 kill_spec2,
   input wire [`DATA_LEN-1:0] 	 exrslt3,
   input wire [`RRF_SEL-1:0] 	 exdst3,
   input wire 			 kill_spec3,
   input wire [`DATA_LEN-1:0] 	 exrslt4,
   input wire [`RRF_SEL-1:0] 	 exdst4,
   input wire 			 kill_spec4,
   input wire [`DATA_LEN-1:0] 	 exrslt5,
   input wire [`RRF_SEL-1:0] 	 exdst5,
   input wire 			 kill_spec5
   );

   reg [`DATA_LEN-1:0] 		 src1 /* verilator public */;
   reg [`DATA_LEN-1:0] 		 src2 /* verilator public */;
   reg 				 valid1 /* verilator public */;
   reg 				 valid2 /* verilator public */;

   wire [`DATA_LEN-1:0] 	 nextsrc1;
   wire [`DATA_LEN-1:0] 	 nextsrc2;   
   wire 			 nextvalid1;
   wire 			 nextvalid2;
   
   assign ready = busy & valid1 & valid2;
   assign ex_src1 = ~valid1 & nextvalid1 ?
		    nextsrc1 : src1;
   assign ex_src2 = ~valid2 & nextvalid2 ?
		    nextsrc2 : src2;
   
   always @ (posedge clk) begin
      if (reset) begin
	 pc <= 0;
	 imm <= 0;
	 rrftag <= 0;
	 dstval <= 0;
	 spectag <= 0;

	 src1 <= 0;
	 src2 <= 0;
	 valid1 <= 0;
	 valid2 <= 0;
      end else if (we) begin
	 pc <= wpc;
	 imm <= wimm;
	 rrftag <= wrrftag;
	 dstval <= wdstval;
	 spectag <= wspectag;

	 src1 <= wsrc1;
	 src2 <= wsrc2;
	 valid1 <= wvalid1;
	 valid2 <= wvalid2;
      end else begin // if (we)
	 src1 <= nextsrc1;
	 src2 <= nextsrc2;
	 valid1 <= nextvalid1;
	 valid2 <= nextvalid2;
      end
   end
   
   src_manager srcmng1(
		       .opr(src1),
		       .opr_rdy(valid1),
		       .exrslt1(exrslt1),
		       .exdst1(exdst1),
		       .kill_spec1(kill_spec1),
		       .exrslt2(exrslt2),
		       .exdst2(exdst2),
		       .kill_spec2(kill_spec2),
		       .exrslt3(exrslt3),
		       .exdst3(exdst3),
		       .kill_spec3(kill_spec3),
		       .exrslt4(exrslt4),
		       .exdst4(exdst4),
		       .kill_spec4(kill_spec4),
		       .exrslt5(exrslt5),
		       .exdst5(exdst5),
		       .kill_spec5(kill_spec5),
		       .src(nextsrc1),
		       .resolved(nextvalid1)
		       );

   src_manager srcmng2(                   ///DC
		       .opr(src2),                ///DC
		       .opr_rdy(valid2),          ///DC
		       .exrslt1(exrslt1),         ///DC
		       .exdst1(exdst1),           ///DC
		       .kill_spec1(kill_spec1),   ///DC
		       .exrslt2(exrslt2),         ///DC
		       .exdst2(exdst2),           ///DC
		       .kill_spec2(kill_spec2),   ///DC
		       .exrslt3(exrslt3),         ///DC
		       .exdst3(exdst3),           ///DC
		       .kill_spec3(kill_spec3),   ///DC
		       .exrslt4(exrslt4),         ///DC
		       .exdst4(exdst4),           ///DC
		       .kill_spec4(kill_spec4),   ///DC
		       .exrslt5(exrslt5),         ///DC
		       .exdst5(exdst5),           ///DC
		       .kill_spec5(kill_spec5),   ///DC
		       .src(nextsrc2),            ///DC
		       .resolved(nextvalid2)      ///DC
		       );                         ///DC
   
endmodule // rs_ldst


module rs_ldst
  (
   //System
   input wire 			   clk,
   input wire 			   reset,
   output reg [`LDST_ENT_NUM-1:0]  busyvec /* verilator public */,
   input wire 			   prmiss,
   input wire 			   prsuccess,
   input wire [`SPECTAG_LEN-1:0] 	   prtag,
   input wire [`SPECTAG_LEN-1:0] 	   specfixtag,
   output wire [`LDST_ENT_NUM-1:0] prbusyvec_next,
   //WriteSignal
   input wire 			   clearbusy, //Issue 
   input wire [`LDST_ENT_SEL-1:0] 	   issueaddr, //= raddr, clsbsyadr
   input wire 			   we1, //alloc1
   input wire 			   we2, //alloc2
   input wire [`LDST_ENT_SEL-1:0] 	   waddr1, //allocent1
   input wire [`LDST_ENT_SEL-1:0] 	   waddr2, //allocent2
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 	   wpc_1,
   input wire [`DATA_LEN-1:0] 	   wsrc1_1,
   input wire [`DATA_LEN-1:0] 	   wsrc2_1,
   input wire 			   wvalid1_1,
   input wire 			   wvalid2_1,
   input wire [`DATA_LEN-1:0] 	   wimm_1,
   input wire [`RRF_SEL-1:0] 	   wrrftag_1,
   input wire 			   wdstval_1,
   input wire [`SPECTAG_LEN-1:0] 	   wspectag_1,
   input wire 			   wspecbit_1,
   //WriteSignal2
   input wire [`ADDR_LEN-1:0] 	   wpc_2,           ///DC
   input wire [`DATA_LEN-1:0] 	   wsrc1_2,         ///DC
   input wire [`DATA_LEN-1:0] 	   wsrc2_2,         ///DC
   input wire 			   wvalid1_2,               ///DC
   input wire 			   wvalid2_2,               ///DC
   input wire [`DATA_LEN-1:0] 	   wimm_2,          ///DC
   input wire [`RRF_SEL-1:0] 	   wrrftag_2,       ///DC
   input wire 			   wdstval_2,               ///DC
   input wire [`SPECTAG_LEN-1:0] 	   wspectag_2,  ///DC
   input wire 			   wspecbit_2,              ///DC

   //ReadSignal
   output wire [`DATA_LEN-1:0] 	   ex_src1,
   output wire [`DATA_LEN-1:0] 	   ex_src2,
   output wire [`LDST_ENT_NUM-1:0] ready,
   output wire [`ADDR_LEN-1:0] 	   pc,
   output wire [`DATA_LEN-1:0] 	   imm,
   output wire [`RRF_SEL-1:0] 	   rrftag,
   output wire 			   dstval,
   output wire [`SPECTAG_LEN-1:0]  spectag,
   output wire 			   specbit,
  
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	   exrslt1,
   input wire [`RRF_SEL-1:0] 	   exdst1,
   input wire 			   kill_spec1,
   input wire [`DATA_LEN-1:0] 	   exrslt2,
   input wire [`RRF_SEL-1:0] 	   exdst2,
   input wire 			   kill_spec2,
   input wire [`DATA_LEN-1:0] 	   exrslt3,
   input wire [`RRF_SEL-1:0] 	   exdst3,
   input wire 			   kill_spec3,
   input wire [`DATA_LEN-1:0] 	   exrslt4,
   input wire [`RRF_SEL-1:0] 	   exdst4,
   input wire 			   kill_spec4,
   input wire [`DATA_LEN-1:0] 	   exrslt5,
   input wire [`RRF_SEL-1:0] 	   exdst5,
   input wire 			   kill_spec5
   );

   //_0
   wire [`DATA_LEN-1:0] 	      ex_src1_0;
   wire [`DATA_LEN-1:0] 	      ex_src2_0;
   wire 			      ready_0;
   wire [`ADDR_LEN-1:0] 	      pc_0;
   wire [`DATA_LEN-1:0] 	      imm_0;
   wire [`RRF_SEL-1:0] 		      rrftag_0;
   wire 			      dstval_0;
   wire [`SPECTAG_LEN-1:0] 	      spectag_0;
   //_1
   wire [`DATA_LEN-1:0] 	      ex_src1_1;       ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_1;       ///DC
   wire 			      ready_1;                 ///DC
   wire [`ADDR_LEN-1:0] 	      pc_1;            ///DC
   wire [`DATA_LEN-1:0] 	      imm_1;           ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_1;        ///DC
   wire 			      dstval_1;                ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_1;       ///DC
   //_2
   wire [`DATA_LEN-1:0] 	      ex_src1_2;       ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_2;       ///DC
   wire 			      ready_2;                 ///DC
   wire [`ADDR_LEN-1:0] 	      pc_2;            ///DC
   wire [`DATA_LEN-1:0] 	      imm_2;           ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_2;        ///DC
   wire 			      dstval_2;                ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_2;       ///DC
   //_3
   wire [`DATA_LEN-1:0] 	      ex_src1_3;       ///DC
   wire [`DATA_LEN-1:0] 	      ex_src2_3;       ///DC
   wire 			      ready_3;                 ///DC
   wire [`ADDR_LEN-1:0] 	      pc_3;            ///DC
   wire [`DATA_LEN-1:0] 	      imm_3;           ///DC
   wire [`RRF_SEL-1:0] 		      rrftag_3;        ///DC
   wire 			      dstval_3;                ///DC
   wire [`SPECTAG_LEN-1:0] 	      spectag_3;       ///DC
   
   reg [`LDST_ENT_NUM-1:0] 	   specbitvec /* verilator public */;

   //busy invalidation
   wire [`LDST_ENT_NUM-1:0] 	   inv_vector =
				   {(spectag_3 & specfixtag) == 0 ? 1'b1 : 1'b0,
				    (spectag_2 & specfixtag) == 0 ? 1'b1 : 1'b0,
				    (spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,
				    (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};

   wire [`LDST_ENT_NUM-1:0] 	   inv_vector_spec =
				   {(spectag_3 == prtag) ? 1'b0 : 1'b1,
				    (spectag_2 == prtag) ? 1'b0 : 1'b1,
				    (spectag_1 == prtag) ? 1'b0 : 1'b1,
				    (spectag_0 == prtag) ? 1'b0 : 1'b1};

   wire [`LDST_ENT_NUM-1:0] 	   specbitvec_next =
				   (inv_vector_spec & specbitvec);
   /*| 
				   (we1 & wspecbit_1 ? (`LDST_ENT_SEL'b1 << waddr1) : 0) |
				   (we2 & wspecbit_2 ? (`LDST_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? 
		    specbitvec_next[issueaddr] : specbitvec[issueaddr];
   
   assign ready = {ready_3, ready_2, ready_1, ready_0};
   assign prbusyvec_next = inv_vector & busyvec;
   
   always @ (posedge clk) begin
      if (reset) begin
	 busyvec <= 0;
	 specbitvec <= 0;
      end else begin
	 if (prmiss) begin
	    busyvec <= prbusyvec_next;
	    specbitvec <= 0;
	 end else if (prsuccess) begin
	    specbitvec <= specbitvec_next;
	    /*
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end else begin
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	       specbitvec[waddr1] <= wspecbit_1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	       specbitvec[waddr2] <= wspecbit_2;
	    end
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end
      end
   end

   rs_ldst_ent ent0(
		    .clk(clk),
		    .reset(reset),
		    .busy(busyvec[0]),
		    .wpc((we1 && (waddr1 == 0)) ? wpc_1 : wpc_2),
		    .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),
		    .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),
		    .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),
		    .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),
		    .wimm((we1 && (waddr1 == 0)) ? wimm_1 : wimm_2),
		    .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),
		    .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),
		    .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),
		    .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),
		    .ex_src1(ex_src1_0),
		    .ex_src2(ex_src2_0),
		    .ready(ready_0),
		    .pc(pc_0),
		    .imm(imm_0),
		    .rrftag(rrftag_0),
		    .dstval(dstval_0),
		    .spectag(spectag_0),
		    .exrslt1(exrslt1),
		    .exdst1(exdst1),
		    .kill_spec1(kill_spec1),
		    .exrslt2(exrslt2),
		    .exdst2(exdst2),
		    .kill_spec2(kill_spec2),
		    .exrslt3(exrslt3),
		    .exdst3(exdst3),
		    .kill_spec3(kill_spec3),
		    .exrslt4(exrslt4),
		    .exdst4(exdst4),
		    .kill_spec4(kill_spec4),
		    .exrslt5(exrslt5),
		    .exdst5(exdst5),
		    .kill_spec5(kill_spec5)
		    );

   rs_ldst_ent ent1(                                                      ///DC
		    .clk(clk),                                                    ///DC
		    .reset(reset),		                                          ///DC
		    .busy(busyvec[1]),                                            ///DC
		    .wpc((we1 && (waddr1 == 1)) ? wpc_1 : wpc_2),                 ///DC
		    .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),           ///DC
		    .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),           ///DC
		    .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),     ///DC
		    .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),     ///DC
		    .wimm((we1 && (waddr1 == 1)) ? wimm_1 : wimm_2),              ///DC
		    .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),     ///DC
		    .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),     ///DC
		    .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),  ///DC
		    .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),        ///DC
		    .ex_src1(ex_src1_1),                                          ///DC
		    .ex_src2(ex_src2_1),                                          ///DC
		    .ready(ready_1),                                              ///DC
		    .pc(pc_1),                                                    ///DC
		    .imm(imm_1),                                                  ///DC
		    .rrftag(rrftag_1),                                            ///DC
		    .dstval(dstval_1),                                            ///DC
		    .spectag(spectag_1),                                          ///DC
		    .exrslt1(exrslt1),                                            ///DC
		    .exdst1(exdst1),                                              ///DC
		    .kill_spec1(kill_spec1),                                      ///DC
		    .exrslt2(exrslt2),                                            ///DC
		    .exdst2(exdst2),                                              ///DC
		    .kill_spec2(kill_spec2),                                      ///DC
		    .exrslt3(exrslt3),                                            ///DC
		    .exdst3(exdst3),                                              ///DC
		    .kill_spec3(kill_spec3),                                      ///DC
		    .exrslt4(exrslt4),                                            ///DC
		    .exdst4(exdst4),                                              ///DC
		    .kill_spec4(kill_spec4),                                      ///DC
		    .exrslt5(exrslt5),                                            ///DC
		    .exdst5(exdst5),                                              ///DC
		    .kill_spec5(kill_spec5)                                       ///DC
		    );                                                            ///DC

   rs_ldst_ent ent2(                                                      ///DC        
		    .clk(clk),                                                    ///DC          
		    .reset(reset),		                                          ///DC                        
		    .busy(busyvec[2]),                                            ///DC                  
		    .wpc((we1 && (waddr1 == 2)) ? wpc_1 : wpc_2),                 ///DC                                             
		    .wsrc1((we1 && (waddr1 == 2)) ? wsrc1_1 : wsrc1_2),           ///DC                                                   
		    .wsrc2((we1 && (waddr1 == 2)) ? wsrc2_1 : wsrc2_2),           ///DC                                                   
		    .wvalid1((we1 && (waddr1 == 2)) ? wvalid1_1 : wvalid1_2),     ///DC                                                         
		    .wvalid2((we1 && (waddr1 == 2)) ? wvalid2_1 : wvalid2_2),     ///DC                                                         
		    .wimm((we1 && (waddr1 == 2)) ? wimm_1 : wimm_2),              ///DC                                                
		    .wrrftag((we1 && (waddr1 == 2)) ? wrrftag_1 : wrrftag_2),     ///DC                                                         
		    .wdstval((we1 && (waddr1 == 2)) ? wdstval_1 : wdstval_2),     ///DC                                                         
		    .wspectag((we1 && (waddr1 == 2)) ? wspectag_1 : wspectag_2),  ///DC                                                            
		    .we((we1 && (waddr1 == 2)) || (we2 && (waddr2 == 2))),        ///DC                                                      
		    .ex_src1(ex_src1_2),                                          ///DC                    
		    .ex_src2(ex_src2_2),                                          ///DC                    
		    .ready(ready_2),                                              ///DC                
		    .pc(pc_2),                                                    ///DC          
		    .imm(imm_2),                                                  ///DC            
		    .rrftag(rrftag_2),                                            ///DC                  
		    .dstval(dstval_2),                                            ///DC                  
		    .spectag(spectag_2),                                          ///DC                    
		    .exrslt1(exrslt1),                                            ///DC                  
		    .exdst1(exdst1),                                              ///DC                
		    .kill_spec1(kill_spec1),                                      ///DC                        
		    .exrslt2(exrslt2),                                            ///DC                  
		    .exdst2(exdst2),                                              ///DC                
		    .kill_spec2(kill_spec2),                                      ///DC                        
		    .exrslt3(exrslt3),                                            ///DC                  
		    .exdst3(exdst3),                                              ///DC                
		    .kill_spec3(kill_spec3),                                      ///DC                        
		    .exrslt4(exrslt4),                                            ///DC                  
		    .exdst4(exdst4),                                              ///DC                
		    .kill_spec4(kill_spec4),                                      ///DC                        
		    .exrslt5(exrslt5),                                            ///DC                  
		    .exdst5(exdst5),                                              ///DC                
		    .kill_spec5(kill_spec5)                                       ///DC                       
		    );                                                            ///DC  

   rs_ldst_ent ent3(                                                      ///DC
		    .clk(clk),                                                    ///DC
		    .reset(reset),		                                          ///DC
		    .busy(busyvec[3]),                                            ///DC
		    .wpc((we1 && (waddr1 == 3)) ? wpc_1 : wpc_2),                 ///DC
		    .wsrc1((we1 && (waddr1 == 3)) ? wsrc1_1 : wsrc1_2),           ///DC
		    .wsrc2((we1 && (waddr1 == 3)) ? wsrc2_1 : wsrc2_2),           ///DC
		    .wvalid1((we1 && (waddr1 == 3)) ? wvalid1_1 : wvalid1_2),     ///DC
		    .wvalid2((we1 && (waddr1 == 3)) ? wvalid2_1 : wvalid2_2),     ///DC
		    .wimm((we1 && (waddr1 == 3)) ? wimm_1 : wimm_2),              ///DC
		    .wrrftag((we1 && (waddr1 == 3)) ? wrrftag_1 : wrrftag_2),     ///DC
		    .wdstval((we1 && (waddr1 == 3)) ? wdstval_1 : wdstval_2),     ///DC
		    .wspectag((we1 && (waddr1 == 3)) ? wspectag_1 : wspectag_2),  ///DC
		    .we((we1 && (waddr1 == 3)) || (we2 && (waddr2 == 3))),        ///DC
		    .ex_src1(ex_src1_3),                                          ///DC
		    .ex_src2(ex_src2_3),                                          ///DC
		    .ready(ready_3),                                              ///DC
		    .pc(pc_3),                                                    ///DC
		    .imm(imm_3),                                                  ///DC
		    .rrftag(rrftag_3),                                            ///DC
		    .dstval(dstval_3),                                            ///DC
		    .spectag(spectag_3),                                          ///DC
		    .exrslt1(exrslt1),                                            ///DC
		    .exdst1(exdst1),                                              ///DC
		    .kill_spec1(kill_spec1),                                      ///DC
		    .exrslt2(exrslt2),                                            ///DC
		    .exdst2(exdst2),                                              ///DC
		    .kill_spec2(kill_spec2),                                      ///DC
		    .exrslt3(exrslt3),                                            ///DC
		    .exdst3(exdst3),                                              ///DC
		    .kill_spec3(kill_spec3),                                      ///DC
		    .exrslt4(exrslt4),                                            ///DC
		    .exdst4(exdst4),                                              ///DC
		    .kill_spec4(kill_spec4),                                      ///DC
		    .exrslt5(exrslt5),                                            ///DC
		    .exdst5(exdst5),                                              ///DC
		    .kill_spec5(kill_spec5)                                       ///DC
		    );                                                            ///DC

   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 :
		    (issueaddr == 1) ? ex_src1_1 :              ///DC
		    (issueaddr == 2) ? ex_src1_2 : ex_src1_3;   ///DC

   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 : 
		    (issueaddr == 1) ? ex_src2_1 :  ///DC
		    (issueaddr == 2) ? ex_src2_2 : ex_src2_3; ///DC

   assign pc = (issueaddr == 0) ? pc_0 :
	       (issueaddr == 1) ? pc_1 :       ///DC
	       (issueaddr == 2) ? pc_2 : pc_3; ///DC

   assign imm = (issueaddr == 0) ? imm_0 :
		(issueaddr == 1) ? imm_1 : ///DC
		(issueaddr == 2) ? imm_2 : imm_3; ///DC

   assign rrftag = (issueaddr == 0) ? rrftag_0 :
		   (issueaddr == 1) ? rrftag_1 : ///DC
		   (issueaddr == 2) ? rrftag_2 : rrftag_3; ///DC

   assign dstval = (issueaddr == 0) ? dstval_0 :
		   (issueaddr == 1) ? dstval_1 :  ///DC
		   (issueaddr == 2) ? dstval_2 : dstval_3; ///DC

   assign spectag = (issueaddr == 0) ? spectag_0 :
		    (issueaddr == 1) ? spectag_1 : ///DC
		    (issueaddr == 2) ? spectag_2 : spectag_3; ///DC
   
   
endmodule // rs_ldst
`default_nettype wire
