# start.asm - entry point for the assembly build
#
# On entry the kernel has argc at (%rsp) and argv starting at 8(%rsp).
# Missing arguments default to length 5 and 2 apples.

        .equ DEFAULT_LEN,    5
        .equ DEFAULT_APPLES, 2

        .text
        .globl _start
        .type _start, @function
_start:
        xorl    %ebp, %ebp
        movq    (%rsp), %r12
        leaq    8(%rsp), %r13
        andq    $-16, %rsp

        movl    $DEFAULT_LEN, %r14d
        movl    $DEFAULT_APPLES, %r15d

        cmpq    $2, %r12
        jl      .Lrun
        movq    8(%r13), %rdi
        call    atoi@PLT
        movl    %eax, %r14d

        cmpq    $3, %r12
        jl      .Lrun
        movq    16(%r13), %rdi
        call    atoi@PLT
        movl    %eax, %r15d

.Lrun:
        movl    %r14d, %edi
        movl    %r15d, %esi
        call    start_game

        xorl    %edi, %edi
        call    exit@PLT
        .size _start, .-_start

        .section .note.GNU-stack,"",@progbits
