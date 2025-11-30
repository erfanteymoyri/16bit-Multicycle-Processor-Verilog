<div align="center">
  <img src="https://cdn.freebiesupply.com/logos/large/2x/sharif-logo-png-transparent.png" width="150" height="150" alt="Sharif University Logo">
  <br><br>
  <h1 align="center">16-bit Multi-Cycle Processor Design</h1>
  <h2 align="center">Digital Systems Design (DSD) Course Project</h2>
  <p align="center">
    <b>Spring 1404 (2025)</b> | <b>Dr. Amin Foshati</b>
  </p>
</div>

---

### 📖 Overview

This repository hosts the complete Verilog implementation of a **16-bit Multi-Cycle Processor**. Unlike single-cycle architectures, this design breaks down instruction execution into multiple clock cycles, allowing for more complex arithmetic operations and efficient hardware reuse.

The processor features a custom **Instruction Set Architecture (ISA)** supporting arithmetic, logical, and memory operations. The core highlight of this project is the hardware-level implementation of advanced algorithms for multiplication and division, rather than using standard Verilog operators (like `*` or `/`).

---

### 🧠 Technical Architecture & Modules

The design uses a modular approach, where the `Top.v` module integrates the **Control Unit** and the **Datapath**. Below is the detailed breakdown of the components:

#### 1. Arithmetic Logic Unit (ALU)
The ALU is the computational heart of the processor, designed to handle 16-bit signed integers (2's complement). It integrates three specialized sub-modules:

* **⚡ High-Speed Adder (Carry Select Adder):**
    * **Module:** `CarrySelectAdder16.v`
    * **Logic:** To overcome the propagation delay of standard Ripple Carry Adders, this module divides the 16-bit number into **4-bit blocks** (`RippleCarryAdder4.v`). It computes sum candidates for both `Cin=0` and `Cin=1` in parallel and selects the correct result using a multiplexer chain.
    
* **✖️ Optimized Multiplier (Karatsuba Algorithm):**
    * **Module:** `KaratsubaMultiplier16.v`
    * **Logic:** Instead of a naive $O(N^2)$ multiplication, this module uses the recursive **Karatsuba algorithm**. It splits the 16-bit inputs into Upper ($H$) and Lower ($L$) 8-bit halves.
    * **Base Case:** The recursion bottoms out at 8-bits, handled by the `ShiftAddMultiplier8.v` module.
    
* **➗ Sequential Divider (Restoring Division):**
    * **Module:** `RestoringDivider16.v`
    * **Logic:** Implements the classic **Restoring Division** algorithm. It operates iteratively over **16 clock cycles**, shifting the remainder and subtracting the divisor to determine the quotient bits.

#### 2. Memory Organization
* **Main Memory (`MainMemory.v`):** A unified architecture (Von Neumann style) where both Instructions and Data share the same address space. It is word-addressable with a depth of $2^{16}$ words.
* **Register File (`RegisterFile.v`):** Contains 4 General-Purpose Registers (**R0-R3**). It supports **Dual-Read** (for fetching two operands simultaneously) and **Single-Write**.

#### 3. Control Unit
* **Module:** `ControlUnit.v`
* **Logic:** A Finite State Machine (FSM) that orchestrates the processor's stages: **Fetch ➞ Decode ➞ Execute ➞ Memory ➞ Write Back**. It generates specific signals to control the ALU operation, memory R/W, and register updates.

---

### 📂 Project Structure

The project files are organized as follows:

```text
.
├── Top.v                     # [Top Module] Connects Control Unit and Datapath
├── ControlUnit.v             # FSM Controller for the processor
├── ALU.v                     # ALU Wrapper selecting Opcode operations
│
├── [Arithmetic Modules]
├── CarrySelectAdder16.v      # 16-bit CSA Adder
├── RippleCarryAdder4.v       # 4-bit block for CSA
├── FullAdder.v               # 1-bit Standard Adder
├── KaratsubaMultiplier16.v   # 16-bit Karatsuba Multiplier
├── ShiftAddMultiplier8.v     # 8-bit Multiplier (Base for Karatsuba)
├── RestoringDivider16.v      # 16-bit Restoring Divider
│
├── [Storage Modules]
├── RegisterFile.v            # Register File (R0-R3)
├── Register.v                # D-FlipFlop Wrapper
├── MainMemory.v              # RAM Module
│
└── testbench.v               # Simulation Testbench
