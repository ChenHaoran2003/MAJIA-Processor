// import "DPI-C" function void wbcommit_fun_1(int wbcommit);

`include "defines.v"

module ifu(
    input                       clk,
    input                       rst,
    input   [5:0]               stall,

    input                       CtrlJump,
    input                       CtrlJALR,
    input                       CtrlWantBranch,
    input                       CtrlBranch,
    input   [`DATA_WIDTH-1:0]   result,
    input   [`INST_WIDTH-1:0]   inst_from_meminst,

    output  [`ADDR_WIDTH-1:0]   addr,
    output  [`INST_WIDTH-1:0]   inst,
    output  reg                 stallreq,
    output                      wbcommit
);

    assign inst = inst_from_meminst;

    pc u_pc(
        .clk            (clk),
        .rst            (rst),
        .stall          (stall),
        
        .CtrlJump       (CtrlJump),
        .CtrlJALR       (CtrlJALR),
        .CtrlWantBranch (CtrlWantBranch),
        .CtrlBranch     (CtrlBranch),
        .result         (result),

        .pc             (addr),
        .commit         (wbcommit)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            stallreq    <= 0;
        end
        else if(stall[5]) begin
            stallreq    <= 1;
        end
        else begin
            stallreq    <= ~stallreq;
        end
    end

endmodule
