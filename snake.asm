# snake.asm - snake game for x86-64 (GNU as, AT&T syntax)
#
# void start_game(int len, int n_apples);

        .equ WIDTH,       40
        .equ HEIGHT,      20
        .equ MAX_LEN,     WIDTH*HEIGHT
        .equ MAX_APPLES,  100

        .equ KEY_DOWN,    258
        .equ KEY_UP,      259
        .equ KEY_LEFT,    260
        .equ KEY_RIGHT,   261

        .equ START_DELAY, 150000
        .equ MIN_DELAY,   50000
        .equ SPEEDUP,     5000
        .equ TIME_LIMIT,  30000000

        .equ CH_HEAD,     '@'
        .equ CH_BODY,     'o'
        .equ CH_APPLE,    '*'
        .equ CH_WALL,     '#'

        .section .rodata
status_fmt:
        .asciz "Score: %-4d Length: %-4d Time left: %2d s "

        .bss
        .align 4
snake_x:    .space 4*MAX_LEN
snake_y:    .space 4*MAX_LEN
apple_x:    .space 4*MAX_APPLES
apple_y:    .space 4*MAX_APPLES
snake_len:  .space 4
n_apples:   .space 4
dir_x:      .space 4
dir_y:      .space 4
next_dx:    .space 4
next_dy:    .space 4
score:      .space 4
delay:      .space 4
elapsed:    .space 4
status_buf: .space 64

        .text
# void start_game(int len, int n_apples)
        .globl start_game
        .type start_game, @function
start_game:
        pushq   %rbp
        movq    %rsp, %rbp
        pushq   %rbx
        subq    $8, %rsp

        # length in [1, WIDTH/2]
        cmpl    $1, %edi
        jge     1f
        movl    $1, %edi
1:      cmpl    $WIDTH/2, %edi
        jle     2f
        movl    $WIDTH/2, %edi
2:      movl    %edi, snake_len(%rip)

        # apples in [1, MAX_APPLES]
        cmpl    $1, %esi
        jge     3f
        movl    $1, %esi
3:      cmpl    $MAX_APPLES, %esi
        jle     4f
        movl    $MAX_APPLES, %esi
4:      movl    %esi, n_apples(%rip)

        movl    $1, dir_x(%rip)
        movl    $0, dir_y(%rip)
        movl    $1, next_dx(%rip)
        movl    $0, next_dy(%rip)
        movl    $0, score(%rip)
        movl    $0, elapsed(%rip)
        movl    $START_DELAY, delay(%rip)

        call    board_init@PLT
        call    draw_border
        call    init_snake

        xorl    %ebx, %ebx
.Lplace_loop:
        cmpl    n_apples(%rip), %ebx
        jge     .Lgame_loop
        movl    %ebx, %edi
        call    place_apple
        incl    %ebx
        jmp     .Lplace_loop

.Lgame_loop:
        call    draw_status
        call    read_input
        call    move_snake
        testl   %eax, %eax
        jz      .Lgame_over

        movl    delay(%rip), %eax
        addl    %eax, elapsed(%rip)
        cmpl    $TIME_LIMIT, elapsed(%rip)
        jge     .Lgame_over

        movl    delay(%rip), %edi
        call    usleep@PLT
        jmp     .Lgame_loop

.Lgame_over:
        call    game_exit@PLT

        addq    $8, %rsp
        popq    %rbx
        popq    %rbp
        ret
        .size start_game, .-start_game

# draw_border
draw_border:
        pushq   %rbx
        xorl    %ebx, %ebx
1:      cmpl    $WIDTH+1, %ebx
        jg      2f
        movl    %ebx, %edi
        movl    $0, %esi
        movl    $CH_WALL, %edx
        call    board_put_char@PLT
        movl    %ebx, %edi
        movl    $HEIGHT+1, %esi
        movl    $CH_WALL, %edx
        call    board_put_char@PLT
        incl    %ebx
        jmp     1b
2:      movl    $1, %ebx
3:      cmpl    $HEIGHT, %ebx
        jg      4f
        movl    $0, %edi
        movl    %ebx, %esi
        movl    $CH_WALL, %edx
        call    board_put_char@PLT
        movl    $WIDTH+1, %edi
        movl    %ebx, %esi
        movl    $CH_WALL, %edx
        call    board_put_char@PLT
        incl    %ebx
        jmp     3b
4:      popq    %rbx
        ret

