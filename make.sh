bison -d lisp.y
flex lisp.l
gcc -c lisp.tab.c
gcc -c lex.yy.c
gcc lex.yy.o lisp.tab.o -lfl
