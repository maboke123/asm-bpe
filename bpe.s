.data
    user_input:
        .asciz "aabcdefgh"
    user_input_end:
    user_input_length = user_input_end - user_input

    newline:
        .asciz "\n"
    newline_end:
    newline_length = newline_end - newline

    placeholder_og_msg:
        .asciz "Original message: "
    placeholder_og_msg_end:
    placeholder_og_msg_length = placeholder_og_msg_end - placeholder_og_msg

    placeholder_buff_msg:
        .asciz "Buffer: "
    placeholder_buff_msg_end:
    placeholder_buff_msg_length = placeholder_buff_msg_end - placeholder_buff_msg

    work_buffer:
        .zero 64

.text
.global _start

_start:

    la a1, placeholder_og_msg
    li a2, placeholder_og_msg_length
    jal ra, print_string

    la a1, user_input
    li a2, user_input_length
    jal ra, print_string

    jal ra, print_newline

    la a0, user_input
    la a1, work_buffer
    li a2, user_input_length
    jal ra, copy_string

    la a1, placeholder_buff_msg
    li a2, placeholder_buff_msg_length
    jal ra, print_string

    la a1, work_buffer
    li a2, 64
    jal ra, print_string

    jal ra, print_newline

    li a7, 93
    li a0, 0
    ecall

print_string:
    li a7, 64
    li a0, 1
    ecall
    
    ret

print_newline:

    addi sp, sp, -8
    sd ra, 0(sp)

    la a1, newline
    li a2, newline_length

    jal ra, print_string

    ld ra, 0(sp)
    addi sp, sp, 8

    ret

copy_string:

    beqz a2, copy_string_done

copy_loop:
    lb t0, 0(a0)
    sb t0, 0(a1)

    addi a0, a0, 1
    addi a1, a1, 1

    addi a2, a2, -1

    bnez a2, copy_loop

copy_string_done:

    ret


# riscv64-linux-gnu-as bpe.s -o bpe.o
# riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe
# qemu-riscv64 ./bpe
# riscv64-linux-gnu-as bpe.s -o bpe.o && riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe && qemu-riscv64 ./bpe
