// 32x32 register file, x0 hardwired to zero
module regfile (
    input         clk,
    input         we3,
    input  [4:0]  ra1,
    input  [4:0]  ra2,
    input  [4:0]  wa3,
    input  [31:0] wd3,
    output [31:0] rd1,
    output [31:0] rd2
);
    reg [31:0] rf [0:31];

    // Write on rising edge
    always @(posedge clk) begin
        if (we3)
            rf[wa3] <= wd3;
    end

    // Two read ports
    assign rd1 = (ra1 != 5'b00000) ? rf[ra1] : 32'b0;
    assign rd2 = (ra2 != 5'b00000) ? rf[ra2] : 32'b0;

endmodule
