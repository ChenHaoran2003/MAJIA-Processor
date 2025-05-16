`include "defines.v"

module id_ex (
    input wire                      clk,
    input wire                      rst,
    input wire [5:0]                stall,

    input wire                      id_wen,
    input wire [`REG_NUM_LOG-1:0] id_rd,
    input wire [`DATA_WIDTH-1:0]    id_imm,
    input wire [`ADDR_WIDTH-1:0]    id_addr,
    input wire [`INST_WIDTH-1:0]    id_inst,
    input wire [`CTRLOP_TYPE_LOG-1:0] id_CtrlOP,
    input wire                      id_CtrlALUSrc,
    input wire                      id_CtrlJAL,
    input wire                      id_CtrlJump,
    input wire                      id_CtrlJALR,
    input wire [1:0]                id_CtrlLoad,
    input wire [1:0]                id_CtrlStore,
    input wire                      id_CtrlWantBranch,
    input wire                      id_CtrlSigned,
    input wire                      id_CtrlSignedLoad,
    input wire [1:0]                id_CtrlCSR,
    input wire [`DATA_WIDTH-1:0]    id_rs1data,
    input wire [`DATA_WIDTH-1:0]    id_rs2data,
    input wire [`DATA_WIDTH-1:0]    id_csr_data,
    input wire                      id_wbcommit,

    // input for CSR
    input wire                      id_wen_mtvec,
    input wire                      id_wen_mcause,
    input wire                      id_wen_mstatus,
    input wire                      id_wen_mepc,
    
    // new add wire for output
    input [`REG_NUM_LOG-1:0]        id_rs1,
    input [`REG_NUM_LOG-1:0]        id_rs2,

    output reg                      ex_wen,
    output reg [`REG_NUM_LOG-1:0] ex_rd,
    output reg [`DATA_WIDTH-1:0]    ex_imm,
    output reg [`ADDR_WIDTH-1:0]    ex_addr,
    output reg [`INST_WIDTH-1:0]    ex_inst,
    output reg [`CTRLOP_TYPE_LOG-1:0] ex_CtrlOP,
    output reg                      ex_CtrlALUSrc,
    output reg                      ex_CtrlJAL,
    output reg                      ex_CtrlJump,
    output reg                      ex_CtrlJALR,
    output reg [1:0]                ex_CtrlLoad,
    output reg [1:0]                ex_CtrlStore,
    output reg                      ex_CtrlWantBranch,
    output reg                      ex_CtrlSigned,
    output reg                      ex_CtrlSignedLoad,
    output reg [1:0]                ex_CtrlCSR,
    output reg [`DATA_WIDTH-1:0]    ex_rs1data,
    output reg [`DATA_WIDTH-1:0]    ex_rs2data,
    output reg [`DATA_WIDTH-1:0]    ex_csr_data,
    output reg                      ex_wbcommit,

    // input for CSR
    output reg                      ex_wen_mtvec,
    output reg                      ex_wen_mcause,
    output reg                      ex_wen_mstatus,
    output reg                      ex_wen_mepc,

    // new add wire for output
    output reg [`REG_NUM_LOG-1:0]        ex_rs1,
    output reg [`REG_NUM_LOG-1:0]        ex_rs2
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ex_wen          <= 0;
            ex_rd           <= 0;
            ex_imm          <= 0;
            ex_addr         <= 0;
            ex_inst         <= 0;
            ex_CtrlOP       <= 0;
            ex_CtrlALUSrc   <= 0;
            ex_CtrlJAL      <= 0;
            ex_CtrlJump     <= 0;
            ex_CtrlJALR     <= 0;
            ex_CtrlLoad     <= 0;
            ex_CtrlStore    <= 0;
            ex_CtrlWantBranch <= 0;
            ex_CtrlSigned   <= 0;
            ex_CtrlSignedLoad <= 0;
            ex_CtrlCSR      <= 0;
            ex_rs1data      <= 0;
            ex_rs2data      <= 0;
            ex_csr_data     <= 0;
            ex_wbcommit     <= 0;

            // input for CSR
            ex_wen_mtvec    <= 0;
            ex_wen_mcause   <= 0;
            ex_wen_mstatus  <= 0;
            ex_wen_mepc     <= 0;

            // new add wire for output
            ex_rs1          <= 0;
            ex_rs2          <= 0;
        end
        else if(stall[2] === 1'b1 && stall[3] === 1'b0) begin
            ex_wen          <= 0;
            ex_rd           <= 0;
            ex_imm          <= 0;
            ex_addr         <= 0;
            ex_inst         <= 0;
            ex_CtrlOP       <= 0;
            ex_CtrlALUSrc   <= 0;
            ex_CtrlJAL      <= 0;
            ex_CtrlJump     <= 0;
            ex_CtrlJALR     <= 0;
            ex_CtrlLoad     <= 0;
            ex_CtrlStore    <= 0;
            ex_CtrlWantBranch <= 0;
            ex_CtrlSigned   <= 0;
            ex_CtrlSignedLoad <= 0;
            ex_CtrlCSR      <= 0;
            ex_rs1data      <= 0;
            ex_rs2data      <= 0;
            ex_csr_data     <= 0;
            ex_wbcommit     <= 0;

            // input for CSR
            ex_wen_mtvec    <= 0;
            ex_wen_mcause   <= 0;
            ex_wen_mstatus  <= 0;
            ex_wen_mepc     <= 0;

            // new add wire for output
            ex_rs1          <= 0;
            ex_rs2          <= 0;
        end
        else if(stall[2] === 1'b0) begin
            ex_wen          <= id_wen;
            ex_rd           <= id_rd;
            ex_imm          <= id_imm;
            ex_addr         <= id_addr;
            ex_inst         <= id_inst;
            ex_CtrlOP       <= id_CtrlOP;
            ex_CtrlALUSrc   <= id_CtrlALUSrc;
            ex_CtrlJAL      <= id_CtrlJAL;
            ex_CtrlJump     <= id_CtrlJump;
            ex_CtrlJALR     <= id_CtrlJALR;
            ex_CtrlLoad     <= id_CtrlLoad;
            ex_CtrlStore    <= id_CtrlStore;
            ex_CtrlWantBranch <= id_CtrlWantBranch;
            ex_CtrlSigned   <= id_CtrlSigned;
            ex_CtrlSignedLoad <= id_CtrlSignedLoad;
            ex_CtrlCSR      <= id_CtrlCSR;
            ex_rs1data      <= id_rs1data;
            ex_rs2data      <= id_rs2data;
            ex_csr_data     <= id_csr_data;
            ex_wbcommit     <= id_wbcommit;

            // input for CSR
            ex_wen_mtvec    <= id_wen_mtvec;
            ex_wen_mcause   <= id_wen_mcause;
            ex_wen_mstatus  <= id_wen_mstatus;
            ex_wen_mepc     <= id_wen_mepc;

            // new add wire for output
            ex_rs1          <= id_rs1;
            ex_rs2          <= id_rs2;
        end
    end

endmodule
