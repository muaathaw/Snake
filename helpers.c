#include <ncurses.h>
#include <stdlib.h>
#include <time.h>

void board_init(void)
{
    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    nodelay(stdscr, TRUE);
    curs_set(0);
    srand(time(NULL));
}

void game_exit(void)
{
    endwin();
    exit(0);
}

int board_get_key(void)
{
    int ch = getch();
    return ch == ERR ? -1 : ch;
}

void board_put_char(int x, int y, int ch)
{
    mvaddch(y, x, ch);
    refresh();
}

void board_put_str(int x, int y, const char *str)
{
    int n = COLS - x;
    if (n < 0)
        n = 0;
    mvaddnstr(y, x, str, n);
    refresh();
}
