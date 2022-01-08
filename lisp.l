%{
    #include "lisp.tab.h"
    // void yyerror(const char *);
%}

separator   [\t\n\r ] 
letter      [a-z]
digit       [0-9]

number      0|[1-9]{digit}*|"-"[1-9]{digit}*
ID          {letter}({letter}|{digit}|"-")* 

%% 
"+"             {return(PLUS);}
"-"             {return(MINUS);}
"*"             {return(MUL);}
"/"             {return(DIV);}
"mod"           {return(MOD);}
">"             {return(GR);}
"<"             {return(SM);}
"="             {return(EQ);}
"and"           {return(AND);}
"or"            {return(OR);}
"not"           {return(NOT);}
"print-num"     {return(PRINTNUM);}
"print-bool"    {return(PRINTBOOL);}
"define"        {return(DEFINE);}
"lambda"        {return(LAMBDA);}
"if"            {return(IF);}
"#t"|"#f"       {
                    if (yytext[1] == 't') {
                        yylval.ival = 1;
                        return(BOOLEAN);
                    } else {
                        yylval.ival = 0;
                        return(BOOLEAN);
                    }
                }
{number}        {yylval.ival = atoi(yytext); return(NUMBER);}
{ID}            {yylval.word = strdup(yytext); return(ID);}
"("|")"         {return(yytext[0]);}
{separator}     {}       
.               {}
%%