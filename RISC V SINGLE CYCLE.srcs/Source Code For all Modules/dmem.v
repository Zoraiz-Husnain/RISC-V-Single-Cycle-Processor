// Data memory: async read, sync write
module dmem (
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wd,
    output [31:0] rd
);
    reg [31:0] RAM [63:0];

    // Word-aligned read
    assign rd = RAM[addr[7:2]];

    // Word-aligned write
    always @(posedge clk) begin
        if (we)
            RAM[addr[7:2]] <= wd;
    end

endmodule
