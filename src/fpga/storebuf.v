`include "constants.vh"

module storebuf   ///MD STOREBUF
  (
   input wire 			 clk,                 ///CTRL_HC STOREBUF
   input wire 			 reset,               ///CTRL_HC STOREBUF
   input wire 			 prsuccess,           ///CTRL_HC STOREBUF
   input wire 			 prmiss,              ///CTRL_HC STOREBUF
   input wire [`SPECTAG_LEN-1:0] prtag,       ///CTRL_HC STOREBUF
   input wire [`SPECTAG_LEN-1:0] spectagfix,  ///CTRL_HC STOREBUF
   input wire 			 stfin,               ///CTRL_HC STOREBUF
   input wire 			 stspecbit,           ///CTRL_HC STOREBUF
   input wire [`SPECTAG_LEN-1:0] stspectag,   ///CTRL_HC STOREBUF
   input wire [`DATA_LEN-1:0] 	 stdata,      ///DATA_HC STOREBUF
   input wire [`ADDR_LEN-1:0] 	 staddr,      ///DATA_HC STOREBUF
   input wire 			 stcom,               ///CTRL_HC STOREBUF
   output wire 			 stretire, //dmem_we  ///CTRL_HC STOREBUF
   output wire [`DATA_LEN-1:0] 	 retdata,     ///DATA_HC STOREBUF
   output wire [`ADDR_LEN-1:0] 	 retaddr,     ///DATA_HC STOREBUF
   input wire 			 memoccupy_ld,        ///CTRL_HC STOREBUF
   output wire 			 sb_full,             ///CTRL_HC STOREBUF
   //ReadSigs
   input wire [`ADDR_LEN-1:0] 	 ldaddr,      ///DATA_HC STOREBUF
   output wire [`DATA_LEN-1:0] 	 lddata,      ///DATA_HC STOREBUF
   output wire 			 hit                  ///CTRL_HC STOREBUF
   );

   wire stspecbitNext = stspecbit & ( (~prsuccess) | (prtag != stspectag));   ///CTRL_CL STOREBUF

   reg [`STBUF_ENT_SEL-1:0] 	 finptr /* verilator public */;   ///CTRL_HWD STOREBUF
   reg [`STBUF_ENT_SEL-1:0] 	 comptr /* verilator public */;   ///CTRL_HWD STOREBUF
   reg [`STBUF_ENT_SEL-1:0] 	 retptr /* verilator public */;   ///CTRL_HWD STOREBUF
   
   reg [`SPECTAG_LEN-1:0] 	 spectag [0:`STBUF_ENT_NUM-1] /* verilator public */;    ///CTRL_HWD STOREBUF
   reg [`STBUF_ENT_NUM-1:0] 	 completed                 /* verilator public */;   ///CTRL_HWD STOREBUF
   reg [`STBUF_ENT_NUM-1:0] 	 valid                     /* verilator public */;   ///CTRL_HWD STOREBUF
   reg [`STBUF_ENT_NUM-1:0] 	 specbit                   /* verilator public */;   ///CTRL_HWD STOREBUF
   reg [`DATA_LEN-1:0] 		 data [0:`STBUF_ENT_NUM-1]    /* verilator public */;    ///DATA_HWD STOREBUF
   reg [`ADDR_LEN-1:0] 		 addr [0:`STBUF_ENT_NUM-1]    /* verilator public */;    ///DATA_HWD STOREBUF

   //when prsuccess, specbit_next = specbit & specbitcls
   wire [`STBUF_ENT_NUM-1:0] 	 specbit_cls;                   ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_NUM-1:0] 	 valid_cls;                     ///CTRL_HWD STOREBUF
   wire 			 notfull_next       /* verilator public */; ///CTRL_HWD STOREBUF
   wire 			 notempty_next      /* verilator public */; ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 nb1 /* verilator public */;    ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 ne1 /* verilator public */;    ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 nb0 /* verilator public */;    ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 finptr_next;                   ///CTRL_HWD STOREBUF
   //For CAM with Priority
   wire [`STBUF_ENT_NUM-1:0] 	 hitvec;       ///CTRL_HWD STOREBUF
   wire [2*`STBUF_ENT_NUM-1:0] 	 hitvec_rot;   ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 ldent_rot;    ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 ldent;        ///CTRL_HWD STOREBUF
   wire [`STBUF_ENT_SEL-1:0] 	 vecshamt;     ///CTRL_HWD STOREBUF
   
   search_begin #(`STBUF_ENT_SEL, `STBUF_ENT_NUM)   ///MD STOREBUF
   snb1(                                            ///MD STOREBUF
	.in(valid & valid_cls),                         ///CTRL_HC+CTRL_CL STOREBUF
	.out(nb1),                                      ///CTRL_HC STOREBUF
	.en()                                           ///DC
	);
   
   search_end #(`STBUF_ENT_SEL, `STBUF_ENT_NUM)   ///MD STOREBUF
   sne1(                                          ///MD STOREBUF
	.in(valid & valid_cls),                       ///CTRL_HC+CTRL_CL STOREBUF
	.out(ne1),                                    ///CTRL_HC STOREBUF
	.en(notempty_next)                            ///CTRL_HC STOREBUF
	);

   search_begin #(`STBUF_ENT_SEL, `STBUF_ENT_NUM)   ///MD STOREBUF
   snb0(                                            ///MD STOREBUF
	.in(~(valid & valid_cls)),                      ///CTRL_HC+CTRL_CL STOREBUF
	.out(nb0),                                      ///CTRL_HC STOREBUF
	.en(notfull_next)                               ///CTRL_HC STOREBUF
	);

   search_end #(`STBUF_ENT_SEL, `STBUF_ENT_NUM)                 ///MD STOREBUF
   findhitent(                                                  ///MD STOREBUF
	      .in(hitvec_rot[2*`STBUF_ENT_NUM-1:`STBUF_ENT_NUM]),   ///CTRL_HC+CTRL_CL STOREBUF
	      .out(ldent_rot),                                      ///CTRL_HC STOREBUF
	      .en(hit)                                              ///CTRL_HC STOREBUF
	      );
   
   assign retdata = data[retptr];                                                       ///DATA_DT STOREBUF
   assign retaddr = addr[retptr];                                                       ///DATA_DT STOREBUF
   assign lddata = data[ldent];                                                         ///DATA_DT STOREBUF
   assign stretire = valid[retptr] && completed[retptr] && ~memoccupy_ld &&  ~prmiss;   ///CTRL_CL STOREBUF
   assign sb_full = ((finptr == retptr) && (valid[finptr] == 1)) ? 1'b1 : 1'b0;         ///CTRL_CL STOREBUF
   assign finptr_next = (~notfull_next | ~notempty_next) ? finptr :                     ///CTRL_CL STOREBUF
			(((nb1 == 0) && (ne1 == {{(`STBUF_ENT_SEL){1'b0}} + (`STBUF_ENT_NUM-1)}       )) ? nb0 : (ne1+1));   ///CTRL_CL STOREBUF
   wire[`STBUF_ENT_SEL: 0] vecshamt_temp = `STBUF_ENT_NUM - {1'b0, finptr};             ///CTRL_CL STOREBUF
   assign vecshamt = vecshamt_temp[`STBUF_ENT_SEL-1: 0];                                ///CTRL_CL STOREBUF

   // assign finptr_next = (~notfull_next | ~notempty_next) ? finptr :
	// 		(((nb1 == 0) && (ne1 == `STBUF_ENT_NUM-1)) ? nb0 : (ne1+1));
   // assign vecshamt = (`STBUF_ENT_NUM - finptr);
   assign hitvec_rot = {hitvec, hitvec} << vecshamt;   ///CTRL_CL STOREBUF
   assign ldent = ldent_rot + finptr;                  ///CTRL_CL STOREBUF
   
   generate                                           ///HLH STOREBUF
      genvar 			 i;                           ///HLH STOREBUF
      for (i = 0 ; i < `STBUF_ENT_NUM ; i = i + 1)    ///HLH STOREBUF
	begin: L1
	   assign specbit_cls[i] = (prtag == spectag[i]) ? 1'b0 : 1'b1;               ///CTRL_CL STOREBUF
	   assign valid_cls[i] = (specbit[i] && ((spectagfix & spectag[i]) != 0)) ? 1'b0 : 1'b1;   ///CTRL_CL STOREBUF
	   assign hitvec[i] = (valid[i] && (addr[i] == ldaddr)) ? 1'b1 : 1'b0;   ///CTRL_CL STOREBUF
	end
   endgenerate

   always @ (posedge clk) begin      ///CTRL_CL STOREBUF
      if (~reset & stfin) begin      ///CTRL_CL STOREBUF
	 data[finptr] <= stdata;         ///DATA_DT STOREBUF
	 addr[finptr] <= staddr;         ///DATA_DT STOREBUF
	 spectag[finptr] <= stspectag;   ///CTRL_DT STOREBUF
      end
   end
   
   always @ (posedge clk) begin   ///CTRL_CL STOREBUF
      if (reset) begin            ///CTRL_CL STOREBUF
	 finptr <= 0;                 ///CTRL_DT STOREBUF
	 comptr <= 0;                 ///CTRL_DT STOREBUF
	 retptr <= 0;                 ///CTRL_DT STOREBUF
	 valid <= 0;                  ///CTRL_DT STOREBUF
	 completed <= 0;              ///CTRL_DT STOREBUF
      end else if (prmiss) begin  ///CTRL_CL STOREBUF
	 if (stfin) begin             ///CTRL_CL STOREBUF
	    //KillNotOccur!!!
	    finptr <= finptr + 1;        ///CTRL_DT STOREBUF
	    valid[finptr] <= 1'b1;       ///CTRL_DT STOREBUF
	    completed[finptr] <= 1'b0;   ///CTRL_DT STOREBUF
	    comptr <= comptr;            ///CTRL_DT STOREBUF
	    retptr <= retptr;            ///CTRL_DT STOREBUF
	 end else begin
	    valid <= valid & valid_cls;                   ///CTRL_CL STOREBUF
	    finptr <= finptr_next;                        ///CTRL_DT STOREBUF
	    comptr <= ~notempty_next ? finptr : comptr;   ///CTRL_CL STOREBUF
	    retptr <= ~notempty_next ? finptr : retptr;   ///CTRL_CL STOREBUF
	 end
      end else begin
	 if (stfin) begin                ///CTRL_CL STOREBUF
	    finptr <= finptr + 1;        ///CTRL_CL STOREBUF
	    valid[finptr] <= 1'b1;       ///CTRL_DT STOREBUF
	    completed[finptr] <= 1'b0;   ///CTRL_DT STOREBUF
	 end
	 if (stcom) begin                ///CTRL_CL STOREBUF
	    comptr <= comptr + 1;        ///CTRL_CL STOREBUF
	    completed[comptr] <= 1'b1;   ///CTRL_DT STOREBUF
	 end
	 if (stretire) begin             ///CTRL_CL STOREBUF
	    retptr <= retptr + 1;        ///CTRL_CL STOREBUF
	    valid[retptr] <= 1'b0;       ///CTRL_DT STOREBUF
	    completed[retptr] <= 1'b0;   ///CTRL_DT STOREBUF
	 end
      end
   end // always @ (posedge clk)

   always @ (posedge clk) begin                                   ///CTRL_CL STOREBUF
      if (reset | prmiss) begin                                   ///CTRL_CL STOREBUF
	 specbit <= 0;                                                ///CTRL_DT STOREBUF
      end else if (prsuccess) begin                               ///CTRL_CL STOREBUF
	 specbit <= ((specbit & specbit_cls) &                        ///CTRL_CL STOREBUF
		    (stfin ?(~({`STBUF_ENT_NUM{1'b1}} << finptr)) :       ///CTRL_CL STOREBUF
                  (~(`STBUF_ENT_NUM'b0))                          ///CTRL_CL STOREBUF
           ))|                                                    ///CTRL_CL STOREBUF
          (stfin ? ({`STBUF_ENT_NUM{stspecbitNext}} << finptr) :  ///CTRL_CL STOREBUF
                   (`STBUF_ENT_NUM'b0)                            ///CTRL_CL STOREBUF
          );                                                      ///CTRL_CL STOREBUF



      end else begin
         if (stfin) begin                   ///CTRL_CL STOREBUF
            specbit[finptr] <= stspecbit;   ///CTRL_DT STOREBUF
         end
      end
   end
endmodule // storebuf
