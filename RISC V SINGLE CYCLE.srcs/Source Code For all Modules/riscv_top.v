// Top module: control + datapath + data memory
module riscv_top (
    input clk,
    input reset,
    input  [31:0] Instr,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData,
    output [31:0] ReadData,
    output        MemWrite,
    output        Zero,
    output        N,
    output        V,
    output        C,
    output        P,
    output        Borrow,
    output        S,
    output        H
);

    // Control signals
    wire [1:0]  PCSrc;
    wire [1:0]  ResultSrc;
    wire        ALUSrc;
    wire [1:0]  ImmSrc;
    wire        RegWrite;
    wire [3:0]  ALUControl;

    // Data memory
    dmem dmem_inst (
        .clk  (clk),
        .we   (MemWrite),
        .addr (ALUResult),
        .wd   (WriteData),
        .rd   (ReadData)
    );

    // Control unit
    control_unit cu (
        .op         (Instr[6:0]),
        .funct3     (Instr[14:12]),
        .funct7b5   (Instr[30]),
        .Zero       (Zero),
        .N          (N),
        .V          (V),
        .PCSrc      (PCSrc),
        .ResultSrc  (ResultSrc),
        .MemWrite   (MemWrite),
        .ALUSrc     (ALUSrc),
        .ImmSrc     (ImmSrc),
        .RegWrite   (RegWrite),
        .ALUControl (ALUControl)
    );

    // Datapath
    datapath dp (
        .clk        (clk),
        .reset      (reset),
        .PCSrc      (PCSrc),
        .ResultSrc  (ResultSrc),
        .ALUSrc     (ALUSrc),
        .ImmSrc     (ImmSrc),
        .RegWrite   (RegWrite),
        .ALUControl (ALUControl),
        .Instr      (Instr),
        .ReadData   (ReadData),
        .PC         (PC),
        .ALUResult  (ALUResult),
        .WriteData  (WriteData),
        .Zero       (Zero),
        .N          (N),
        .V          (V),
        .C          (C),
        .P          (P),
        .Borrow     (Borrow),
        .S          (S),
        .H          (H)
    );

endmodule
