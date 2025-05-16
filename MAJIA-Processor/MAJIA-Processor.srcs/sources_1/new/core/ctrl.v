`include "defines.v"

module ctrl(
    input   stall_req_from_if,
    input   stall_req_from_id_1,
    input   stall_req_from_id_2,
    input   stall_req_from_ex,

    output reg [5:0] stall
);

    always @(*) begin
        if(stall_req_from_ex) begin
            stall = 6'b011111;
        end
        else if(stall_req_from_id_2) begin
            stall = 6'b000111;
        end
        else if(stall_req_from_id_1) begin
            stall = 6'b100011;
        end
        else if(stall_req_from_if) begin
            stall = 6'b000011;
        end
        else begin
            stall = 6'b000000;
        end
    end


endmodule