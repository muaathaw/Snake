# helpers.asm - ncurses wrappers
#
# Uses the real ncurses functions (wmove, waddch, ...) because mvaddch,
# getch and friends are C macros.

        .text
# void board_init(void)
        .globl board_init
        .type board_init, @function
board_init:
        subq    $8, %rsp
        call    initscr@PLT
        call    cbreak@PLT
        call    noecho@PLT
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        movl    $1, %esi
        call    keypad@PLT
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        movl    $1, %esi
        call    nodelay@PLT
        xorl    %edi, %edi
        call    curs_set@PLT
        xorl    %edi, %edi
        call    time@PLT
        movl    %eax, %edi
        call    srand@PLT
        addq    $8, %rsp
        ret
        .size board_init, .-board_init

# void game_exit(void)
        .globl game_exit
        .type game_exit, @function
game_exit:
        subq    $8, %rsp
        call    endwin@PLT
        xorl    %edi, %edi
        call    exit@PLT
        .size game_exit, .-game_exit

# int board_get_key(void)
        .globl board_get_key
        .type board_get_key, @function
board_get_key:
        subq    $8, %rsp
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        call    wgetch@PLT
        addq    $8, %rsp
        ret
        .size board_get_key, .-board_get_key

# void board_put_char(int x, int y, int ch)
        .globl board_put_char
        .type board_put_char, @function
board_put_char:
        pushq   %rbx
        movl    %edx, %ebx
        movl    %edi, %edx
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        call    wmove@PLT
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        movl    %ebx, %esi
        call    waddch@PLT
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        call    wrefresh@PLT
        popq    %rbx
        ret
        .size board_put_char, .-board_put_char

# void board_put_str(int x, int y, const char *str)
        .globl board_put_str
        .type board_put_str, @function
board_put_str:
        pushq   %rbx
        pushq   %r12
        subq    $8, %rsp
        movq    %rdx, %rbx
        movl    %edi, %r12d
        movl    %edi, %edx
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        call    wmove@PLT
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        call    getmaxx@PLT
        subl    %r12d, %eax
        jns     1f
        xorl    %eax, %eax
1:      movl    %eax, %edx
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        movq    %rbx, %rsi
        call    waddnstr@PLT
        movq    stdscr@GOTPCREL(%rip), %rax
        movq    (%rax), %rdi
        call    wrefresh@PLT
        addq    $8, %rsp
        popq    %r12
        popq    %rbx
        ret
        .size board_put_str, .-board_put_str

        .section .note.GNU-stack,"",@progbits
