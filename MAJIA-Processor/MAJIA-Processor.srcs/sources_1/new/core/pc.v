`include "defines.v"

module pc(
    input clk,
    input rst,
    input [5:0] stall,

    input CtrlJump,
    input CtrlJALR,
    input CtrlBranch,
    input CtrlWantBranch,
    input [`DATA_WIDTH-1:0] result,

    output reg [`ADDR_WIDTH-1:0] pc,
    output reg commit
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc <= 32'h80000000 - 4;
            commit <= 1'b0;
        end
        else if(stall[0] != 1'b1 || CtrlJump === 1'b1 || (CtrlWantBranch === 1'b1 && CtrlBranch === 1'b1) || CtrlJALR === 1'b1) begin
            if(CtrlJump === 1'b1 || (CtrlWantBranch === 1'b1 && CtrlBranch === 1'b1)) begin
                pc <= result;
                commit <= 1'b1;
            end
            else if(CtrlJALR === 1'b1) begin
                pc <= result & 32'hFFFFFFFE;
                commit <= 1'b1;
            end
            else begin
                pc <= pc + 4;
                commit <= 1'b1;
            end
        end
    end

    // reg [`ADDR_WIDTH-1:0] next_pc;

    // always @(*) begin
    //     if(CtrlJump === 1'b1 || (CtrlWantBranch === 1'b1 && CtrlBranch === 1'b1)) begin
    //         next_pc = result;
    //     end
    //     else if(CtrlJALR === 1'b1) begin
    //         next_pc = result & 32'hFFFFFFFE;
    //     end
    //     else begin
    //         next_pc = pc + 4;
    //     end
    // end

    // always @(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         pc <= 32'h80000000 - 4;
    //         commit <= 1'b0;
    //     end
    //     else if(!stall[0]) begin
    //         pc <= next_pc;
    //         commit <= 1'b1;
    //     end
    // end

    // assign commit = !stall[0];

endmodule
