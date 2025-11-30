module ShiftAddMultiplier8 (
    input wire clk,
    input wire reset,
    input wire start,
    input wire signed [7:0] a,
    input wire signed [7:0] b,
    output reg signed [15:0] result,
    output reg done
);
    reg [3:0] count;
    reg signed [7:0] multiplicand;
    reg signed [15:0] accumulator;
    reg signed [7:0] multiplier;
    reg active;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 16'b0;
            accumulator <= 16'b0;
            multiplicand <= 8'b0;
            multiplier <= 8'b0;
            count <= 0;
            done <= 0;
            active <= 0;
        end else if (start) begin
            // Initialize multiplication
            multiplicand <= a;
            multiplier <= b;
            accumulator <= 16'b0;
            count <= 0;
            done <= 0;
            active <= 1;
        end else if (active) begin
            if (multiplier[0])
                accumulator <= accumulator + {8'b0, multiplicand}; // Add if LSB is 1

            multiplier <= multiplier >> 1;
            multiplicand <= multiplicand << 1;
            count <= count + 4'd1;

            if (count == 4'd7) begin
                result <= accumulator;
                done <= 1;
                active <= 0;
            end
        end
    end
endmodule
