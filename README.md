# x86 Storage Management

Low-level storage allocation simulator implemented in 32-bit x86 Assembly.

## Overview

This project implements a simplified block-storage management simulator in
32-bit x86 Assembly. It contains two separate implementations:

- [1D storage allocator](src/storage_1d.s) using a linear array of 1024 blocks.
- [2D storage allocator](src/storage_2d.s) using a 1024 x 1024 block matrix.

Both versions model storage allocation and support allocation, lookup, deletion,
and defragmentation. Storage is simulated in memory; this is an academic simulator,
not a production filesystem.

## Tech Stack

- 32-bit x86 Assembly using GNU assembler AT&T syntax.
- GCC build workflow, recorded in the original repository.
- libc I/O through `printf`, `scanf`, and `fflush`.
- Linux system calls through `int $0x80`.

## Features

- **ADD:** contiguous allocation by numeric storage ID.
- **GET:** lookup of an allocation's coordinates.
- **DELETE:** release of blocks associated with an ID.
- **SHOW:** internal routine for displaying active allocations.
- **DEFRAGMENTATION:** compaction or repositioning of allocated blocks.

The 2D implementation also accepts operation `5` (`CONCRETE`). It reads a path,
issues the Linux i386 `open` system call with read-only flags, and stores the
returned descriptor. It does not enumerate directory contents or allocate their
files, and does not check the result or close the descriptor.

## Storage Model

### 1D implementation

A linear array holds 1024 blocks, each represented by a 32-bit ID. Zero denotes a
free block. ADD scans for a contiguous free interval and stores the requested ID
in that interval. Requested size is converted to `ceil(size / 8)` blocks;
sizes of 8 or less are rejected by the existing implementation.
Locations use zero-based, inclusive start and end indices.

### 2D implementation

A 1024 x 1024 matrix holds 32-bit IDs, with zero marking free blocks.
The code manually translates row/column coordinates into linear memory addresses:
`base + (row * 1024 + column) * 4`. ADD scans rows for contiguous free blocks
within a single row, using the same size conversion and rejection rule as the
1D version. Locations use zero-based, inclusive row/column coordinates.

## Operations

### ADD

Finds a contiguous free region large enough for the requested allocation.
Input code: `1`, followed by an allocation count and that many `ID size` pairs.

### GET

Finds an allocation by storage ID and prints its location.
Input code: `2`, followed by the ID.

### DELETE

Clears blocks belonging to an ID, then displays remaining allocations.
Input code: `3`, followed by the ID.

### SHOW

Displays active allocations. This is an internal routine with no standalone
input code. It runs after deletion in both versions and after 1D defragmentation.

### DEFRAGMENTATION

Compacts/repositions allocated blocks to reduce fragmentation. The 1D version
moves occupied blocks left; the 2D version clears allocation runs and reinserts
them through ADD, which prints their new locations.
Input code: `4`, with no additional arguments.

## Low-Level Concepts

- General-purpose x86 registers and stack-based calls using `push`, `call`, and `ret`.
- Indexed addressing and manual traversal of storage memory.
- Integer division and multiplication for block counts and matrix addressing.
- Explicit control flow through labels, comparisons, and jumps.
- libc calls through `printf`/`scanf`, with explicit output flushing.
- Linux `int $0x80` calls for process exit in both versions and path opening in 2D.
- Manual storage-allocation and compaction logic.

## Repository Structure

```text
x86-storage-management/
├── README.md
├── .gitignore
├── src/
│   ├── storage_1d.s
│   └── storage_2d.s
├── examples/
│   ├── input_1d.txt
│   └── input_2d.txt
└── docs/
    └── assignment-notes.md
```

The [historical build note](docs/assignment-notes.md) preserves the original
repository's build context. Both Assembly files retain their original contents.

## Build and Run

Use an x86 Linux environment with GCC, GNU assembler, 32-bit libc development
files, and support for running i386 executables. On x86-64 Linux, a multilib
toolchain and 32-bit runtime are needed. Run from the repository root:

```sh
mkdir -p build
gcc -m32 -no-pie -o build/storage_1d src/storage_1d.s
gcc -m32 -no-pie -o build/storage_2d src/storage_2d.s

./build/storage_1d < examples/input_1d.txt
./build/storage_2d < examples/input_2d.txt
```

`-m32` selects 32-bit code, as in the original build note. `-no-pie` selects a
non-PIE executable to accommodate the sources' absolute symbol addressing.
These are the intended Linux build commands; full GCC linking and execution
have **not been verified** in the current environment.

Both sources were successfully assembled into Intel 80386 ELF relocatable objects
on ARM macOS using these cross-target syntax checks:

```sh
clang -target i386-linux-gnu -c src/storage_1d.s -o build/storage_1d.o
clang -target i386-linux-gnu -c src/storage_2d.s -o build/storage_2d.o
```

These checks do not link libc or validate runtime behavior. Native compilation
with the installed Apple `gcc` (Clang) failed. Both programs use the Linux i386
system-call ABI and do not run natively on modern macOS. Use a suitable x86 Linux
VM or emulated environment on an ARM Mac. The original README mentioned a Lima
environment; no VM configuration was supplied.

## Example Input

Input begins with the number of operations. Numeric values are read by `scanf`,
so spaces and newlines can separate them. The two example files use the same
source-derived input format:

```text
5
1
2
1 16
2 24
2
1
3
1
4
2
2
```

This requests five operations: ADD two allocations (IDs 1 and 2, sizes 16 and 24),
GET ID 1, DELETE ID 1, DEFRAGMENTATION, and GET ID 2.
Use [input_1d.txt](examples/input_1d.txt) or
[input_2d.txt](examples/input_2d.txt) with its corresponding executable.
These examples were derived from the source's input handling; they have not been
executed in a Linux runtime.

## Known Limitations

- Targets 32-bit x86 and uses Linux-specific system calls.
- Fixed-size storage structures; 2D allocations must fit within a single row.
- ADD rejects requested sizes of 8 or less.
- Academic, in-memory storage simulation rather than a real filesystem.
- The 2D path operation only opens a path and remains incomplete.
- No automated test suite is included; runtime behavior has not been validated
  during this reorganization.

## Academic Context

Developed as part of the Computer Systems Architecture coursework at the University of Bucharest.

## Author

Pal Robert-Attila
