# Asynchronous FIFO (SystemVerilog)

This repository implements an Asynchronous FIFO (First-In, First-Out) in SystemVerilog to provide reliable data transfer between two independent clock domains. The design focuses on robust metastability handling using Gray code pointer synchronization, correct full/empty detection across domains, and a simple, parameterizable interface suitable for FPGA and ASIC flows. The repository also includes a functional verification environment to exercise the design under realistic asynchronous conditions.

## Features

- Independent write and read clock domains (asynchronous clocks).
- Gray code pointer conversion and multi-stage synchronizers to prevent metastability when crossing clock domains.
- Correct full and empty generation across domains without data corruption or false flags.
- Parameterizable data width and FIFO depth.
- Uses a dual-port memory structure (inferred or explicit block RAM) for storage.
- Functional verificationbench (SystemVerilog testbench) to cover common corner cases including simultaneous wrap-around, back-to-back writes/reads, and varying clock ratios.

## Theory of operation

1. Pointer representation and Gray code
   - The write and read pointers are maintained independently in their respective clock domains. Each pointer increments on successful write/read events.
   - To transfer pointer values across clock domains safely, pointers are converted to Gray code before being synchronized to the other domain. Gray code has the property that only one bit changes between successive values, which reduces the chance of transient misinterpretation during metastability windows.

2. Synchronization and metastability
   - Each transferred Gray-coded pointer is passed through a multi-stage flip-flop synchronizer (commonly two or more stages) in the receiving clock domain. This greatly reduces the probability of metastability affecting downstream logic.
   - After synchronization, the Gray code is converted back to binary to allow arithmetic comparisons (distance calculation) for full/empty detection and level counting.

3. Full / Empty detection
   - Empty is detected in the read domain by comparing the synchronized (from write) write pointer with the read pointer. When they are equal, FIFO is empty (no unread data).
   - Full is detected in the write domain by comparing the write pointer with the synchronized (from read) read pointer. A common technique compares the next write pointer value with the read pointer with the most-significant-bit (MSB) inverted (for circular buffer wrap detection), or equivalently computes the distance between pointers considering the FIFO depth. Using synchronized pointer values ensures decisions are made using stable information from the other domain.

4. Dual-port memory
   - Storage is typically implemented using a true dual-port memory (one port for write clock domain, one port for read clock domain). On FPGAs this can be inferred as block RAM (BRAM). For ASIC flows a register-based or multi-ported memory macro may be used.

## Implementation details

The implementation follows a modular approach:

- fifo_core.sv (or similar)
  - Top-level module that instantiates write-side pointer logic, read-side pointer logic, pointer synchronizers, and the storage memory.
  - Exposes the standard FIFO interface signals (see Interface below).

- write_ptr.sv
  - Maintains the write pointer in the write clock domain.
  - Generates write-side full flag by comparing the binary write pointer (or next pointer) with the synchronized read pointer coming from the read domain.
  - Converts the binary pointer into Gray code for transfer.

- read_ptr.sv
  - Maintains the read pointer in the read clock domain.
  - Generates read-side empty flag by comparing the binary read pointer with the synchronized write pointer coming from the write domain.
  - Converts the binary pointer into Gray code for transfer.

- sync_regs.sv
  - Implements a parameterizable N-stage synchronizer used to transfer Gray-coded pointers between domains.
  - Typically two flip-flops are used, but this is configurable for stricter metastability mitigation.

- dual_port_mem.sv
  - Simple dual-port storage abstraction. For FPGA synthesis this should infer block RAM if depth and access patterns are appropriate.

Note: The actual file names in this repository may differ — the above list describes the logical modules and how they are organized.

## Interface (typical)

Signals typically used in the FIFO top-level:

- input wire wr_clk
- input wire rd_clk
- input wire rst_n  (active-low reset) or rst (active-high) — follow the repo's reset convention
- input wire wr_en
- input wire rd_en
- input wire [DATA_WIDTH-1:0] din
- output wire [DATA_WIDTH-1:0] dout
- output wire full
- output wire empty
- optional: output wire [ADDR_WIDTH:0] wr_level, rd_level (status)

