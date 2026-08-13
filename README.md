# 5-Stage RISC-V Pipeline Core

A classic 5-stage, in-order RISC-V core (IF → ID → EX → MEM → WB) written in
Verilog, with load-use hazard detection, full data forwarding, and
branch-flush control. A single-cycle reference datapath is kept alongside it
for comparison.

## Features

- Full 5-stage in-order pipeline with 4 pipeline registers (`IF/ID`, `ID/EX`,
  `EX/MEM`, `MEM/WB`)
- **Load-use hazard detection** - stalls PC and IF/ID for one cycle and
  bubbles ID/EX when an instruction needs a value a preceding `lw` hasn't
  loaded yet
- **Full operand forwarding** - EX/MEM → EX and MEM/WB → EX, covering ALU
  operands, branch comparisons, and store data
- **Branch flush** - branches resolve in EX; a taken branch flushes the
  wrong-path instruction in IF/ID and redirects the PC
- A synchronous register file with `x0` hardwired to zero
- A single-cycle datapath (`source/examples/single_cycle/`) built from the
  same core building blocks, useful as a testable reference for what the
  pipeline should compute

## Layout

```
source/
  core/                       building blocks shared by both designs
    pc.v                      program counter
    instruction_memory.v      instruction ROM
    register_file.v           32×32-bit regfile, x0 hardwired to 0
    imm_gen.v                 I/S/B-type immediate generation
    control_unit.v            opcode -> control signal decode
    alu_control.v             alu_op + funct3/funct7 -> ALU opcode
    alu.v                     add/sub/and/or/xor/slt
    data_memory.v             64-word data RAM

  pipeline/                   the 5-stage pipelined core
    if_stage.v, if_id.v           IF stage + IF/ID register
    id_stage.v, id_ex.v           ID stage + ID/EX register
    ex_stage.v, ex_mem.v          EX stage + EX/MEM register
    mem_stage.v, mem_wb.v         MEM stage + MEM/WB register
    wb_stage.v                    WB mux
    hazard_detection.v            load-use stall logic
    forwarding_unit.v             EX/MEM & MEM/WB -> EX forwarding
    top_pipeline.v                wires all of the above together

  examples/single_cycle/
    top.v                     single-cycle datapath built from source/core

tb/
  unit/                       one testbench per building block
    alu_tb.v, alu_control_tb.v, control_unit_tb.v,
    pc_im_tb.v, regfile_immgen_tb.v,
    hazard_detection_tb.v, forwarding_unit_tb.v

  pipeline/                   full-pipeline testbenches
    top_pipeline_tb.v         basic run, dumps per-cycle trace + final regs
    top_pipeline_flush_tb.v   verifies a taken branch flushes correctly
    regression_tb.v           one program exercising EX->EX forwarding,
                               load-use stall, and branch flush together,
                               with known preloaded inputs so every final
                               register value is independently checkable

  examples/single_cycle/
    top_tb.v                  testbench for the single-cycle reference design
```

## Instruction set support

| Type            | Instructions                                | Notes |
|-----------------|----------------------------------------------|-------|
| R-type          | `add`, `sub`, `and`, `or`, `xor`, `slt`       | |
| I-type ALU      | `addi`, `andi`, `ori`, `xori`, `slti`         | shares `alu_control` decode with R-type |
| Load            | `lw`                                          | word-aligned only; `funct3` isn't decoded, so all loads act as `lw` |
| Store           | `sw`                                          | word-aligned only; all stores act as `sw` |
| Branch          | `beq`                                         | `funct3` isn't decoded, so all branches behave as `beq` |

This is a deliberately minimal ISA subset — enough to exercise every hazard
type (RAW through ALU ops, load-use, and control hazards) without the extra
decode complexity of byte/half-word memory access or the full branch family.

## Building & running the tests

Requires [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog` / `vvp`).

```bash
make test               # everything: unit + pipeline + single-cycle
make test-unit          # per-module testbenches only
make test-pipeline      # full pipeline: basic run + flush + regression
make test-single-cycle  # single-cycle reference design only
make clean              # remove build/ (compiled sims + .vcd waveforms)
```

Individual targets are also available, each printing its own pass/fail
`$display` output:

```
alu  alu_control  control_unit  pc_im  regfile_immgen
hazard_detection  forwarding_unit  pipeline  flush  regression  single_cycle
```

e.g.:

```bash
make regression
```

All compiled simulations and `.vcd` waveforms land in `build/` (git-ignored),
so the repo stays clean between runs.

### Running a single testbench manually

If you'd rather not use `make`, any testbench can be built and run directly:

```bash
iverilog -o sim_regression source/core/*.v source/pipeline/*.v tb/pipeline/regression_tb.v
vvp sim_regression
```

Swap in `tb/pipeline/top_pipeline_flush_tb.v` (or any other testbench) to
run something else the same way. This drops the compiled binary and its
`.vcd` waveform in the current directory — both are already covered by
`.gitignore`.

### Viewing waveforms

Every testbench calls `$dumpfile` / `$dumpvars`, so a `.vcd` is produced on
every run. Open it in [GTKWave](http://gtkwave.sourceforge.net/) or a VS Code
waveform extension (e.g. WaveTrace) — nothing extra to configure.

```bash
gtkwave build/regression_tb.vcd
```

## Hazard handling, in detail

- **Load-use stall** (`hazard_detection.v`): compares the two source
  registers of the instruction currently in ID against the destination
  register of a `lw` currently in EX. On a match, it holds the PC and IF/ID
  register for one cycle (`pc_write` / `if_id_write` low) and forces a
  bubble into ID/EX (`control_mux_sel`), so the load's result is available
  by the time the dependent instruction re-enters EX.
- **Forwarding** (`forwarding_unit.v` + `ex_stage.v`): every cycle, EX's
  source registers are compared against the destination registers in
  EX/MEM and MEM/WB. A match forwards that value directly into the ALU
  operand (and into store data for `sw`), with EX/MEM taking priority over
  MEM/WB since it's the more recent result.
- **Control hazard / flush**: branches are resolved in EX (`ex_branch &&
  ex_zero`). On a taken branch, the instruction already fetched into IF/ID
  is flushed to a bubble and the PC is redirected to the branch target —
  a one-instruction penalty per taken branch.
- **WB → ID same-cycle write**: the register file writes on the **falling**
  clock edge rather than the rising edge. This lets a same-cycle
  write-then-read (the classic case where a value's producer and consumer
  are exactly 3 instructions apart) settle before the next rising edge
  reads it, without needing a dedicated WB→ID forwarding path.
