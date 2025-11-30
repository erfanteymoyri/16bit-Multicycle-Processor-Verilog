module top (
    input clk,
    input rst,
    output [15:0] pc_out,
    output ready_out
);
    // Internal wires
    wire [15:0] instr;
    wire signed [15:0] alu_result;
    wire signed [15:0] mem_data_out;
    wire signed [15:0] rf_data_rs1, rf_data_rs2;
    wire [1:0] rs1, rs2, rd;
    wire [2:0] alu_op;
    wire alu_start, alu_done;
    wire rf_write, rf_read;
    wire mem_read, mem_write;
    wire [15:0] mem_addr;
    wire signed [15:0] rf_write_data;
    wire [15:0] pc;
    wire immediate_sel;
    wire signed [15:0] b_real;
    wire [1:0] read_addr2_real;
    wire signed [15:0] sign_extended;
    wire ready;

    assign pc_out = pc;
    assign ready_out = ready;
    assign b_real = immediate_sel ? sign_extended : rf_data_rs2;
    assign read_addr2_real = immediate_sel ? rd : rs2;

    // Instantiate memory
    MainMemory memory (
        .clk(clk),
        .read_enable(mem_read),
        .write_enable(mem_write),
        .addr(mem_addr),
        .write_data(rf_data_rs2),
        .data_out(mem_data_out)
    );

    // Instantiate ALU
    ALU alu_inst (
        .clk(clk),
        .reset(rst),
        .start(alu_start),
        .opcode(alu_op),
        .a(rf_data_rs1),
        .b(b_real),
        .result(alu_result),
        .done(alu_done)
    );

    // Instantiate register file
    RegisterFile rf (
        .clk(clk),
        .reset(rst),
        .read_enable(rf_read),
        .write_enable(rf_write),
        .read_addr1(rs1),
        .read_addr2(read_addr2_real),
        .write_addr(rd),
        .write_data(rf_write_data),
        .read_data1(rf_data_rs1),
        .read_data2(rf_data_rs2)
    );

    // Instantiate controller
    controller ctrl (
        .clk(clk),
        .rst(rst),
        .instr_in(instr),
        .alu_out(alu_result),
        .mem_out(mem_data_out),
        .alu_done(alu_done),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .alu_op(alu_op),
        .alu_start(alu_start),
        .rf_write(rf_write),
        .rf_read(rf_read),
        .rf_write_data(rf_write_data),
        .mem_addr(mem_addr),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .sign_extended(sign_extended),
        .immediate_sel(immediate_sel),
        .pc(pc),
        .ready(ready)
    );

    assign instr = mem_data_out;

endmodule
