`include "defines.v"

module mem_wb (
    input wire                      clk,
    input wire                      rst,
    input wire [5:0]                stall,

    input wire [`ADDR_WIDTH-1:0]    mem_addr,
    input wire [`INST_WIDTH-1:0]    mem_inst,
    input wire                      mem_wen,
    input wire [`REG_NUM_LOG-1:0]   mem_rd,
    input wire [`DATA_WIDTH-1:0]    mem_data,
    input wire [`DATA_WIDTH-1:0]    mem_result,
    input wire                      mem_CtrlJump,
    input wire                      mem_CtrlJALR,
    input wire [1:0]                mem_CtrlLoad,
    input wire                      mem_CtrlWantBranch,
    input wire                      mem_CtrlBranch,
    input wire [1:0]                mem_CtrlCSR,
    input wire [`DATA_WIDTH-1:0]    mem_csr_data,
    input wire                      mem_wbcommit,

    // input for CSR
    input wire                      mem_wen_mtvec,
    input wire                      mem_wen_mcause,
    input wire                      mem_wen_mstatus,
    input wire                      mem_wen_mepc,
    input wire [`DATA_WIDTH-1:0]    mem_rs1data,

    // new add wire for output
    input wire [`REG_NUM_LOG-1:0]     mem_rs1,
    input wire [`REG_NUM_LOG-1:0]     mem_rs2,
    input wire [`CTRLOP_TYPE_LOG-1:0] mem_CtrlOP,
    input wire                        mem_CtrlALUSrc,
    input wire                        mem_CtrlJAL,
    input wire [`DATA_WIDTH-1:0]      mem_imm,
    input wire [`DATA_WIDTH-1:0]    mem_op1,
    input wire [`DATA_WIDTH-1:0]    mem_op2,

    output reg [`ADDR_WIDTH-1:0]    wb_addr,
    output reg [`INST_WIDTH-1:0]    wb_inst,
    output reg                      wb_wen,
    output reg [`REG_NUM_LOG-1:0]   wb_rd,
    output reg [`DATA_WIDTH-1:0]    wb_data,
    output reg [`DATA_WIDTH-1:0]    wb_result,
    output reg                      wb_CtrlJump,
    output reg                      wb_CtrlJALR,
    output reg [1:0]                wb_CtrlLoad,
    output reg                      wb_CtrlWantBranch,
    output reg                      wb_CtrlBranch,
    output reg [1:0]                wb_CtrlCSR,
    output reg [`DATA_WIDTH-1:0]    wb_csr_data,
    output reg                      wb_wbcommit,
    
    // input for CSR
    output reg                      wb_wen_mtvec,
    output reg                      wb_wen_mcause,
    output reg                      wb_wen_mstatus,
    output reg                      wb_wen_mepc,
    output reg [`DATA_WIDTH-1:0]    wb_rs1data,

    // new add wire for output
    output reg [`REG_NUM_LOG-1:0]     wb_rs1,
    output reg [`REG_NUM_LOG-1:0]     wb_rs2,
    output reg [`CTRLOP_TYPE_LOG-1:0] wb_CtrlOP,
    output reg                        wb_CtrlALUSrc,
    output reg                        wb_CtrlJAL,
    output reg [`DATA_WIDTH-1:0]      wb_imm,
    output reg [`DATA_WIDTH-1:0]    wb_op1,
    output reg [`DATA_WIDTH-1:0]    wb_op2
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            wb_addr         <= 0;
            wb_inst         <= 0;
            wb_wen          <= 0;
            wb_rd           <= 0;
            wb_data         <= 0;
            wb_result       <= 0;
            wb_CtrlJump     <= 0;
            wb_CtrlJALR     <= 0;
            wb_CtrlLoad     <= 0;
            wb_CtrlCSR      <= 0;
            wb_csr_data     <= 0;
            wb_wbcommit     <= 0;

            // input for CSR
            wb_wen_mtvec    <= 0;
            wb_wen_mcause   <= 0;
            wb_wen_mstatus  <= 0;
            wb_wen_mepc     <= 0;
            wb_rs1data      <= 0;

            // new add wire for output
            wb_rs1         <= 0;
            wb_rs2         <= 0;
            wb_CtrlOP      <= 0;
            wb_CtrlALUSrc  <= 0;
            wb_CtrlJAL     <= 0;
            wb_imm         <= 0;
            wb_op1          <= 0;
            wb_op2          <= 0;
        end
        else if(stall[4] === 1'b1 && stall[5] === 1'b0) begin
            wb_addr         <= 0;
            wb_inst         <= 0;
            wb_wen          <= 0;
            wb_rd           <= 0;
            wb_data         <= 0;
            wb_result       <= 0;
            wb_CtrlJump     <= 0;
            wb_CtrlJALR     <= 0;
            wb_CtrlLoad     <= 0;
            wb_CtrlCSR      <= 0;
            wb_csr_data     <= 0;
            wb_wbcommit     <= 0;

            // input for CSR
            wb_wen_mtvec    <= 0;
            wb_wen_mcause   <= 0;
            wb_wen_mstatus  <= 0;
            wb_wen_mepc     <= 0;
            wb_rs1data      <= 0;

            // new add wire for output
            wb_rs1         <= 0;
            wb_rs2         <= 0;
            wb_CtrlOP      <= 0;
            wb_CtrlALUSrc  <= 0;
            wb_CtrlJAL     <= 0;
            wb_imm         <= 0;
            wb_op1          <= 0;
            wb_op2          <= 0;
        end
        else if(stall[4] === 1'b0) begin
            wb_addr         <= mem_addr;
            wb_inst         <= mem_inst;
            wb_wen          <= mem_wen;
            wb_rd           <= mem_rd;
            wb_data         <= mem_data;
            wb_result       <= mem_result;
            wb_CtrlJump     <= mem_CtrlJump;
            wb_CtrlJALR     <= mem_CtrlJALR;
            wb_CtrlLoad     <= mem_CtrlLoad;
            wb_CtrlCSR      <= mem_CtrlCSR;
            wb_csr_data     <= mem_csr_data;
            wb_wbcommit     <= mem_wbcommit;

            // input for CSR
            wb_wen_mtvec    <= mem_wen_mtvec;
            wb_wen_mcause   <= mem_wen_mcause;
            wb_wen_mstatus  <= mem_wen_mstatus;
            wb_wen_mepc     <= mem_wen_mepc;
            wb_rs1data      <= mem_rs1data;

            // new add wire for output
            wb_rs1         <= mem_rs1;
            wb_rs2         <= mem_rs2;
            wb_CtrlOP      <= mem_CtrlOP;
            wb_CtrlALUSrc  <= mem_CtrlALUSrc;
            wb_CtrlJAL     <= mem_CtrlJAL;
            wb_imm         <= mem_imm;
            wb_op1          <= mem_op1;
            wb_op2          <= mem_op2;
        end
    end

endmodule
