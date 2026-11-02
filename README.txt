Snake (x86-64 assembly, GNU as, AT&T syntax)
============================================

Build
-----
    make                builds ./snake (_start in start.asm)
                        and    ./snake_c (main in main.c)
    make HELPERS=c      links helpers.c instead of helpers.asm
    make clean          removes objects and binaries

Run
---
    ./snake 5 2
    ./snake_c 5 2

Both arguments are optional. Length defaults to 5 (clamped to 1..20),
apples default to 2 (clamped to 1..100).

Controls: arrow keys. The playfield is 40x20 inside a '#' border.

Rules
-----
- The snake starts in the middle and grows by one when it eats an apple.
- Apples only appear on cells not occupied by the snake or another apple.
- Hitting the wall or the snake itself ends the game.
- The step delay drops by 5 ms per apple, from 150 ms down to 50 ms.
- 30 seconds without an apple ends the game; the timer resets on each apple.
- The status line shows score, length and time left.

Files
-----
    start.asm    _start: parses argv and calls start_game
    main.c       C entry point for ./snake_c
    snake.asm    game logic, start_game(len, n_apples)
    helpers.asm  ncurses wrappers
    helpers.c    C version of the same helpers
