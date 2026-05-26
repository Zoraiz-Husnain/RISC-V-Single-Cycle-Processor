<div align="center">

<!-- Animated Banner -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,50:16213e,100:0f3460&height=200&section=header&text=RISC-V%20Single-Cycle%20Processor&fontSize=36&fontColor=e94560&fontAlignY=38&desc=32-bit%20RV32I%20Implementation%20in%20Verilog%20HDL&descAlignY=58&descColor=a8b2d8&animation=fadeIn" width="100%"/>

<!-- Logos -->
<br/>

<img src="https://riscv.org/wp-content/uploads/2020/06/riscv-color.svg" alt="RISC-V Logo" height="50"/>
&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://img.shields.io/badge/Xilinx-Vivado-76b900?style=for-the-badge&logo=xilinx&logoColor=white" alt="Vivado" height="32"/>

<br/>

<br/><br/>

<!-- Badges -->
![Verilog](https://img.shields.io/badge/Language-Verilog%20HDL-blueviolet?style=for-the-badge&logo=v&logoColor=white)
![ISA](https://img.shields.io/badge/ISA-RISC--V%20RV32I-red?style=for-the-badge)
![CPI](https://img.shields.io/badge/CPI-1.0%20(Single--Cycle)-brightgreen?style=for-the-badge)
![Simulator](https://img.shields.io/badge/Simulator-Xilinx%20Vivado-76b900?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Verified%20%26%20Functional-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-informational?style=for-the-badge)

<br/>

> **A complete, functionally verified 32-bit single-cycle RISC-V processor built entirely in Verilog HDL.**
> Implements a representative subset of the RV32I base integer instruction set with CPI = 1.0.

</div>

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Datapath Modules](#datapath-modules)
- [Control Unit](#control-unit)
- [Supported Instructions](#supported-instructions)
- [Simulation and Verification](#simulation-and-verification)
- [Performance Analysis](#performance-analysis)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Authors](#authors)
- [References](#references)

---

## Overview

<div align="center">

```
+----------------------------------------------------------+
|                  Single-Cycle Execution                  |
|                                                          |
|  [ IF ] --> [ ID ] --> [ EX ] --> [ MEM ] --> [ WB ]    |
|                                                          |
|        All stages complete within ONE clock cycle        |
+----------------------------------------------------------+
```

</div>

This project presents the design, synthesis, and RTL simulation of a **32-bit single-cycle RISC-V microprocessor** implemented in Verilog HDL. The processor strictly adheres to the classical single-cycle datapath model, wherein all five stages of instruction processing — **Instruction Fetch (IF)**, **Instruction Decode (ID)**, **Execute (EX)**, **Memory Access (MEM)**, and **Write-Back (WB)** — are cascaded as pure combinational logic, gated only by the Program Counter and Register File state registers.

The design was developed as part of a Computer Engineering project at **Ghulam Ishaq Khan Institute of Engineering Sciences and Technology (GIKI)** and verified using a comprehensive RTL simulation testbench in Xilinx Vivado.

### Key Highlights

| Property | Value |
|---|---|
| Architecture | Single-Cycle, Harvard Memory Model |
| ISA | RISC-V RV32I Base Integer |
| Word Width | 32-bit |
| Registers | 32 x 32-bit (x0 hardwired to zero) |
| CPI | Exactly 1.0 |
| HDL | Verilog (Structural + Behavioral) |
| Critical Path | Load-Word (`lw`) instruction |
| Toolchain | Xilinx Vivado (RTL Simulation) |
| Verification | RTL Testbench with PASS/FAIL Assertions |

---

## Architecture

The top-level processor architecture is divided into two interacting domains:

```
                         32-bit Instruction Word
                                  |
              +-------------------v--------------------+
              |              CONTROL UNIT              |
              |  (Main Decoder + ALU Decoder)          |
              |  Opcode --> Control Signals             |
              +----+----------------------------------+-+
                   |  RegWrite, MemWrite, ALUSrc...   |
                   |                                  |
              +----v----------------------------------v----+
              |                 DATAPATH                   |
              |                                            |
   CLK ------>|  PC --> InstMem --> RegFile --> ALU        |
              |              |                  |          |
              |          ImmGen            DataMem         |
              |              |                  |          |
              |          MUXes            Write-Back MUX   |
              +--------------------------------------------+
```

### Instruction Execution Flow

```
CLOCK EDGE
    |
    v
+-------+     +---------+     +----------+     +------------+     +----------+
|  IF   | --> |   ID    | --> |    EX    | --> |    MEM     | --> |    WB    |
|       |     |         |     |          |     |            |     |          |
| PC -> | --> | Decode  | --> |  ALU     | --> | DataMem    | --> | rd <-    |
| InstM |     | RegRead |     | Compute  |     | Load/Store |     | Result   |
+-------+     +---------+     +----------+     +------------+     +----------+
                                    |
                              All combinational
                              (no pipeline registers)
```

The design uses a **Harvard memory architecture**, physically separating Instruction Memory (asynchronous, read-only) from Data Memory (synchronous read/write), thereby eliminating structural hazards within a single clock period.

---

## Datapath Modules

### Program Counter (PC)

The PC is an edge-triggered 32-bit register with an **asynchronous active-low reset**. A dedicated hardwired adder computes `PC + 4` for sequential execution. A **3-to-1 multiplexer** governed by the `PCSrc` control vector selects among:

| `PCSrc` | Next PC Source | Used By |
|---|---|---|
| `00` | `PC + 4` | All sequential instructions |
| `01` | `PC + SignExt(Imm)` | Branch, JAL |
| `10` | `ALUResult` | JALR (register-relative jump) |

### Register File

- 32 general-purpose registers, each 32 bits wide
- Dual **asynchronous read ports** for zero-latency operand fetch
- Single **synchronous write port** on the positive clock edge
- `x0` (register zero) is hardwired to `0x00000000` — reads always return zero, writes are silently discarded

### Arithmetic Logic Unit (ALU)

Directed by a **4-bit `ALUControl`** signal, the ALU performs:

| Operation | Description |
|---|---|
| `ADD` | Signed 32-bit addition |
| `SUB` | Two's complement subtraction (B inverted + carry-in = 1) |
| `AND` | Bitwise AND |
| `OR` | Bitwise OR |
| `XOR` | Bitwise XOR |
| `SLL` | Shift Left Logical |
| `SRL` | Shift Right Logical |
| `SRA` | Shift Right Arithmetic |
| `SLT` | Set Less Than (signed two's complement comparison) |

The ALU exports the following condition flags for branch resolution:

```
Result[31:0]
    |
    +---> Zero (Z)     : HIGH when result == 32'b0
    +---> Negative (N) : Mirrors result[31] (MSB)
    +---> Overflow (V) : Signed arithmetic boundary violation
    +---> Carry (C)    : Unsigned addition overflow
    +---> Parity (P)   : XOR reduction of all result bits
    +---> Borrow       : Subtraction borrow flag
```

### Immediate Generation Unit

The `ImmGen` module unpacks and sign-extends compressed immediate fields from the 32-bit instruction word:

| Format | Encoding | Bits Extracted | Usage |
|---|---|---|---|
| I-Type | `[31:20]` | 12-bit sign-extended | ADDI, LW, JALR |
| S-Type | `[31:25] + [11:7]` | 12-bit store offset | SW |
| B-Type | `[31] + [7] + [30:25] + [11:8]` | 13-bit (LSB=0) | BEQ, BNE, BLT, BGE |
| J-Type | Complex 21-bit reshuffle from `[31:12]` | 21-bit jump offset | JAL |
| U-Type | `[31:12]` shifted left 12 | 32-bit upper immediate | LUI, AUIPC |

---

## Control Unit

The Control Unit is a **purely combinational logic block** split into two sub-decoders for modularity and synthesis optimization.

### Main Decoder

Ingests the 7-bit `Opcode` field (`instruction[6:0]`) and asserts macro-level datapath controls:

| Opcode | Instruction Type | RegWrite | ImmSrc | ALUSrc | MemWrite | ResultSrc |
|---|---|---|---|---|---|---|
| `0110011` | R-type | 1 | xx | 0 | 0 | 00 |
| `0010011` | I-type ALU | 1 | 00 | 1 | 0 | 00 |
| `0000011` | Load (LW) | 1 | 00 | 1 | 0 | 01 |
| `0100011` | Store (SW) | 0 | 01 | 1 | 1 | xx |
| `1100011` | Branch | 0 | 10 | 0 | 0 | xx |
| `1101111` | JAL | 1 | 11 | 0 | 0 | 10 |

`ResultSrc` selects the write-back data:
- `00` : ALU result (arithmetic, logical, address computation)
- `01` : Data memory read output (load instructions)
- `10` : `PC + 4` (return address linkage for JAL)

### ALU Decoder

Processes `ALUOp[1:0]` from the Main Decoder, along with `funct3[2:0]` and `funct7[5]` (instruction bit 30) to determine the precise ALU operation. Bit 30 serves as the critical toggle between `ADD/SUB` and `SRL/SRA`.

### Branch Logic

Dedicated combinational gate array that resolves branch conditions by evaluating exported ALU flags against `funct3`:

```
BEQ  (funct3 = 000) : Branch taken when  Z == 1
BNE  (funct3 = 001) : Branch taken when  Z == 0
BLT  (funct3 = 100) : Branch taken when  N ^ V == 1
BGE  (funct3 = 101) : Branch taken when  N ^ V == 0
```

---

## Supported Instructions

The processor implements a fully functional subset of the **RV32I Base Integer Instruction Set**:

### R-Type (Register-Register)

```
 31      25 24   20 19   15 14  12 11    7 6       0
+----------+-------+-------+------+-------+---------+
|  funct7  |  rs2  |  rs1  |funct3|   rd  | opcode  |
+----------+-------+-------+------+-------+---------+

Supported: ADD  SUB  SLL  SLT  XOR  SRL  SRA  OR  AND
```

### I-Type (Immediate)

```
 31              20 19   15 14  12 11    7 6       0
+------------------+-------+------+-------+---------+
|     imm[11:0]    |  rs1  |funct3|   rd  | opcode  |
+------------------+-------+------+-------+---------+

Supported: ADDI  ANDI  ORI  SLTI  LW  JALR
```

### S-Type (Store)

```
 31      25 24   20 19   15 14  12 11    7 6       0
+----------+-------+-------+------+-------+---------+
| imm[11:5]|  rs2  |  rs1  |funct3|imm[4:0]| opcode |
+----------+-------+-------+------+-------+---------+

Supported: SW
```

### B-Type (Branch)

```
 31      25 24   20 19   15 14  12 11    7 6       0
+----------+-------+-------+------+-------+---------+
|imm[12|10:5] rs2  |  rs1  |funct3|imm[4:1|11]|opc |
+----------+-------+-------+------+-------+---------+

Supported: BEQ  BNE  BLT  BGE
```

### J-Type and U-Type

```
Supported: JAL  JALR  LUI  AUIPC
```

---

## Simulation and Verification

Verification was carried out using an **RTL-level simulation testbench** in Xilinx Vivado, exercising every supported instruction type through systematic PASS/FAIL assertions.

### Testbench Methodology

```
Testbench
    |
    +--- Load program into InstructionMemory (hex file)
    |
    +--- Drive CLK and RST_N
    |
    +--- At each clock edge:
    |       Monitor: PC, instruction[31:0], ALUResult,
    |                RegFile[rd], MemData, ControlSignals
    |
    +--- Assert expected values against computed results
    |
    +--- Report PASS / FAIL per instruction execution
```

### Verified Test Cases

| Test Case | Operation | Input | Expected Output | Result |
|---|---|---|---|---|
| Arithmetic ADD | `ADD x3, x1, x2` | x1=5, x2=3 | x3=8 | PASS |
| Arithmetic SUB | `SUB x3, x1, x2` | x1=4, x2=2 | x3=2 | PASS |
| Shift Left | `SLL x3, x1, x2` | x1=5, x2=3 | x3=40 | PASS |
| Memory Store | `SW x2, 0(x1)` | x1=addr, x2=data | Mem[addr]=data | PASS |
| Memory Load | `LW x3, 0(x1)` | Mem[addr]=data | x3=data | PASS |
| Branch Taken | `BEQ x1, x2, offset` | x1==x2 | PC = PC+offset | PASS |
| Branch Not Taken | `BNE x1, x2, offset` | x1==x2 | PC = PC+4 | PASS |
| Jump and Link | `JAL x1, offset` | - | x1=PC+4, PC=PC+offset | PASS |

### Control Signal Trace (SW instruction at PC = 0x58)

```
PC       : 0x00000058
Opcode   : 0100011  (S-type Store)
           |
           v
MemWrite : 1   <-- Data memory write ENABLED
RegWrite : 0   <-- Register file PROTECTED
ALUSrc   : 1   <-- Immediate offset routed into ALU
ImmSrc   : 01  <-- S-type immediate encoding selected
ResultSrc: xx  <-- Write-back path irrelevant (no rd write)
```

---

## Performance Analysis

### CPI and Throughput

The single-cycle architecture guarantees a **CPI (Cycles Per Instruction) of exactly 1.0** — one instruction completes per clock edge without exception. This provides perfectly deterministic, hazard-free execution, making the design well-suited for real-time embedded systems where predictability is paramount.

### Critical Path

The maximum operating frequency `F_max` is inversely constrained by the **critical path delay** — the longest combinational logic chain that must resolve within a single clock period `T_c`:

```
Critical Path: Load-Word (lw) instruction

T_c >= t_pcq  +  t_imem  +  t_decode  +  t_regread  +  t_alu  +  t_dmem  +  t_mux

Where:
  t_pcq     = PC register clock-to-output propagation delay
  t_imem    = Instruction memory asynchronous read latency
  t_decode  = Control unit combinational decode delay
  t_regread = Register file asynchronous read port latency
  t_alu     = ALU computation propagation delay
  t_dmem    = Data memory read latency
  t_mux     = Write-back multiplexer propagation delay
```

The `lw` instruction uniquely traverses **both** memory subsystems (instruction fetch + data memory read) sequentially, making it the bottleneck for the entire processor's clock rate. All other instruction types have shorter critical paths.

### Performance Comparison

| Architecture | CPI | F_max (relative) | Hazard Handling |
|---|---|---|---|
| Single-Cycle (this design) | 1.0 (fixed) | Low | None required |
| 5-Stage Pipeline | 1.0 (ideal), >1 (hazards) | High | Forwarding + Stalling |
| Out-of-Order Superscalar | <1.0 | Very High | Complex OoO engine |

---

## Project Structure

```
risc-v-single-cycle/
|
+-- src/
|   +-- top.v                  # Top-level module (instantiates all units)
|   +-- datapath/
|   |   +-- pc.v               # Program Counter with async reset
|   |   +-- register_file.v    # 32x32 Register File (dual read, single write)
|   |   +-- alu.v              # 32-bit ALU with flag outputs
|   |   +-- imm_gen.v          # Immediate Generation Unit (I/S/B/J/U types)
|   |   +-- mux2.v             # 2-to-1 Multiplexer
|   |   +-- mux3.v             # 3-to-1 Multiplexer (PCSrc)
|   +-- control/
|   |   +-- main_decoder.v     # Opcode -> Control Signal decoder
|   |   +-- alu_decoder.v      # funct3/funct7 -> ALUControl decoder
|   |   +-- branch_logic.v     # Flag-based branch condition evaluator
|   +-- memory/
|   |   +-- inst_mem.v         # Asynchronous Instruction Memory (ROM)
|   |   +-- data_mem.v         # Synchronous Data Memory (RAM)
|
+-- sim/
|   +-- tb_top.v               # Top-level RTL testbench
|   +-- tb_alu.v               # ALU unit-level testbench
|   +-- program.hex            # Assembled RISC-V test program
|
+-- docs/
|   +-- RISC_V_Report.pdf      # Full project report
|   +-- datapath_diagram.png   # Datapath schematic
|
+-- constraints/
|   +-- timing.xdc             # Vivado timing constraints
|
+-- README.md
```

---

## Getting Started

### Prerequisites

- **Xilinx Vivado** (2020.2 or later) — for simulation and synthesis
- A RISC-V assembler (e.g., `riscv32-unknown-elf-as`) to compile test programs, or use the provided `program.hex`

### Simulation in Vivado

**Step 1 — Clone the repository**

```bash
git clone https://github.com/Zoraiz-Husnain/RISC-V-Single-Cycle-Processor.git
cd RISC-V-Single-Cycle-Processor
```

**Step 2 — Open Vivado and create a new project**

```
File -> New Project -> RTL Project
Add Sources: all .v files from src/
Add Simulation Sources: sim/tb_top.v
```

**Step 3 — Load the test program**

Place `program.hex` in the simulation working directory, or modify the `$readmemh` path in `inst_mem.v` to point to your assembled hex file:

```verilog
initial begin
    $readmemh("program.hex", memory);
end
```

**Step 4 — Run RTL Simulation**

```
Flow Navigator -> Simulation -> Run Simulation -> Run Behavioral Simulation
```

**Step 5 — Inspect Waveforms**

Add the following signals to the waveform viewer for full visibility:

```
clk, rst_n, pc[31:0], instruction[31:0],
RegWrite, MemWrite, ALUSrc, PCSrc[1:0], ResultSrc[1:0],
ALUResult[31:0], ReadData[31:0], WriteData[31:0],
Zero, Negative, Overflow, Carry
```

### Writing and Assembling Test Programs

```asm
# Example: Simple arithmetic and memory test
.text
.globl _start
_start:
    addi x1, x0, 5        # x1 = 5
    addi x2, x0, 3        # x2 = 3
    add  x3, x1, x2       # x3 = 8
    sw   x3, 0(x0)        # Mem[0] = 8
    lw   x4, 0(x0)        # x4 = Mem[0] = 8
    beq  x3, x4, pass     # Branch if x3 == x4
    addi x5, x0, 0xDEAD   # FAIL marker
pass:
    addi x5, x0, 0xBEEF   # PASS marker
```

Assemble with:

```bash
riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o program.o test.s
riscv32-unknown-elf-objcopy -O verilog program.o program.hex
```

---

## Authors

<div align="center">

| Name | Reg Number | Department |
|---|---|---|
| [Muhammad Zoraiz Husnain](https://github.com/Zoraiz-Husnain) | 2024498 | Computer Engineering, GIKI |
| Farzeen Fatima | 2024171 | Computer Engineering, GIKI |
| Zahra Aliabbas | 2024668 | Computer Engineering, GIKI |

**Ghulam Ishaq Khan Institute of Engineering Sciences and Technology**

</div>

---

## Future Work

The single-cycle baseline establishes a solid foundation. The following enhancements are planned:

**5-Stage Pipeline**
Segment the datapath into Fetch, Decode, Execute, Memory, and Write-Back pipeline stages to reduce the critical path length and dramatically increase the achievable clock frequency, at the cost of an increased effective CPI due to hazards.

**Hazard Resolution Logic**
Implement dynamic data forwarding paths (EX-EX and MEM-EX bypass networks) and a hazard detection unit capable of inserting pipeline stalls (bubble insertion) to resolve RAW data hazards and control hazards introduced by branching.

**L1 Cache Integration**
Replace the idealized, zero-latency memory modules with realistic L1 Instruction and Data Caches backed by a simulated main memory hierarchy. Cache misses will be managed by a finite-state machine that issues stall signals to freeze upstream pipeline stages.

**Extended ISA Support**
Add support for RV32M (integer multiply/divide), RV32F (single-precision floating point), and the full set of CSR (Control and Status Register) instructions required for privilege-level operation and interrupt handling.

---

## References

```
[1] A. Waterman and K. Asanovic, "The RISC-V Instruction Set Manual,"
    RISC-V Foundation, 2019.
    https://riscv.org/technical/specifications/

[2] D. Patterson and J. Hennessy, "Computer Organization and Design:
    The Hardware/Software Interface, RISC-V Edition,"
    Morgan Kaufmann, 2021.

[3] S. Harris and D. Harris, "Digital Design and Computer Architecture:
    RISC-V Edition," Morgan Kaufmann, 2022.
```

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f3460,50:16213e,100:1a1a2e&height=120&section=footer" width="100%"/>

**Built with Verilog HDL -- Verified on Xilinx Vivado -- GIKI Computer Engineering**

</div>
