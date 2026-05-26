// 32-bit adder
module adder (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] y
);
    assign y = a + b;
endmodule

// 32-bit register with sync reset
module flopr (
    input             clk,
    input             reset,
    input      [31:0] d,
    output reg [31:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 32'h00000000;
        else
            q <= d;
    end
endmodule

// 2:1 mux
module mux2 (
    input  [31:0] d0,
    input  [31:0] d1,
    input         s,
    output [31:0] y
);
    assign y = s ? d1 : d0;
endmodule

// 3:1 mux
module mux3 (
    input  [31:0] d0,
    input  [31:0] d1,
    input  [31:0] d2,
    input  [1:0]  s,
    output [31:0] y
);
    assign y = (s == 2'b00) ? d0 :
               (s == 2'b01) ? d1 :
                               d2;
endmodule

// Immediate extension unit
module extend (
    input  [31:7] instr,
    input  [1:0]  immsrc,
    output reg [31:0] immext
);
    always @(*) begin
        case (immsrc)
            // I-type
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};
            // S-type
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // B-type
            2'b10: immext = {{20{instr[31]}},
                              instr[7],
                              instr[30:25],
                              instr[11:8],
                              1'b0};
            // J-type
            2'b11: immext = {{12{instr[31]}},
                              instr[19:12],
                              instr[20],
                              instr[30:21],
                              1'b0};

            default: immext = 32'bx;
        endcase
    end
endmodule
