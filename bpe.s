.data
    user_input:
        .asciz "aabcdefgh"
    user_input_end:
    user_input_length = user_input_end - user_input

    newline:
        .asciz "\n"
    newline_end:
    newline_length = newline_end - newline

    placeholder_msg:
        .asciz "Original message: "
    placeholder_msg_end:
    placeholder_msg_length = placeholder_msg_end - placeholder_msg

.text
.global _start

_start:
    li a7, 64
    li a0, 1
    la a1, placeholder_msg
    li a2, placeholder_msg_length
    ecall

    li a7, 64
    li a0, 1
    la a1, user_input
    li a2, user_input_length
    ecall

    jal ra, print_newline

    li a7, 93
    li a0, 0
    ecall

print_newline:

    li a7, 64
    li a0, 1
    la a1, newline
    li a2, newline_length
    ecall

    ret


# riscv64-linux-gnu-as bpe.s -o bpe.o
# riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe
# qemu-riscv64 ./bpe
# riscv64-linux-gnu-as bpe.s -o bpe.o && riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe && qemu-riscv64 ./bpe
