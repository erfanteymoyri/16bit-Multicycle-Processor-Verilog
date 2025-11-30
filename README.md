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

### :computer: About The Project

This repository contains the Verilog implementation of a **16-bit Multi-Cycle Processor**. The design features a modular architecture, breaking down complex arithmetic operations into efficient hardware blocks. The processor supports a custom ISA with both **R-Type** (Arithmetic) and **M-Type** (Memory) instructions.

The core focus of this implementation is hardware optimization using advanced algorithms like **Karatsuba Multiplication** and **Carry Select Addition**.

---

### :gear: Architecture & Modules

The project is built using a bottom-up design approach. Below are the key components based on the file structure:

#### 1. Top-Level Integration
* **`Top.v`**: The main processor module that connects the Datapath (ALU, Registers, Memory) with the Control Unit.
* **`ControlUnit.v`**: Manages the multi-cycle state machine and generates control signals for each stage of execution.

#### 2. Arithmetic Logic Unit (ALU) Breakdown
The `ALU.v` acts as a wrapper for specialized sub-modules:

* **Addition/Subtraction:**
    * **`CarrySelectAdder16.v`**: 16-bit adder using the Carry Select algorithm for speed.
    * **`RippleCarryAdder4.v`**: Basic 4-bit building block used within the larger adders.
    * **`FullAdder.v`**: The fundamental 1-bit adder cell.
    
* **Multiplication (Karatsuba):**
    * **`KaratsubaMultiplier16.v`**: Implements the recursive Karatsuba algorithm to multiply 16-bit numbers.
    * **`ShiftAddMultiplier8.v`**: An 8-bit multiplier used as the base case for the Karatsuba recursion.

* **Division:**
    * **`RestoringDivider16.v`**: Implements the Restoring Division algorithm (iterative subtraction/shift).

#### 3. Memory & Storage
* **`RegisterFile.v`**: Contains the 4 General Purpose Registers (GPRs).
* **`Register.v`**: A generic register module used for internal state storage (PC, IR, MDR, etc.).
* **`MainMemory.v`**: A unified 16-bit word-addressable memory for instructions and data.

---

### :file_folder: File Structure

```text
.
├── ALU.v                     # ALU Top module
├── CarrySelectAdder16.v      # Optimized Adder
├── ControlUnit.v             # Controller FSM
├── FullAdder.v               # 1-bit Adder
├── KaratsubaMultiplier16.v   # Optimized Multiplier
├── MainMemory.v              # RAM
├── Register.v                # D-FlipFlop/Register module
├── RegisterFile.v            # GPRs (R0-R3)
├── RestoringDivider16.v      # Divider Module
├── RippleCarryAdder4.v       # 4-bit Adder block
├── ShiftAddMultiplier8.v     # 8-bit Multiplier block
├── Top.v                     # Processor Entry Point (CPU)
└── testbench.v               # Simulation Testbench
