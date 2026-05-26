// Instruction memory: load from memfile.dat
module imem (
    input  [31:0] addr,
    output [31:0] rd
);
    reg [31:0] RAM [0:63];

    // Load program at simulation start
    initial begin
        $readmemh("memfile.dat", RAM);
    end

    // Word-aligned read
    assign rd = RAM[addr[7:2]];

endmodule
