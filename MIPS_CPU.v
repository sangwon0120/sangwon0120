`timescale 1ns/1ns

module mIM(op, rs, rt, rd, shamt_val, funct_code, Instruction, CLK);
    input [31:0] Instruction;
    input CLK;

    output [5:0] op;
    output [4:0] rs, rt, rd, shamt_val;
    output [5:0] funct_code;

    assign op = Instruction[31:26];
    assign rs = Instruction[25:21];
    assign rt = Instruction[20:16];
    assign rd = Instruction[15:11];
    assign shamt_val = Instruction[10:6];
    assign funct_code = Instruction[5:0];
endmodule

module regfile(CLK, ra1, ra2, wa, wd, we, rd1, rd2);
    input CLK;
    input [4:0] ra1, ra2, wa;
    input [31:0] wd;
    input we;

    output reg [31:0] rd1, rd2;

    reg [31:0] register [0:31];

    always @(posedge CLK) begin
        if (we) register[wa] <= wd;
    end

    always @(*) begin
        rd1 = register[ra1];
        rd2 = register[ra2];
    end
endmodule

module mALU(rd1, rd2, shamt, ALUop, funct_code, data);
    input [31:0] rd1, rd2;
    input [4:0] shamt;
    input [1:0] ALUop;
    input [5:0] funct_code;

    output reg [31:0] data;

    always @(*) begin
        case (ALUop)
            2'b00: data = rd1 + rd2; // ADD
            2'b01: data = rd1 - rd2; // SUB
            2'b10: data = rd1 * rd2; // MUL
            2'b11: begin
                if (funct_code[0] == 1'b0)
                    data = rd1 << shamt; // Left shift
                else
                    data = rd1 >> shamt; // Right shift
            end
            default: data = 0;
        endcase
    end
endmodule

module MIPS_CPU(CLK, Instruction, ALU_Result);
    input CLK;
    input [31:0] Instruction;
    output [31:0] ALU_Result;

    wire [5:0] op, funct_code;
    wire [4:0] rs, rt, rd, shamt;
    wire [31:0] rd1, rd2, wd;
    wire we;
    wire [1:0] ALUop;

    // Instantiate mIM
    mIM im(
        .op(op), .rs(rs), .rt(rt), .rd(rd), .shamt_val(shamt), .funct_code(funct_code),
        .Instruction(Instruction), .CLK(CLK)
    );

    // Decode signals for control logic
    assign we = funct_code[5];
    assign ALUop = op[1:0];
    assign wd = 32'b0; // Example write data

    // Instantiate regfile
    regfile rf(
        .CLK(CLK), .ra1(rs), .ra2(rt), .wa(rd), .wd(wd), .we(we),
        .rd1(rd1), .rd2(rd2)
    );

    // Instantiate mALU
    mALU alu(
        .rd1(rd1), .rd2(rd2), .shamt(shamt), .ALUop(ALUop), .funct_code(funct_code),
        .data(ALU_Result)
    );
endmodule
