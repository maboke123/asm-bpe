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

    translation_table:
        .zero 48

    pair_frequency_table:
        .zero 768

.text
.global _start

_start:

    # print user input
    la a1, placeholder_og_msg
    li a2, placeholder_og_msg_length
    jal ra, print_string

    la a1, user_input
    li a2, user_input_length
    jal ra, print_string

    jal ra, print_newline


    # copy user input to bufffer and print
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


    # init state
    li s0, user_input_length
    li s1, 0
    li s2, 0x7B
    la s3, work_buffer
    la s4, translation_table
    li s5, 4


    # bpe loop
    jal ra, bpe


    # exit
    li a7, 93
    li a0, 0
    ecall

bpe:

    addi sp, sp, -8
    sd ra, 0(sp)

    beqz s5, bpe_done

bpe_loop:

    mv a0, s3
    mv a1, s0
    jal count_pairs # f(buffer ptr, buffer len)

bpe_done:

    ld ra, 0(sp)
    addi sp, sp, 8

    ret

count_pairs:

    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    mv s0, a0
    mv s1, a1

    la a0, pair_frequency_table
    li a1, 768
    jal ra, clear_memory # f(freq table ptr, freq table size)

    li t0, 2
    blt s1, t0, count_pairs_done

    li s2, 0 # loooping idx

count_pairs_loop:

    addi t0, s1, -1
    bge s2, t0, count_pairs_done

    add t1, s0, s2
    lb a0, 0(t1)
    lb a1, 1(t1)

    jal ra, increment_pair_count # f(first byte, second byte)

    addi s2, s2, 1

    j count_pairs_loop

count_pairs_done:

    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32

    ret

clear_memory:

    beqz a1, clear_done

    sb zero, 0(a0)

    addi a0, a0, 1
    addi a1, a1, -1

    j clear_memory

clear_done:

    ret

increment_pair_count:

    addi sp, sp, -16
    sd s0, 8(sp)
    sd s1, 0(sp)

    mv s0, a0
    mv s1, a1

    la t0, pair_frequency_table
    li t1, 0

search_corresponding_pair:

    li t2, 256
    bge t1, t2, add_new_pair

    mv t3, t1
    li t4, 3
    mul t3, t3, t4 # entry address: entry => byte 1 byte 2 count
    add t3, t0, t3

    lb t4, 2(t3)
    beqz t4, add_at_index

    lb t5, 0(t3)
    lb t6, 1(t3)

    bne t5, s0, next_pair
    bne t6, s1, next_pair

    addi t4, t4, 1
    sb t4, 2(t3)

    j increment_done

next_pair:

    addi t1, t1, 1

    j search_corresponding_pair

add_at_index:

    mv t3, t1
    li t4, 3
    mul t3, t3, t4
    add t3, t0, t3
    
add_new_pair:

    sb s0, 0(t3)
    sb s1, 1(t3)
    li t4, 1
    sb t4, 2(t3)

increment_done:

    ld s0, 8(sp)
    ld s1, 0(sp)
    addi sp, sp, 16
    
    ret

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
