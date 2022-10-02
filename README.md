# Mini-LISP-interpreter

NCU compiler final project

## how to compile this project

###### method 1 - run make.sh in your ubuntu shell

        ./make.sh

###### method 2 - run this script of code in your ubuntu shell

        bison -d lisp.y
        flex lisp.l
        gcc -c lisp.tab.c
        gcc -c lex.yy.c
        gcc lex.yy.o lisp.tab.o -lfl

## Program Flow Chart

string stream(mini lisp code) -> lex -> token stream -> yacc -> syntax tree -> c code to traverse tree -> symbol table & execute

### AST tree node

| non-terminal                                        | type | id                  |
| --------------------------------------------------- | ---- | ------------------- |
| number                                              | I    |                     |
| boolean                                             | B    |                     |
| variable                                            | V    | variable identifier |
| exps                                                | E    |                     |
| printnum                                            | P    |                     |
| printbool                                           | p    |                     |
| stmts                                               | T    |                     |
| define                                              | D    |                     |
| num_op                                              | O    |                     |
| logical_op                                          | O    |                     |
| fun_ids                                             | S    |                     |
| fun_exp                                             | F    |                     |
| fun_call                                            | C    |                     |
| params                                              | A    |                     |
| if_exp                                              | G    |                     |
| if_tmp(left child: then_exp, right child: else_exp) | X    |                     |

### symbol_table_node

use symbol table to store those variables declared by user

        struct symbol_table_node{
                char type; // F: function, B: bool, I: integer
                char* id; // id
                int value; // if variable is bool or integer, store value here
                int scope; // work in which scope, e.g. global or only is declared in a function
                struct Node* fun; // if type == function, store the tree node here
        };
