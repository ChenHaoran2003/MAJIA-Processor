`include "defines.v"

module if_id (
    input wire                      clk,
    input wire                      rst,
    input wire [5:0]                stall,

    input wire [`ADDR_WIDTH-1:0]    if_addr,
    input wire [`INST_WIDTH-1:0]    if_inst,
    input wire                      if_wbcommit,

    output reg [`ADDR_WIDTH-1:0]    id_addr,
    output reg [`INST_WIDTH-1:0]    id_inst,
    output reg                      id_wbcommit
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            id_addr     <= 0;
            id_inst     <= 0;
            id_wbcommit <= 0;
        end
        else if(stall[1] === 1'b1 && stall[2] === 1'b0) begin // if stall and id not stall
            id_addr     <= 0;
            id_inst     <= `INST_NOP;
            id_wbcommit <= 0;
        end
        else if(stall[1] === 1'b0) begin
            id_addr     <= if_addr;
            id_inst     <= if_inst;
            id_wbcommit <= if_wbcommit;
        end
    end

endmodule
