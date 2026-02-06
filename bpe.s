.data
msg2:
    .asciz "haha\n"
msg2_end:
msg2_length = msg2_end - msg2

msg:
    .asciz "hello world\n"
msg_end:
msg_length = msg_end - msg

msg3:
    .asciz "nice\n"
msg_end3:
msg3_length = msg_end3 - msg3


.text
.global _start

_start:
    li a7, 64
    li a0, 1
    la a1, msg2
    li a2, msg2_length
    ecall

    li a7, 64
    li a0, 1
    la a1, msg
    li a2, msg_length
    ecall
    
    li a7, 64
    li a0, 1
    la a1, msg3
    li a2, msg3_length
    ecall

    li a7, 93
    li a0, 0
    ecall

# riscv64-linux-gnu-as bpe.s -o bpe.o
# riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe
# qemu-riscv64 ./bpe
# riscv64-linux-gnu-as bpe.s -o bpe.o && riscv64-linux-gnu-ld -T linker.ld bpe.o -o bpe && qemu-riscv64 ./bpe
