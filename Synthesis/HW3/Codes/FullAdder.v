module FullAdder (
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);
    wire w1, w2, w3;

    // sum = a ^ b ^ cin
    xor (w1, a, b);
    xor (sum, w1, cin);

    // cout = (a & b) | (b & cin) | (a & cin)
    and (w2, a, b);
    and (w3, w1, cin);
    or  (cout, w2, w3);
endmodule