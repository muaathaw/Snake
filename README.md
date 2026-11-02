# Snake
Unix assignment 3

Snake (x86-64 assembly, GNU as, AT&T syntax)
Muaath Awad Muaw22
Oskar Ohvo osoh22
Desired grade (B/A)
============================================

## Build
-----
    make                builds ./snake (_start in start.asm)
                        and    ./snake_c (main in main.c)
    make HELPERS=c      links helpers.c instead of helpers.asm
    make clean          removes objects and binaries

## Run
---
    ./snake 5 2
    ./snake_c 5 2


## Files
-----
    start.asm    _start: parses argv and calls start_game
    main.c       C entry point for ./snake_c
    snake.asm    game logic, start_game(len, n_apples)
    helpers.asm  ncurses wrappers
    helpers.c    C version of the same helpers
-----
## Supported features:
    - Playable snake game
    - Configurable initial length and number of apples via command line
    - Arrow-key control, cannot reverse
    - Snake grows when eating an apple
    - Self-collision and wall collision end the game
    - Apples randomly placed, never on the snake or other apples
    - Board fits the terminal (up to 40x20)
    - Speed increases per apple
    - 30 s timer, reset per apple
    - Helper functions implemented in assembly (helpers.asm); Makefile builds them by default
    - Starts from assembly (_start) and C (main.c)
-----
## Approach:
    start.asm reads argc/argv, parses the optional length and apple count and
    calls start_game(len, n_apples). The game state lives in .bss (snake body
    coordinates, apple coordinates, direction, score, delay, elapsed time).
    start_game initialises ncurses through the helper functions, sizes the
    playfield to the terminal (capped at 40x20), draws the border, places the
    snake in the middle and spawns the apples with rand().

    The main loop draws the status line, reads at most one direction change
    per iteration with board_get_key, moves the snake, and sleeps with
    usleep(delay). Movement shifts the body coordinate arrays, erases the old
    tail, checks wall and self collisions, and grows the snake when the new
    head lands on an apple. Eaten apples are respawned on a free cell and
    reset the timer; the delay is reduced to increase the speed. The elapsed
    time is accumulated from the per-iteration delay, so the 30 s limit is
    independent of the current speed. helpers.asm contains assembly wrappers
    for the ncurses functions (initscr, cbreak, noecho, keypad, nodelay,
    curs_set, wmove, waddch, wgetch, wrefresh, srand/time); helpers.c is the
    provided C version and main.c is the C entry point for ./snake_c.
