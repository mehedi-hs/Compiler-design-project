%{
#include "simple.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int checkType(char* name);

%}
%x COMMENT
%%

"-?"          { BEGIN(COMMENT); }
<COMMENT>"?-" { BEGIN(INITIAL); }
<COMMENT>.|\n { }
"--"[^<\n][^\n]* {}

[0-9]*\.[0-9]+ {yylval.fl=atof(yytext); return FRACTION;}
[0-9]+ { yylval.in=atoi(yytext); return NUMBER; } // convert string to int

gate          {return GATE;}
take          { return TAKE; }
in            { return INT; }
fl            { return FLOAT; }
cr            { return CHAR; }
show          { return PRINT; }

[a-z_A-Z_][a-z_A-Z0-9]* {
    yylval.cr=strdup(yytext);
    int type = checkType(yytext);

    if (type == 1) {
        return VAR_INT; 
    } else if (type == 2) {
        return VAR_FLOAT;
    } else {
       return NAME;}
    }


\" {return QUOTE;}
";" {return SEMICOLON;}
"=" {return EQUAL;}
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MULTIPLY;}
"/" { return DIVISION;}
"(" {return LEFTPAREN;}
")" {return RIGHTPAREN;}
\n { return EOL; }
[ \t\r]+ { }
. { printf("Unknown character: %s\n", yytext);}

%%

int yywrap(void) { return 1; }