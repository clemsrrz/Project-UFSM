# AES-128 - Advanced UVM verification

This folder contains an **AES-128** encryption accelerator
(SystemVerilog, retrieved as open source) verified with a more advanced
UVM environment than the one in `adder/`: an independent reference model
in C (via DPI-C), functional coverage, fault injection and validation
against the official NIST test vectors.

## Directory structure

```
AES-128/
├── makefile                  # All simulation commands (see below)
├── frontend/                  # DUT: hardware description of AES-128
│   ├── AES.sv                  # Top-level module (encrypt/decrypt, key expansion)
│   ├── AES_encrypt.sv          # Encryption (SubBytes, ShiftRows, MixColumns, AddRoundKey)
│   ├── AES_decrypt.sv          # Decryption (inverse operations)
│   ├── key_expansion.sv        # Round sub-key generation
│   ├── s_box.sv / inv_s_box.sv # Substitution tables (forward / inverse)
│   ├── g_funct.sv              # Galois field functions used by MixColumns
│   ├── AES_tb.sv               # Original "classic" testbench (without UVM)
│   └── filelist.f
└── verification/              # UVM environment
    ├── AES_if.sv                # Interface, with the fault_injection signal (negative testing)
    ├── AES_sequence_item.sv     # Transaction (key, plaintext, ciphertext, round control)
    ├── AES_sequence.sv          # "Custom" sequence: random + dist constraints + corner cases
    ├── AES_nist_sequence.sv     # Sequence replaying the official NIST test vectors
    ├── AES_driver.sv            # Drives the DUT over the 10 encryption/decryption rounds
    ├── AES_monitor.sv           # Observes the DUT and rebuilds the transactions
    ├── AES_coverage.sv          # Functional coverage (coverpoints + cross-coverage)
    ├── AES_scoreboard.sv        # Compares the DUT to a reference model in C via DPI-C
    ├── AES_agent.sv / AES_env.sv/ AES_test.sv / AES_top.sv  # Standard UVM topology
    ├── aes.c / aes.h            # Open-source AES-128 implementation in C (reference model)
    ├── aes_dpi_bridge.c         # DPI-C bridge between SystemVerilog and the C model
    ├── NIST_KAT/KAT_AES/*.rsp   # Official NIST test vectors (AES-128 ECB)
    └── filelist.f
```

## Two available UVM tests

`AES_test.sv` contains two test classes, selectable via the makefile's
`TEST` variable:

| `TEST=` | UVM class | Usage |
|---|---|---|
| `AES_test` (default) | `AES_test` | "Custom" sequence (`AES_sequence.sv`): random messages, `dist` constraints (keys/texts uniformly 0, uniformly 1, alternating patterns), and fault injection (`fault_injection`) to cover `MixColumns` negative testing |
| `AES_nist_test` | `AES_nist_test` | Replays the official NIST test vectors (`AES_nist_sequence.sv`, ECB mode) from `verification/NIST_KAT/KAT_AES/` |

In both cases, the scoreboard does not just compare against a
SystemVerilog model: it calls, via DPI-C, the `c_aes_encrypt` /
`c_aes_decrypt` functions implemented in `aes.c` (import declared in
`AES_scoreboard.sv`) to obtain a reference that is fully independent from
the RTL under test.

## Commands

All commands are run from this folder (`AES-128/`), on the laboratory
server.

```bash
make help                          # Full list of available targets
```

### "Classic" simulation (without UVM)

```bash
make sim_rtl                       # Compile + simulate the frontend with AES_tb.sv
make sim_rtl GUI=1                 # Same, with the Cadence interface (waveforms)
```

### UVM simulation

```bash
make uvm_sim                                  # Equivalent to TEST=AES_test
make uvm_sim TEST=AES_test                    # "Custom" sequence (random + corner cases + fault injection)
make uvm_sim TEST=AES_nist_test               # Sequence replaying the NIST test vectors
make uvm_sim GUI=1                            # Add GUI=1 to any of the commands above to open Cadence
```

### Coverage

```bash
make cov_gui         # Opens Cadence IMC (run after make uvm_sim, results in cov_work/)
```

Two metrics should be checked in IMC:
- The classic **code coverage** (executed lines/branches).
- The **functional coverage** defined in `AES_coverage.sv`
  (coverpoints `cp_key`, `cp_plaintext`, `cp_fault`, and their crosses
  `cx_key_plaintext`, `cx_fault_key`, `cx_fault_plaintext`), which
  guarantees that specific categories of values (key/text uniformly 0,
  uniformly 1, alternating patterns, with/without injected fault) have
  actually been hit.

### Cleanup

```bash
make clean
```

> As with `adder/`, the makefile contains ASIC targets (`synth`,
> `layout_*`, `sweep_*`, ...) inherited from a generic laboratory
> template and not used for AES verification.

## How to modify / extend

- **Add a random scenario or a corner case**: `AES_sequence.sv`
  (the `dist` constraints on the key/plaintext are defined there).
- **Add an additional NIST test vector**: place the matching `.rsp`
  file in `verification/NIST_KAT/KAT_AES/` and check the path read by
  `AES_nist_sequence.sv` (`dir_path`).
- **Add a coverpoint**: `AES_coverage.sv`.
- **Modify the reference model**: `aes.c` (the DPI-C bridge
  `aes_dpi_bridge.c` normally does not need to be modified as long as
  the signature of the `c_aes_encrypt` / `c_aes_decrypt` functions stays
  the same).
- **Test a new hardware fault case**: the `fault_injection` mechanism is
  propagated from `AES_if.sv` down into `AES_encrypt.sv` / `AES_decrypt.sv`
  (`MixColumns` step); follow this signal if you want to inject another
  type of fault.
