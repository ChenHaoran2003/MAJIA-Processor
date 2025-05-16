`include "defines.v"

module register (
    input wire                      clk,
    input wire                      rst,

    input wire                      commit_in,
    input wire  [`ADDR_WIDTH-1:0]   addr_in,
    input wire  [`INST_WIDTH-1:0]   inst_in,
    input wire                      CtrlJump_in,
    input wire                      CtrlJALR_in,
    input wire                      CtrlWantBranch_in,
    input wire                      CtrlBranch_in,

    output reg                      commit_out,
    output reg [`ADDR_WIDTH-1:0]    addr_out,
    output reg [`INST_WIDTH-1:0]    inst_out,
    output reg                      CtrlJump_out,
    output reg                      CtrlJALR_out,
    output reg                      CtrlWantBranch_out,
    output reg                      CtrlBranch_out
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            commit_out <= 0;
            addr_out   <= 0;
            inst_out   <= 0;
            CtrlJump_out <= 0;
            CtrlJALR_out <= 0;
            CtrlWantBranch_out <= 0;
            CtrlBranch_out <= 0;
        end
        else begin
            commit_out <= commit_in;
            addr_out   <= addr_in;
            inst_out   <= inst_in;
            CtrlJump_out <= CtrlJump_in;
            CtrlJALR_out <= CtrlJALR_in;
            CtrlWantBranch_out <= CtrlWantBranch_in;
            CtrlBranch_out <= CtrlBranch_in;
        end
    end

endmodule