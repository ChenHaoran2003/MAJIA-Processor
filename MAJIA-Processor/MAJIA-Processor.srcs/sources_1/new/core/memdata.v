`include "defines.v"

module memdata(
    input                       clk,
    input                       rst,

    input                       i_ce,
    input   [`ADDR_WIDTH-1:0]   i_addr,
    input   [`DATA_WIDTH-1:0]   i_data,
    input                       i_we,
    input   [3:0]               i_sel,

    output reg [`DATA_WIDTH-1:0] o_data
);

    reg     [`DATA_WIDTH-1:0]   i_data_temp;
    wire    [`DATA_WIDTH-1:0]   o_data_temp;
    wire    [`ADDR_WIDTH-1:0]   i_addr_temp;
    assign i_addr_temp  = {i_addr[31:2], 2'b00};

    // reg [`DATA_WIDTH-1:0] data_tmp;

    // always @(*) begin
    //     if(i_we != 0) begin
    //         stall_req = 1;
    //     end
    //     else begin
    //         stall_req = 0;
    //     end
    // end

    // always @(*) begin
    //     if(i_ce && i_we) begin
    //         if(i_sel === 4'b0001) begin
    //             pmem_write(i_addr, i_data, 1);
    //         end
    //         else if(i_sel === 4'b0011) begin
    //             pmem_write(i_addr, i_data, 2);
    //         end
    //         else if(i_sel === 4'b1111) begin
    //             pmem_write(i_addr, i_data, 4);
    //         end
    //     end
    // end

    // always @(*) begin
    //     if(i_ce && (i_we === 1'b0)) begin
    //         if(i_sel === 4'b0001) begin
    //             data_tmp = pmem_read_data(i_addr);
    //             o_data = {{24{1'b0}}, data_tmp[7:0]};
    //         end
    //         else if(i_sel === 4'b0011) begin
    //             data_tmp = pmem_read_data(i_addr);
    //             o_data = {{16{1'b0}}, data_tmp[15:0]};
    //         end
    //         else if(i_sel === 4'b1111) begin
    //             data_tmp = pmem_read_data(i_addr);
    //             o_data = data_tmp;
    //         end
    //         else begin
    //             data_tmp = {`DATA_WIDTH{1'b0}};
    //             o_data = {`DATA_WIDTH{1'b0}};
    //         end
    //     end
    //     else begin
    //         data_tmp = {`DATA_WIDTH{1'b0}};
    //         o_data = {`DATA_WIDTH{1'b0}};
    //     end
    // end

    always @(*) begin
        if(i_ce && i_we) begin
            if(i_sel === 4'b0001) begin
                i_data_temp = {24'b0, i_data[7:0]};
            end
            else if(i_sel === 4'b0010) begin
                i_data_temp = {16'b0, i_data[7:0], 8'b0};
            end
            else if(i_sel === 4'b0100) begin
                i_data_temp = {8'b0, i_data[7:0], 16'b0};
            end
            else if(i_sel === 4'b1000) begin
                i_data_temp = {i_data[7:0], 24'b0};
            end
            else if(i_sel === 4'b0011) begin
                i_data_temp = {16'b0, i_data[15:0]};
            end
            else if(i_sel === 4'b1100) begin
                i_data_temp = {i_data[15:0], 16'b0};
            end
            else if(i_sel === 4'b1111) begin
                i_data_temp = i_data[31:0];
            end
            else begin
                i_data_temp = 32'b0;
            end
        end
        else begin
            i_data_temp = 32'b0;
        end
    end

    always @(*) begin
        if(i_ce && (i_we === 1'b0)) begin
            if(i_sel === 4'b0001) begin
                o_data  = {24'b0, o_data_temp[7:0]};
            end
            else if(i_sel === 4'b0010) begin
                o_data  = {16'b0, o_data_temp[7:0], 8'b0};
            end
            else if(i_sel === 4'b0100) begin
                o_data  = {8'b0, o_data_temp[7:0], 16'b0};
            end
            else if(i_sel === 4'b1000) begin
                o_data  = {o_data_temp[7:0], 24'b0};
            end
            else if(i_sel === 4'b0011) begin
                o_data  = {16'b0, o_data_temp[15:0]};
            end
            else if(i_sel === 4'b1100) begin
                o_data  = {o_data_temp[15:0], 16'b0};
            end
            else if(i_sel === 4'b1111) begin
                o_data  = o_data_temp[31:0];
            end
            else begin
                o_data  = 32'b0;
            end
        end
        else begin
            o_data  = 32'b0;
        end
    end

    blk_mem_gen_0 blk_mem_gen_0_memdata(
        .clka(clk),    // input wire clka
        .ena(i_ce),      // input wire ena
        .wea(i_we),      // input wire [0 : 0] wea
        .addra(i_addr_temp / 4),  // input wire [13 : 0] addra
        .dina(i_data_temp),    // input wire [31 : 0] dina
        .douta(o_data_temp)  // output wire [31 : 0] douta
    );

endmodule
