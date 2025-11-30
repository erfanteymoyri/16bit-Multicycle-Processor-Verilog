module CarrySelectAdder16 (
    input wire signed [15:0] a,
    input wire signed [15:0] b,
    input wire cin,
    output wire signed [15:0] sum,
    output wire cout
);
    wire signed [3:0] sum0 [3:0], sum1 [3:0];
    wire cout0 [3:0], cout1 [3:0];
    wire carry [4:0];
    wire signed [15:0] final_sum;

    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : csa_blocks
            wire signed [3:0] a_block = a[i*4 +: 4];
            wire signed [3:0] b_block = b[i*4 +: 4];

            RippleCarryAdder4 adder0 (
                .a(a_block), .b(b_block), .cin(1'b0),
                .sum(sum0[i]), .cout(cout0[i])
            );
            RippleCarryAdder4 adder1 (
                .a(a_block), .b(b_block), .cin(1'b1),
                .sum(sum1[i]), .cout(cout1[i])
            );

            if (i == 0) begin
                assign final_sum[3:0] = cin ? sum1[0] : sum0[0];
                assign carry[1] = cin ? cout1[0] : cout0[0];
            end else begin
                assign final_sum[i*4 +: 4] = carry[i] ? sum1[i] : sum0[i];
                assign carry[i+1] = carry[i] ? cout1[i] : cout0[i];
            end
        end
    endgenerate

    assign sum = final_sum;
    assign cout = carry[4];
endmodule