Behavior notes:
- A write occurs when wr_en is asserted and full is not asserted on rising edge of wr_clk.
- A read occurs when rd_en is asserted and empty is not asserted on rising edge of rd_clk.
- Reset should initialize pointers and synchronizers to a known state; after reset pointers are equal and FIFO is empty.

## Parameterization

Typical parameters to expose:
- DATA_WIDTH: number of data bits per word.
- ADDR_WIDTH or FIFO_DEPTH: controls the FIFO depth as 2**ADDR_WIDTH entries (common for power-of-two depth implementations to simplify modulo arithmetic).
- SYNC_STAGES: number of flip-flops used in the cross-domain synchronizer (default 2).

Choosing FIFO depth
- Power-of-two depths simplify pointer arithmetic and Gray code conversion modulo wrap-around, which is why many implementations size the memory to 2^N entries.

## Simulation and verification

- Use a SystemVerilog testbench that drives the write and read clock domains with independent clock generators. Vary the clock frequencies and phase relationships to stress synchronization.
- Stimulus should include random write and read enables, boundary conditions such as trying to write while full and reading while empty, and sequences that force pointer wrap-around.
- Check for data integrity: data read out must match the sequence written in-order and without corruption or duplication.
- Check robust handling near the full and empty thresholds: ensure no false positives or negatives for flags occur even with asynchronous clocks.

Suggested flow:
- Run with a SystemVerilog simulator (VCS, Questa/ModelSim, Xcelium, or open-source Verilator with additional SV support) and record waveforms for visual verification.
- Create functional coverage or assertions for key properties (e.g., no write when full, no read when empty, pointer monotonicity modulo depth).

## Synthesis considerations

- Infer or instantiate a dual-port RAM primitive for storage to reduce area and timing overhead instead of large register arrays.
- Keep the synchronizer (Gray code and register chain) purely sequential; avoid combinational paths that depend on unsynchronized signals from the other domain.
- For FPGAs, map the read and write ports to the FPGA's true dual-port BRAM resources where possible to get best performance.
- Avoid using asynchronous resets on memory primitives that do not support them; prefer synchronous resets or reset sequencing that is compatible with target technology.

## Example instantiation (conceptual)

```systemverilog
// Parameters for example
localparam DATA_WIDTH = 32;
localparam ADDR_WIDTH = 6; // 64-depth FIFO

async_fifo #(
  .DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH),
  .SYNC_STAGES(2)
) u_async_fifo (
  .wr_clk  (wr_clk),
  .rd_clk  (rd_clk),
  .rst_n   (rst_n),
  .wr_en   (wr_en),
  .rd_en   (rd_en),
  .din     (din),
  .dout    (dout),
  .full    (full),
  .empty   (empty)
);
```

Adjust parameter names and ports to the concrete module names used in the repository.

## Tests and recommended checks

- Run corner-case scenarios:
  - Read and write at nearly equal rates to reveal ordering issues.
  - Large bursts of writes followed by large bursts of reads to test wrap-around.
  - Randomized patterns with checker logic to validate integrity.
- Use assert statements to catch illegal conditions in simulation early.

## Documentation and comments

- Keep pointer arithmetic, Gray conversion, and synchronization stages commented and documented — these are the most subtle and critical parts of the design.
- Clearly document any assumptions made about reset polarity, clock domain crossing behavior, and memory inference requirements.

## Licensing

If you intend others to reuse the code, include an appropriate LICENSE file (MIT, Apache-2.0, or other). This repository does not modify licensing; add a license file at the repo root if you want to permit reuse.

## Contact / Contributing

- If you want to contribute, open issues or pull requests describing proposed changes, additional verification, or desirable features such as almost-full flags, asynchronous almost-empty thresholds, or integrated AXI-Stream/ready-valid adapters.



