module RestoringDivider16 (
    input wire clk,
    input wire reset,
    input wire start,
    input wire signed [15:0] a,
    input wire signed [15:0] b,
    output reg signed [15:0] quotient,
    output reg done
);

    reg [4:0] count;
    reg [31:0] A_Q; // A = upper 16 bits, Q = lower 16 bits
    reg [15:0] M;   // Divisor absolute
    reg sign_dividend, sign_divisor;
    reg [15:0] abs_dividend, abs_divisor;
    reg busy;
    reg compute_result;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            quotient <= 0;
            done <= 0;
            busy <= 0;
            count <= 0;
            M <= 0;
            A_Q = 0;
        end else begin
            if (start) begin
                busy <= 1;
                done <= 0;
                count <= 0;

                sign_dividend <= a[15];
                sign_divisor <= b[15];
                abs_dividend <= a[15] ? (~a + 1) : a;
                abs_divisor <= b[15] ? (~b + 1) : b;

                M <= b[15] ? (~b + 1) : b;
                A_Q = {16'b0, a[15] ? (~a + 1) : a};
            end 
            if (busy) begin
                if (count < 16) begin
                    A_Q = A_Q << 1;

                    // A = A - M
                    A_Q[31:16] = A_Q[31:16] - M;

                    if (A_Q[31]) begin
                        A_Q[31:16] = A_Q[31:16] + M;
                        A_Q[0] = 1'b0;
                    end else begin
                        A_Q[0] = 1'b1;
                    end

                    count <= count + 1;
                end else if (count == 5'd16) begin
                    compute_result <= 1;
                    count <= count + 1;
                end else begin
                    compute_result <= 0;
                    busy <= 0;
                end
            end

            if (compute_result) begin
                done <= 1;
                quotient <= (sign_dividend ^ sign_divisor) ? ~A_Q[15:0] : A_Q[15:0];
            end
            else
                done <= 0;
        end
    end
endmodule
