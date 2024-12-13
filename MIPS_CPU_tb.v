`timescale 1ns/1ns

module MIPS_CPU_tb;
    reg CLK;
    reg [31:0] Instruction;
    reg [31:0] wd;
    wire [31:0] ALU_Result;

    // Instantiate the top module
    MIPS_CPU uut (
        .CLK(CLK),
        .Instruction(Instruction),
        .ALU_Result(ALU_Result)
    );

    // Clock generation
    always #5 CLK = ~CLK;

    // Initialize and run the test
    initial begin
        $dumpfile("MIPS_CPU.vcd");
        $dumpvars(1);
    end
    
    initial begin
        CLK = 1; Instruction = 32'hC00A020; wd = 34;
        #20 Instruction = 32'hE80A020; wd = 60;
        #20 Instruction = 32'h2B49820; wd = 40;
        #20 Instruction = 32'h693B020; wd = 80;
        #20 $finish;
    end
endmodule

