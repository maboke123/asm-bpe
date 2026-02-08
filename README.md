# BPE Compression in RISC-V Assembly

A Linux userspace implementation of Byte Pair Encoding (BPE) written entirely in RISC-V assembly.  
Uses only raw RISC-V instructions and Linux syscalls — no external libraries or runtime.

---

## What is this?

This program is a simplified byte-level BPE compressor — the same concept behind tokenization in many modern language models.  
It reads a text input (up to 256 characters), compresses it iteratively by replacing the most frequent byte pairs with new tokens, and displays both the compressed output and the translation table.

Unlike high-level implementations, this version runs at the assembly level on RISC-V Linux, demonstrating compression mechanics in a minimal and interactive form.

---

## Features

- **Pure Assembly**: Entirely in RISC-V instructions, no libraries.  
- **Interactive**: Enter text and watch compression happen step-by-step.  
- **Verbose Output**: Iterations, frequency tables, and intermediate messages are printed.  
- **Detailed Statistics**: Original vs. compressed size, translation table size, and bytes saved.

---

## How it Works

1. Reads user input (max 256 characters).  
2. Counts frequencies of all byte pairs.  
3. Replaces the most frequent pair with a new token.  
4. Updates the translation table.  
5. Repeats until no more savings are possible.  
6. Prints the compressed output, translation table, and compression statistics.

---

## Build & Run

```bash
# Assemble
riscv64-linux-gnu-as bpe.s -o bpe.o

# Link
riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe

# Run in QEMU
qemu-riscv64 ./bpe

# Or all at once:
riscv64-linux-gnu-as bpe.s -o bpe.o && riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe && qemu-riscv64 ./bpe
```

## Example Output

```
==================================
Enter text to compress (max 256 chars); ababababababababababababababababababababab

Original message: ababababababababababababababababababababab
Buffer: ababababababababababababababababababababab
==================================
Iteration: 0
Frequency table: 
a, b, 21
b, a, 20
Replacing: a, b, 21 -> {
Current message: {{{{{{{{{{{{{{{{{{{{{
==================================
Iteration: 1
Frequency table: 
{, {, 20
Replacing: {, {, 20 -> |
Current message: ||||||||||{
==================================
Iteration: 2
Frequency table: 
|, |, 9
|, {, 1
Replacing: |, |, 9 -> }
Current message: }}}}}{
==================================
Iteration: 3
Frequency table: 
}, }, 4
}, {, 1
Replacing: }, }, 4 -> ~
Current message: ~~}{
==================================
Iteration: 4
Frequency table: 
~, ~, 1
~, }, 1
}, {, 1
==================================
Translation table: 
a, b -> {
{, { -> |
|, | -> }
}, } -> ~
==================================
Output message: ~~}{
==================================
Compression stats: 
Original size: 42 bytes
Compressed size: 4 bytes
Translation table entries: 4
Total translation table size: 12 bytes
Total compressed size: 16 bytes
26 bytes saved (61%)
Iterations: 4
==================================
```