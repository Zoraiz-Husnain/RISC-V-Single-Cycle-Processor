`timescale 1ns/1ps

module processor_tb;

// Testbench signals
reg clk;
reg reset;

wire [31:0] pc;
wire [31:0] instr;

wire memwrite;
wire [31:0] alu_result;
wire [31:0] write_data;
wire [31:0] read_data;
wire zero_flag;
wire neg_flag;
wire ovf_flag;
wire carry_flag;
wire parity_flag;
wire borrow_flag;
wire sign_flag;
wire halfcarry_flag;
reg  [31:0] exp_addr;
reg  [31:0] exp_data;


// Processor instance
riscv_top dut(
    .clk(clk),
    .reset(reset),
    .PC(pc),
    .Instr(instr),
    .MemWrite(memwrite),
    .ALUResult(alu_result),
    .WriteData(write_data),
    .ReadData(read_data),
    .Zero(zero_flag),
    .N(neg_flag),
    .V(ovf_flag),
    .C(carry_flag),
    .P(parity_flag),
    .Borrow(borrow_flag),
    .S(sign_flag),
    .H(halfcarry_flag)
);


// Local instruction memory
reg [31:0] imem [0:100];

assign instr = imem[pc[31:2]];


// 10 ns clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// Reset pulse
initial begin
    reset = 1;
    #20;
    reset = 0;
end


// Program with all required instruction types
initial begin

    imem[0]  = 32'h00500093;
    imem[1]  = 32'h00300113;
    imem[2]  = 32'h002081B3;
    imem[3]  = 32'h40208233;
    imem[4]  = 32'h0020F2B3;
    imem[5]  = 32'h0020E333;
    imem[6]  = 32'h0020C3B3;
    imem[7]  = 32'h00112433;
    imem[8]  = 32'h002094B3;
    imem[9]  = 32'h0021D533;
    imem[10] = 32'hFF800C13;
    imem[11] = 32'h402C55B3;
    imem[12] = 32'h06400613;
    imem[13] = 32'h00A0A713;
    imem[14] = 32'h0080E793;
    imem[15] = 32'h00647813;
    imem[16] = 32'h00302023;
    imem[17] = 32'h00402223;
    imem[18] = 32'h00502423;
    imem[19] = 32'h00602623;
    imem[20] = 32'h00702823;
    imem[21] = 32'h00802A23;
    imem[22] = 32'h00902C23;
    imem[23] = 32'h00A02E23;
    imem[24] = 32'h02B02023;
    imem[25] = 32'h02C02223;
    imem[26] = 32'h02E02423;
    imem[27] = 32'h02F02623;
    imem[28] = 32'h03002823;
    imem[29] = 32'h00002683;
    imem[30] = 32'h02D02A23;
    imem[31] = 32'h00368463;
    imem[32] = 32'h00000893;
    imem[33] = 32'h00100893;
    imem[34] = 32'h03102C23;
    imem[35] = 32'h00209463;
    imem[36] = 32'h00000913;
    imem[37] = 32'h00100913;
    imem[38] = 32'h03202E23;
    imem[39] = 32'h00114463;
    imem[40] = 32'h00000993;
    imem[41] = 32'h00100993;
    imem[42] = 32'h05302023;
    imem[43] = 32'h0020D463;
    imem[44] = 32'h00000A13;
    imem[45] = 32'h00100A13;
    imem[46] = 32'h05402223;
    imem[47] = 32'h00800AEF;
    imem[48] = 32'h00000B13;
    imem[49] = 32'h00100B13;
    imem[50] = 32'h05502423;
    imem[51] = 32'h05602623;
    imem[52] = 32'h0DC00B93;
    imem[53] = 32'h000B8C67;
    imem[54] = 32'h00000C93;
    imem[55] = 32'h00100C93;
    imem[56] = 32'h05802823;
    imem[57] = 32'h05902A23;
    imem[58] = 32'h12345D37;
    imem[59] = 32'h00001D97;
    imem[60] = 32'h05A02C23;
    imem[61] = 32'h05B02E23;
    imem[62] = 32'h0000006F;

end


// Manual PASS/FAIL checks using memory write bus
initial begin
    wait(reset == 0);

    exp_addr = 32'd0;   exp_data = 32'd8;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS ADD");   else $display("FAIL ADD");   @(posedge clk);
    exp_addr = 32'd4;   exp_data = 32'd2;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SUB");   else $display("FAIL SUB");   @(posedge clk);
    exp_addr = 32'd8;   exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS AND");   else $display("FAIL AND");   @(posedge clk);
    exp_addr = 32'd12;  exp_data = 32'd7;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS OR");    else $display("FAIL OR");    @(posedge clk);
    exp_addr = 32'd16;  exp_data = 32'd6;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS XOR");   else $display("FAIL XOR");   @(posedge clk);
    exp_addr = 32'd20;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SLT");   else $display("FAIL SLT");   @(posedge clk);
    exp_addr = 32'd24;  exp_data = 32'd40;       wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SLL");   else $display("FAIL SLL");   @(posedge clk);
    exp_addr = 32'd28;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SRL");   else $display("FAIL SRL");   @(posedge clk);
    exp_addr = 32'd32;  exp_data = 32'hFFFFFFFF; wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SRA");   else $display("FAIL SRA");   @(posedge clk);
    exp_addr = 32'd36;  exp_data = 32'd100;      wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS ADDI");  else $display("FAIL ADDI");  @(posedge clk);
    exp_addr = 32'd40;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SLTI");  else $display("FAIL SLTI");  @(posedge clk);
    exp_addr = 32'd44;  exp_data = 32'd13;       wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS ORI");   else $display("FAIL ORI");   @(posedge clk);
    exp_addr = 32'd48;  exp_data = 32'd0;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS ANDI");  else $display("FAIL ANDI");  @(posedge clk);
    exp_addr = 32'd52;  exp_data = 32'd8;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS LW");    else $display("FAIL LW");    @(posedge clk);
    exp_addr = 32'd52;  exp_data = 32'd8;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS SW");    else $display("FAIL SW");    @(posedge clk);
    exp_addr = 32'd56;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS BEQ");   else $display("FAIL BEQ");   @(posedge clk);
    exp_addr = 32'd60;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS BNE");   else $display("FAIL BNE");   @(posedge clk);
    exp_addr = 32'd64;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS BLT");   else $display("FAIL BLT");   @(posedge clk);
    exp_addr = 32'd68;  exp_data = 32'd1;        wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS BGE");   else $display("FAIL BGE");   @(posedge clk);
    exp_addr = 32'd72;  exp_data = 32'h000000C0; wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS JAL");   else $display("FAIL JAL");   @(posedge clk);
    exp_addr = 32'd80;  exp_data = 32'h000000D8; wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS JALR");  else $display("FAIL JALR");  @(posedge clk);
    exp_addr = 32'd88;  exp_data = 32'h12345000; wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS LUI");   else $display("FAIL LUI");   @(posedge clk);
    exp_addr = 32'd92;  exp_data = 32'h000010EC; wait(memwrite == 1); #1; if (alu_result == exp_addr && write_data == exp_data) $display("PASS AUIPC"); else $display("FAIL AUIPC");
end


// Stop simulation
initial begin
    #1000;
    $display("Simulation Finished");
    $stop;
end

endmodule
