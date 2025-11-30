module MainMemory (
    input wire clk,
    input wire read_enable,
    input wire write_enable,
    input wire [15:0] addr,           // Word address (0 to 65535)
    input wire signed [15:0] write_data,     // Data to store
    output reg signed [15:0] data_out        // Output for read
);
    // Memory array: 65536 words of 16-bit (each word = 2 bytes)
    reg signed [15:0] memory_array [0:65535];

    // Combinational read
    always @(*) begin
        if (read_enable)
            data_out = memory_array[addr];
        else
            data_out = 16'b0;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (write_enable) begin
            memory_array[addr] <= write_data;
        end
    end
endmodule
