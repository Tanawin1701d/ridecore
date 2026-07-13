`include "constants.vh"

//`default_nettype none
  
module alloc_issue_ino  #(            ///MD RSV_SHARED
			  parameter ENTSEL = 2,   ///PARAM RSV_SHARED
			  parameter ENTNUM = 4    ///PARAM RSV_SHARED
			  )
   (
    input wire 		     clk,                                   ///CTRL_HC RSV_SHARED
    input wire 		     reset,                                 ///CTRL_HC RSV_SHARED
    input wire [1:0] 	     reqnum /* verilator public */,     ///CTRL_HC RSV_SHARED
    input wire [ENTNUM-1:0]  busyvec,                           ///CTRL_HC RSV_SHARED
    input wire [ENTNUM-1:0]  prbusyvec_next,                    ///CTRL_HC RSV_SHARED
    input wire [ENTNUM-1:0]  readyvec,                          ///CTRL_HC RSV_SHARED
    input wire 		     prmiss,                                ///CTRL_HC RSV_SHARED
    input wire 		     exunit_busynext,                       ///CTRL_HC RSV_SHARED
    input wire 		     stall_DP,                              ///CTRL_HC RSV_SHARED
    input wire 		     kill_DP,                               ///CTRL_HC RSV_SHARED
    output reg [ENTSEL-1:0]  allocptr /* verilator public */,   ///CTRL_HC RSV_SHARED
    output wire 	     allocatable,                           ///CTRL_HC RSV_SHARED
    output wire [ENTSEL-1:0] issueptr ,                         ///CTRL_HC RSV_SHARED
    output wire 	     issuevalid                             ///CTRL_HC RSV_SHARED
   );


   wire [ENTSEL-1:0] 	    allocptr2 = allocptr + 1;   ///CTRL_CL RSV_SHARED
   wire [ENTSEL-1:0] 	    b0;                         ///CTRL_HWD RSV_SHARED
   wire [ENTSEL-1:0] 	    e0;                         ///CTRL_HWD RSV_SHARED
   wire [ENTSEL-1:0] 	    b1;                         ///CTRL_HWD RSV_SHARED
   wire [ENTSEL-1:0] 	    e1;                         ///CTRL_HWD RSV_SHARED
   wire 		    notfull;                            ///CTRL_HWD RSV_SHARED

   wire [ENTSEL-1:0] 	    ne1;                       ///CTRL_HWD RSV_SHARED
   wire [ENTSEL-1:0] 	    nb0;                       ///CTRL_HWD RSV_SHARED
   wire [ENTSEL-1:0] 	    nb1;                       ///CTRL_HWD RSV_SHARED
   wire 		    notfull_next;                      ///CTRL_HWD RSV_SHARED
   
   search_begin #(ENTSEL, ENTNUM) sb1(                 ///MD RSV_SHARED
				      .in(busyvec),                    ///CTRL_HC RSV_SHARED
				      .out(b1),                        ///CTRL_HC RSV_SHARED
				      .en()                            ///DC
				      );
   
   search_end #(ENTSEL, ENTNUM) se1(                   ///MD RSV_SHARED
				    .in(busyvec),                      ///CTRL_HC RSV_SHARED
				    .out(e1),                          ///CTRL_HC RSV_SHARED
				    .en()                              ///DC
				    );

   search_end #(ENTSEL, ENTNUM) se0(                   ///MD RSV_SHARED
				    .in(~busyvec),                     ///CTRL_HC+CTRL_CL RSV_SHARED
				    .out(e0),                          ///CTRL_HC RSV_SHARED
				    .en(notfull)                       ///CTRL_HC RSV_SHARED
				    );

   search_begin #(ENTSEL, ENTNUM) snb1(                ///MD RSV_SHARED
				       .in(prbusyvec_next),            ///CTRL_HC RSV_SHARED
				       .out(nb1),                      ///CTRL_HC RSV_SHARED
				       .en()                           ///DC
				       );
   
   search_end #(ENTSEL, ENTNUM) sne1(       ///MD RSV_SHARED
				     .in(prbusyvec_next),   ///CTRL_HC RSV_SHARED
				     .out(ne1),             ///CTRL_HC RSV_SHARED
				     .en()                  ///DC
				     );

   search_begin #(ENTSEL, ENTNUM) snb0(        ///MD RSV_SHARED
				       .in(~prbusyvec_next),   ///CTRL_HC+CTRL_CL RSV_SHARED
				       .out(nb0),              ///CTRL_HC RSV_SHARED
				       .en(notfull_next)       ///CTRL_HC RSV_SHARED
				       );

   
   assign issueptr = ~notfull ? allocptr :                                ///CTRL_CL RSV_SHARED
		     ((b1 == 0) && (e1 == {{(ENTSEL){1'b0}} + (ENTNUM-1)}  )) ?   ///CTRL_CL RSV_SHARED
		     (e0+1) : b1;                                                 ///CTRL_CL RSV_SHARED

   // assign issueptr = ~notfull ? allocptr :
	// 	     ((b1 == 0) && (e1 == ENTNUM-1)) ? (e0+1) : 
	// 	     b1;
   
   assign issuevalid = readyvec[issueptr] & ~prmiss & ~exunit_busynext;    ///CTRL_CL RSV_SHARED

   assign allocatable = (reqnum == 2'h0) ? 1'b1 :                          ///CTRL_CL RSV_SHARED
			(reqnum == 2'h1) ? ((~busyvec[allocptr] ? 1'b1 : 1'b0)) :      ///CTRL_CL RSV_SHARED
			((~busyvec[allocptr] && ~busyvec[allocptr2]) ? 1'b1 : 1'b0);   ///CTRL_CL RSV_SHARED
   
   always @ (posedge clk) begin                                                             ///CTRL_CL RSV_SHARED
      if (reset) begin                                                                      ///CTRL_CL RSV_SHARED
	 allocptr <= 0;                                                                         ///CTRL_DT RSV_SHARED
      end else if (prmiss) begin                                                            ///CTRL_CL RSV_SHARED
	 allocptr <= ~notfull_next ? allocptr :                                                 ///CTRL_CL RSV_SHARED
		     (((nb1 == 0) && (ne1 == {{(ENTSEL){1'b0}} + (ENTNUM-1)} )) ? nb0 : (ne1+1));   ///CTRL_CL RSV_SHARED

   // allocptr <= ~notfull_next ? allocptr :
	// 	     (((nb1 == 0) && (ne1 == ENTNUM-1)) ? nb0 : (ne1+1));
      end else if (~stall_DP && ~kill_DP) begin   ///CTRL_CL RSV_SHARED
	 allocptr <= allocptr + reqnum;               ///CTRL_CL RSV_SHARED
      end
   end
endmodule // alloc_issue_ino

//`default_nettype wire
