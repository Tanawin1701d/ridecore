`default_nettype none

module oldest_finder2 #(               ///MD RSV_SHARED
			parameter ENTLEN = 1,      ///PARAM RSV_SHARED
			parameter VALLEN = 8       ///PARAM RSV_SHARED
			)
  (
   input wire [2*ENTLEN-1:0] entvec,   ///CTRL_HC RSV_SHARED
   input wire [2*VALLEN-1:0] valvec,   ///CTRL_HC RSV_SHARED
   output wire [ENTLEN-1:0]  oldent,   ///CTRL_HC RSV_SHARED
   output wire [VALLEN-1:0]  oldval    ///CTRL_HC RSV_SHARED
   );
   //VALLEN = RRF_SEL+sortbit+~rdy
   
   wire [ENTLEN-1:0] 	     ent1 = entvec[0+:ENTLEN];        ///CTRL_CL RSV_SHARED
   wire [ENTLEN-1:0] 	     ent2 = entvec[ENTLEN+:ENTLEN];   ///CTRL_CL RSV_SHARED
   wire [VALLEN-1:0] 	     val1 = valvec[0+:VALLEN];        ///CTRL_CL RSV_SHARED
   wire [VALLEN-1:0] 	     val2 = valvec[VALLEN+:VALLEN];   ///CTRL_CL RSV_SHARED

   assign oldent = (val1 < val2) ? ent1 : ent2;               ///CTRL_CL RSV_SHARED
   assign oldval = (val1 < val2) ? val1 : val2;               ///CTRL_CL RSV_SHARED

endmodule // oldest_finder2

module oldest_finder4 #(                    ///MD RSV_SHARED
			parameter ENTLEN = 2,           ///PARAM RSV_SHARED
			parameter VALLEN = 8            ///PARAM RSV_SHARED
			)
   (
    input wire [4*ENTLEN-1:0] entvec,       ///CTRL_HC RSV_SHARED
    input wire [4*VALLEN-1:0] valvec,       ///CTRL_HC RSV_SHARED
    output wire [ENTLEN-1:0]  oldent,       ///CTRL_HC RSV_SHARED
    output wire [VALLEN-1:0]  oldval        ///CTRL_HC RSV_SHARED
   );
   //VALLEN = RRF_SEL+sortbit+~rdy

   wire [ENTLEN-1:0] 	     oldent1;       ///CTRL_HWD RSV_SHARED
   wire [ENTLEN-1:0] 	     oldent2;       ///CTRL_HWD RSV_SHARED
   wire [VALLEN-1:0] 	     oldval1;       ///CTRL_HWD RSV_SHARED
   wire [VALLEN-1:0] 	     oldval2;       ///CTRL_HWD RSV_SHARED

   oldest_finder2 #(ENTLEN, VALLEN) of2_1   ///MD RSV_SHARED
     (
      .entvec({entvec[ENTLEN+:ENTLEN], entvec[0+:ENTLEN]}),   ///CTRL_HC+CTRL_CL RSV_SHARED
      .valvec({valvec[VALLEN+:VALLEN], valvec[0+:VALLEN]}),   ///CTRL_HC+CTRL_CL RSV_SHARED
      .oldent(oldent1),                                       ///CTRL_HC RSV_SHARED
      .oldval(oldval1)                                        ///CTRL_HC RSV_SHARED
      );

   oldest_finder2 #(ENTLEN, VALLEN) of2_2   ///MD RSV_SHARED
     (
      .entvec({entvec[3*ENTLEN+:ENTLEN], entvec[2*ENTLEN+:ENTLEN]}),   ///CTRL_HC+CTRL_CL RSV_SHARED
      .valvec({valvec[3*VALLEN+:VALLEN], valvec[2*VALLEN+:VALLEN]}),   ///CTRL_HC+CTRL_CL RSV_SHARED
      .oldent(oldent2),                                                ///CTRL_HC RSV_SHARED
      .oldval(oldval2)                                                 ///CTRL_HC RSV_SHARED
      );

   oldest_finder2 #(ENTLEN, VALLEN) ofmas   ///MD RSV_SHARED
     (
      .entvec({oldent2, oldent1}),          ///CTRL_HC+CTRL_CL RSV_SHARED
      .valvec({oldval2, oldval1}),          ///CTRL_HC+CTRL_CL RSV_SHARED
      .oldent(oldent),                      ///CTRL_HC RSV_SHARED
      .oldval(oldval)                       ///CTRL_HC RSV_SHARED
      );
   
endmodule // oldest_finder4

module oldest_finder8 #(            ///MD RSV_SHARED
			parameter ENTLEN = 3,   ///PARAM RSV_SHARED
			parameter VALLEN = 8    ///PARAM RSV_SHARED
			)
   (
    input wire [8*ENTLEN-1:0] entvec,   ///CTRL_HC RSV_SHARED
    input wire [8*VALLEN-1:0] valvec,   ///CTRL_HC RSV_SHARED
    output wire [ENTLEN-1:0]  oldent,   ///CTRL_HC RSV_SHARED
    output wire [VALLEN-1:0]  oldval    ///CTRL_HC RSV_SHARED
   );
   //VALLEN = RRF_SEL+sortbit+~rdy

   wire [ENTLEN-1:0] 	     oldent1;   ///CTRL_HWD RSV_SHARED
   wire [ENTLEN-1:0] 	     oldent2;   ///CTRL_HWD RSV_SHARED
   wire [VALLEN-1:0] 	     oldval1;   ///CTRL_HWD RSV_SHARED
   wire [VALLEN-1:0] 	     oldval2;   ///CTRL_HWD RSV_SHARED
   
   oldest_finder4 #(ENTLEN, VALLEN) of4_1   ///MD RSV_SHARED
     (
      .entvec({entvec[3*ENTLEN+:ENTLEN], entvec[2*ENTLEN+:ENTLEN],   ///CTRL_HC+CTRL_CL RSV_SHARED
	       entvec[ENTLEN+:ENTLEN], entvec[0+:ENTLEN]}),              ///CTRL_HC+CTRL_CL RSV_SHARED
      .valvec({valvec[3*VALLEN+:VALLEN], valvec[2*VALLEN+:VALLEN],   ///CTRL_HC+CTRL_CL RSV_SHARED
	       valvec[VALLEN+:VALLEN], valvec[0+:VALLEN]}),              ///CTRL_HC+CTRL_CL RSV_SHARED
      .oldent(oldent1),                                              ///CTRL_HC RSV_SHARED
      .oldval(oldval1)                                               ///CTRL_HC RSV_SHARED
      );

   oldest_finder4 #(ENTLEN, VALLEN) of4_2   ///MD RSV_SHARED
     (
      .entvec({entvec[7*ENTLEN+:ENTLEN], entvec[6*ENTLEN+:ENTLEN],   ///CTRL_HC+CTRL_CL RSV_SHARED
	       entvec[5*ENTLEN+:ENTLEN], entvec[4*ENTLEN+:ENTLEN]}),     ///CTRL_HC+CTRL_CL RSV_SHARED
      .valvec({valvec[7*VALLEN+:VALLEN], valvec[6*VALLEN+:VALLEN],   ///CTRL_HC+CTRL_CL RSV_SHARED
	       valvec[5*VALLEN+:VALLEN], valvec[4*VALLEN+:VALLEN]}),     ///CTRL_HC+CTRL_CL RSV_SHARED
      .oldent(oldent2),                                              ///CTRL_HC RSV_SHARED
      .oldval(oldval2)                                               ///CTRL_HC RSV_SHARED
      );

   oldest_finder2 #(ENTLEN, VALLEN) ofmas   ///MD RSV_SHARED
     (
      .entvec({oldent2, oldent1}),   ///CTRL_HC+CTRL_CL RSV_SHARED
      .valvec({oldval2, oldval1}),   ///CTRL_HC+CTRL_CL RSV_SHARED
      .oldent(oldent),   ///CTRL_HC RSV_SHARED
      .oldval(oldval)   ///CTRL_HC RSV_SHARED
      );
   
endmodule // oldest_finder8

`default_nettype wire
