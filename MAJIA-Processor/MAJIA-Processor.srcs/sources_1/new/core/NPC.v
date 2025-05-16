`include "defines.v"

module NPC(
    input clk,
    input rst,

    // /* inst wishbone */
    // input   [`DATA_WIDTH-1:0]   iwishbone_data_i,
    // input                       iwishbone_ack_i,
    // output  [`ADDR_WIDTH-1:0]   iwishbone_addr_o,
    // output  [`DATA_WIDTH-1:0]   iwishbone_data_o,
    // output                      iwishbone_we_o,
    // output  [3:0]               iwishbone_sel_o,
    // output                      iwishbone_stb_o,
    // output                      iwishbone_cyc_o,

    /* data wishbone */
    input   [`DATA_WIDTH-1:0]   dwishbone_data_i,
    input                       dwishbone_ack_i,
    output  [`ADDR_WIDTH-1:0]   dwishbone_addr_o,
    output  [`DATA_WIDTH-1:0]   dwishbone_data_o,
    output                      dwishbone_we_o,
    output  [3:0]               dwishbone_sel_o,
    output                      dwishbone_stb_o,
    output                      dwishbone_cyc_o
);

    wire [`REG_NUM_LOG-1:0] id_ex_rs1_o;
    wire [`REG_NUM_LOG-1:0] id_ex_rs2_o;

    wire [`REG_NUM_LOG-1:0]     ex_mem_rs1_o;
    wire [`REG_NUM_LOG-1:0]     ex_mem_rs2_o;
    wire [`CTRLOP_TYPE_LOG-1:0] ex_mem_CtrlOP_o;
    wire                        ex_mem_CtrlALUSrc_o;
    wire                        ex_mem_CtrlJAL_o;
    wire [`DATA_WIDTH-1:0]      ex_mem_imm_o;

    wire [`REG_NUM_LOG-1:0]     mem_wb_rs1_o;
    wire [`REG_NUM_LOG-1:0]     mem_wb_rs2_o;
    wire [`CTRLOP_TYPE_LOG-1:0] mem_wb_CtrlOP_o;
    wire                        mem_wb_CtrlALUSrc_o;
    wire                        mem_wb_CtrlJAL_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_imm_o;

    wire [`DATA_WIDTH-1:0]      ex_op1_o;
    wire [`DATA_WIDTH-1:0]      ex_op2_o;
    wire [`DATA_WIDTH-1:0]      ex_mem_op1_o;
    wire [`DATA_WIDTH-1:0]      ex_mem_op2_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_op1_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_op2_o;

    // u_ifu --> u_if_id
    wire [`ADDR_WIDTH-1:0]  ifu_addr_o;
    wire [`ADDR_WIDTH-1:0]  ifu_addr_to_id_o;
    wire [`INST_WIDTH-1:0]  ifu_inst_o;
    wire                    ifu_stall_req_o;
    wire                    ifu_wbcommit_o;

    // u_meminst
    wire    [`INST_WIDTH-1:0]   u_meminst_o_data;

    // u_if_id --> u_id or u_if_id --> u_id_ex
    wire [`ADDR_WIDTH-1:0]  if_id_addr_o;       // u_if_id --> u_id and u_id_ex
    wire [`INST_WIDTH-1:0]  if_id_inst_o;
    wire                    if_id_wbcommit_o;   // u_if_id --> u_id_ex

    // u_id --> u_id_ex or u_id --> u_regs or u_id --> u_if_id
    wire                        id_stall_req_1_o;
    wire                        id_stall_req_2_o;
    wire                        id_wen_o;
    wire                        id_wen_csr_mtvec_o;
    wire                        id_wen_csr_mcause_o;
    wire                        id_wen_csr_mstatus_o;
    wire                        id_wen_csr_mepc_o;
    wire [`REG_NUM_LOG-1:0]     id_rd_o;
    wire [`REG_NUM_LOG-1:0]     id_rs1_o;
    wire [`REG_NUM_LOG-1:0]     id_rs2_o;
    wire [`CSR_IDX_LEN-1:0]     id_rs_csr_o;
    wire [`DATA_WIDTH-1:0]      id_imm_o;
    wire [`ADDR_WIDTH-1:0]      id_addr_o;
    wire [`INST_WIDTH-1:0]      id_inst_o;
    wire [`CTRLOP_TYPE_LOG-1:0] id_CtrlOP_o;
    wire                        id_CtrlALUSrc_o;
    wire                        id_CtrlJAL_o;
    wire                        id_CtrlJump_o;
    wire                        id_CtrlJALR_o;
    wire [1:0]                  id_CtrlLoad_o;
    wire [1:0]                  id_CtrlStore_o;
    wire                        id_CtrlWantBranch_o;
    wire                        id_CtrlBranch_o;
    wire                        id_CtrlSigned_o;
    wire                        id_CtrlSignedLoad_o;
    wire [1:0]                  id_CtrlCSR_o;
    wire [`ADDR_WIDTH-1:0]      jump_result_from_id;
    wire [`DATA_WIDTH-1:0]      id_rs1data_o;
    wire [`DATA_WIDTH-1:0]      id_rs2data_o;
    // wire [`DATA_WIDTH-1:0]      id_csr_data_o;

    // u_regs --> u_id_ex
    wire [`DATA_WIDTH-1:0]      regs_rs1data_o;
    wire [`DATA_WIDTH-1:0]      regs_rs2data_o;
    wire [`DATA_WIDTH-1:0]      regs_rsdata_csr_o;

    // u_csrfile --> u_regs
    wire [`DATA_WIDTH-1:0]      csrfile_csr_data_o;

    // u_id_ex --> u_ex or u_id_ex --> u_if_id or u_id_ex --> u_ex_mem
    wire                        id_ex_wen_o;
    wire [`REG_NUM_LOG-1:0]     id_ex_rd_o;
    wire [`DATA_WIDTH-1:0]      id_ex_imm_o;
    wire [`ADDR_WIDTH-1:0]      id_ex_addr_o;
    wire [`INST_WIDTH-1:0]      id_ex_inst_o;
    wire [`CTRLOP_TYPE_LOG-1:0] id_ex_CtrlOP_o;
    wire                        id_ex_CtrlALUSrc_o;
    wire                        id_ex_CtrlJAL_o;
    wire                        id_ex_CtrlJump_o;
    wire                        id_ex_CtrlJALR_o;
    wire [1:0]                  id_ex_CtrlLoad_o;       // u_id_ex --> u_ex_mem
    wire [1:0]                  id_ex_CtrlStore_o;      // u_id_ex --> u_ex_mem
    wire                        id_ex_CtrlWantBranch_o; // u_id_ex --> u_ex and u_ex_mem
    wire                        id_ex_CtrlSigned_o;
    wire                        id_ex_CtrlSignedLoad_o; // u_id_ex --> u_ex_mem
    wire [1:0]                  id_ex_CtrlCSR_o;
    wire [`DATA_WIDTH-1:0]      id_ex_rs1data_o;
    wire [`DATA_WIDTH-1:0]      id_ex_rs2data_o;        // u_id_ex --> u_ex and u_ex_mem
    wire [`DATA_WIDTH-1:0]      id_ex_csr_data_o;
    wire                        id_ex_wbcommit_o;
    wire                        id_ex_wen_csr_mtvec_o;
    wire                        id_ex_wen_csr_mcause_o;
    wire                        id_ex_wen_csr_mstatus_o;
    wire                        id_ex_wen_csr_mepc_o;

    // u_ex --> u_ex_mem or u_ex --> u_id_ex
    wire                        ex_stall_req_o;
    wire [`DATA_WIDTH-1:0]      ex_result_o;
    wire                        ex_CtrlBranch_o;

    // u_ex_mem --> u_memdata or u_ex_mem --> u_mem_wb or u_ex_mem --> u_id_ex
    wire [`ADDR_WIDTH-1:0]      ex_mem_addr_o;          // u_ex_mem --> u_mem_wb
    wire [`INST_WIDTH-1:0]      ex_mem_inst_o;          // u_ex_mem --> u_mem_wb
    wire [`DATA_WIDTH-1:0]      ex_mem_result_o;
    wire                        ex_mem_CtrlBranch_o;
    wire                        ex_mem_wen_o;           // u_ex_mem --> u_mem_wb
    wire [`REG_NUM_LOG-1:0]     ex_mem_rd_o;            // u_ex_mem --> u_mem_wb
    wire                        ex_mem_CtrlJump_o;      // u_ex_mem --> u_mem_wb
    wire                        ex_mem_CtrlJALR_o;      // u_ex_mem --> u_mem_wb
    wire [1:0]                  ex_mem_CtrlLoad_o;      // u_ex_mem --> u_memdata and u_mem_wb
    wire [1:0]                  ex_mem_CtrlStore_o;
    wire                        ex_mem_CtrlWantBranch_o;
    wire                        ex_mem_CtrlSignedLoad_o;
    wire [1:0]                  ex_mem_CtrlCSR_o;
    wire [`DATA_WIDTH-1:0]      ex_mem_rs1data_o;
    wire [`DATA_WIDTH-1:0]      ex_mem_rs2data_o;
    wire [`DATA_WIDTH-1:0]      ex_mem_csr_data_o;
    wire                        ex_mem_wbcommit_o;      // u_ex_mem --> u_mem_wb
    wire                        ex_mem_wen_csr_mtvec_o;
    wire                        ex_mem_wen_csr_mcause_o;
    wire                        ex_mem_wen_csr_mstatus_o;
    wire                        ex_mem_wen_csr_mepc_o;

    // u_ls
    wire                        u_ls_o_ce;
    wire    [`ADDR_WIDTH-1:0]   u_ls_o_addr;
    wire    [`DATA_WIDTH-1:0]   u_ls_o_data_to_memdata;
    wire    [`DATA_WIDTH-1:0]   u_ls_o_data_from_memdata;
    wire    [3:0]               u_ls_o_sel;
    wire                        u_ls_o_we;
    wire                        u_ls_o_stall;

    // u_memdata --> u_mem_wb
    wire                        memdata_stall_req_o;
    wire [`DATA_WIDTH-1:0]      memdata_data_out_o;

    // u_mem_wb --> u_regs or u_mem_wb --> u_register or u_mem_wb --> u_ex_mem or u_mem_wb --> u_ifu
    wire                        mem_wb_wen_o;
    wire [`REG_NUM_LOG-1:0]     mem_wb_rd_o;
    wire [1:0]                  mem_wb_CtrlLoad_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_data_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_result_o;        // u_mem_wb --> u_ifu
    wire                        mem_wb_CtrlJump_o;      // u_mem_wb --> u_ifu
    wire                        mem_wb_CtrlJALR_o;      // u_mem_wb --> u_ifu
    wire                        mem_wb_CtrlWantBranch_o;// u_mem_wb --> u_ifu
    wire                        mem_wb_CtrlBranch_o;    // u_mem_wb --> u_ifu
    wire [1:0]                  mem_wb_CtrlCSR_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_csr_data_o;
    wire                        mem_wb_wbcommit_o;      // u_mem_wb --> u_register
    wire [`ADDR_WIDTH-1:0]      mem_wb_addr_o;          // u_mem_wb --> u_register
    wire [`INST_WIDTH-1:0]      mem_wb_inst_o;
    wire                        mem_wb_wen_csr_mtvec_o;
    wire                        mem_wb_wen_csr_mcause_o;
    wire                        mem_wb_wen_csr_mstatus_o;
    wire                        mem_wb_wen_csr_mepc_o;
    wire [`DATA_WIDTH-1:0]      mem_wb_rs1data_o;

    // u_ctrl
    wire [5:0]                  stall_from_ctrl;

    // u_register --> wbcommit_fun
    wire                        register_commit_out_o;
    wire [`ADDR_WIDTH-1:0]      register_addr_out_o;
    wire [`INST_WIDTH-1:0]      register_inst_out_o;
    wire                        register_CtrlJump_out_o;
    wire                        register_CtrlJALR_out_o;
    wire                        register_CtrlWantBranch_out_o;
    wire                        register_CtrlBranch_out_o;

    // u_dwishbone_bus_if
    wire    [`DATA_WIDTH-1:0]   u_dwishbone_bus_if_cpu_data_o;

    ifu u_ifu(
        .clk                (clk),
        .rst                (rst),
        .stall              (stall_from_ctrl),

        .CtrlJump           (id_CtrlJump_o),
        .CtrlJALR           (id_CtrlJALR_o),
        .CtrlBranch         (id_CtrlBranch_o),
        .CtrlWantBranch     (id_CtrlWantBranch_o),
        .result             ((id_CtrlJump_o || (id_CtrlWantBranch_o && id_CtrlBranch_o) || id_CtrlJALR_o) ? jump_result_from_id : mem_wb_result_o), // mem_wb_result_o or 0 ???
        .inst_from_meminst  (u_meminst_o_data),

        .addr               (ifu_addr_o),
        .inst               (ifu_inst_o),
        .stallreq           (ifu_stall_req_o),
        .wbcommit           (ifu_wbcommit_o)
    );

    meminst u_meminst(
        .clk            (clk),

        .i_ce           (1),
        .i_addr         (ifu_addr_o),
        .i_data         (0),
        .i_we           (0),
        .i_sel          (4'b1111),

        .o_data         (u_meminst_o_data)
    );

    if_id u_if_id(
        .clk            (clk),
        .rst            (rst),
        .stall          (stall_from_ctrl),
        
        .if_addr        (ifu_addr_o),
        .if_inst        (ifu_inst_o),
        .if_wbcommit    (ifu_wbcommit_o),

        .id_addr        (if_id_addr_o),
        .id_inst        (if_id_inst_o),
        .id_wbcommit    (if_id_wbcommit_o)
    );

    id u_id(
        .clk                        (clk),
        .rst                        (rst),

        .addr                       (if_id_addr_o),
        .inst                       (if_id_inst_o),
        .rs1data_from_regs          (regs_rs1data_o),
        .rs2data_from_regs          (regs_rs2data_o),
        .rsdata_csr_from_csrfile    (csrfile_csr_data_o),
        .write_regs_from_ex         (id_ex_wen_o),
        .write_regs_addr_from_ex    ((id_ex_addr_o === 0) ? ex_mem_rd_o : id_ex_rd_o), // id_ex_addr_o === 0这个条件是通过看时序图想到的，如果传入的地址是全0，说明下一个流水线中的内容是暂停的空内容，那么rd就在下一个流水段了
        .write_regs_data_from_ex    (id_ex_CtrlCSR_o != 0 ? id_ex_csr_data_o : ex_result_o),
        .write_regs_from_mem        (ex_mem_wen_o),
        .write_regs_addr_from_mem   (ex_mem_rd_o),
        .write_regs_data_from_mem   (ex_mem_CtrlCSR_o != 0 ? ex_mem_csr_data_o :
                                     ex_mem_CtrlLoad_o != 0 ? u_ls_o_data_from_memdata : ex_mem_result_o),
        .write_regs_from_wb         (mem_wb_wen_o),
        .write_regs_addr_from_wb    (mem_wb_rd_o),
        .write_regs_data_from_wb    (mem_wb_CtrlCSR_o != 0 ? mem_wb_csr_data_o :
                                     mem_wb_CtrlLoad_o != 0 ? mem_wb_data_o : mem_wb_result_o),
        .pre_inst_is_load           ((id_ex_addr_o === 0) ? (ex_mem_CtrlLoad_o != 0) : (id_ex_CtrlLoad_o != 0)), // id_ex_addr_o === 0这个条件是通过看时序图想到的，如果传入的地址是全0，说明下一个流水线中的内容是暂停的空内容，那么rd就在下一个流水段了

        .stall_req_1    (id_stall_req_1_o),
        .stall_req_2    (id_stall_req_2_o),
        .wen            (id_wen_o),
        .wen_csr_mtvec  (id_wen_csr_mtvec_o),
        .wen_csr_mcause (id_wen_csr_mcause_o),
        .wen_csr_mstatus(id_wen_csr_mstatus_o),
        .wen_csr_mepc   (id_wen_csr_mepc_o),
        .rd             (id_rd_o),
        .rs1            (id_rs1_o),
        .rs2            (id_rs2_o),
        .rs_csr         (id_rs_csr_o),
        .imm            (id_imm_o),
        .CtrlOP         (id_CtrlOP_o),
        .CtrlALUSrc     (id_CtrlALUSrc_o),
        .CtrlJAL        (id_CtrlJAL_o),
        .CtrlJump       (id_CtrlJump_o),
        .CtrlJALR       (id_CtrlJALR_o),
        .CtrlLoad       (id_CtrlLoad_o),
        .CtrlStore      (id_CtrlStore_o),
        .CtrlWantBranch (id_CtrlWantBranch_o),
        .CtrlBranch     (id_CtrlBranch_o),
        .CtrlSigned     (id_CtrlSigned_o),
        .CtrlSignedLoad (id_CtrlSignedLoad_o),
        .CtrlCSR        (id_CtrlCSR_o),
        .jump_result    (jump_result_from_id),
        .rs1data        (id_rs1data_o),
        .rs2data        (id_rs2data_o)
    );

    regs u_regs(
        .clk                (clk),
        .rst                (rst),

        .wdata              ((mem_wb_CtrlLoad_o != 2'b00) ? mem_wb_data_o :
                             (mem_wb_CtrlCSR_o != 2'b00) ? mem_wb_csr_data_o : mem_wb_result_o),
        .rd                 (mem_wb_rd_o),
        .wen                (mem_wb_wen_o),
        .rs1                (id_rs1_o),
        .rs2                (id_rs2_o),
        .CtrlJumpORCtrlJALR (mem_wb_CtrlJump_o || mem_wb_CtrlJALR_o),
        .pc                 (mem_wb_addr_o),

        .rs1data            (regs_rs1data_o),
        .rs2data            (regs_rs2data_o)
    );

    csrfile u_csrfile(
        .i_clk              (clk),
        .i_rst              (rst),

        .i_csr_r_addr       (id_rs_csr_o),
        .i_wen_mtvec        (mem_wb_wen_csr_mtvec_o),
        .i_wdata_mtvec      (mem_wb_rs1data_o),
        .i_wen_mcause       (mem_wb_wen_csr_mcause_o),
        .i_wdata_mcause     (mem_wb_rs1data_o),
        .i_wen_mstatus      (mem_wb_wen_csr_mstatus_o),
        .i_wdata_mstatus    ((mem_wb_CtrlCSR_o != 2'b00) ? mem_wb_rs1data_o : 32'h1800),
        .i_wen_mepc         (mem_wb_wen_csr_mepc_o),
        .i_CtrlCSR          (mem_wb_CtrlCSR_o), // 当从wb返回的mem_wb_CtrlCSR_o�?2'b01�?2'b10时，表示对mepc赋�?�为rs1或rs1与mepc取或，反之对mepc赋�?�为pc�?
        .i_wdata_mepc       (mem_wb_CtrlCSR_o != 2'b00 ? mem_wb_rs1data_o : mem_wb_addr_o),

        .o_csr_data         (csrfile_csr_data_o)
    );

    id_ex u_id_ex(
        .clk                (clk),
        .rst                (rst),
        .stall              (stall_from_ctrl),

        .id_wen             (id_wen_o),
        .id_rd              (id_rd_o),
        .id_imm             (id_imm_o),
        // .id_addr            (register_CtrlJump_out_o || register_CtrlJALR_out_o || (register_CtrlWantBranch_out_o && register_CtrlBranch_out_o) ? jump_result_from_id : if_id_addr_o),
        // .id_addr            (id_CtrlJump_o || id_CtrlJALR_o || (id_CtrlWantBranch_o && id_CtrlBranch_o) ? jump_result_from_id : if_id_addr_o),
        .id_addr            (if_id_addr_o),
        .id_inst            (if_id_inst_o),
        .id_CtrlOP          (id_CtrlOP_o),
        .id_CtrlALUSrc      (id_CtrlALUSrc_o),
        .id_CtrlJAL         (id_CtrlJAL_o),
        .id_CtrlJump        (id_CtrlJump_o),
        .id_CtrlJALR        (id_CtrlJALR_o),
        .id_CtrlLoad        (id_CtrlLoad_o),
        .id_CtrlStore       (id_CtrlStore_o),
        .id_CtrlWantBranch  (id_CtrlWantBranch_o),
        .id_CtrlSigned      (id_CtrlSigned_o),
        .id_CtrlSignedLoad  (id_CtrlSignedLoad_o),
        .id_CtrlCSR         (id_CtrlCSR_o),
        .id_rs1data         (id_rs1data_o),
        .id_rs2data         (id_rs2data_o),
        .id_csr_data        (csrfile_csr_data_o),
        .id_wbcommit        (if_id_wbcommit_o),

        // input for CSR
        .id_wen_mtvec       (id_wen_csr_mtvec_o),
        .id_wen_mcause      (id_wen_csr_mcause_o),
        .id_wen_mstatus     (id_wen_csr_mstatus_o),
        // .id_wdata_mcause    (id_rs1data_o), // 和id_rs1data相同
        .id_wen_mepc        (id_wen_csr_mepc_o),
        // .id_wdata_mepc      (if_id_addr_o), // 和id_addr相同

        // new add wire for output
        .id_rs1             (id_rs1_o),
        .id_rs2             (id_rs2_o),

        .ex_wen             (id_ex_wen_o),
        .ex_rd              (id_ex_rd_o),
        .ex_imm             (id_ex_imm_o),
        .ex_addr            (id_ex_addr_o),
        .ex_inst            (id_ex_inst_o),
        .ex_CtrlOP          (id_ex_CtrlOP_o),
        .ex_CtrlALUSrc      (id_ex_CtrlALUSrc_o),
        .ex_CtrlJAL         (id_ex_CtrlJAL_o),
        .ex_CtrlJump        (id_ex_CtrlJump_o),
        .ex_CtrlJALR        (id_ex_CtrlJALR_o),
        .ex_CtrlLoad        (id_ex_CtrlLoad_o),
        .ex_CtrlStore       (id_ex_CtrlStore_o),
        .ex_CtrlWantBranch  (id_ex_CtrlWantBranch_o),
        .ex_CtrlSigned      (id_ex_CtrlSigned_o),
        .ex_CtrlSignedLoad  (id_ex_CtrlSignedLoad_o),
        .ex_CtrlCSR         (id_ex_CtrlCSR_o),
        .ex_rs1data         (id_ex_rs1data_o),
        .ex_rs2data         (id_ex_rs2data_o),
        .ex_csr_data        (id_ex_csr_data_o),
        .ex_wbcommit        (id_ex_wbcommit_o),

        // input for CSR
        .ex_wen_mtvec       (id_ex_wen_csr_mtvec_o),
        .ex_wen_mcause      (id_ex_wen_csr_mcause_o),
        .ex_wen_mstatus     (id_ex_wen_csr_mstatus_o),
        .ex_wen_mepc        (id_ex_wen_csr_mepc_o),

        // new add wire for output
        .ex_rs1             (id_ex_rs1_o),
        .ex_rs2             (id_ex_rs2_o)
    );

    ex u_ex(
        .clk                (clk),
        .rst                (rst),

        .rs1data            (id_ex_rs1data_o),
        .rs2data            (id_ex_rs2data_o),
        .imm                (id_ex_imm_o),
        .pc                 (id_ex_addr_o),
        .CtrlOP             (id_ex_CtrlOP_o),
        .CtrlALUSrc         (id_ex_CtrlALUSrc_o),
        .CtrlJAL            (id_ex_CtrlJAL_o),
        .CtrlWantBranch     (id_ex_CtrlWantBranch_o),
        .CtrlSigned         (id_ex_CtrlSigned_o),
        .CtrlJumpORCtrlJALR (id_ex_CtrlJump_o || id_ex_CtrlJALR_o),
        .CtrlLoad           (id_ex_CtrlLoad_o != 0),

        .result             (ex_result_o),
        .CtrlBranch         (ex_CtrlBranch_o),
        .stall_req          (ex_stall_req_o),
        
        // test
        .operand1out_from_ALU   (ex_op1_o),
        .operand2out_from_ALU   (ex_op2_o)
    );

    ex_mem u_ex_mem(
        .clk                (clk),
        .rst                (rst),
        .stall              (stall_from_ctrl),

        .ex_addr            (id_ex_addr_o),
        .ex_inst            (id_ex_inst_o),
        .ex_result          (ex_result_o),
        .ex_wen             (id_ex_wen_o),
        .ex_rd              (id_ex_rd_o),
        .ex_CtrlJump        (id_ex_CtrlJump_o),
        .ex_CtrlJALR        (id_ex_CtrlJALR_o),
        .ex_CtrlLoad        (id_ex_CtrlLoad_o),
        .ex_CtrlStore       (id_ex_CtrlStore_o),
        .ex_CtrlWantBranch  (id_ex_CtrlWantBranch_o),
        .ex_CtrlBranch      (ex_CtrlBranch_o),
        .ex_CtrlSignedLoad  (id_ex_CtrlSignedLoad_o),
        .ex_CtrlCSR         (id_ex_CtrlCSR_o),
        .ex_rs1data         (id_ex_rs1data_o),
        .ex_rs2data         (id_ex_rs2data_o),
        .ex_csr_data        (id_ex_csr_data_o),
        .ex_wbcommit        (id_ex_wbcommit_o),

        // input for CSR
        .ex_wen_mtvec       (id_ex_wen_csr_mtvec_o),
        .ex_wen_mcause      (id_ex_wen_csr_mcause_o),
        .ex_wen_mstatus     (id_ex_wen_csr_mstatus_o),
        .ex_wen_mepc        (id_ex_wen_csr_mepc_o),

        // new add wire for output
        .ex_rs1             (id_ex_rs1_o),
        .ex_rs2             (id_ex_rs2_o),
        .ex_CtrlOP          (id_ex_CtrlOP_o),
        .ex_CtrlALUSrc      (id_ex_CtrlALUSrc_o),
        .ex_CtrlJAL         (id_ex_CtrlJAL_o),
        .ex_imm             (id_ex_imm_o),
        .ex_op1             (ex_op1_o),
        .ex_op2             (ex_op2_o),

        .mem_addr           (ex_mem_addr_o),
        .mem_inst           (ex_mem_inst_o),
        .mem_result         (ex_mem_result_o),
        .mem_wen            (ex_mem_wen_o),
        .mem_rd             (ex_mem_rd_o),
        .mem_CtrlJump       (ex_mem_CtrlJump_o),
        .mem_CtrlJALR       (ex_mem_CtrlJALR_o),
        .mem_CtrlLoad       (ex_mem_CtrlLoad_o),
        .mem_CtrlStore      (ex_mem_CtrlStore_o),
        .mem_CtrlWantBranch (ex_mem_CtrlWantBranch_o),
        .mem_CtrlBranch     (ex_mem_CtrlBranch_o),
        .mem_CtrlSignedLoad (ex_mem_CtrlSignedLoad_o),
        .mem_CtrlCSR        (ex_mem_CtrlCSR_o),
        .mem_rs1data        (ex_mem_rs1data_o),
        .mem_rs2data        (ex_mem_rs2data_o),
        .mem_csr_data       (ex_mem_csr_data_o),
        .mem_wbcommit       (ex_mem_wbcommit_o),

        // input for CSR
        .mem_wen_mtvec       (ex_mem_wen_csr_mtvec_o),
        .mem_wen_mcause      (ex_mem_wen_csr_mcause_o),
        .mem_wen_mstatus     (ex_mem_wen_csr_mstatus_o),
        .mem_wen_mepc        (ex_mem_wen_csr_mepc_o),

        // new add wire for output
        .mem_rs1            (ex_mem_rs1_o),
        .mem_rs2            (ex_mem_rs2_o),
        .mem_CtrlOP         (ex_mem_CtrlOP_o),
        .mem_CtrlALUSrc     (ex_mem_CtrlALUSrc_o),
        .mem_CtrlJAL        (ex_mem_CtrlJAL_o),
        .mem_imm            (ex_mem_imm_o),
        .mem_op1            (ex_mem_op1_o),
        .mem_op2            (ex_mem_op2_o)
    );

    ls u_ls(
        .i_CtrlLoad             (ex_mem_CtrlLoad_o),
        .i_CtrlStore            (ex_mem_CtrlStore_o),
        .i_CtrlSignedLoad       (ex_mem_CtrlSignedLoad_o),
        .i_addr                 (ex_mem_result_o),
        .i_data_to_memdata      (ex_mem_rs2data_o),
        .i_data_from_memdata    (memdata_data_out_o),

        .o_ce                   (u_ls_o_ce),
        .o_addr                 (u_ls_o_addr),
        .o_data_to_memdata      (u_ls_o_data_to_memdata),
        .o_data_from_memdata    (u_ls_o_data_from_memdata),
        .o_sel                  (u_ls_o_sel),
        .o_we                   (u_ls_o_we)
    );

    memdata u_memdata(
        .clk                (clk),
        .rst                (rst),

        .i_ce               (u_ls_o_ce),
        .i_addr             (u_ls_o_addr),
        .i_data             (u_ls_o_data_to_memdata),
        .i_we               (u_ls_o_we),
        .i_sel              (u_ls_o_sel),

        .o_data             (memdata_data_out_o)
    );

    mem_wb u_mem_wb(
        .clk                (clk),
        .rst                (rst),
        .stall              (stall_from_ctrl),

        .mem_addr           (ex_mem_addr_o),
        .mem_inst           (ex_mem_inst_o),
        .mem_wen            (ex_mem_wen_o),
        .mem_rd             (ex_mem_rd_o),
        // .mem_data           (u_ls_o_data_from_memdata),
        .mem_data           ((u_ls_o_data_from_memdata === 0) && (u_dwishbone_bus_if_cpu_data_o != 0) ? u_dwishbone_bus_if_cpu_data_o : u_ls_o_data_from_memdata),
        .mem_result         (ex_mem_result_o),
        .mem_CtrlJump       (ex_mem_CtrlJump_o),
        .mem_CtrlJALR       (ex_mem_CtrlJALR_o),
        .mem_CtrlLoad       (ex_mem_CtrlLoad_o),
        .mem_CtrlWantBranch (ex_mem_CtrlWantBranch_o),
        .mem_CtrlBranch     (ex_mem_CtrlBranch_o),
        .mem_CtrlCSR        (ex_mem_CtrlCSR_o),
        .mem_csr_data       (ex_mem_csr_data_o),
        .mem_wbcommit       (ex_mem_wbcommit_o),
        
        // input for CSR
        .mem_wen_mtvec       (ex_mem_wen_csr_mtvec_o),
        .mem_wen_mcause      (ex_mem_wen_csr_mcause_o),
        .mem_wen_mstatus     (ex_mem_wen_csr_mstatus_o),
        .mem_wen_mepc        (ex_mem_wen_csr_mepc_o),
        .mem_rs1data        (ex_mem_rs1data_o),

        // new add wire for output
        .mem_rs1            (ex_mem_rs1_o),
        .mem_rs2            (ex_mem_rs2_o),
        .mem_CtrlOP         (ex_mem_CtrlOP_o),
        .mem_CtrlALUSrc     (ex_mem_CtrlALUSrc_o),
        .mem_CtrlJAL        (ex_mem_CtrlJAL_o),
        .mem_imm            (ex_mem_imm_o),
        .mem_op1            (ex_mem_op1_o),
        .mem_op2            (ex_mem_op2_o),

        .wb_addr            (mem_wb_addr_o),
        .wb_inst            (mem_wb_inst_o),
        .wb_wen             (mem_wb_wen_o),
        .wb_rd              (mem_wb_rd_o),
        .wb_data            (mem_wb_data_o),
        .wb_result          (mem_wb_result_o),
        .wb_CtrlJump        (mem_wb_CtrlJump_o),
        .wb_CtrlJALR        (mem_wb_CtrlJALR_o),
        .wb_CtrlLoad        (mem_wb_CtrlLoad_o),
        .wb_CtrlWantBranch  (mem_wb_CtrlWantBranch_o),
        .wb_CtrlBranch      (mem_wb_CtrlBranch_o),
        .wb_CtrlCSR         (mem_wb_CtrlCSR_o),
        .wb_csr_data        (mem_wb_csr_data_o),
        .wb_wbcommit        (mem_wb_wbcommit_o),
        
        // input for CSR
        .wb_wen_mtvec       (mem_wb_wen_csr_mtvec_o),
        .wb_wen_mcause      (mem_wb_wen_csr_mcause_o),
        .wb_wen_mstatus     (mem_wb_wen_csr_mstatus_o),
        .wb_wen_mepc        (mem_wb_wen_csr_mepc_o),
        .wb_rs1data         (mem_wb_rs1data_o),

        // new add wire for output
        .wb_rs1             (mem_wb_rs1_o),
        .wb_rs2             (mem_wb_rs2_o),
        .wb_CtrlOP          (mem_wb_CtrlOP_o),
        .wb_CtrlALUSrc      (mem_wb_CtrlALUSrc_o),
        .wb_CtrlJAL         (mem_wb_CtrlJAL_o),
        .wb_imm             (mem_wb_imm_o),
        .wb_op1             (mem_wb_op1_o),
        .wb_op2             (mem_wb_op2_o)
    );

    wb u_wb(
        .clk                (clk),
        .rst                (rst),
        
        .wen                (mem_wb_wen_o),
        .rd                 (mem_wb_rd_o),
        .data               (mem_wb_data_o),
        .result             (mem_wb_result_o),
        .CtrlJump           (mem_wb_CtrlJump_o),
        .CtrlJALR           (mem_wb_CtrlJALR_o),
        .CtrlLoad           (mem_wb_CtrlLoad_o),
        .CtrlWantBranch     (mem_wb_CtrlWantBranch_o),
        .CtrlBranch         (mem_wb_CtrlBranch_o),

        .out_wen            (),
        .out_rd             (),
        .out_data           (),
        .out_result         (),
        .out_CtrlJump       (),
        .out_CtrlJALR       (),
        .out_CtrlLoad       (),
        .out_CtrlWantBranch (),
        .out_CtrlBranch     ()
    );

    ctrl u_ctrl(
        .stall_req_from_if      (ifu_stall_req_o),
        .stall_req_from_id_1    (id_stall_req_1_o),
        .stall_req_from_id_2    (id_stall_req_2_o),
        .stall_req_from_ex      (ex_stall_req_o),

        .stall              (stall_from_ctrl)
    );

    register u_register(
        .clk            (clk),
        .rst            (rst),
        .commit_in      (mem_wb_wbcommit_o),
        .addr_in        (mem_wb_addr_o),
        .inst_in        (mem_wb_inst_o),
        .CtrlJump_in    (mem_wb_CtrlJump_o),
        .CtrlJALR_in    (mem_wb_CtrlJALR_o),
        .CtrlWantBranch_in (mem_wb_CtrlWantBranch_o),
        .CtrlBranch_in  (mem_wb_CtrlBranch_o),

        .commit_out     (register_commit_out_o),
        .addr_out       (register_addr_out_o),
        .inst_out       (register_inst_out_o),
        .CtrlJump_out   (register_CtrlJump_out_o),
        .CtrlJALR_out   (register_CtrlJALR_out_o),
        .CtrlWantBranch_out (register_CtrlWantBranch_out_o),
        .CtrlBranch_out (register_CtrlBranch_out_o)
    );

    wishbone_bus_if u_dwishbone_bus_if(
        .clk                (clk),
        .rst                (rst),

        .stall_i            (),

        .cpu_ce_i           (u_ls_o_ce),
        .cpu_addr_i         (u_ls_o_addr),
        .cpu_data_i         (u_ls_o_data_to_memdata),
        .cpu_we_i           (u_ls_o_we),
        // .cpu_sel_i          ({u_ls_o_sel[0], u_ls_o_sel[1], u_ls_o_sel[2], u_ls_o_sel[3]}),
        .cpu_sel_i          (u_ls_o_sel),
        .cpu_data_o         (u_dwishbone_bus_if_cpu_data_o),

        .wishbone_data_i    (dwishbone_data_i),
        .wishbone_ack_i     (dwishbone_ack_i),
        .wishbone_addr_o    (dwishbone_addr_o),
        .wishbone_data_o    (dwishbone_data_o),
        .wishbone_we_o      (dwishbone_we_o),
        .wishbone_sel_o     (dwishbone_sel_o),
        .wishbone_stb_o     (dwishbone_stb_o),
        .wishbone_cyc_o     (dwishbone_cyc_o),

        .stallreq           ()
    );

    // wishbone_bus_if u_iwishbone_bus_if(
    //     .clk                (clk),
    //     .rst                (rst),

    //     .stall_i            (),

    //     .cpu_ce_i           (1),
    //     .cpu_addr_i         (ifu_addr_o),
    //     .cpu_data_i         (32'h00000000),
    //     .cpu_we_i           (0),
    //     .cpu_sel_i          (4'b1111),
    //     .cpu_data_o         (),

    //     .wishbone_data_i    (iwishbone_data_i),
    //     .wishbone_ack_i     (iwishbone_ack_i),
    //     .wishbone_addr_o    (iwishbone_addr_o),
    //     .wishbone_data_o    (iwishbone_data_o),
    //     .wishbone_we_o      (iwishbone_we_o),
    //     .wishbone_sel_o     (iwishbone_sel_o),
    //     .wishbone_stb_o     (iwishbone_stb_o),
    //     .wishbone_cyc_o     (iwishbone_cyc_o),

    //     .stallreq           ()
    // );

endmodule
