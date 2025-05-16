`include "defines.v"

module csrfile (
    input                       i_clk,
    input                       i_rst,

    input [`CSR_IDX_LEN-1:0]    i_csr_r_addr,
    input                       i_wen_mtvec,
    input [`DATA_WIDTH-1:0]     i_wdata_mtvec,
    input                       i_wen_mcause,
    input [`DATA_WIDTH-1:0]     i_wdata_mcause,
    input                       i_wen_mstatus,
    input [`DATA_WIDTH-1:0]     i_wdata_mstatus,
    input                       i_wen_mepc,
    input [1:0]                 i_CtrlCSR,
    input [`DATA_WIDTH-1:0]     i_wdata_mepc,

    output [`DATA_WIDTH-1:0]    o_csr_data
    // output [`DATA_WIDTH-1:0]    o_mtvec,
    // output [`DATA_WIDTH-1:0]    o_mcause,
    // output [`DATA_WIDTH-1:0]    o_mstatus,
    // output [`DATA_WIDTH-1:0]    o_mepc
);

    reg [`DATA_WIDTH-1:0] mtvec;
    reg [`DATA_WIDTH-1:0] mcause;
    reg [`DATA_WIDTH-1:0] mstatus;
    reg [`DATA_WIDTH-1:0] mepc;

    assign o_csr_data = i_csr_r_addr === `CSR_IDX_LEN'h305 ? mtvec :
                        i_csr_r_addr === `CSR_IDX_LEN'h342 ? mcause :
                        i_csr_r_addr === `CSR_IDX_LEN'h300 ? mstatus :
                        i_csr_r_addr === `CSR_IDX_LEN'h341 ? mepc : 32'b0;

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            mtvec <= 32'b0;
            mcause <= 32'b0;
            mstatus <= 32'b0;
            mepc <= 32'b0;
        end else begin
            if(i_wen_mtvec) begin
                if(i_CtrlCSR === 2'b01) begin
                    mtvec <= i_wdata_mtvec;
                end
                else if(i_CtrlCSR === 2'b10) begin
                    mtvec <= mtvec | i_wdata_mtvec;
                end
                else begin
                    mtvec <= i_wdata_mtvec;
                end
            end
            if(i_wen_mcause) begin
                if(i_CtrlCSR === 2'b01) begin
                    mcause <= i_wdata_mcause;
                end
                else if(i_CtrlCSR === 2'b10) begin
                    mcause <= mcause | i_wdata_mcause;
                end
                else begin
                    mcause <= i_wdata_mcause;
                end
            end
            if(i_wen_mstatus) begin
                if(i_CtrlCSR === 2'b01) begin
                    mstatus <= i_wdata_mstatus;
                end
                else if(i_CtrlCSR === 2'b10) begin
                    mstatus <= mstatus | i_wdata_mstatus;
                end
                else begin
                    mstatus <= i_wdata_mstatus;
                end
            end
            if(i_wen_mepc) begin
                if(i_CtrlCSR === 2'b01) begin
                    mepc <= i_wdata_mepc;
                end
                else if(i_CtrlCSR === 2'b10) begin
                    mepc <= mepc | i_wdata_mepc;
                end
                else begin
                    mepc <= i_wdata_mepc;
                end
            end
        end
    end    

endmodule