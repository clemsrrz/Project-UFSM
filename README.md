# UFSM Project - GMICRO 2nd-Year Internship (Bordeaux INP - ENSEIRB-MATMECA)

This repository gathers all the work carried out during a 2nd-year
internship at the **GMICRO** (Microelectronics Group) laboratory of the
**University Federal of Santa Maria (UFSM)**, in Brazil, supervised by
Mateus Beck Rutzig and accompanied on a daily basis by Vinicius Rocca.

The internship focused on the **functional verification** of digital
circuits using the **UVM (Universal Verification Methodology)** in
**SystemVerilog**, as well as on **modifying a RISC-V processor** to add
new instructions to it. The work was carried out progressively, with
increasing complexity, which explains the organization of the repository
into three folders.

## Overview of the three sub-projects

| Folder | Content | Purpose |
|---|---|---|
| [`adder/`](adder/README.md) | Signed 8-bit adder + UVM testbench | Getting started with SystemVerilog and the UVM flow on a simple circuit |
| [`AES-128/`](AES-128/README.md) | AES-128 encryption accelerator + advanced UVM testbench | Applying UVM to a complex circuit, verified via a reference model in C (DPI-C), functional coverage and the official NIST test vectors |
| [`cv32e40p/`](cv32e40p/README.md) | CV32E40P RISC-V processor core (fork of the OpenHW Group repository) + implementation of the **Zb** bit-manipulation extension | Getting hands-on with a real RISC-V processor and adding the 7 Zb sub-extensions, with a view to a future integration of AES into the processor |

Each folder has its own README explaining in detail **how to use it**
(commands, internal directory structure, how to modify/extend the tests).
The root README intentionally only gives an overview and redirects to
these guides.

## Internship progression

The work followed a progressive learning path:

1. **Adder** (`adder/`): getting started with SystemVerilog and UVM
   on a simple circuit, up to 100% code coverage.
2. **AES-128** (`AES-128/`): applying UVM to a complex circuit
   (encryption accelerator retrieved as open source), then strengthening
   the verification with a reference model in C via DPI-C, functional
   coverage and the official NIST test vectors.
3. **CV32E40P + Zb extension** (`cv32e40p/`): studying a full RISC-V
   processor (OpenHW Group) and implementing the 7 Zb bit-manipulation
   sub-extensions (Zba, Zbb, Zbc, Zbs, Zbkb, Zbkc, Zbkx), in preparation
   for a future integration of AES directly into the processor.

## Common prerequisites

All the simulations in this repository were developed and run on the
GMICRO laboratory server, accessible via SSH, and require:

- **Cadence Xcelium** (`xrun`): RTL/UVM simulator, loaded through a module
  system (`module add cdn/xcelium/...`) and a laboratory license.
- **Cadence IMC** (`imc`): code coverage viewer (`make cov_gui`
  in `adder/` and `AES-128/`).
- **GNU Make** and a bash shell.
- For `cv32e40p/`: a **RISC-V GNU Toolchain** (environment variable
  `RISCV` pointing to the installation).

As these tools are proprietary and/or specific to the laboratory
environment, the commands described in each sub-project's README can only
be reproduced from a machine with access to these licenses and modules
(typically the GMICRO server). Each sub-README details the `make`
commands specific to its folder.

## Author

Clément Sarrazin - ENSEIRB-MATMECA, Bordeaux INP.
