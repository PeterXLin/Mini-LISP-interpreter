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

    struct symbol_table_node {
        // F: function, B: bool, I: integer
        char type;   
        char* id;
        int value; 
        // also have a global variable to count now scope
        int scope;
        struct Node* fun;
    };

    struct Node* head = NULL;
    struct symbol_table_node symbol_table[100];
    int param_stack[100];
    int scope_count = 0, symbol_table_count = 0, param_stack_count = 0;
    // for debug print tree
    int depth = 0;
    
    // declare function here 
    struct Node* create_node(struct Node* left, struct Node* right, char type);
    // put variable to symbol table
    void insert_symbol_table(char type, char* id, int value, int scope, struct Node* fun);
    // get the index of the variable you want
    int get_symbol_table_index(char* id);
    // for debug
    void print_ast(struct Node* root);
    // travese AST tree
    int Interpret_expression(struct Node* root); 
    void remove_symbol_table_entry(int scope);
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
program: stmts { head = $1; }
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

exp: BOOLEAN        { 
                        $$ = create_node(NULL, NULL, 'B');
                        $$->value = $1;    
                    }
| NUMBER            {
                        $$ = create_node(NULL, NULL, 'I');
                        $$->value = $1;
                    }
| variable          { $$ = $1; /*type = V*/}
| num_op            { $$ = $1;}
| logical_op        { $$ = $1;}
| fun_exp           { $$ = $1; /*if not define or call, do nothing*/}
| fun_call          { $$ = $1;}
| if_exp            { $$ = $1;}
;

exps: exp exps      { $$ = create_node($1, $2, 'E'); }
| exp               {$$ = create_node($1, NULL, 'E'); }
;

num_op: '(' PLUS exp exps ')'   { $$ = create_node($3, $4, '+');}
| '(' MINUS exp exp ')'         { $$ = create_node($3, $4, '-'); }    
| '(' MUL exp exps ')'          { $$ = create_node($3, $4, '*'); }
| '(' DIV exp exp ')'           { $$ = create_node($3, $4, '/'); }
| '(' MOD exp exp ')'           { $$ = create_node($3, $4, '%'); }
| '(' GR exp exp ')'            { $$ = create_node($3, $4, '>'); }
| '(' SM exp exp ')'            { $$ = create_node($3, $4, '<'); }
| '(' EQ exp exps ')'           { $$ = create_node($3, $4, '='); }
;

logical_op: '(' AND exp exps ')'    { $$ = create_node($3, $4, '&'); }
| '(' OR exp exps ')'               { $$ = create_node($3, $4, '|'); } 
| '(' NOT exp ')'                   { $$ = create_node($3, NULL, '^');}
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
    // print_ast(head);
    Interpret_expression(head);
    /* for (int i = 0; i < symbol_table_count; i++) {
        printf("symbol_tabel: %s\n", symbol_table[i].id);
    } */
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

void print_ast(struct Node* root) {
    if (root != NULL) {
        depth += 1;
        print_ast(root -> leftChild);
        print_ast(root -> rightChild);
        depth -= 1;
        printf("%d %c\n", depth, root->type);
    }
}