# init_snake: horizontal in the middle, head at WIDTH/2
init_snake:
        pushq   %rbx
        xorl    %ebx, %ebx
1:      cmpl    snake_len(%rip), %ebx
        jge     3f
        movl    $WIDTH/2, %edi
        subl    %ebx, %edi
        movl    $HEIGHT/2, %esi
        leaq    snake_x(%rip), %rax
        movl    %edi, (%rax,%rbx,4)
        leaq    snake_y(%rip), %rax
        movl    %esi, (%rax,%rbx,4)
        movl    $CH_BODY, %edx
        testl   %ebx, %ebx
        jnz     2f
        movl    $CH_HEAD, %edx
2:      call    board_put_char@PLT
        incl    %ebx
        jmp     1b
3:      popq    %rbx
        ret

# read_input: drain keys, reject reversing the last move
read_input:
        subq    $8, %rsp
.Lread_loop:
        call    board_get_key@PLT
        cmpl    $-1, %eax
        je      .Lread_done
        cmpl    $KEY_UP, %eax
        je      .Lkey_up
        cmpl    $KEY_DOWN, %eax
        je      .Lkey_down
        cmpl    $KEY_LEFT, %eax
        je      .Lkey_left
        cmpl    $KEY_RIGHT, %eax
        je      .Lkey_right
        jmp     .Lread_loop

.Lkey_up:
        movl    $0, %ecx
        movl    $-1, %edx
        jmp     .Lkey_set
.Lkey_down:
        movl    $0, %ecx
        movl    $1, %edx
        jmp     .Lkey_set
.Lkey_left:
        movl    $-1, %ecx
        movl    $0, %edx
        jmp     .Lkey_set
.Lkey_right:
        movl    $1, %ecx
        movl    $0, %edx

.Lkey_set:
        movl    dir_x(%rip), %eax
        negl    %eax
        cmpl    %eax, %ecx
        jne     .Lkey_accept
        movl    dir_y(%rip), %eax
        negl    %eax
        cmpl    %eax, %edx
        je      .Lread_loop
.Lkey_accept:
        movl    %ecx, next_dx(%rip)
        movl    %edx, next_dy(%rip)
        jmp     .Lread_loop

.Lread_done:
        addq    $8, %rsp
        ret

# int move_snake(void) - 1 while alive, 0 on game over
move_snake:
        pushq   %rbx
        pushq   %r12
        pushq   %r13

        movl    next_dx(%rip), %eax
        movl    %eax, dir_x(%rip)
        movl    next_dy(%rip), %eax
        movl    %eax, dir_y(%rip)

        movl    snake_x(%rip), %r12d
        addl    dir_x(%rip), %r12d
        movl    snake_y(%rip), %r13d
        addl    dir_y(%rip), %r13d

        cmpl    $1, %r12d
        jl      .Ldead
        cmpl    $WIDTH, %r12d
        jg      .Ldead
        cmpl    $1, %r13d
        jl      .Ldead
        cmpl    $HEIGHT, %r13d
        jg      .Ldead

        # body check, tail excluded since it moves away
        movl    %r12d, %edi
        movl    %r13d, %esi
        movl    snake_len(%rip), %edx
        decl    %edx
        call    on_snake
        testl   %eax, %eax
        jnz     .Ldead

        movl    %r12d, %edi
        movl    %r13d, %esi
        movl    $-1, %edx
        call    find_apple
        movl    %eax, %ebx
        cmpl    $-1, %ebx
        jne     .Lgrow

        movl    snake_len(%rip), %eax
        decl    %eax
        leaq    snake_x(%rip), %rcx
        movl    (%rcx,%rax,4), %edi
        leaq    snake_y(%rip), %rcx
        movl    (%rcx,%rax,4), %esi
        movl    $' ', %edx
        call    board_put_char@PLT
        jmp     .Lshift

.Lgrow:
        cmpl    $MAX_LEN, snake_len(%rip)
        jge     1f
        incl    snake_len(%rip)
1:      incl    score(%rip)
        movl    $0, elapsed(%rip)
        movl    delay(%rip), %eax
        subl    $SPEEDUP, %eax
        cmpl    $MIN_DELAY, %eax
        jge     2f
        movl    $MIN_DELAY, %eax
2:      movl    %eax, delay(%rip)

.Lshift:
        movl    snake_len(%rip), %ecx
        decl    %ecx
        leaq    snake_x(%rip), %r8
        leaq    snake_y(%rip), %r9
