# Makefile

OB	= bison.o lex.o main.o

CC	= g++
CF	= -g -Wall -ansi -pedantic

mini:		$(OB)
		$(CC) $(CF) $(OB) -o mini -lfl

lex.o:		lex.c
		$(CC) $(CF) -c lex.c -o lex.o		

lex.c:		mini.lex
		flex mini.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CF) -c bison.c -o bison.o

bison.c:	mini.y
		bison -d -v mini.y
		cp mini.tab.c bison.c
		cmp -s mini.tab.h tok.h || cp mini.tab.h tok.h

main.o:		main.cc
		$(CC) $(CF) -c main.cc -o main.o

lex.o yac.o main.o	: heading.h
lex.o main.o		: tok.h

clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h mini.tab.c mini.tab.h mini.output mini 
