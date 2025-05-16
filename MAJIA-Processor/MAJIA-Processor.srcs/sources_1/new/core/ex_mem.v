`include "defines.v"

module ex_mem (
    input wire                      clk,
    input wire                      rst,
    input wire [5:0]                stall,
    
    input wire [`ADDR_WIDTH-1:0]    ex_addr,
    input wire [`INST_WIDTH-1:0]    ex_inst,
    input wire [`DATA_WIDTH-1:0]    ex_result,
    input wire                      ex_wen,
    input wire [`REG_NUM_LOG-1:0]   ex_rd,
    input wire                      ex_CtrlJump,
    input wire                      ex_CtrlJALR,
    input wire [1:0]                ex_CtrlLoad,
    input wire [1:0]                ex_CtrlStore,
    input wire                      ex_CtrlWantBranch,
    input wire                      ex_CtrlBranch,
    input wire                      ex_CtrlSignedLoad,
    input wire [1:0]                ex_CtrlCSR,
    input wire [`DATA_WIDTH-1:0]    ex_rs1data,
    input wire [`DATA_WIDTH-1:0]    ex_rs2data,
    input wire [`DATA_WIDTH-1:0]    ex_csr_data,
    input wire                      ex_wbcommit,

    // input for CSR
    input wire                      ex_wen_mtvec,
    input wire                      ex_wen_mcause,
    input wire                      ex_wen_mstatus,
    input wire                      ex_wen_mepc,

    // new add wire for output
    input wire [`REG_NUM_LOG-1:0]     ex_rs1,
    input wire [`REG_NUM_LOG-1:0]     ex_rs2,
    input wire [`CTRLOP_TYPE_LOG-1:0] ex_CtrlOP,
    input wire                        ex_CtrlALUSrc,
    input wire                        ex_CtrlJAL,
    input wire [`DATA_WIDTH-1:0]      ex_imm,
    input wire [`DATA_WIDTH-1:0]    ex_op1,
    input wire [`DATA_WIDTH-1:0]    ex_op2,

    output reg [`ADDR_WIDTH-1:0]    mem_addr,
    output reg [`INST_WIDTH-1:0]    mem_inst,
    output reg [`DATA_WIDTH-1:0]    mem_result,
    output reg                      mem_wen,
    output reg [`REG_NUM_LOG-1:0]   mem_rd,
    output reg                      mem_CtrlJump,
    output reg                      mem_CtrlJALR,
    output reg [1:0]                mem_CtrlLoad,
    output reg [1:0]                mem_CtrlStore,
    output reg                      mem_CtrlWantBranch,
    output reg                      mem_CtrlBranch,
    output reg                      mem_CtrlSignedLoad,
    output reg [1:0]                mem_CtrlCSR,
    output reg [`DATA_WIDTH-1:0]    mem_rs1data,
    output reg [`DATA_WIDTH-1:0]    mem_rs2data,
    output reg [`DATA_WIDTH-1:0]    mem_csr_data,
    output reg                      mem_wbcommit,
    
    // input for CSR
    output reg                      mem_wen_mtvec,
    output reg                      mem_wen_mcause,
    output reg                      mem_wen_mstatus,
    output reg                      mem_wen_mepc,

    // new add wire for output
    output reg [`REG_NUM_LOG-1:0]     mem_rs1,
    output reg [`REG_NUM_LOG-1:0]     mem_rs2,
    output reg [`CTRLOP_TYPE_LOG-1:0] mem_CtrlOP,
    output reg                        mem_CtrlALUSrc,
    output reg                        mem_CtrlJAL,
    output reg [`DATA_WIDTH-1:0]      mem_imm,
    output reg [`DATA_WIDTH-1:0]    mem_op1,
    output reg [`DATA_WIDTH-1:0]    mem_op2
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mem_addr        <= 0;
            mem_inst        <= 0;
            mem_result      <= 0;
            mem_CtrlBranch  <= 0;
            mem_wen         <= 0;
            mem_rd          <= 0;
            mem_CtrlJump    <= 0;
            mem_CtrlJALR    <= 0;
            mem_CtrlLoad    <= 0;
            mem_CtrlStore   <= 0;
            mem_CtrlWantBranch  <= 0;
            mem_CtrlSignedLoad  <= 0;
            mem_CtrlCSR     <= 0;
            mem_rs1data     <= 0;
            mem_rs2data     <= 0;
            mem_csr_data    <= 0;
            mem_wbcommit    <= 0;

            // input for CSR
            mem_wen_mtvec   <= 0;
            mem_wen_mcause  <= 0;
            mem_wen_mstatus <= 0;
            mem_wen_mepc    <= 0;

            // new add wire for output
            mem_rs1         <= 0;
            mem_rs2         <= 0;
            mem_CtrlOP      <= 0;
            mem_CtrlALUSrc  <= 0;
            mem_CtrlJAL     <= 0;
            mem_imm         <= 0;
            mem_op1         <= 0;
            mem_op2         <= 0;
        end
        else if(stall[3] === 1'b1 && stall[4] === 1'b0) begin
            mem_addr        <= 0;
            mem_inst        <= 0;
            mem_result      <= 0;
            mem_CtrlBranch  <= 0;
            mem_wen         <= 0;
            mem_rd          <= 0;
            mem_CtrlJump    <= 0;
            mem_CtrlJALR    <= 0;
            mem_CtrlLoad    <= 0;
            mem_CtrlStore   <= 0;
            mem_CtrlWantBranch  <= 0;
            mem_CtrlSignedLoad  <= 0;
            mem_CtrlCSR     <= 0;
            mem_rs1data     <= 0;
            mem_rs2data     <= 0;
            mem_csr_data    <= 0;
            mem_wbcommit    <= 0;

            // input for CSR
            mem_wen_mtvec   <= 0;
            mem_wen_mcause  <= 0;
            mem_wen_mstatus <= 0;
            mem_wen_mepc    <= 0;

            // new add wire for output
            mem_rs1         <= 0;
            mem_rs2         <= 0;
            mem_CtrlOP      <= 0;
            mem_CtrlALUSrc  <= 0;
            mem_CtrlJAL     <= 0;
            mem_imm         <= 0;
            mem_op1         <= 0;
            mem_op2         <= 0;
        end
        else if(stall[3] === 1'b0) begin
            mem_addr        <= ex_addr;
            mem_inst        <= ex_inst;
            mem_result      <= ex_result;
            mem_CtrlBranch  <= ex_CtrlBranch;
            mem_wen         <= ex_wen;
            mem_rd          <= ex_rd;
            mem_CtrlJump    <= ex_CtrlJump;
            mem_CtrlJALR    <= ex_CtrlJALR;
            mem_CtrlLoad    <= ex_CtrlLoad;
            mem_CtrlStore   <= ex_CtrlStore;
            mem_CtrlWantBranch  <= ex_CtrlWantBranch;
            mem_CtrlSignedLoad  <= ex_CtrlSignedLoad;
            mem_CtrlCSR     <= ex_CtrlCSR;
            mem_rs1data     <= ex_rs1data;
            mem_rs2data     <= ex_rs2data;
            mem_csr_data    <= ex_csr_data;
            mem_wbcommit    <= ex_wbcommit;

            // input for CSR
            mem_wen_mtvec   <= ex_wen_mtvec;
            mem_wen_mcause  <= ex_wen_mcause;
            mem_wen_mstatus <= ex_wen_mstatus;
            mem_wen_mepc    <= ex_wen_mepc;

            // new add wire for output
            mem_rs1         <= ex_rs1;
            mem_rs2         <= ex_rs2;
            mem_CtrlOP      <= ex_CtrlOP;
            mem_CtrlALUSrc  <= ex_CtrlALUSrc;
            mem_CtrlJAL     <= ex_CtrlJAL;
            mem_imm         <= ex_imm;
            mem_op1         <= ex_op1;
            mem_op2         <= ex_op2;
        end
    end
    
endmodule