3:      testl   %ecx, %ecx
        jle     4f
        movl    -4(%r8,%rcx,4), %eax
        movl    %eax, (%r8,%rcx,4)
        movl    -4(%r9,%rcx,4), %eax
        movl    %eax, (%r9,%rcx,4)
        decl    %ecx
        jmp     3b
4:      movl    %r12d, (%r8)
        movl    %r13d, (%r9)

        cmpl    $1, snake_len(%rip)
        jle     5f
        movl    4(%r8), %edi
        movl    4(%r9), %esi
        movl    $CH_BODY, %edx
        call    board_put_char@PLT
5:      movl    %r12d, %edi
        movl    %r13d, %esi
        movl    $CH_HEAD, %edx
        call    board_put_char@PLT

        # respawn the eaten apple if the board still has a free cell
        cmpl    $-1, %ebx
        je      6f
        movl    $WIDTH*HEIGHT, %eax
        subl    snake_len(%rip), %eax
        subl    n_apples(%rip), %eax
        cmpl    $1, %eax
        jl      .Ldead
        movl    %ebx, %edi
        call    place_apple
6:      movl    $1, %eax
        jmp     .Lmove_ret

.Ldead:
        xorl    %eax, %eax
.Lmove_ret:
        popq    %r13
        popq    %r12
        popq    %rbx
        ret

# int on_snake(int x, int y, int count)
on_snake:
        leaq    snake_x(%rip), %r8
        leaq    snake_y(%rip), %r9
        xorl    %ecx, %ecx
1:      cmpl    %edx, %ecx
        jge     3f
        cmpl    (%r8,%rcx,4), %edi
        jne     2f
        cmpl    (%r9,%rcx,4), %esi
        jne     2f
        movl    $1, %eax
        ret
2:      incl    %ecx
        jmp     1b
3:      xorl    %eax, %eax
        ret

# int find_apple(int x, int y, int skip)
find_apple:
        leaq    apple_x(%rip), %r8
        leaq    apple_y(%rip), %r9
        xorl    %ecx, %ecx
1:      cmpl    n_apples(%rip), %ecx
        jge     3f
        cmpl    %edx, %ecx
        je      2f
        cmpl    (%r8,%rcx,4), %edi
        jne     2f
        cmpl    (%r9,%rcx,4), %esi
        jne     2f
        movl    %ecx, %eax
        ret
2:      incl    %ecx
        jmp     1b
3:      movl    $-1, %eax
        ret

# void place_apple(int i)
place_apple:
        pushq   %rbx
        pushq   %r12
        pushq   %r13
        movl    %edi, %ebx
.Lretry:
        call    rand@PLT
        xorl    %edx, %edx
        movl    $WIDTH, %ecx
        divl    %ecx
        leal    1(%rdx), %r12d
        call    rand@PLT
        xorl    %edx, %edx
        movl    $HEIGHT, %ecx
        divl    %ecx
        leal    1(%rdx), %r13d

        movl    %r12d, %edi
        movl    %r13d, %esi
        movl    snake_len(%rip), %edx
        call    on_snake
        testl   %eax, %eax
        jnz     .Lretry

        movl    %r12d, %edi
        movl    %r13d, %esi
        movl    %ebx, %edx
        call    find_apple
        cmpl    $-1, %eax
        jne     .Lretry

        leaq    apple_x(%rip), %rax
        movl    %r12d, (%rax,%rbx,4)
        leaq    apple_y(%rip), %rax
        movl    %r13d, (%rax,%rbx,4)
        movl    %r12d, %edi
        movl    %r13d, %esi
        movl    $CH_APPLE, %edx
        call    board_put_char@PLT

        popq    %r13
        popq    %r12
        popq    %rbx
        ret

# draw_status
draw_status:
        subq    $8, %rsp
        movl    $TIME_LIMIT+999999, %eax
        subl    elapsed(%rip), %eax
        xorl    %edx, %edx
        movl    $1000000, %ecx
        divl    %ecx
        movl    %eax, %r8d

        leaq    status_buf(%rip), %rdi
        leaq    status_fmt(%rip), %rsi
        movl    score(%rip), %edx
        movl    snake_len(%rip), %ecx
        xorl    %eax, %eax
        call    sprintf@PLT

        movl    $0, %edi
        movl    $HEIGHT+2, %esi
        leaq    status_buf(%rip), %rdx
        call    board_put_str@PLT
        addq    $8, %rsp
        ret

        .section .note.GNU-stack,"",@progbits
