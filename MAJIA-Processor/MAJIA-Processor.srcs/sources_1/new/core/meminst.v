`include "defines.v"

module meminst(
    input                           clk,

    input                           i_ce,
    input   [`ADDR_WIDTH-1:0]       i_addr,
    input   [`DATA_WIDTH-1:0]       i_data,
    input                           i_we,
    input   [3:0]                   i_sel,

    output  [`INST_WIDTH-1:0]       o_data
);

    // reg    [`INST_WIDTH-1:0]    pmem    [255:0];

    // always @(*) begin
    //     if(i_ce) begin
    //         o_data  = pmem[(i_addr - `CONFIG_MBASE) / 4];
    //     end
    // end



    blk_mem_gen_0 blk_mem_gen_0_meminst(
        .clka(clk),    // input wire clka
        .ena(i_ce),      // input wire ena
        .wea(i_we),      // input wire [0 : 0] wea
        .addra((i_addr - `CONFIG_MBASE) / 4),  // input wire [13 : 0] addra
        .dina(i_data),    // input wire [31 : 0] dina
        .douta(o_data)  // output wire [31 : 0] douta
    );

endmodule
