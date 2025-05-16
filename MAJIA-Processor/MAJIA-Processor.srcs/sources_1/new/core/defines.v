`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define INST_WIDTH 32
`define REG_WIDTH 32
`define REG_NUM 32
`define REG_NUM_LOG 5
`define CSR_NUM 4
`define CSR_IDX_LEN 12
`define CTRLOP_TYPE_LOG 4
`define STALL_WIDTH 5
`define CONFIG_MBASE 32'h80000000

`define IDLE        2'b01
`define WAIT_READY  2'b10

`define OP_ADD  4'b0001
`define OP_SLL  4'b0010
`define OP_LT   4'b0011
`define OP_GE   4'b0100
`define OP_XOR  4'b0101
`define OP_OR   4'b0110
`define OP_EQ   4'b0111
`define OP_AND  4'b1000
`define OP_SRA  4'b1001
`define OP_NE   4'b1010
`define OP_SUB  4'b1011
`define OP_SRL  4'b1100

`define LS_W 2'b01
`define LS_B 2'b10
`define LS_H 2'b11

`define OPCODE_ADDI     7'b00100_11
`define OPCODE_EBREAK   7'b11100_11
`define OPCODE_AUIPC    7'b00101_11
`define OPCODE_LUI      7'b01101_11
`define OPCODE_JAL      7'b11011_11
`define OPCODE_JALR     7'b11001_11
`define OPCODE_SW       7'b01000_11
`define OPCODE_LW       7'b00000_11
`define OPCODE_BLTU     7'b11000_11
`define OPCODE_BGEU     7'b11000_11
`define OPCODE_SLLI     7'b00100_11
`define OPCODE_ADD      7'b01100_11
`define OPCODE_XOR      7'b01100_11
`define OPCODE_OR       7'b01100_11
`define OPCODE_SLTIU    7'b00100_11
`define OPCODE_BEQ      7'b11000_11
`define OPCODE_SB       7'b01000_11
`define OPCODE_SLL      7'b01100_11
`define OPCODE_LBU      7'b00000_11
`define OPCODE_XORI     7'b00100_11
`define OPCODE_ANDI     7'b00100_11
`define OPCODE_SRAI     7'b00100_11
`define OPCODE_SLTU     7'b01100_11
`define OPCODE_AND      7'b01100_11
`define OPCODE_BNE      7'b11000_11
`define OPCODE_BGE      7'b11000_11
`define OPCODE_SUB      7'b01100_11
`define OPCODE_BLT      7'b11000_11
`define OPCODE_SRLI     7'b00100_11
`define OPCODE_LH       7'b00000_11
`define OPCODE_LHU      7'b00000_11
`define OPCODE_SRA      7'b01100_11
`define OPCODE_SRL      7'b01100_11
`define OPCODE_ORI      7'b00100_11
`define OPCODE_LB       7'b00000_11
`define OPCODE_SH       7'b01000_11
`define OPCODE_SLT      7'b01100_11
`define OPCODE_ECALL    7'b11100_11
`define OPCODE_CSRRW    7'b11100_11
`define OPCODE_CSRRS    7'b11100_11
`define OPCODE_MRET     7'b11100_11

// opcode === 7'b00100_11
`define FUN3_ADDI   3'b000
`define FUN3_SLLI   3'b001
`define FUN3_SLTIU  3'b011
`define FUN3_XORI   3'b100
`define FUN3_ANDI   3'b111
`define FUN3_SRAI   3'b101
`define FUN3_SRLI   3'b101
`define FUN3_ORI    3'b110

    // fun3 === 3'b101
`define FUN6_SRAI   6'b010000
`define FUN6_SRLI   6'b000000

// opcode === 7'b11000_11
`define FUN3_BLTU   3'b110
`define FUN3_BGEU   3'b111
`define FUN3_BEQ    3'b000
`define FUN3_BNE    3'b001
`define FUN3_BGE    3'b101
`define FUN3_BLT    3'b100

// opcode === 7'b01100_11
`define FUN3_ADD    3'b000
`define FUN3_XOR    3'b100
`define FUN3_OR     3'b110
`define FUN3_SLL    3'b001
`define FUN3_SLTU   3'b011
`define FUN3_AND    3'b111
`define FUN3_SUB    3'b000
`define FUN3_SRA    3'b101
`define FUN3_SRL    3'b101
`define FUN3_SLT    3'b010

    // fun3 === 3'b000
`define FUN7_ADD    7'b0000000
`define FUN7_SUB    7'b0100000

    // fun3 === 3'b101
`define FUN7_SRA    7'b0100000
`define FUN7_SRL    7'b0000000

// opcode === 7'b01000_11
`define FUN3_SW     3'b010
`define FUN3_SB     3'b000
`define FUN3_SH     3'b001

