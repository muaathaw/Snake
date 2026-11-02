#include <stdlib.h>

void start_game(int len, int n_apples);

int main(int argc, char *argv[])
{
    int len = 5, n_apples = 2;

    if (argc > 1)
        len = atoi(argv[1]);
    if (argc > 2)
        n_apples = atoi(argv[2]);

    start_game(len, n_apples);
    return 0;
}
