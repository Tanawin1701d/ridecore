`default_nettype none
module prioenc #(                  ///MD RSV_SHARED
		 parameter REQ_LEN = 4,    ///PARAM RSV_SHARED
		 parameter GRANT_LEN = 2   ///PARAM RSV_SHARED
		 )
   (
    input wire [REQ_LEN-1:0]   in,    ///CTRL_HC RSV_SHARED
    output reg [GRANT_LEN-1:0] out,   ///CTRL_HC RSV_SHARED
    output reg 		       en         ///CTRL_HC RSV_SHARED
   );
   
   integer 		      i;                               ///HLH RSV_SHARED
   always @ (*) begin                                  ///CTRL_CL RSV_SHARED
      en = 0;                                          ///CTRL_DT RSV_SHARED
      out = 0;                                         ///CTRL_DT RSV_SHARED
      for (i = REQ_LEN-1 ; i >= 0 ; i = i - 1) begin   ///HLH RSV_SHARED
	 if (~in[i]) begin                                 ///CTRL_CL RSV_SHARED
	    out = i[GRANT_LEN-1:0]; // out = i;            ///CTRL_DT RSV_SHARED
	    en = 1;                                        ///CTRL_DT RSV_SHARED
	 end
      end
   end
endmodule

module maskunit  #(                  ///MD RSV_SHARED
		   parameter REQ_LEN = 4,    ///PARAM RSV_SHARED
		   parameter GRANT_LEN = 2   ///PARAM RSV_SHARED
		   )
   (
    input wire [GRANT_LEN-1:0] mask,   ///CTRL_HC RSV_SHARED
    input wire [REQ_LEN-1:0]   in,     ///CTRL_HC RSV_SHARED
    output reg [REQ_LEN-1:0]   out     ///CTRL_HC RSV_SHARED
   );
   
   integer 		      i;   ///HLH RSV_SHARED
   always @ (*) begin      ///CTRL_CL RSV_SHARED
      out = 0;   ///CTRL_DT RSV_SHARED
      for (i = 0 ; i < REQ_LEN ; i = i+1) begin          ///HLH RSV_SHARED
	 out[i] = (mask < i[GRANT_LEN-1:0]) ? 1'b0 : 1'b1;   ///CTRL_CL RSV_SHARED
      end
   end
endmodule

module allocateunit  #(                   ///MD RSV_SHARED
		       parameter REQ_LEN = 4,     ///PARAM RSV_SHARED
		       parameter GRANT_LEN = 2    ///PARAM RSV_SHARED
		       )
   (
    input wire [REQ_LEN-1:0] 	busy,        ///CTRL_HC RSV_SHARED
    output wire 		en1,                 ///CTRL_HC RSV_SHARED
    output wire 		en2,                 ///CTRL_HC RSV_SHARED
    output wire [GRANT_LEN-1:0] free_ent1,   ///CTRL_HC RSV_SHARED
    output wire [GRANT_LEN-1:0] free_ent2,   ///CTRL_HC RSV_SHARED
    input wire [1:0] 		reqnum,          ///CTRL_HC RSV_SHARED
    output wire 		allocatable          ///CTRL_HC RSV_SHARED
   );
   
   wire [REQ_LEN-1:0] 	       busy_msk;     ///CTRL_HWD RSV_SHARED
   
   prioenc #(REQ_LEN, GRANT_LEN) p1          ///MD RSV_SHARED
     (
      .in(busy),                             ///CTRL_HC RSV_SHARED
      .out(free_ent1),                       ///CTRL_HC RSV_SHARED
      .en(en1)                               ///CTRL_HC RSV_SHARED
      );

   maskunit #(REQ_LEN, GRANT_LEN) msku   ///MD RSV_SHARED
     (
      .mask(free_ent1),   ///CTRL_HC RSV_SHARED
      .in(busy),          ///CTRL_HC RSV_SHARED
      .out(busy_msk)      ///CTRL_HC RSV_SHARED
      );
   
   prioenc #(REQ_LEN, GRANT_LEN) p2   ///MD RSV_SHARED
     (
      .in(busy | busy_msk),           ///CTRL_HC+CTRL_CL RSV_SHARED
      .out(free_ent2),                ///CTRL_HC RSV_SHARED
      .en(en2)                        ///CTRL_HC RSV_SHARED
      );

   assign allocatable = (reqnum > ({1'b0,en1}+{1'b0,en2})) ? 1'b0 : 1'b1;   ///CTRL_CL RSV_SHARED
endmodule
`default_nettype wire