// opcode === 7'b00000_11
`define FUN3_LW     3'b010
`define FUN3_LBU    3'b100
`define FUN3_LH     3'b001
`define FUN3_LHU    3'b101
`define FUN3_LB     3'b000

// opcode === 7'b11100_11
`define FUN3_EBREAK 3'b000
`define FUN3_ECALL  3'b000
`define FUN3_CSRRW  3'b001
`define FUN3_CSRRS  3'b010
`define FUN3_MRET   3'b000
    
    // fun3 === 3'b000
`define FUN12_EBREAK    12'b000000000001
`define FUN12_ECALL     12'b000000000000
`define FUN12_MRET      12'b001100000010

`define INST_KONG   32'b00000000_00000000_00000000_00000000
`define INST_NOP    32'b00000000_00000000_00000000_00010011
`define INST_ADDI   opcode === `OPCODE_ADDI     && fun3 === `FUN3_ADDI
`define INST_EBREAK opcode === `OPCODE_EBREAK   && fun3 === `FUN3_EBREAK    && fun12 === `FUN12_EBREAK
`define INST_AUIPC  opcode === `OPCODE_AUIPC
`define INST_LUI    opcode === `OPCODE_LUI
`define INST_JAL    opcode === `OPCODE_JAL
`define INST_JALR   opcode === `OPCODE_JALR
`define INST_SW     opcode === `OPCODE_SW       && fun3 === `FUN3_SW
`define INST_LW     opcode === `OPCODE_LW       && fun3 === `FUN3_LW
`define INST_BLTU   opcode === `OPCODE_BLTU     && fun3 === `FUN3_BLTU
`define INST_BGEU   opcode === `OPCODE_BGEU     && fun3 === `FUN3_BGEU
`define INST_SLLI   opcode === `OPCODE_SLLI     && fun3 === `FUN3_SLLI
`define INST_ADD    opcode === `OPCODE_ADD      && fun3 === `FUN3_ADD       && fun7 === `FUN7_ADD
`define INST_XOR    opcode === `OPCODE_XOR      && fun3 === `FUN3_XOR
`define INST_OR     opcode === `OPCODE_OR       && fun3 === `FUN3_OR
`define INST_SLTIU  opcode === `OPCODE_SLTIU    && fun3 === `FUN3_SLTIU
`define INST_BEQ    opcode === `OPCODE_BEQ      && fun3 === `FUN3_BEQ
`define INST_SB     opcode === `OPCODE_SB       && fun3 === `FUN3_SB
`define INST_SLL    opcode === `OPCODE_SLL      && fun3 === `FUN3_SLL
`define INST_LBU    opcode === `OPCODE_LBU      && fun3 === `FUN3_LBU
`define INST_XORI   opcode === `OPCODE_XORI     && fun3 === `FUN3_XORI
`define INST_ANDI   opcode === `OPCODE_ANDI     && fun3 === `FUN3_ANDI
`define INST_SRAI   opcode === `OPCODE_SRAI     && fun3 === `FUN3_SRAI      && fun6 === `FUN6_SRAI
`define INST_SLTU   opcode === `OPCODE_SLTU     && fun3 === `FUN3_SLTU
`define INST_AND    opcode === `OPCODE_AND      && fun3 === `FUN3_AND
`define INST_BNE    opcode === `OPCODE_BNE      && fun3 === `FUN3_BNE
`define INST_BGE    opcode === `OPCODE_BGE      && fun3 === `FUN3_BGE
`define INST_SUB    opcode === `OPCODE_SUB      && fun3 === `FUN3_SUB       && fun7 === `FUN7_SUB
`define INST_BLT    opcode === `OPCODE_BLT      && fun3 === `FUN3_BLT
`define INST_SRLI   opcode === `OPCODE_SRLI     && fun3 === `FUN3_SRLI      && fun6 === `FUN6_SRLI
`define INST_LH     opcode === `OPCODE_LH       && fun3 === `FUN3_LH
`define INST_LHU    opcode === `OPCODE_LHU      && fun3 === `FUN3_LHU
`define INST_SRA    opcode === `OPCODE_SRA      && fun3 === `FUN3_SRA       && fun7 === `FUN7_SRA
`define INST_SRL    opcode === `OPCODE_SRL      && fun3 === `FUN3_SRL       && fun7 === `FUN7_SRL
`define INST_ORI    opcode === `OPCODE_ORI      && fun3 === `FUN3_ORI
`define INST_LB     opcode === `OPCODE_LB       && fun3 === `FUN3_LB
`define INST_SH     opcode === `OPCODE_SH       && fun3 === `FUN3_SH
`define INST_SLT    opcode === `OPCODE_SLT      && fun3 === `FUN3_SLT
`define INST_ECALL  opcode === `OPCODE_ECALL    && fun3 === `FUN3_ECALL     && fun12 === `FUN12_ECALL
`define INST_CSRRW  opcode === `OPCODE_CSRRW    && fun3 === `FUN3_CSRRW
`define INST_CSRRS  opcode === `OPCODE_CSRRS    && fun3 === `FUN3_CSRRS
`define INST_MRET   opcode === `OPCODE_MRET     && fun3 === `FUN3_MRET      && fun12 === `FUN12_MRET
