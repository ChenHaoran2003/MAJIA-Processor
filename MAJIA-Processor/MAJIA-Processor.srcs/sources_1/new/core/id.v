`include "defines.v"

module id(
    input clk,
    input rst,

    input [`ADDR_WIDTH-1:0] addr,
    input [`INST_WIDTH-1:0] inst,
    input [`DATA_WIDTH-1:0] rs1data_from_regs,
    input [`DATA_WIDTH-1:0] rs2data_from_regs,
    input [`DATA_WIDTH-1:0] rsdata_csr_from_csrfile,
    input write_regs_from_ex,
    input [`REG_NUM_LOG-1:0] write_regs_addr_from_ex,
    input [`DATA_WIDTH-1:0] write_regs_data_from_ex,
    input write_regs_from_mem,
    input [`REG_NUM_LOG-1:0] write_regs_addr_from_mem,
    input [`DATA_WIDTH-1:0] write_regs_data_from_mem,
    input write_regs_from_wb,
    input [`REG_NUM_LOG-1:0] write_regs_addr_from_wb,
    input [`DATA_WIDTH-1:0] write_regs_data_from_wb,
    input pre_inst_is_load,

    output stall_req_1,
    output stall_req_2,
    output wen,
    output wen_csr_mtvec,
    output wen_csr_mcause,
    output wen_csr_mstatus,
    output wen_csr_mepc,
    output [`REG_NUM_LOG-1:0] rd,
    output [`REG_NUM_LOG-1:0] rs1,
    output [`REG_NUM_LOG-1:0] rs2,
    output [`CSR_IDX_LEN-1:0] rs_csr,
    output [`DATA_WIDTH-1:0] imm,
    output [`CTRLOP_TYPE_LOG-1:0] CtrlOP,
    output CtrlALUSrc,
    output CtrlJAL,
    output CtrlJump,
    output CtrlJALR,
    output [1:0] CtrlLoad,
    output [1:0] CtrlStore,
    output CtrlWantBranch,
    output CtrlBranch,
    output CtrlSigned,
    output CtrlSignedLoad,
    output [1:0] CtrlCSR,
    output [`ADDR_WIDTH-1:0] jump_result,
    output reg [`DATA_WIDTH-1:0] rs1data,
    output reg [`DATA_WIDTH-1:0] rs2data
);

    wire read_rs1;
    wire read_rs2;

    wire [6:0] opcode = inst[6:0];
    wire [2:0] fun3 = inst[14:12];
    wire [6:0] fun7 = inst[31:25];
    wire [5:0] fun6 = inst[31:26];
    wire [11:0] fun12 = inst[31:20];
    wire [11:0] csr_idx = inst[31:20];
    wire stop;
    wire [`DATA_WIDTH-1:0] imm_i;
    wire [`DATA_WIDTH-1:0] imm_u;
    wire [`DATA_WIDTH-1:0] imm_j;
    wire [`DATA_WIDTH-1:0] imm_s;
    wire [`DATA_WIDTH-1:0] imm_b;
    wire [5:0] imm_shamt;

    // i type: addi jalr
    // u type: auipc lui 
    // j type: jal
    // b type: bltu

    assign rs1 = (`INST_LUI) ? 5'b0 :
                 (`INST_ECALL) ? 5'd15 : inst[19:15];
    assign rs2 = inst[24:20];

    assign read_rs1 = `INST_ADDI || `INST_JALR || `INST_SW || `INST_LW || `INST_BLTU || `INST_BGEU || `INST_SLLI || `INST_ADD
        || `INST_XOR || `INST_OR || `INST_SLTIU || `INST_BEQ || `INST_SB || `INST_SLL || `INST_LBU
        || `INST_XORI || `INST_ANDI || `INST_SLTU || `INST_AND || `INST_SRAI || `INST_BNE || `INST_BGE
        || `INST_SUB || `INST_BLT || `INST_SRLI || `INST_LH || `INST_LHU || `INST_BLT || `INST_SRA
        || `INST_SRL || `INST_ORI || `INST_LB || `INST_SH || `INST_SLT || `INST_ECALL || `INST_CSRRW || `INST_CSRRS;

    assign read_rs2 = `INST_SW || `INST_BLTU || `INST_BGEU || `INST_ADD || `INST_XOR || `INST_OR || `INST_BEQ
        || `INST_SB || `INST_SLL || `INST_SLTU || `INST_AND || `INST_BNE || `INST_BGE || `INST_SUB
        || `INST_BLT || `INST_BLT || `INST_SRA || `INST_SRL || `INST_SH || `INST_SLT;

    reg stall_for_load_read_rs1;
    reg stall_for_load_read_rs2;

    always @(*) begin
        if(rst) begin
            rs1data = 0;
            stall_for_load_read_rs1 = 0;
        end
        else begin
            if(rs1 != 0) begin
                // 判断rs1是否有load相关，因为load系列指令只会读rs1，因此无�?判断rs2 更新：这个判断是错的，load-use�?要判断那些寄存器是在use阶段可能�?要读，�?�use阶段rs1或rs2都可能要用到�?
                if(read_rs1 === 1'b1 && pre_inst_is_load === 1'b1 && write_regs_addr_from_ex == rs1) begin
                    rs1data = 0; // this rs1data will not be used
                    stall_for_load_read_rs1 = 1;
                end
                else if(read_rs1 === 1'b1 && write_regs_from_ex === 1'b1 && write_regs_addr_from_ex === rs1) begin
                    rs1data = write_regs_data_from_ex;
                    stall_for_load_read_rs1 = 0;
                end
                else if(read_rs1 === 1'b1 && write_regs_from_mem === 1'b1 && write_regs_addr_from_mem === rs1) begin
                    rs1data = write_regs_data_from_mem;
                    stall_for_load_read_rs1 = 0;
                end
                else if(read_rs1 === 1'b1 && write_regs_from_wb === 1'b1 && write_regs_addr_from_wb === rs1) begin
                    rs1data = write_regs_data_from_wb;
                    stall_for_load_read_rs1 = 0;
                end
                else if(read_rs1 === 1'b1) begin
                    rs1data = rs1data_from_regs;
                    stall_for_load_read_rs1 = 0;
                end
                else begin
                    rs1data = 0;
                    stall_for_load_read_rs1 = 0;
                end
            end
            else begin
                rs1data = 0;
                stall_for_load_read_rs1 = 0;
            end
        end
    end

    always @(*) begin
        if(rst) begin
            rs2data = 0;
            stall_for_load_read_rs2 = 0;
        end
        else begin
            if(rs2 != 0) begin
                if(read_rs2 === 1'b1 && pre_inst_is_load === 1'b1 && write_regs_addr_from_ex == rs2) begin
                    rs2data = 0; // this rs2data will not be used
                    stall_for_load_read_rs2 = 1;
                end
                else if(read_rs2 === 1'b1 && write_regs_from_ex === 1'b1 && write_regs_addr_from_ex === rs2) begin
                    rs2data = write_regs_data_from_ex;
                    stall_for_load_read_rs2 = 0;
                end
                else if(read_rs2 === 1'b1 && write_regs_from_mem === 1'b1 && write_regs_addr_from_mem === rs2) begin
                    rs2data = write_regs_data_from_mem;
                    stall_for_load_read_rs2 = 0;
                end
                else if(read_rs2 === 1'b1 && write_regs_from_wb === 1'b1 && write_regs_addr_from_wb === rs2) begin
                    rs2data = write_regs_data_from_wb;
                    stall_for_load_read_rs2 = 0;
                end
                else if(read_rs2 === 1'b1) begin
                    rs2data = rs2data_from_regs;
                    stall_for_load_read_rs2 = 0;
                end
                else begin
                    rs2data = 0;
                    stall_for_load_read_rs2 = 0;
                end
            end
            else begin
                rs2data = 0;
                stall_for_load_read_rs2 = 0;
            end
        end
    end

    wire signed [`DATA_WIDTH-1:0] signed_rs1data = $signed(rs1data);
    wire signed [`DATA_WIDTH-1:0] signed_rs2data = $signed(rs2data);

    assign rd = inst[11:7];
    assign imm_i = {{20{inst[31]}}, inst[31:20]};
    assign imm_u = {inst[31:12], {12{1'b0}}};
    assign imm_j = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
    assign imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    assign imm_b = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign imm_shamt = inst[25:20];
    
    wire is_i_type;
    wire is_u_type;
    wire is_j_type;
    wire is_s_type;
    wire is_b_type;
    wire is_shamt_type;

    assign is_i_type = (`INST_ADDI || `INST_JALR || `INST_LW || `INST_SLTIU || `INST_LBU || `INST_XORI
                     || `INST_ANDI || `INST_LH || `INST_LHU || `INST_ORI || `INST_LB);
    assign is_u_type = (`INST_AUIPC || `INST_LUI);
    assign is_j_type = (`INST_JAL);
    assign is_s_type = (`INST_SW || `INST_SB || `INST_SH);
    assign is_b_type = (`INST_BLTU || `INST_BGEU || (`INST_BEQ)
                     || (`INST_BNE) || (`INST_BGE)
                     || (`INST_BLT));
    assign is_shamt_type = ((`INST_SLLI) || (`INST_SRAI)
                     || (`INST_SRLI));

    assign wen = (((`INST_ADDI) || `INST_AUIPC || `INST_LUI
                 || `INST_JAL || `INST_JALR || (`INST_LW)
                 || `INST_SLLI || `INST_ADD || `INST_XOR
                 || `INST_OR || (`INST_SLTIU)
                 || (`INST_SLL) || (`INST_XORI)
                 || (`INST_ANDI) || (`INST_SRAI)
                 || (`INST_SLTU) || (`INST_AND)
                 || (`INST_SUB) || (`INST_SRLI)
                 || (`INST_LH) || (`INST_LHU)
                 || (`INST_SRA)
                 || (`INST_SRL) || `INST_LBU || `INST_ORI || `INST_LB || `INST_SLT || `INST_CSRRW || `INST_CSRRS) && inst != `INST_NOP);

    assign wen_csr_mtvec = ((`INST_CSRRW || `INST_CSRRS) && csr_idx === `CSR_IDX_LEN'h305);

    assign wen_csr_mcause = `INST_ECALL || ((`INST_CSRRW || `INST_CSRRS) && csr_idx === `CSR_IDX_LEN'h342);

    assign wen_csr_mstatus = `INST_ECALL || ((`INST_CSRRW || `INST_CSRRS) && csr_idx === `CSR_IDX_LEN'h300);

    assign wen_csr_mepc = `INST_ECALL || ((`INST_CSRRW || `INST_CSRRS) && csr_idx === `CSR_IDX_LEN'h341);

    assign CtrlCSR = `INST_CSRRW ? 2'b01 :
                    `INST_CSRRS ? 2'b10 : 0;

    assign rs_csr = (`INST_CSRRW || `INST_CSRRS) ? csr_idx :
                    `INST_ECALL ? `CSR_IDX_LEN'h305 :
                    `INST_MRET ? `CSR_IDX_LEN'h341 : 0;

    assign imm =    is_i_type ? imm_i :
                    is_u_type ? imm_u :
                    is_j_type ? imm_j :
                    is_s_type ? imm_s :
                    is_b_type ? imm_b :
                    is_shamt_type ? {{26{1'b0}}, imm_shamt} : 32'b0;

    assign CtrlOP = (`INST_AUIPC || (`INST_ADDI) || `INST_JAL
                 || `INST_JALR || `INST_SW || (`INST_LW)
                 || `INST_LUI || (`INST_ADD)
                 || (`INST_SB) || (`INST_LBU)
                 || (`INST_LH) || (`INST_LHU) || `INST_LB || `INST_SH) ? `OP_ADD :
                    
                    ((`INST_SLLI) || (`INST_SLL)) ? `OP_SLL :
                    
                    ((`INST_BLTU) || (`INST_SLTIU)
                 || (`INST_SLTU) || (`INST_BLT) || `INST_SLT) ? `OP_LT :
                    
                    ((`INST_BGEU) || (`INST_BGE)) ? `OP_GE :
                    
                    ((`INST_XOR) || (`INST_XORI)) ? `OP_XOR :
                    
                    (`INST_OR || `INST_ORI) ? `OP_OR :
                    
                    (`INST_BEQ) ? `OP_EQ :
                    
                    ((`INST_ANDI) || (`INST_AND)) ? `OP_AND :
                    
                    ((`INST_SRAI) || (`INST_SRA)) ? `OP_SRA :
                    
                    (`INST_BNE) ? `OP_NE :
                    
                    (`INST_SUB) ? `OP_SUB :
                    
                    ((`INST_SRLI) || (`INST_SRL)) ? `OP_SRL : 4'b0;


    assign CtrlJAL = (`INST_AUIPC || `INST_JAL); // operand1 = pc

    assign CtrlALUSrc = (`INST_AUIPC || (`INST_ADDI) || `INST_JALR
                 || `INST_JAL || `INST_SW
                || (`INST_LW)
                 || (`INST_SLLI)
                || (`INST_SB)
                 || (`INST_LBU) || (`INST_XORI)
                 || (`INST_ANDI) || (`INST_SRAI)
                 || `INST_LUI
                 || (`INST_SRLI) || (`INST_SLTIU)
                 || (`INST_LH) || (`INST_LHU) || `INST_ORI || `INST_LB || `INST_SH);

    assign CtrlJump = (`INST_JAL || `INST_ECALL || `INST_MRET);

    // assign stall_req = (wen && (inst != `INST_NOP) || CtrlJump || CtrlJALR || CtrlWantBranch || CtrlStore != 0);
    assign stall_req_1 = CtrlJump || CtrlJALR || (CtrlWantBranch && CtrlBranch);    // stall for branch or jump, so stall = 000011
    assign stall_req_2 = stall_for_load_read_rs1 || stall_for_load_read_rs2;                                            // stall for load-use hazard, so stall = 000111

    assign CtrlBranch = stall_req_2 ? 0 :
                        `INST_BGEU ? rs1data >= rs2data :
                        `INST_BLTU ? rs1data < rs2data :
                        `INST_BGE ? signed_rs1data >= signed_rs2data :
                        `INST_BLT ? signed_rs1data < signed_rs2data :
                        `INST_BNE ? rs1data != rs2data :
                        `INST_BEQ ? rs1data === rs2data : 0;

    assign jump_result = (`INST_JAL || CtrlBranch) ? addr + imm :
                        (CtrlJALR) ? rs1data + imm :
                        (`INST_ECALL || `INST_MRET) ? rsdata_csr_from_csrfile : 0;

    assign CtrlJALR = (`INST_JALR);

    assign CtrlStore = (`INST_SW) ? `LS_W :
                        (`INST_SB) ? `LS_B :
                        (`INST_SH) ? `LS_H : 2'b0;

    assign CtrlLoad = (`INST_LW) ? `LS_W :
                        (`INST_LBU || `INST_LB) ? `LS_B :
                        (`INST_LH) ? `LS_H :
                        (`INST_LHU) ? `LS_H : 2'b0;

    assign CtrlWantBranch = ((`INST_BLTU) || (`INST_BGEU)
                         || (`INST_BNE) || (`INST_BGE)
                         || (`INST_BLT) || (`INST_BEQ));

    assign CtrlSigned = (`INST_BLT || `INST_BGE || `INST_SLT);

    assign CtrlSignedLoad = (`INST_LH || `INST_LB);

    // assign in_ready = ~(`INST_JAL || `INST_JALR || `INST_BEQ || (wen && (inst != `INST_NOP)) || ~out_ready);

    assign stop = (`INST_EBREAK);

    always @(stop) begin
        if(stop === 1'b1) begin
            $display("stop");
        end
    end

endmodule
