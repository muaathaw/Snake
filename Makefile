# Makefile for the snake game
#
#   make              builds ./snake   (entry point _start in start.asm)
#                     and    ./snake_c (entry point main in main.c)
#   make HELPERS=c    same, but uses helpers.c instead of helpers.asm
#   make zip          packs the submission into snake.zip
#   make clean        removes object files and binaries
#
# Run: ./snake <length> <apples>, e.g. ./snake 5 2

AS      = as
CC      = gcc
ASFLAGS = -g
CFLAGS  = -Wall -Wextra -g
LDLIBS  = -lncurses

# The helper functions are built from assembly by default
HELPERS ?= asm
ifeq ($(HELPERS),c)
HELPER_OBJ = helpers_c.o
else
HELPER_OBJ = helpers.o
endif

all: snake snake_c

# Assembly entry point: no C runtime startup files (we provide _start)
snake: start.o snake.o $(HELPER_OBJ)
	$(CC) -nostartfiles -o $@ $^ $(LDLIBS)

# C entry point: normal crt0 + main.c
snake_c: main.o snake.o $(HELPER_OBJ)
	$(CC) -o $@ $^ $(LDLIBS)

%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

helpers_c.o: helpers.c
	$(CC) $(CFLAGS) -c -o $@ $<

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

zip: clean
	zip snake.zip snake.asm start.asm helpers.asm helpers.c main.c Makefile README.txt

clean:
	rm -f *.o snake snake_c snake.zip

.PHONY: all zip clean
