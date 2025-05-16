`include "defines.v"

module ls(
    input   [1:0]                   i_CtrlLoad,
    input   [1:0]                   i_CtrlStore,
    input                           i_CtrlSignedLoad,
    input   [`ADDR_WIDTH-1:0]       i_addr,
    input   [`DATA_WIDTH-1:0]       i_data_to_memdata,
    input   [`DATA_WIDTH-1:0]       i_data_from_memdata,

    output                          o_ce,
    output  [`ADDR_WIDTH-1:0]       o_addr,
    output  [`DATA_WIDTH-1:0]       o_data_to_memdata,
    output  reg [`DATA_WIDTH-1:0]   o_data_from_memdata,
    output  reg [3:0]               o_sel,
    output                          o_we
);

    assign o_ce     = (i_CtrlLoad != 2'b00) || (i_CtrlStore != 2'b00);

    assign o_addr   = i_addr;

    assign o_data_to_memdata    = i_data_to_memdata;

    always @(*) begin
        if(i_CtrlSignedLoad) begin
            if(i_CtrlLoad === `LS_B) begin
                o_data_from_memdata = {{24{i_data_from_memdata[7]}}, i_data_from_memdata[7:0]};
            end
            else if(i_CtrlLoad === `LS_H) begin
                o_data_from_memdata = {{16{i_data_from_memdata[15]}}, i_data_from_memdata[15:0]};
            end
            else begin
                o_data_from_memdata = i_data_from_memdata;
            end
        end
        else begin
            o_data_from_memdata = i_data_from_memdata;
        end
    end

    always @(*) begin
        if(i_CtrlLoad === `LS_B || i_CtrlStore === `LS_B) begin
            case(i_addr[1:0])
                2'b00: o_sel    = 4'b0001;
                2'b01: o_sel    = 4'b0010;
                2'b10: o_sel    = 4'b0100;
                2'b11: o_sel    = 4'b1000;
                default: o_sel  = 4'b0001;
            endcase
        end
        else if(i_CtrlLoad === `LS_H || i_CtrlStore === `LS_H) begin
            case(i_addr[1:0])
                2'b00: o_sel    = 4'b0011;
                2'b10: o_sel    = 4'b1100;
                default: o_sel  = 4'b0011;
            endcase
        end
        else if(i_CtrlLoad === `LS_W || i_CtrlStore === `LS_W) begin
            o_sel   = 4'b1111;
        end
        else begin
            o_sel   = 4'b0000;
        end
    end

    assign o_we     = (i_CtrlStore != 2'b00 && i_CtrlLoad === 2'b00) ? 1'b1 :
                      (i_CtrlLoad != 2'b00 && i_CtrlStore === 2'b00) ? 1'b0 : 1'b0;

endmodule
