
module search_begin #(   ///MD RSV_SHARED
		      parameter ENTSEL = 2,   ///PARAM RSV_SHARED
		      parameter ENTNUM = 4   ///PARAM RSV_SHARED
		     )
  (
   input wire [ENTNUM-1:0] in,   ///CTRL_HC RSV_SHARED
   output reg [ENTSEL-1:0] out,   ///CTRL_HC RSV_SHARED
   output reg 		   en   ///CTRL_HC RSV_SHARED
   );

   integer 		   i;   ///HLH RSV_SHARED
   always @ (*) begin   ///CTRL_CL RSV_SHARED
      out = 0;   ///CTRL_DT RSV_SHARED
      en = 0;   ///CTRL_DT RSV_SHARED
      for (i = ENTNUM-1; i >= 0 ; i = i - 1) begin   ///HLH RSV_SHARED
	 if (in[i]) begin   ///CTRL_CL RSV_SHARED
	    out = i[ENTSEL-1:0]; ///out = i;   ///CTRL_DT RSV_SHARED
	    en = 1;   ///CTRL_DT RSV_SHARED
	 end
      end
   end
   
endmodule // search_from_top

module search_end #(   ///DC
		    parameter ENTSEL = 2,   ///DC
		    parameter ENTNUM = 4   ///DC
		    )   ///DC
   (   ///DC
    input wire [ENTNUM-1:0] in,   ///DC
    output reg [ENTSEL-1:0] out,   ///DC
    output reg 		    en   ///DC
   );   ///DC

   integer 		   i;   ///DC
   always @ (*) begin   ///DC
      out = 0;   ///DC
      en = 0;   ///DC
      for (i = 0 ; i < ENTNUM ; i = i + 1) begin   ///DC
	 if (in[i]) begin   ///DC
	    out = i[ENTSEL-1:0]; //// out = i;   ///DC
	    en = 1;   ///DC
	 end   ///DC
      end   ///DC
   end   ///DC

endmodule // search_from_bottom   ///DC
