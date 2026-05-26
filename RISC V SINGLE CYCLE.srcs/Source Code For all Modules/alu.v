// 32-bit ALU
module alu (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output [31:0] Result,
    output        Z,
    output        N,
    output        V,
    output        C,
    output        P,
    output        Borrow,
    output        S,
    output        H
);

    // Logic ops
    wire [31:0] a_and_b;
    wire [31:0] a_or_b;
    wire [31:0] a_xor_b;

    assign a_and_b = A & B;
    assign a_or_b  = A | B;
    assign a_xor_b = A ^ B;

    // Shift ops
    wire [31:0] a_sll;
    wire [31:0] a_srl;
    wire [31:0] a_sra;

    assign a_sll = A << B[4:0];
    assign a_srl = A >> B[4:0];
    assign a_sra = $signed(A) >>> B[4:0];

    // Add/Sub path
    wire [31:0] not_b;
    wire [31:0] b_mux;
    wire        cout;
    wire [31:0] sum;

    assign not_b = ~B;
    assign b_mux = (ALUControl[0]) ? not_b : B;

    assign {cout, sum} = A + b_mux + {31'b0, ALUControl[0]};

    // Flags
    assign C = cout & (~ALUControl[1]);

    assign V = (~ALUControl[1]) &
               (A[31] ^ sum[31]) &
               (~(A[31] ^ B[31] ^ ALUControl[0]));

    // Lower-nibble carry for half-carry flag
    wire [4:0] low_sum;
    assign low_sum = {1'b0, A[3:0]} + {1'b0, b_mux[3:0]} + {4'b0000, ALUControl[0]};

    // SLT result
    wire [31:0] slt_result;
    assign slt_result = {31'b0, (sum[31] ^ V)};

    // Output mux by ALUControl
    assign Result =
        (ALUControl == 4'b0000) ? sum        :
        (ALUControl == 4'b0001) ? sum        :
        (ALUControl == 4'b0010) ? a_and_b    :
        (ALUControl == 4'b0011) ? a_or_b     :
        (ALUControl == 4'b0100) ? a_xor_b    :
        (ALUControl == 4'b0101) ? slt_result :
        (ALUControl == 4'b0110) ? a_sll      :
        (ALUControl == 4'b0111) ? a_srl      :
        (ALUControl == 4'b1000) ? a_sra      :
        32'h00000000;

    assign Z = (Result == 32'd0);   // zero flag
    assign N = Result[31];          // sign flag
    assign S = Result[31];          // duplicate sign output
    assign P = ~^Result;            // even parity flag
    assign Borrow = (ALUControl == 4'b0001) ? ~cout : 1'b0; // borrow for SUB
    assign H = (~ALUControl[1]) ? low_sum[4] : 1'b0;   // half-carry for ADD/SUB

endmodule
