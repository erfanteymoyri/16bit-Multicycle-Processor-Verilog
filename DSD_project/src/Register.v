module Register (
    input wire clk,
    input wire reset,               // Active-high reset
    input wire write_enable,
    input wire signed [15:0] data_in,
    output reg signed [15:0] data_out,
    output reg valid
);
    always @(posedge clk) begin
        if (reset) begin
            data_out <= 16'b0;
            valid <= 1'b0;
        end else if (write_enable) begin
            data_out <= data_in;
            valid <= 1'b1;
        end
    end
endmodule