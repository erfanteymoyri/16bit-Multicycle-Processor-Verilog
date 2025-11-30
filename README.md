# 16-bit Multi-Cycle Processor Design

### Digital Systems Design (DSD) — Spring 1404 (2025)

### Instructor: **Dr. Amin Foshati**

<div align="center">
  <img src="https://cdn.freebiesupply.com/logos/large/2x/sharif-logo-png-transparent.png" width="150" height="150" alt="Sharif University Logo">
</div>

---

## 📖 Overview

This repository contains the full Verilog implementation of a **16-bit Multi-Cycle Processor**. Unlike single-cycle architectures, this processor divides each instruction into multiple clock cycles, reducing hardware cost and allowing complex arithmetic operations.

This custom-designed processor features a tailored **Instruction Set Architecture (ISA)** supporting arithmetic, logic, and memory instructions. A key highlight of this design is the **hardware-level implementation of multiplication and division algorithms** rather than using built‑in Verilog operators.

---

## 🧠 Technical Architecture

The processor architecture is modular. The `Top.v` file connects the **Control Unit** and **Datapath**.

### 1. Arithmetic Logic Unit (ALU)

The ALU handles 16‑bit signed (2's complement) arithmetic and includes three major modules:

#### ⚡ High-Speed Adder — Carry Select Adder

* **Module:** `CarrySelectAdder16.v`
* The 16‑bit adder is divided into **4‑bit blocks** using `RippleCarryAdder4.v`.
* Each block computes results for both `Cin = 0` and `Cin = 1`, and then selects the correct outputs.

#### ✖️ Optimized Multiplier — Karatsuba Algorithm

* **Module:** `KaratsubaMultiplier16.v`
* Multiplies two 16‑bit numbers using a recursive **Karatsuba** approach.
* Inputs are split into Upper (H) and Lower (L) 8‑bit halves.
* The base case uses `ShiftAddMultiplier8.v` (Shift‑and‑Add method).

#### ➗ Sequential Divider — Restoring Division

* **Module:** `RestoringDivider16.v`
* Implements the **Restoring Division** algorithm.
* The division operates over **16 clock cycles**, determining quotient bits iteratively.

---

### 2. Memory Organization

#### 🧱 Main Memory (`MainMemory.v`)

* Shared Instruction + Data memory.
* Word‑addressable: **2¹⁶ × 16‑bit** memory.

#### 📦 Register File (`RegisterFile.v`)

* Contains **4 General‑Purpose Registers (R0–R3)**.
* Supports **dual‑read** and **single‑write** operations.

---

### 3. Control Unit

* **Module:** `ControlUnit.v`
* A multi‑state FSM controlling:

  * ALU operations
  * Register file writes
  * Memory read/write
  * State progression for multi‑cycle instructions

---

## 📜 Instruction Set Architecture (ISA)

The processor supports two instruction formats.

---

### **1. R‑Type (Arithmetic Instructions)**

Used for register calculations. Results are stored in `rd`.

| Opcode | Mnemonic | Function         | Algorithm            |
| ------ | -------- | ---------------- | -------------------- |
| `000`  | **ADD**  | `rd = rs1 + rs2` | Carry Select Adder   |
| `001`  | **SUB**  | `rd = rs1 - rs2` | 2's complement + CSA |
| `010`  | **MUL**  | `rd = rs1 * rs2` | Karatsuba            |
| `011`  | **DIV**  | `rd = rs1 / rs2` | Restoring Division   |

---

### **2. M‑Type (Memory Instructions)**

| Opcode | Mnemonic  | Function                                   |
| ------ | --------- | ------------------------------------------ |
| `100`  | **LOAD**  | `reg[rd] = Mem[reg[base] + SignExt(addr)]` |
| `101`  | **STORE** | `Mem[reg[base] + SignExt(addr)] = reg[rd]` |

---

## 📂 Project Structure

```
.
├── Top.v                     # Main processor module
├── ControlUnit.v             # FSM Controller
├── ALU.v                     # ALU operation selector
│
├── Arithmetic Modules
│   ├── CarrySelectAdder16.v
│   ├── RippleCarryAdder4.v
│   ├── FullAdder.v
│   ├── KaratsubaMultiplier16.v
│   └── ShiftAddMultiplier8.v
│   └── RestoringDivider16.v
│
├── Storage Modules
│   ├── RegisterFile.v
│   ├── Register.v
│   └── MainMemory.v
│
└── testbench.v               # Simulation testbench
```

---

## 🚀 Simulation Guide

You can simulate this processor using **ModelSim**, **Vivado**, **Quartus**, or **Icarus Verilog**.

### **Step 1 — Clone the Repository**

```bash
git clone https://github.com/YourUsername/16bit-Multicycle-Processor-Verilog.git
cd 16bit-Multicycle-Processor-Verilog
```

### **Step 2 — Load Files**

* Open your preferred Verilog simulator.
* Create a new project.
* Add **all `.v` files** to your project.

### **Step 3 — Select Simulation Top**

* Set **`testbench.v`** as the simulation top.
* (Do *not* select `Top.v` — it needs clock/reset stimulus from the testbench.)

### **Step 4 — Run Simulation**

* Compile all modules.
* Add the following signals to the waveform:

  * `clk`, `rst`
  * `Top_instance/PC`
  * `Top_instance/ALU_out`
  * `Top_instance/RegisterFile_instance/reg_array`

### **Step 5 — Verify Outputs**

* Multi‑cycle instructions use additional clock cycles.
* For example, **DIV** will stall the FSM longer than **ADD**.

---

## 👨‍💻 Author

**Erfan Teymouri**
