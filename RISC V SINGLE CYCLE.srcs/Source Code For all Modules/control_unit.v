// Main control unit
module control_unit (
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7b5,
    input        Zero,
    input        N,
    input        V,
    output [1:0] PCSrc,
    output [1:0] ResultSrc,
    output       MemWrite,
    output       ALUSrc,
    output [1:0] ImmSrc,
    output       RegWrite,
    output [3:0] ALUControl
);

    // Internal control wires
    wire [1:0] ALUOp;
    wire       Branch;
    wire       Jump;
    wire       Jalr;

    // Opcode to high-level control signals
    maindec md (
        .op        (op),
        .Branch    (Branch),
        .Jump      (Jump),
        .Jalr      (Jalr),
        .ResultSrc (ResultSrc),
        .MemWrite  (MemWrite),
        .ALUSrc    (ALUSrc),
        .ImmSrc    (ImmSrc),
        .RegWrite  (RegWrite),
        .ALUOp     (ALUOp)
    );

    // ALU operation decode
    aludec ad (
        .opb5      (op[5]),
        .funct3    (funct3),
        .funct7b5  (funct7b5),
        .ALUOp     (ALUOp),
        .ALUControl(ALUControl)
    );

    // Branch decision logic
    wire branch_taken;
    assign branch_taken = (Branch &  Zero      & (funct3 == 3'b000)) |
                          (Branch & ~Zero      & (funct3 == 3'b001)) |
                          (Branch & (N ^ V)    & (funct3 == 3'b100)) |
                          (Branch & ~(N ^ V)   & (funct3 == 3'b101));

    // PC source select: jalr, branch/jump, or pc+4
    assign PCSrc = Jalr                    ? 2'b10 :
                   (Jump | branch_taken)   ? 2'b01 :
                                             2'b00;

endmodule

// Opcode decoder
module maindec (
    input  [6:0] op,
    output       Branch,
    output       Jump,
    output       Jalr,
    output [1:0] ResultSrc,
    output       MemWrite,
    output       ALUSrc,
    output [1:0] ImmSrc,
    output       RegWrite,
    output [1:0] ALUOp
);
    reg [11:0] controls;

    // Control word unpack
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
            ResultSrc, Branch, ALUOp, Jump, Jalr} = controls;

    always @(*) begin
        case (op)
            7'b0110011: controls = 12'b1_xx_0_0_00_0_10_0_0;
            7'b0010011: controls = 12'b1_00_1_0_00_0_10_0_0;
            7'b0000011: controls = 12'b1_00_1_0_01_0_00_0_0;
            7'b0100011: controls = 12'b0_01_1_1_00_0_00_0_0;
            7'b1100011: controls = 12'b0_10_0_0_00_1_01_0_0;
            7'b1101111: controls = 12'b1_11_0_0_10_0_00_1_0;
            7'b1100111: controls = 12'b1_00_1_0_10_0_00_0_1;
            default:    controls = 12'b0_xx_0_0_00_0_00_0_0;
        endcase
    end

endmodule

// ALU control decoder
module aludec (
    input        opb5,
    input  [2:0] funct3,
    input        funct7b5,
    input  [1:0] ALUOp,
    output reg [3:0] ALUControl
);
    // SUB for R-type when funct7[5]=1
    wire rtype_sub;
    assign rtype_sub = opb5 & funct7b5;

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000;
            2'b01: ALUControl = 4'b0001;
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = rtype_sub ? 4'b0001 : 4'b0000;
                    3'b001: ALUControl = 4'b0110;
                    3'b010: ALUControl = 4'b0101;
                    3'b011: ALUControl = 4'b0101;
                    3'b100: ALUControl = 4'b0100;
                    3'b101: ALUControl = funct7b5 ? 4'b1000 : 4'b0111;
                    3'b110: ALUControl = 4'b0011;
                    3'b111: ALUControl = 4'b0010;
                    default: ALUControl = 4'bxxxx;
                endcase
            end

            default: ALUControl = 4'bxxxx;
        endcase
    end

endmodule
