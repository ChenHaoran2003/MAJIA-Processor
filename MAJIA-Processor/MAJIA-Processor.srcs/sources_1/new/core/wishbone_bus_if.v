`include "defines.v"

module wishbone_bus_if(
    input                           clk,
    input                           rst,

    /* from ctrl */
    input   [5:0]                   stall_i,

    /* cpu side */
    input                           cpu_ce_i,
    input   [`DATA_WIDTH-1:0]       cpu_data_i,
    input   [`ADDR_WIDTH-1:0]       cpu_addr_i,
    input                           cpu_we_i,
    input   [3:0]                   cpu_sel_i,
    output  reg [`DATA_WIDTH-1:0]   cpu_data_o,

    /* wishbone side */
    input   [`DATA_WIDTH-1:0]       wishbone_data_i,
    input                           wishbone_ack_i,
    output  reg [`ADDR_WIDTH-1:0]   wishbone_addr_o,
    output  reg [`DATA_WIDTH-1:0]   wishbone_data_o,
    output  reg                     wishbone_we_o,
    output  reg [3:0]               wishbone_sel_o,
    output  reg                     wishbone_stb_o,
    output  reg                     wishbone_cyc_o,

    output  reg                     stallreq
);

    localparam  [1:0]   WB_IDLE             = 2'b01;
    localparam  [1:0]   WB_BUSY             = 2'b10;
    localparam  [1:0]   WB_WAIT_FOR_STALL   = 2'b11;

    reg [1:0]               wishbone_state;
    reg [`DATA_WIDTH-1:0]   rd_buf;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            wishbone_state  <= WB_IDLE;
            wishbone_addr_o <= 0;
            wishbone_data_o <= 0;
            wishbone_we_o   <= 0;
            wishbone_sel_o  <= 0;
            wishbone_stb_o  <= 0;
            wishbone_cyc_o  <= 0;
            rd_buf          <= 0;
        end
        else begin
            case(wishbone_state)
                WB_IDLE: begin
                    if(cpu_ce_i) begin
                        wishbone_stb_o  <= 1;
                        wishbone_cyc_o  <= 1;
                        wishbone_addr_o <= cpu_addr_i;
                        wishbone_data_o <= cpu_data_i;
                        wishbone_we_o   <= cpu_we_i;
                        wishbone_sel_o  <= cpu_sel_i;
                        wishbone_state  <= WB_BUSY;
                        rd_buf          <= 0;
                    end
                    // else begin
                    //     wishbone_stb_o  <= 0;
                    //     wishbone_cyc_o  <= 0;
                    //     wishbone_addr_o <= 0;
                    //     wishbone_data_o <= 0;
                    //     wishbone_we_o   <= 0;
                    //     wishbone_sel_o  <= 0;
                    //     wishbone_state  <= WB_IDLE;
                    //     rd_buf          <= 0;
                    // end
                end
                WB_BUSY: begin
                    if(wishbone_ack_i) begin
                        wishbone_stb_o  <= 0;
                        wishbone_cyc_o  <= 0;
                        wishbone_addr_o <= 0;
                        wishbone_data_o <= 0;
                        wishbone_we_o   <= 0;
                        wishbone_sel_o  <= 0;
                        wishbone_state  <= WB_IDLE;
                        if(cpu_we_i === 0) begin
                            rd_buf      <= wishbone_data_i;
                        end

                        if(stall_i != 6'b000000) begin
                            wishbone_state  <= WB_WAIT_FOR_STALL;
                        end
                    end
                end
                WB_WAIT_FOR_STALL: begin
                    if(stall_i === 6'b000000) begin
                        wishbone_state  <= WB_IDLE;
                    end
                end
                default: begin
                    wishbone_state  <= WB_IDLE;
                    wishbone_addr_o <= 0;
                    wishbone_data_o <= 0;
                    wishbone_we_o   <= 0;
                    wishbone_sel_o  <= 0;
                    wishbone_stb_o  <= 0;
                    wishbone_cyc_o  <= 0;
                    rd_buf          <= 0;
                end
            endcase
        end
    end

    always @(*) begin
        if(rst) begin
            stallreq    = 0;
            cpu_data_o  = 0;
        end
        else begin
            stallreq    = 0;
            case(wishbone_state)
                WB_IDLE: begin
                    if(cpu_ce_i) begin
                        stallreq    = 1;
                        cpu_data_o  = 0;
                    end
                end
                WB_BUSY: begin
                    if(wishbone_ack_i) begin
                        stallreq        = 0;
                        if(wishbone_we_o === 0) begin
                            cpu_data_o  = wishbone_data_i;
                        end
                        else begin
                            cpu_data_o  = 0;
                        end
                    end
                    else begin
                        stallreq    = 1;
                        cpu_data_o  = 0;
                    end
                end
                WB_WAIT_FOR_STALL: begin
                    stallreq        = 0;
                    cpu_data_o      = rd_buf;
                end
                default: begin
                    stallreq        = 0;
                    cpu_data_o      = 0;
                end
            endcase
        end
    end

endmodule