int Interpret_expression(struct Node* root) {
    if (root == NULL) {
        return 0;
    } else if (root -> type == 'I') {
        return root -> value;
    } else if (root -> type == 'B') {
        return root -> value;
    } else if (root -> type == 'V') {
        // return value, also change this node's type
        int index = get_symbol_table_index(root -> id);
        // printf("want to access: %s\n", root->id);
        // printf("index: %d\n", index);
        if (index != -1) {
            if (symbol_table[index].type != 'f') {
                return symbol_table[index].value;
            } else {
                printf("want to return function\n");
            }
        } else {
            yyerror("variable not exist");
            // printf("variable not exist\n");
            return 66666;
        }
    } else if (root -> type == 'E') {
        // type E node should not be called directly, because node type will be changed while traverse
        printf("call type E\n");
        return 0;
        // exps for num_ops and bool_ops
    } else if (root -> type == 'P') {
        int tmp_value = Interpret_expression(root -> leftChild);
        printf("%d\n", tmp_value);
        return 0;
    } else if (root -> type == 'p') {
        int tmp_value = Interpret_expression(root -> leftChild);
        if (tmp_value == 1) {
            printf("#t\n");
        } else {
            printf("#f\n");
        }
        return 0;
    } else if (root -> type == 'T') {
        Interpret_expression(root -> leftChild);
        Interpret_expression(root -> rightChild);
        return 0;
    } else if (root -> type == 'D') {
        // printf("define\n");
        symbol_table[symbol_table_count].id = root -> leftChild -> id;
        // printf("%s\n", symbol_table[symbol_table_count].id);
        symbol_table[symbol_table_count].scope = scope_count;
        if (root -> rightChild -> type == 'F') {
            symbol_table[symbol_table_count].type = 'F';
            symbol_table[symbol_table_count].fun = root -> rightChild;
            symbol_table[symbol_table_count].value = 0;
        } else {
            // don't care about type now, if rightChild type == bool or type == O and 
            symbol_table[symbol_table_count].type = 'I';
            symbol_table[symbol_table_count].value = Interpret_expression(root -> rightChild);
            // printf("%d\n", symbol_table[symbol_table_count].value);
            symbol_table[symbol_table_count].fun = NULL;
        }
        symbol_table_count += 1;
    } else if (root -> type == '+') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = 0;
        if (root -> rightChild == NULL) {
            return tmp_1;
        } else if (root -> rightChild -> type == 'E' || root -> rightChild -> type == '+') {
            root -> rightChild -> type = '+';
            tmp_2 = Interpret_expression(root -> rightChild); 
        } else {
            printf("unexpected plus\n");
        }
        return tmp_1 + tmp_2;
    } else if (root -> type == '-') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = Interpret_expression(root -> rightChild);
        return tmp_1 - tmp_2;
    } else if (root -> type == '*') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = 1;
        if (root -> rightChild == NULL) {
            return tmp_1;
        } else if (root -> rightChild -> type == 'E' || root -> rightChild -> type == '*') {
            root -> rightChild -> type = '*';
            tmp_2 = Interpret_expression(root -> rightChild); 
        } else {
            printf("unexpected mul\n");
        }
        return tmp_1 * tmp_2;
    } else if (root -> type == '/') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = Interpret_expression(root -> rightChild);
        return tmp_1 / tmp_2;
    } else if (root -> type == '%') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = Interpret_expression(root -> rightChild);
        return tmp_1 % tmp_2;
    } else if (root -> type == '>') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = Interpret_expression(root -> rightChild);
        return tmp_1 > tmp_2;
    } else if (root -> type == '<') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = Interpret_expression(root -> rightChild);
        return tmp_1 < tmp_2;
    } else if (root -> type == '=') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = 0;
        if (root -> rightChild == NULL) {
            return tmp_1;
        } else if (root -> rightChild -> type == 'E' || root -> rightChild -> type == '=') {
            root -> rightChild -> type = '=';
            tmp_2 = Interpret_expression(root -> rightChild); 
        } else {
            printf("unexpected equal\n");
        }
        return tmp_1 == tmp_2;
    } else if (root -> type == '&') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = 0;
        if (root -> rightChild == NULL) {
            return tmp_1;
        } else if (root -> rightChild -> type == 'E' || root -> rightChild -> type == '&') {
            root -> rightChild -> type = '&';
            tmp_2 = Interpret_expression(root -> rightChild); 
        } else {
            printf("unexpected and\n");
        }
        // printf("%d\n", tmp_1);
        // printf("%d\n", tmp_2);


        return tmp_1 && tmp_2;
    } else if (root -> type == '|') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        int tmp_2 = 0;
        if (root -> rightChild == NULL) {
            return tmp_1;
        } else if (root -> rightChild -> type == 'E' || root -> rightChild -> type == '|') {
            root -> rightChild -> type = '|';
            tmp_2 = Interpret_expression(root -> rightChild); 
        } else {
            printf("unexpected or\n");
        }
        return tmp_1 || tmp_2;
    } else if (root -> type == '^') {
        int value = Interpret_expression(root -> leftChild);
        // printf("original: %d\n", value);
        if (value == 1) {
            return 0;
        } else if (value == 0) {
            return 1;
        } else {
            yyerror("Type error!");
            return 0;
        }
    } else if (root -> type == 'S') {
        // when function is called 
        insert_symbol_table('I', root -> leftChild -> id, param_stack[param_stack_count - 1], scope_count, NULL);
        param_stack_count -= 1;
        Interpret_expression(root -> rightChild);
        return 0;
    } else if (root -> type == 'F') {
        // link param
        // printf("called\n");
        Interpret_expression(root -> leftChild);
        return Interpret_expression(root -> rightChild);
    } else if (root -> type == 'C') {
        // push parameter to stack
        Interpret_expression(root -> leftChild);
        if (root -> rightChild -> type == 'V') {
            int index = get_symbol_table_index(root -> rightChild -> id);
            // printf("function index: %d\n", index);
            root -> rightChild = symbol_table[index].fun;
        }
        scope_count += 1;
        int tmp_1 = Interpret_expression(root -> rightChild);

        remove_symbol_table_entry(scope_count);
        scope_count -= 1;
        return tmp_1;
    } else if (root -> type == 'A') {
        // push parameters to stack
        Interpret_expression(root -> rightChild);
        int tmp_1 = Interpret_expression(root -> leftChild);
        param_stack[param_stack_count] = tmp_1;
        param_stack_count += 1;
        return 0;
    } else if (root -> type == 'G') {
        int tmp_1 = Interpret_expression(root -> leftChild);
        root -> rightChild -> value = tmp_1;
        int tmp_2 = Interpret_expression(root -> rightChild);
        return tmp_2;
    } else if (root -> type == 'X') {
        int tmp = 0;
        if (root -> value == 1) {
            tmp = Interpret_expression(root -> leftChild);
        } else if (root -> value == 0) {
            tmp = Interpret_expression(root -> rightChild);
        }
        return tmp;
    } else {
        // the type should not exist 
        yyerror("unexpected type");
    }
}

// search symbol table to access variable
int get_symbol_table_index(char* tmp_id) {
    for (int index = 0; index < symbol_table_count; index++) {
        // printf("%s %s\n", symbol_table[index].id, tmp_id);
        // printf("%d %d\n", symbol_table[index].scope, scope_count);
        // printf("%d %d\n", strcmp(symbol_table[index].id, tmp_id) == 0, symbol_table[index].scope == scope_count);

        if ((strcmp(symbol_table[index].id, tmp_id) == 0) && (symbol_table[index].scope == scope_count)) {
            // printf("return: %d\n", index);
            return index;
        }
    }
    // -1 means variable not exist
    return -1;
}

void remove_symbol_table_entry(int scope) {
    for (int index = 0; index < symbol_table_count; index++) {
        if (symbol_table[index].scope == scope) {
            // printf("symbol_table_count: %d\n", symbol_table_count);
            symbol_table_count--;
        }
    }
}

void insert_symbol_table(char type, char* id, int value, int scope, struct Node* fun) {
    symbol_table[symbol_table_count].type = type;
    symbol_table[symbol_table_count].id = id;
    symbol_table[symbol_table_count].value = value;
    symbol_table[symbol_table_count].scope = scope;
    symbol_table[symbol_table_count].fun = fun;
    symbol_table_count += 1;
}

