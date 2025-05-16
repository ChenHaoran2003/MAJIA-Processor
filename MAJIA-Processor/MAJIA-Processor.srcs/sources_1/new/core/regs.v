`include "defines.v"

module regs (
    input clk,
    input rst,

    input [`DATA_WIDTH-1:0] wdata,
    input [`REG_NUM_LOG-1:0] rd,
    input wen,
    input [`REG_NUM_LOG-1:0] rs1,
    input [`REG_NUM_LOG-1:0] rs2,
    input CtrlJumpORCtrlJALR,
    input [`ADDR_WIDTH-1:0] pc,

    output [`DATA_WIDTH-1:0] rs1data,
    output [`DATA_WIDTH-1:0] rs2data
);

    reg [`DATA_WIDTH-1:0] rf [`REG_NUM-1:0];
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i = 0; i < `REG_NUM; i = i + 1) begin
                rf[i] <= {`DATA_WIDTH{1'b0}};
            end
        end else begin
            if(wen && CtrlJumpORCtrlJALR === 1'b0) begin
                if(rd != 5'b00000) begin
                    rf[rd] <= wdata;
                end else begin
                    rf[rd] <= 32'b0;
                end
            end else if(wen && CtrlJumpORCtrlJALR === 1'b1) begin
                if(rd != 5'b00000) begin
                    rf[rd] <= pc + 4;
                end else begin
                    rf[rd] <= 32'b0;
                end
            end else begin
                rf[0] <= 32'b0;
            end
        end
    end

    // always @(posedge clk) begin
    //     if(rst != 1'b1 && wen === 1'b1) begin
    //         wbcommit_fun(32'b1);
    //     end
    // end

    assign rs1data = (rs1 === 5'b00000) ? 32'b0 : rf[rs1];
    assign rs2data = (rs2 === 5'b00000) ? 32'b0 : rf[rs2];

endmodule
