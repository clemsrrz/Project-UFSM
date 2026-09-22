# CV32E40P - Zb Extension (internship work)

> This folder is a **fork of the official OpenHW Group CV32E40P
> repository**. This file specifically documents the work carried out
> during the internship: getting hands-on with the processor and the
> full implementation of the **Zb** bit-manipulation extension. For the
> original processor core documentation, see
> [`README_OPENHW.md`](README_OPENHW.md).

## Objective

- Understand the internal workings of the CV32E40P RISC-V core (4-stage
  pipeline: IF, ID, EX, WB).
- Implement the **7 Zb sub-extensions** (Zba, Zbb, Zbc, Zbs, Zbkb,
  Zbkc, Zbkx), with a view to a future integration of AES directly into
  the processor (several Zb instructions, such as `clmul` or `xperm8`,
  accelerate operations used in AES).

The actual integration of AES into the processor and the UVM verification
of the core + Zb were **not** carried out within the internship's time
frame.

## Files modified for Zb

The original RTL core and trace environment were modified in the
following places (the rest of the repository is unchanged compared to
upstream OpenHW):

| File | Role in the Zb implementation |
|---|---|
| `rtl/include/cv32e40p_pkg.sv` | New opcodes / parameters related to Zb |
| `rtl/cv32e40p_decoder.sv` | Recognition of the new instructions (decoding of the Zb opcodes, without conflict with the existing instruction set) |
| `rtl/cv32e40p_alu.sv` | Implementation of the new operations (shift+add, bit masking, carry-less multiplication, rotation, permutations, etc.) |
| `rtl/cv32e40p_id_stage.sv` | Propagation of the Zb control signals from the decoder to the ALU |
| `rtl/cv32e40p_core.sv`, `rtl/cv32e40p_top.sv` | Propagation of the Zb parameters at the core/top level |
| `bhv/cv32e40p_instr_trace.svh`, `bhv/include/cv32e40p_tracer_pkg.sv`, `bhv/cv32e40p_tb_wrapper.sv` | Recognition and display of the new instructions in `trace_core_00000000.log` |
| `example_tb/core/Makefile` | Addition of a **Cadence Xcelium** simulation flow (`xrun-run`, `custom-xrun-run`) alongside the original `vsim`/ModelSim flow |

## The 7 implemented sub-extensions

| Sub-extension | Instructions | Reuse of existing circuits |
|---|---|---|
| **Zba** | `sh1add`, `sh2add`, `sh3add` | Reuses the existing adder (adds a shift before the addition) |
| **Zbs** | `bset`, `bclr`, `binv`, `bext` (+ immediate variants) | Reuses a bit-masking mechanism already present |
| **Zbc** | `clmul`, `clmulh`, `clmulr` | Entirely new: combinational logic for a 64-bit carry-less multiplication |
| **Zbb** | `andn`, `orn`, `xnor`, `clz`, `ctz`, `cpop`, `min`/`max`, `rol`/`ror`(`i`), sign extensions, `rev8`... | Reuses shift, comparators and small counting modules already present; `rol` and the rest are new |
| **Zbkb** | `pack`, `packh`, `brev8`, `zip`/`unzip` (+ instructions shared with Zbb) | `pack` shares the opcode of `zext.h` (Zbb) |
| **Zbkc** | `clmul`, `clmulh` | Identical to Zbc, just a widening of the decoder condition |
| **Zbkx** | `xperm4`, `xperm8` | Entirely new: reorganization of bit blocks via an index register |

Each instruction was tested and validated by systematically cross-checking
the terminal, the trace file `trace_core_00000000.log` and the Cadence
simulation.

## How to build and run

### Prerequisites

- Environment variable `RISCV` pointing to an installation of the
  [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain)
  (`riscv32-unknown-elf-gcc`, etc.).
- Cadence Xcelium module loaded by the makefile (`module add
  cdn/xcelium/xcelium2409`, adjustable via the `XCELIUM_MOD` variable).

All commands are run from `example_tb/core/`.

```bash
cd example_tb/core
```

### Running the Zb extension tests

```bash
make custom-xrun-run              # Compiles hello_world.c, simulates the core, prints the results in the terminal
make custom-xrun-run GUI=1        # Same, with the Cadence interface to observe the waveforms
```

This target compiles `custom/hello_world.c` with `riscv32-unknown-elf-gcc`
(`-march=rv32imc`), generates the corresponding `.hex` file, then runs
`xrun` on the testbench (`tb_top`).

`custom/hello_world.c` was modified during the internship: the original
"hello world!" was replaced with the validation tests for the 7 Zb
sub-extensions. For each of them, the file contains the manual encoding
of the instructions (via inline assembly, since no compiler natively
recognizes the Zb mnemonics), a C wrapper calling each instruction, and
for some of them (for example `clmul`/`clmulh`/`clmulr` from Zbc) a small
software reference model used to validate the result. This is the same
file that was used to test and validate the 7 sub-extensions as they were
implemented.

### Checking the execution trace

Each simulation generates `trace_core_00000000.log`, which lists every
executed instruction along with the PC (Program Counter) value at each
cycle. It is the main tool for checking that a Zb instruction was
correctly decoded and executed at the right time (by comparing with the
registers observed on Cadence).

### Cleanup

```bash
make custom-clean       # Removes the generated .elf/.hex
make xrun-clean         # Removes Xcelium logs/history
```

## Testing a new instruction / writing your own program

1. Write (or adapt) a C program in `example_tb/core/custom/`, for
   example based on `custom/hello_world.c`, with inline assembly to
   directly call a Zb instruction (e.g. `sh1add`, `clmul`, `pack`...).
2. Recompile and rerun: `make custom-xrun-run`.
3. Check the result at three levels, as done during the internship:
   - the output printed in the terminal;
   - the matching line in `trace_core_00000000.log` (which
     instruction, which register, at what time);
   - the value of the relevant register in Cadence simulation (`GUI=1`).

## Limitations and next steps

- No **UVM** verification was performed on the core + Zb extension
  (the full UVM environment for the CV32E40P, developed by Vinicius, is
  still being finalized and could not be reused within the internship's
  time frame).
- The **integration of AES** into the processor, building on the Zb
  instructions implemented here, remains to be done.
- A UVM verification of the processor with AES integrated would be the
  final step of this work.
