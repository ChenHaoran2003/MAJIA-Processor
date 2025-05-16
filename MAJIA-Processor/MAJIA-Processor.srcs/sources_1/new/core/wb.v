`include "defines.v"

module wb (
    input clk,
    input rst,

    input wen,
    input [`REG_NUM_LOG-1:0] rd,
    input [`DATA_WIDTH-1:0] data,
    input [`DATA_WIDTH-1:0] result,
    input CtrlJump,
    input CtrlJALR,
    input [1:0] CtrlLoad,
    input CtrlWantBranch,
    input CtrlBranch,

    output out_wen,
    output [`REG_NUM_LOG-1:0] out_rd,
    output [`DATA_WIDTH-1:0] out_data,
    output [`DATA_WIDTH-1:0] out_result,
    output out_CtrlJump,
    output out_CtrlJALR,
    output [1:0] out_CtrlLoad,
    output out_CtrlWantBranch,
    output out_CtrlBranch
);

    assign out_wen = wen;
    assign out_rd = rd;
    assign out_data = data;
    assign out_result = result;
    assign out_CtrlJump = CtrlJump;
    assign out_CtrlJALR = CtrlJALR;
    assign out_CtrlLoad = CtrlLoad;
    assign out_CtrlWantBranch = CtrlWantBranch;
    assign out_CtrlBranch = CtrlBranch;

endmodule
