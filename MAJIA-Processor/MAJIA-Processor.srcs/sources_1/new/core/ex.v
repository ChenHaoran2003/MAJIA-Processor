`include "defines.v"

module ex (
    input clk,
    input rst,
    input [`DATA_WIDTH-1:0] rs1data,
    input [`DATA_WIDTH-1:0] rs2data,
    input [`DATA_WIDTH-1:0] imm,
    input [`ADDR_WIDTH-1:0] pc,
    input [`CTRLOP_TYPE_LOG-1:0] CtrlOP,
    input CtrlALUSrc,
    input CtrlJAL,
    input CtrlWantBranch,
    input CtrlSigned,
    input CtrlJumpORCtrlJALR,
    input CtrlLoad,

    output reg [`DATA_WIDTH-1:0] result,
    output reg CtrlBranch,
    output reg stall_req,

    // test
    output [`DATA_WIDTH-1:0] operand1out_from_ALU,
    output [`DATA_WIDTH-1:0] operand2out_from_ALU
);

    wire [`DATA_WIDTH-1:0] operand1;
    wire [`DATA_WIDTH-1:0] operand2;

    wire signed [`DATA_WIDTH-1:0] signed_operand1 = $signed(operand1);
    wire signed [`DATA_WIDTH-1:0] signed_operand2 = $signed(operand2);

    // test
    assign operand1out_from_ALU = CtrlSigned ? signed_operand1 : operand1;
    assign operand2out_from_ALU = CtrlSigned ? signed_operand2 : operand2;

    assign operand1 = CtrlJAL ? pc : rs1data;
    assign operand2 = CtrlALUSrc ? imm : rs2data;

    always @(*) begin
        if(CtrlOP === `OP_ADD) begin
            if(CtrlJumpORCtrlJALR === 1'b1) begin
                CtrlBranch = 1'b0;
                result = pc + 4;
            end
            else begin
                CtrlBranch = 1'b0;
                result = operand1 + operand2;
            end
        end
        else if(CtrlOP === `OP_SLL) begin
            CtrlBranch = 1'b0;
            result = operand1 << operand2;
        end
        else if(CtrlOP === `OP_LT) begin
            if(CtrlSigned === 1'b1) begin
                if(signed_operand1 < signed_operand2) begin
                    if(CtrlWantBranch === 1'b1) begin
                        CtrlBranch = 1'b1;
                        result = pc + imm;
                    end
                    else begin
                        CtrlBranch = 1'b0;
                        result = 32'b1;
                    end
                end
                else begin
                    CtrlBranch = 1'b0;
                    result = 32'b0;
                end
            end
            else begin
                if(operand1 < operand2) begin
                    if(CtrlWantBranch === 1'b1) begin
                        CtrlBranch = 1'b1;
                        result = pc + imm;
                    end
                    else begin
                        CtrlBranch = 1'b0;
                        result = 32'b1;
                    end
                end
                else begin
                    CtrlBranch = 1'b0;
                    result = 32'b0;
                end
            end
        end
        else if(CtrlOP === `OP_GE) begin
            if(CtrlSigned === 1'b1) begin
                if(signed_operand1 >= signed_operand2) begin
                    CtrlBranch = 1'b1;
                    result = pc + imm;
                end
                else begin
                    CtrlBranch = 1'b0;
                    result = 32'b0;
                end
            end
            else begin
                if(operand1 >= operand2) begin
                    CtrlBranch = 1'b1;
                    result = pc + imm;
                end
                else begin
                    CtrlBranch = 1'b0;
                    result = 32'b0;
                end
            end
        end
        else if(CtrlOP === `OP_XOR) begin
            CtrlBranch = 1'b0;
            result = operand1 ^ operand2;
        end
        else if(CtrlOP === `OP_OR) begin
            CtrlBranch = 1'b0;
            result = operand1 | operand2;
        end
        else if(CtrlOP === `OP_EQ) begin
            if(operand1 === operand2) begin
                CtrlBranch = 1'b1;
                result = pc + imm;
            end
            else begin
                CtrlBranch = 1'b0;
                result = 32'b0;
            end
        end
        else if(CtrlOP === `OP_AND) begin
            CtrlBranch = 1'b0;
            result = operand1 & operand2;
        end
        else if(CtrlOP === `OP_SRA) begin
            CtrlBranch = 1'b0;
            result = (operand1 >> operand2[4:0]) | ({32{operand1[31]}} << (32 - operand2));
        end
        else if(CtrlOP === `OP_NE) begin
            if(operand1 != operand2) begin
                CtrlBranch = 1'b1;
                result = pc + imm;
            end
            else begin
                CtrlBranch = 1'b0;
                result = 32'b0;
            end
        end
        else if(CtrlOP === `OP_SUB) begin
            CtrlBranch = 1'b0;
            result = operand1 - operand2;
        end
        else if(CtrlOP === `OP_SRL) begin
            CtrlBranch = 1'b0;
            result = operand1 >> operand2[4:0];
        end
        else begin
            CtrlBranch = 1'b0;
            result = 32'b0;
        end
    end

    always @(posedge clk) begin
        if(CtrlLoad && stall_req === 0) begin
            stall_req = 1;
        end
        else begin
            stall_req = 0;
        end
    end
    
endmodule
