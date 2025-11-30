`timescale 1ns/1ps

module Processor_TB;

    reg clk = 0;
    reg reset = 0;
    wire ready;
    wire [15:0] pc_out;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .rst(reset),
        .ready_out(ready),
        .pc_out(pc_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        reset = 1;          // Reset initially active
        #10 reset = 0;


        uut.memory.memory_array[16] = 16'b111_11_11_111111100;  // mem[16] = -4
        uut.memory.memory_array[17] = 16'b000_00_00_000000110;  // mem[17] = 6
        uut.memory.memory_array[18] = 16'b000_00_00_000001101;  // mem[18] = 13
        uut.memory.memory_array[19] = 16'b111_11_11_111110110;  // mem[19] = -10

        // Initialize instruction memory

        uut.memory.memory_array[0] = 16'b100_00_00_000010000;   // load x0, -4 -> x0 = -4
        uut.memory.memory_array[1] = 16'b100_01_11_000010001;   // load x1, 6 -> x1 = 6
        uut.memory.memory_array[2] = 16'b100_10_11_000010010;  // load x2, 13 -> x2 = 13
        uut.memory.memory_array[3] = 16'b000_11_01_00_0001000;  // Add x3, x1, x0 -> x3 = 2
        uut.memory.memory_array[4] = 16'b010_10_10_00_0001000;  // Mul x2, x2, x0 -> x2 = -52
        uut.memory.memory_array[5] = 16'b011_00_10_01_0001000;  // Div x0, x2, x1 -> x0 = -9
        uut.memory.memory_array[6] = 16'b001_01_01_00_0001000;  // Sub x1, x1, x0 -> x1 = 15
        uut.memory.memory_array[7] = 16'b101_10_11_000010001;  // Store x2, Mem[19] -> Mem[19] = -52
        uut.memory.memory_array[8] = 16'b000_01_01_01_0001000;  // Add x1, x1, x1 -> x1 = 30
        
        #1500;

        $stop();
    end

    always @(posedge clk) begin
        // Display register contents
        $display("Register x0: %d", uut.rf.reg0.data_out);
        $display("Register x1: %d", uut.rf.reg1.data_out);
        $display("Register x2: %d", uut.rf.reg2.data_out);
        $display("Register x3: %d", uut.rf.reg3.data_out);

        // Display memory contents
        $display("memory[16]: %d", uut.memory.memory_array[16]);
        $display("memory[17]: %d", uut.memory.memory_array[17]);
        $display("memory[18]: %d", uut.memory.memory_array[18]);
        $display("memory[19]: %d", uut.memory.memory_array[19]);

        $display("pc: %d", uut.pc_out);
        // $display("instr: %d", uut.instr);
        // $display("mem_out: %d", uut.mem_data_out);
        // $display("mem_read: %d", uut.ctrl.mem_read);
        // $display("state: %d", uut.ctrl.state);
        // $display("alu_out: %d", uut.alu_inst.result);
        // $display("alu_1: %d", uut.alu_inst.a);
        // $display("alu_2: %d", uut.alu_inst.b);
        // $display("alu_done: %d", uut.alu_inst.done);
        // $display("karatsuba_done: %d", uut.alu_inst.mul.done);
        // $display("mul_done: %d", uut.alu_inst.mul_done);
        // $display("div_result: %d", uut.alu_inst.divider.A_Q[15:0]);
        // $display("M: %d", uut.alu_inst.divider.M);
        // $display("abs_dividend: %d", uut.alu_inst.divider.abs_dividend);
        // $display("abs_divisor: %d", uut.alu_inst.divider.abs_divisor);
        // $display("count: %d", uut.alu_inst.divider.count);
        // $display("immediate_sel: %d", uut.immediate_sel);
        // $display("sign_extended: %d", uut.sign_extended);
        // $display("rf_data_rs1: %d", uut.rf_data_rs1);
        // $display("rf_data_rs2: %d", uut.rf_data_rs2);
        $display("---------------------------------------------");
    end

endmodule
