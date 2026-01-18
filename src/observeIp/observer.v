module resultObs
#(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32,
    parameter OBSERVE_WIDTH = 8
)
(
    input wire clk,
    input wire rst,
    ////////// PL writer
    input  wire                   pl_write_enable,
    input  wire [ADDR_WIDTH-1: 0] pl_write_address,
    input  wire [DATA_WIDTH-1: 0] pl_write_data,
    ////////// RIDE command
    output reg                      resetSignal,
    ////////// ARM connect
    input  wire [3: 0]              ps_write_enable,
    input  wire [ADDR_WIDTH-1:0]    ps_address,
    input  wire [DATA_WIDTH-1:0]    ps_write_data,
    output reg  [DATA_WIDTH-1:0]    ps_read_data
    
);

/**
    0x000 reset signal ( read/Write)
    0x004 finish signal (read only)
    0x008 print counter  (read only)
    0x00C main counter (read only)
    0x100 - 0x200 to  data ...
*/

    // BRAM instance (using Xilinx BRAM or generic)
    reg [DATA_WIDTH-1:0] bram [(1<<OBSERVE_WIDTH)-1:0];  // 2^OBSERVE_WIDTH locations

    //////// read command pipeline buffer 
    reg                      ps_bufWen;   //// pipeline the bufWen
    reg  [ADDR_WIDTH-1:0]    ps_bufAddr;  //// pipeline the bufAddr

    /////// meta-data/data register
    reg                      finish;       
    reg  [OBSERVE_WIDTH-1:0] print_counter;
    reg  [DATA_WIDTH-1: 0  ] main_counter; 
    reg  [DATA_WIDTH-1:0]    read_data;    

    // Counter for address

    wire [31:0] addr_offset = ps_address - 32'h100;
    
    always @(posedge clk) begin

        if (rst) begin
            resetSignal  <= 0;
            ps_read_data <= 0;

            ps_bufWen     <= 0;
            ps_bufAddr    <= 0;
            finish        <= 0;
            print_counter <= 0;
            main_counter  <= 0;
            /// read_data 

        end else begin
            /**
             *    ----- PS SECTION -----
             */
            /////// responds to PS READ stage1
            ps_bufWen  <= ps_write_enable != 0;
            ps_bufAddr <= ps_address;
            /////// responds to PS READ stage2
            if (!ps_bufWen)begin
                case (ps_bufAddr)
                    32'h00000000: begin ps_read_data <= {{(DATA_WIDTH-1            ){1'b0}}, resetSignal  }; end
                    32'h00000004: begin ps_read_data <= {{(DATA_WIDTH-1            ){1'b0}}, finish       }; end
                    32'h00000008: begin ps_read_data <= {{(DATA_WIDTH-OBSERVE_WIDTH){1'b0}}, print_counter}; end
                    32'h0000000C: begin ps_read_data <= main_counter; end
                    default     : begin ps_read_data <= read_data   ; end
                endcase
            end
            /////// responds to PS WRITE stage
            if ( (ps_write_enable != 0) && (ps_address == 0)) begin
                ///// reset occure
                resetSignal   <= (ps_write_data == 1);
            end

            /**
             *    ----- PL SECTION -----
             */


            /////// responds to PL WRITE stage
            if (resetSignal)begin
                finish        <= 0;
                print_counter <= {OBSERVE_WIDTH{1'b0}};
                main_counter  <= {DATA_WIDTH   {1'b0}};
            end else begin
                /// for finish signal
                if (pl_write_enable && (pl_write_address == 8)) begin
                    finish <= 1;
                end
                /// for bram and print counter
                if (!finish)begin
                    if (pl_write_enable && (pl_write_address == 0) && (print_counter != 8'hFF)) begin
                    bram[print_counter] <= pl_write_data;
                    print_counter       <= print_counter + 1;
                    end
                /// for mainCnt signal
                    main_counter <= main_counter + 1;
                end
                
            end
            /////// do not interfere this with any conditional block due to maintain bram utilization
        end
        read_data <= bram[addr_offset[OBSERVE_WIDTH+2-1: 2]];

    end

endmodule