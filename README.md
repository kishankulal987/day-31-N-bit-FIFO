# 🧮 N-bit FIFO in Verilog

## 📝 Overview
This project implements an **N-bit FIFO (First-In, First-Out)** buffer in **Verilog** to manage data flow in pipelined systems. The module is **parameterized** for configurable `DEPTH` and `WIDTH`, and supports:
- Write and read operations
- `full` and `empty` status flags
- synchronous reset

For example, with `DEPTH=8` and `WIDTH=32`, writing `din=0x00000001` when not full updates the FIFO, and reading when not empty retrieves the same value via `dout`.

---

## 📦 Module: `FIFO_Nbit`

### ✅ Features
- Parameterized FIFO depth and data width
- synchronous reset
- Full and empty detection
- Behavioral style design

### 🎛️ Parameters
- `DEPTH`: Number of entries in the FIFO (default: 8)
- `WIDTH`: Bit width of each entry (default: 32)

### 🔌 Inputs
| Signal | Description |
|--------|-------------|
| `clk`   | Clock signal |
| `cs`    | Chip select (enable) |
| `reset` | synchronous reset |
| `we`    | Write enable |
| `re`    | Read enable |
| `din[WIDTH-1:0]` | Data input |

### 🔋 Outputs
| Signal | Description |
|--------|-------------|
| `dout[WIDTH-1:0]` | Data output |
| `full`   | High if FIFO is full |
| `empty`  | High if FIFO is empty |

---

## ⚙️ Internal Working

- Calculated `fifo_depth = $clog2(DEPTH)`
- Storage: `reg [WIDTH-1:0] fifo[0:DEPTH-1]`
- Pointers: `write_p` and `read_p`
- **Write Logic**:
  - If `reset = 1`, clear `write_p`
  - If `cs = 1 && we = 1 && !full`:  
    → `fifo[write_p] = din`  
    → `write_p++`
- **Read Logic**:
  - If `reset = 1`, clear `read_p`
  - If `cs = 1 && re = 1 && !empty`:  
    → `dout = fifo[read_p]`  
    → `read_p++`
- **Flags**:
  ```verilog
  empty = (read_p == write_p);
  full  = (read_p == {~write_p[fifo_depth], write_p[fifo_depth-1:0]});
### 🚩 Flags
| Signal | Description |
|--------|-------------|
| `full`  | Asserted when FIFO is full |
| `empty` | Asserted when FIFO is empty |

---

## ⚙️ How It Works

- `fifo_depth = $clog2(DEPTH)` determines pointer width.
- FIFO storage is an array: `reg [WIDTH-1:0] fifo [0:DEPTH-1]`.
- `write_p` and `read_p` track write and read positions.

### ✍️ Write Operation (`always @(posedge clk or posedge reset)`)
- On `reset`, `write_p` is cleared.
- On `we == 1`, `cs == 1`, and `!full`, write `din` to `fifo[write_p]`, then increment `write_p`.

### 📤 Read Operation (`always @(posedge clk or posedge reset)`)
- On `reset`, `read_p` is cleared.
- On `re == 1`, `cs == 1`, and `!empty`, read from `fifo[read_p]` into `dout`, then increment `read_p`.

### ⚖️ Status Logic (Combinational)
- `empty = (read_p == write_p)`
- `full  = (read_p == {~write_p[fifo_depth], write_p[fifo_depth-1:0]})` (circular buffer detection)

---

## 🧪 Testbench: `FIFO_tb`

### 🎯 Objective
Verify the FIFO’s functionality across various scenarios using simulation.

### 🧰 Features
- Parameters: `DEPTH = 8`, `WIDTH = 32`
- Clock generation: `#5 clk = ~clk` (10ns period)
- `reset = 1` for 10ns, then deasserted

### 📚 Test Cases
1. **Fill FIFO**: Write 8 values (0x01 to 0x08), check `full`
2. **Write on Full**: Attempt to write (0x09), verify no change
3. **Empty FIFO**: Read all 8 values, check `empty`
4. **Read on Empty**: Attempt read, verify no change
5. **Alternate**: Write `0xA5A5A5A5`, read; then write `0x5A5A5A5A`, read

### 📘 Tasks Used
- `write_data(value)` – Performs write operation
- `read_data()` – Performs read operation

## 🛠️ Files

| File         | Description                                  |
|--------------|----------------------------------------------|
| `FIFO_Nbit.v`| Verilog module that implements the N-bit FIFO|
| `FIFO_tb.v`  | Testbench for verifying FIFO functionality   |

> Make sure both files are in the same project directory when simulating.

---

## 📷 Circuit Diagram

![Sync_fifo_block](https://github.com/user-attachments/assets/b57b469c-2eb3-4c09-89ef-bda05c9c629b)

---

## 📈 Simulation Waveform

![Screenshot 2025-07-02 210720](https://github.com/user-attachments/assets/dfbaa574-2da2-4722-87cb-e79c8a5dd049)
> *Illustrates the timing of `clk`, `reset`, `we`, `re`, `din`, `dout`, `full`, and `empty` signals during simulation.*

---

## 🧾 Console Output

![Screenshot 2025-07-02 210841](https://github.com/user-attachments/assets/baa2f777-ca93-44ec-b97a-8b7c5f1f78de)
> *Shows logs of FIFO transactions such as:*
> - `Write: 00000001, Full: 0, Empty: 1`
> - `Read: 00000001, Full: 0, Empty: 0`

---
