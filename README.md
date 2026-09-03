# IL2234 — RISC-V Processor Project

Digital Systems Design and Verification using Hardware Description Languages.

Over four milestones you design, verify, and implement a **RISC-V RV32I processor**
in SystemVerilog, simulate it (QuestaSim / Vivado Simulator), and run a real
program on it on the **Urbana FPGA** board. This repository is where you submit
**all** of your work.

> **Golden rule:** only source files go in this repo. Do **not** commit Vivado or
> QuestaSim files, working directories, etc


## Getting started with Git

After you've done with code, you can push it by simply doing these three steps in the terminal.

```
$ git add .
$ git commit -m "my first commit"
$ git push
```

If you are unsure, what you are gonna submit. Please check it with this command after "add"  
```
$ git status
```


---

## What you will build 

| Milestone | Topic | You design |
|:---:|---|---|
| **1** | Combinational circuits | ALU, and an ALU demo on the FPGA board |
| **2** | Register file & memory | Register File; SRAM-based memory system + ready logic |
| **3** | Decoder, control & integration | Instruction decoder; datapath + controller schematics; controller FSM; full processor |
| **4** | Complete system | CPU + memory on the FPGA running a RISC-V program |

The detailed task descriptions are in the milestone PDFs handed out separately on Canvas.

---

## Repository structure

Every deliverable has a fixed home. Put files **only** in these folders — and only
the file types shown. Anything else (including files at the top level) is ignored
by git on purpose.

| Folder | Holds | Milestone (To submit)| Allowed files |
|---|---|---|---|
| `riscv/alu/`        | ALU RTL + testbench | M1                         | `*.sv` |
| `riscv/rf/`         | Register File RTL + testbench | M2                | `*.sv` |
| `riscv/memsys/`     | Memory-system RTL + testbench (**not** the generated SRAM) | M2 | `*.sv` |
| `riscv/decoder/`  | Instruction decoder RTL | M3                      | `*.sv` |
| `riscv/controller/` | Controller FSM RTL                    | M3 | `*.sv` |
| `riscv/top/`        | Full processor (CPU) RTL + testbench         | M3 & M4 | `*.sv` |
| `fpga/m1/`          | Milestone-1 ALU-on-FPGA system RTL           |  | `*.sv` |
| `fpga/m4/`          | Milestone-4 complete system RTL + testbench | M4  | `*.sv` |
| `constr/`           | FPGA constraints (`urbana.xdc` provided)    | | `*.xdc` |
| `firmware/`         | Provided examination program + build scripts |  | C/asm sources |
| `report/`           | All PDF reports, schematics, and drawings   | M3 | `*.pdf` |


**Submission deadline:** before the examination.
**Group work:** identical content is allowed within a group (submit individually).

---

## What must NOT be committed

Keep the repository to **source files only**. The following are ignored by
`.gitignore` and must never be added:

- **Vivado** project files and working dirs 
- **QuestaSim / ModelSim** working files 
- **Toolchain build artifacts**
