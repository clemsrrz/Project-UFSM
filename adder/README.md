# 8-bit Adder - Getting started with SystemVerilog + UVM

This folder contains a signed 8-bit adder (with carry in/out) together
with a full **UVM** verification environment. It was used to get familiar
with SystemVerilog and then with the UVM methodology, before moving on to
more complex circuits (AES).

## Directory structure

```
adder/
├── makefile                 # All simulation commands (see below)
├── frontend/
│   ├── adder.sv              # DUT: signed 8-bit adder, with carry_i/carry_o
│   ├── adder_tb.sv           # "Classic" testbench (without UVM), for the first hands-on test
│   └── filelist.f            # List of compiled frontend files
└── verification/             # Full UVM environment
    ├── adder_if.sv            # Interface: electrical bridge between the DUT and UVM
    ├── adder_sequence_item.sv # Transaction: packet (a, b, carry_i, sum, carry_o)
    ├── adder_sequence.sv      # Test sequence + adder_sequencer class
    ├── adder_driver.sv        # Translates an item into signals applied to the DUT
    ├── adder_monitor.sv       # Observes the DUT and rebuilds an item from the outputs
    ├── adder_scoreboard.sv    # Compares the DUT's result to a reference model
    ├── adder_agent.sv         # Groups sequencer + driver + monitor
    ├── adder_env.sv           # Connects agent, scoreboard (testbench topology)
    ├── adder_test.sv          # Entry point: instantiates the env and starts the sequence
    ├── adder_top.sv           # SystemVerilog root module, starts run_test("adder_test")
    └── filelist.f             # List of compiled UVM files
```

## How it works

The flow is standard UVM: `adder_test` builds `adder_env`, which assembles
`adder_agent` (sequencer + driver + monitor) and the `adder_scoreboard`.
The sequence (`adder_sequence.sv`) generates three families of scenarios
sent to the DUT via the driver:

1. 20 **random** draws of `a`, `b`, `carry_i`.
2. Deterministic **corner cases** (`0 + 0`, `127 + 127`, `-128 + -128`,
   overflows, etc.).
3. **Cross-coverage** combinations (sign of `a`, sign of `b`,
   `carry_i` at 0 or 1, to systematically sweep the combinations).

The monitor captures the DUT's outputs (`sum`, `carry_o`) and forwards
them to the scoreboard, which compares them against an internally
computed reference model and prints `[SB_PASS] Match!` or
`[SB_FAIL] Mismatch!`.

## Commands

All commands are run from this folder (`adder/`), on the laboratory
server (Cadence modules are loaded automatically by the makefile).

```bash
make help          # Full list of available targets
```

### "Classic" simulation (without UVM)

```bash
make sim_rtl              # Compile + simulate adder.sv with adder_tb.sv, result in the terminal
make sim_rtl GUI=1        # Same, but opens the Cadence interface (signal waveforms)
```

In the Cadence interface (`GUI=1`), to view the signals: in
`simulator -> adder_tb -> DUT`, right-click then *"send to waveform window"*.

### UVM simulation

```bash
make uvm_sim               # Runs the full UVM environment (adder_test)
make uvm_sim GUI=1         # Same, with the Cadence interface to observe the signals
```

### Code coverage

Once `make uvm_sim` has been run (results are saved in `cov_work/`):

```bash
make cov_gui        # Opens the Cadence IMC interface to view coverage (%)
```

IMC shows, line by line and signal by signal, what was exercised during
the simulation. A red line (0%) indicates a signal that was never
exercised.

### Cleanup

```bash
make clean          # Removes xcelium logs/history (xcelium.d, xrun.log, ...)
```

> The makefile also contains ASIC flow targets (`synth`,
> `layout_innovus`, `sweep_*`, `innovus_power`, ...) inherited from a
> generic laboratory template. They are not used as part of the UVM
> verification for this internship: only `sim_rtl`, `uvm_sim`, `cov_gui`
> and `clean` are relevant here.

## How to modify / extend the tests

- **Add a corner case**: in `verification/adder_sequence.sv`, add
  an item with fixed values (`item.a = ...; item.b = ...;`) in the
  deterministic test phase.
- **Change the number of random draws**: modify the `repeat
  (20)` loop in `adder_sequence.sv`.
- **Add a signal to the interface** (e.g. a new DUT port): declare it
  in `adder_if.sv`, then propagate it in `adder_sequence_item.sv`,
  `adder_driver.sv` and `adder_monitor.sv`.
- **Change the pass/fail criterion**: the comparison is done in
  `adder_scoreboard.sv` (function called for each item received from the
  monitor).
