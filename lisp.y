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
        struct Node* leftChild;
        struct Node* rightChild;
    };

    struct Node* root = NULL;
    // declare function here 
    struct Node* create_node(struct Node* left, struct Node* right, char type);
%}

%union {
    int ival;
    char* word;
    struct Node* node_info;
}

%token<ival> NUMBER 
%token<ival> BOOLEAN
%token<word> ID 
%token PRINTNUM PRINTBOOL DEFINE LAMBDA IF PLUS MINUS MUL DIV MOD GR SM EQ AND OR NOT

// return int or boolean
%type<node_info> program stmts stmt print_stmt exp exps num_op logical_op def_stmt variable 
%type<node_info> fun_exp fun_ids fun_body fun_call params param fun_name 
%type<node_info> if_exp test_exp then_exp else_exp
 
%%
program: stmts { root = $1; }
;

stmts: stmt stmts{ $$ = create_node($1, $2, 'T'); }
| stmt           { $$ = create_node($1, NULL, 'T'); }
;

stmt: exp       { $$ = $1; }
| def_stmt      { $$ = $1; }
| print_stmt    { $$ = $1; }
;

print_stmt: '(' PRINTNUM exp ')'  { $$ = create_node($3, NULL, 'P');}
| '(' PRINTBOOL exp ')'           { $$ = create_node($3, NULL, 'p');}
; 

// add type id value func scope
exp: BOOLEAN        { 
                        $$ = create_node(NULL, NULL, 'B');
                        $$->value = $1;    
                    }
| NUMBER            {
                        $$ = create_node(NULL, NULL, 'I');
                        $$->value = $1;
                    }
| variable          { $$ = $1; /*type = V*/}
| num_op            { $$ = $1; /*type = O*/}
| logical_op        { $$ = $1; /*type = O*/}
| fun_exp           { $$ = $1; /*if not define or call, do nothing*/}
| fun_call          { $$ = $1; }
| if_exp            { $$ = $1; }
;

exps: exp exps      { $$ = create_node($1, $2, 'E'); }
| exp               {$$ = create_node($1, NULL, 'E'); }
;


num_op: '(' PLUS exp exps ')'   { $$ = create_node($3, $4, 'O'); $$->id = "+"; }
| '(' MINUS exp exp ')'         { $$ = create_node($3, $4, 'O'); $$->id = "-"; }    
| '(' MUL exp exps ')'          { $$ = create_node($3, $4, 'O'); $$->id = "*"; }
| '(' DIV exp exp ')'           { $$ = create_node($3, $4, 'O'); $$->id = "/"; }
| '(' MOD exp exp ')'           { $$ = create_node($3, $4, 'O'); $$->id = "%"; }
| '(' GR exp exp ')'            { $$ = create_node($3, $4, 'O'); $$->id = ">"; }
| '(' SM exp exp ')'            { $$ = create_node($3, $4, 'O'); $$->id = "<"; }
| '(' EQ exp exps ')'           { $$ = create_node($3, $4, 'O'); $$->id = "="; }
;


logical_op: '(' AND exp exps ')'    { $$ = create_node($3, $4, 'O'); $$->id = "&"; }
| '(' OR exp exps ')'               { $$ = create_node($3, $4, 'O'); $$->id = "|"; } 
| '(' NOT exp ')'                   { $$ = create_node($3, NULL, 'O'); $$->id = "^";}
;

def_stmt: '(' DEFINE variable exp ')' { $$ = create_node($3, $4, 'D'); /*check right child's type*/}
;

variable: ID    {
                    $$ = create_node(NULL, NULL, 'V');
                    $$->id = $1;
                }
;

fun_exp: '(' LAMBDA '(' fun_ids ')' fun_body ')'  { $$ = create_node($4, $6, 'F');}
;

// function parameter
fun_ids: ID fun_ids {
                        struct Node* tmp = create_node(NULL, NULL, 'V');
                        tmp->id = $1;
                        $$ = create_node(tmp, $2, 'S');
                    }
|                   { $$ = NULL; }
;

fun_body: exp {$$ = $1;}
;

fun_call: '(' fun_exp params ')' {$$ = create_node($3, $2, 'C');}
| '(' fun_name params ')'        {$$ = create_node($3, $2, 'C');}
;

params: param params {$$ = create_node($1, $2, 'A');}
|                    {$$ = NULL;}
;

param: exp {$$ = $1;}
;

fun_name: ID    {
                    $$ = create_node(NULL, NULL, 'V');
                    $$->id = $1;
                }
;

if_exp: '(' IF test_exp then_exp else_exp ')'  { 
                                                    struct Node* tmp = create_node($4, $5, 'X');
                                                    $$ = create_node($3, tmp, 'G');
                                                }
;

test_exp: exp { $$ = $1; }
;

then_exp: exp { $$ = $1; }
;

else_exp: exp { $$ = $1; }
;


%%
int main(void) {
    yyparse();
    return 0;
}

void yyerror(const char *message) {
    fprintf(stderr, "%s\n", message);
}

struct Node* create_node(struct Node* left, struct Node* right, char type) {
    struct Node* tmp = (struct Node*) malloc(sizeof(struct Node));
    tmp->type = type;
    tmp->id = "";
    tmp->value = 0;
    tmp->leftChild = left;
    tmp->rightChild = right;
    return tmp;
}
