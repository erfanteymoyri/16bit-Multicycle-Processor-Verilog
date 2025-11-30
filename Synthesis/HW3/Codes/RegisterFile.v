module RegisterFile (
    input wire clk,
    input wire reset,                 // Active-high reset
    input wire read_enable,
    input wire write_enable,
    input wire [1:0] write_addr,      // Write address
    input wire signed [15:0] write_data,     // Data to write

    input wire [1:0] read_addr1,      // Read address 1
    input wire [1:0] read_addr2,      // Read address 2
    output reg signed [15:0] read_data1,     // Output data 1
    output reg signed [15:0] read_data2      // Output data 2
);

    // Output wires from each register
    wire signed [15:0] reg_out [3:0];

    // Individual write enable signals for each register
    wire [3:0] reg_write_en;

    wire reg_valid [3:0];

    // Generate write enable signals based on selected write address
    assign reg_write_en[0] = write_enable & (write_addr == 2'b00);
    assign reg_write_en[1] = write_enable & (write_addr == 2'b01);
    assign reg_write_en[2] = write_enable & (write_addr == 2'b10);
    assign reg_write_en[3] = write_enable & (write_addr == 2'b11);

    // Instantiate 4 registers
    Register reg0 (.clk(clk), .reset(reset), .write_enable(reg_write_en[0]), .data_in(write_data), .data_out(reg_out[0]), .valid(reg_valid[0]));
    Register reg1 (.clk(clk), .reset(reset), .write_enable(reg_write_en[1]), .data_in(write_data), .data_out(reg_out[1]), .valid(reg_valid[1]));
    Register reg2 (.clk(clk), .reset(reset), .write_enable(reg_write_en[2]), .data_in(write_data), .data_out(reg_out[2]), .valid(reg_valid[2]));
    Register reg3 (.clk(clk), .reset(reset), .write_enable(reg_write_en[3]), .data_in(write_data), .data_out(reg_out[3]), .valid(reg_valid[3]));

    // Read on the falling edge of the clock
    always @(negedge clk) begin
        if (read_enable) begin
            read_data1 <= reg_valid[read_addr1] ? reg_out[read_addr1] : 16'b0;
            read_data2 <= reg_valid[read_addr2] ? reg_out[read_addr2] : 16'b0;
        end
    end

endmodule