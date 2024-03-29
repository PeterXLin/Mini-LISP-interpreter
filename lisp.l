/* definintion section */
%{
    /* cause we want to use the token defined by yacc*/
    #include "lisp.tab.h"
    // void yyerror(const char *);
%}

separator   [\t\n\r ] 
letter      [a-z]
digit       [0-9]

number      0|[1-9]{digit}*|"-"[1-9]{digit}*
ID          {letter}({letter}|{digit}|"-")* 

%% 
"+"             {return(PLUS);}   /* rule section */
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
"fun"        {return(LAMBDA);}
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
{number}        {yylval.ival = atoi(yytext); return(NUMBER); /* set yylval.ival to pass readed input to yacc */}
{ID}            {yylval.word = strdup(yytext); return(ID);}
"("|")"         {return(yytext[0]); /* yytext is a char pointer, which store the matched string */ }
{separator}     {}       
.               {}
%%

/* subrountine section */