# Mini-LISP-interpreter

NCU compiler final project

### TODO

- [ ] build AST

### What does this program do?

string stream -> lex -> token stream -> yacc -> syntax tree -> c code to traverse tree -> symbol table & execute

### AST

| non-terminal | type | id   |
| ------------ | ---- | ---- |
| number       | I    | null |
| boolean      | B    | null |
| variable     | V    |      |
| exps         | E    |      |
| printnum     | P    |      |
| printbool    | p    |      |
| stmts        | T    |      |
| define       | D    |      |
| num_op       | O    |      |
| logical_op   | O    |      |
| fun_ids      | S    |      |
| fun_exp      | F    |      |
| fun_call     | C    |      |
| params       | A    |      |
| if_exp       | G    |      |
| if_tmp       | X    |      |

### complain

compare string in c is really hard QAQ
