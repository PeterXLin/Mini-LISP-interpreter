%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    void yyerror(const char *);
    int yylex(void);

    // tree node of syntax tree
    struct Node {
        char type;
        char* id;
        int value;
        node* leftChild;
        node* rightChild;
    };


    // declare function here 
    struct node* create_node(node *, node*, char);

    // int symbol_amount = 0;
    // struct variable_info {
    //     string id;
    //     string type;
    //     int value;
    //     node* func;
    //     string scope;
    // } symbol_table[40];

    // void insert_type();
    // void add_symbol(string, string, int, node*, string);
    // int search_table(string);
%}

%union {
    int ival;
    char* word;
    struct Node* node_info_1;
}

%token<ival> NUMBER 
%token<ival> BOOLEAN
%token<word> ID PLUS MINUS MUL DIV MOD GR SM EQ AND OR NOT
%token PRINTNUM PRINTBOOL DEFINE LAMBDA IF

// return int or boolean
%type<node_info_1> exp exps variable num_op logical_op fun_exp fun_call if_exp test_exp then_exp else_exp fun_body
// %type<node_info_2> exps
 
%%
program: stmts
;

stmts: stmt stmts
|
;

stmt: exp
| def_stmt
| print_stmt
;

print_stmt: '(' PRINTNUM exp ')'
| '(' PRINTBOOL exp ')'
; 

// add type id value func scope
exp: BOOLEAN        {
                        $$.type = "bool";
                        $$.value = $1;
                        $$.func = NULL;
                        $$.scope = "main";
                    }
| NUMBER            {
                        $$.type = "int"; 
                        $$.value = $1; 
                        $$.func = NULL; 
                        $$.scope = "main";
                    }
| variable          {/*check if variable is exist, if exist load variable*/}
| num_op            {}
| logical_op
| fun_exp
| fun_call
| if_exp
;

exps: exp exps  {
                }
| exp  {}
;


num_op: '(' PLUS exp exps ')'   {}
| '(' MINUS exp exp ')'         {}    
| '(' MUL exp exps ')'          {}
| '(' DIV exp exp ')'           {}
| '(' MOD exp exp ')'           {}
| '(' GR exp exp ')'            {}
| '(' SM exp exp ')'            {}
| '(' EQ exp exps ')'           {}
;


logical_op: '(' AND exp exps ')'    {$$.type = "bool";}
| '(' OR exp exps ')'               {$$.type = "bool";} 
| '(' NOT exp ')'                   {$$.type = "bool";}
;

def_stmt: '(' DEFINE variable exp ')' {add_symbol($3.id, $4.type, $4.value, $4.func, $4.scope);}
;

variable: ID  {$$.id = $1;}
;

fun_exp: '(' LAMBDA '(' fun_ids ')' fun_body ')'  {/*store funcion in symbol table*/}
;

// function parameter
fun_ids: ID fun_ids  {/* add id to symbol table, scope = tmp*/}
|
;

fun_body: exp
;

fun_call: '(' fun_exp params ')'
| '(' fun_name params ')'
;

params: param params
| 
;

param: exp
;

fun_name: ID   // check if the funciton exist
;

if_exp: '(' IF test_exp then_exp else_exp ')'
;


test_exp: exp
;

then_exp: exp
;

else_exp: exp
;


%%
int main(void) {
    yyparse();
    return 0;
}

void yyerror(const char *message) {
    fprintf(stderr, "%s\n", message);
}

/* void insert_type(char* from, char* to) {
    // doesn't copy, only point to 
    to = from;
} */

/* int search_table(string var_name) {
    string tmp = var_name;
    for (int i = symbol_amount - 1; i >= 0; i--) {
        if (symbol_table[i].id == tmp) {
            // todo also check scope
            return -1;
        }
    }
    return 1;
} */

/* void add_symbol(string identifier, string type, int value, node* nd, string scope) {
    if (search_table(identifier) != -1) {
        symbol_table[symbol_amount].id = identifier;
        symbol_table[symbol_amount].type = type;
        symbol_table[symbol_amount].value = value;
        symbol_table[symbol_amount].func = nd;
        symbol_table[symbol_amount].scope = scope;
        symbol_amount++;
    } else {
        cout << "varaiable all ready exist" << endl;
    }
} */