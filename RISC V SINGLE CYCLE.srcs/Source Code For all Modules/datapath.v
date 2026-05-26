// Single-cycle datapath
module datapath (
    input         clk,
    input         reset,
    input  [1:0]  PCSrc,
    input  [1:0]  ResultSrc,
    input         ALUSrc,
    input  [1:0]  ImmSrc,
    input         RegWrite,
    input  [3:0]  ALUControl,
    input  [31:0] Instr,
    input  [31:0] ReadData,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData,
    output        Zero,
    output        N,
    output        V,
    output        C,
    output        P,
    output        Borrow,
    output        S,
    output        H
);

    // PC and datapath wires
    wire [31:0] PCNext;
    wire [31:0] PCPlus4;
    wire [31:0] PCTarget;

    wire [31:0] ImmExt;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] Result;

    // Program counter register
    flopr pc_reg (
        .clk   (clk),
        .reset (reset),
        .d     (PCNext),
        .q     (PC)
    );

    // PC + 4
    adder pcplus4_adder (
        .a (PC),
        .b (32'd4),
        .y (PCPlus4)
    );

    // Branch/jump target
    adder pctarget_adder (
        .a (PC),
        .b (ImmExt),
        .y (PCTarget)
    );

    // Next PC select
    mux3 pcnext_mux (
        .d0 (PCPlus4),
        .d1 (PCTarget),
        .d2 (ALUResult),
        .s  (PCSrc),
        .y  (PCNext)
    );

    // Immediate generator
    extend imm_ext (
        .instr  (Instr[31:7]),
        .immsrc (ImmSrc),
        .immext (ImmExt)
    );

    // Register file
    regfile rf (
        .clk (clk),
        .we3 (RegWrite),
        .ra1 (Instr[19:15]),
        .ra2 (Instr[24:20]),
        .wa3 (Instr[11:7]),
        .wd3 (Result),
        .rd1 (SrcA),
        .rd2 (WriteData)
    );

    // ALU second operand select
    mux2 alusrc_mux (
        .d0 (WriteData),
        .d1 (ImmExt),
        .s  (ALUSrc),
        .y  (SrcB)
    );

    // ALU
    alu alu_inst (
        .A          (SrcA),
        .B          (SrcB),
        .ALUControl (ALUControl),
        .Result     (ALUResult),
        .Z          (Zero),
        .N          (N),
        .V          (V),
        .C          (C),
        .P          (P),
        .Borrow     (Borrow),
        .S          (S),
        .H          (H)
    );

    // Write-back data select
    mux3 result_mux (
        .d0 (ALUResult),
        .d1 (ReadData),
        .d2 (PCPlus4),
        .s  (ResultSrc),
        .y  (Result)
    );

endmodule
