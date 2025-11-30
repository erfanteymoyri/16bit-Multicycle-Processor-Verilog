module KaratsubaMultiplier16_Parallel (
    input wire clk,
    input wire reset,
    input wire start,
    input wire signed [15:0] a,
    input wire signed [15:0] b,
    output reg signed [15:0] result,
    output reg done
);
    wire signed [15:0] a_negated = ~a + 16'd1;
    wire signed [15:0] a_eff = (a[15] == 1'b1) ? a_negated : a;
    wire signed [15:0] b_negated = ~b + 16'd1;
    wire signed [15:0] b_eff = (b[15] == 1'b1) ? b_negated : b;

    wire signed [15:0] z0, z2, z1_full;
    wire done0, done1, done2;
    reg compute_result_unsigned, compute_result;

    reg signed [15:0] result_unsigned;
    wire is_result_neg = a[15] ^ b[15];

    wire signed [7:0] a_low = a_eff[7:0];
    wire signed [7:0] a_high = a_eff[15:8];
    wire signed [7:0] b_low = b_eff[7:0];
    wire signed [7:0] b_high = b_eff[15:8];

    wire signed [7:0] a_sum = a_low + a_high;
    wire signed [7:0] b_sum = b_low + b_high;

    // Three 8x8 multipliers in parallel
    ShiftAddMultiplier8 mul_z0 (
        .clk(clk), .reset(reset), .start(start),
        .a(a_low), .b(b_low),
        .result(z0), .done(done0)
    );

    ShiftAddMultiplier8 mul_z2 (
        .clk(clk), .reset(reset), .start(start),
        .a(a_high), .b(b_high),
        .result(z2), .done(done1)
    );

    ShiftAddMultiplier8 mul_z1 (
        .clk(clk), .reset(reset), .start(start),
        .a(a_sum), .b(b_sum),
        .result(z1_full), .done(done2)
    );

    reg signed [15:0] z1;
    reg [3:0] wait_cycles;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 0;
            done <= 0;
            wait_cycles <= 0;
        end else begin
            // Wait ~8 cycles for all multipliers to finish
            if (start)
                wait_cycles <= 9;
            else if (wait_cycles > 0)
                wait_cycles <= wait_cycles - 4'd1;

            if (wait_cycles == 1) begin
                z1 <= z1_full - z0 - z2;
                compute_result_unsigned <= 1;
            end else
                compute_result_unsigned <= 0;

            if (compute_result_unsigned) begin
                result_unsigned <= z0 + (z1 <<< 8);  // z2 shifted 16 bits gets ignored (result limited to 16 bits)
                compute_result <= 1;
            end else
                compute_result <= 0;

            if (compute_result) begin
                if (is_result_neg)
                    result <= ~result_unsigned + 1'd1;
                else
                    result <= result_unsigned;
                done <= 1;
            end else begin
                done <= 0;
            end
        end
    end
endmodule
