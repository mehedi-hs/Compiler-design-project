%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(const char *s);
extern FILE *yyin;

/* Symbol table */
typedef enum {TYPE_IN, TYPE_FL, TYPE_CR} Data_type;
struct Symbol {
    char* name;
    Data_type type;
    union{
        int val_in;
        float val_fl;
        char* val_cr;
    } Data;
};

    struct Symbol symbol_table[100];
    int table_count = 0;

    void storeIn(char* name, int val);
    void storeFl(char* name, float val);
    void storeCr(char* name, char* val);
    void showVal(char* name);
    int getIn(char* name);
    float getFl(char* name);
    int checkType (char* name);
    void readInput(int type, char* name);

%}

/* ===== Union ===== */
%union {
    int in;
    float fl;
    char* cr;
}

/* ===== Tokens ===== */
%token EOL
%token <in> NUMBER
%token <cr> CHARACTER
%token <fl> FRACTION
%token <cr> NAME
%token GATE
%token TAKE
%token PLUS
%token SEMICOLON
%token QUOTE
%token <cr> VAR_INT
%token <cr> VAR_FLOAT

%type <in> expression
%type <fl> expression2

%token PRINT
%token EQUAL
%token MINUS
%token MULTIPLY
%left PLUS MINUS
%left MULTIPLY
%left DIVISION

%token LEFTPAREN
%token RIGHTPAREN

%type <in> fact
%type <fl> fact2

%token INT
%token FLOAT
%token CHAR
%%

program:
     
    |program statement
;

statement:
    GATE INT NAME EQUAL expression SEMICOLON EOL {storeIn($3, $5);printf("%d is the value \n",$5);}
|   GATE INT NAME EQUAL expression SEMICOLON {storeIn($3, $5);printf("%d is the value\n",$5);}
|   GATE FLOAT NAME EQUAL expression2 SEMICOLON {storeFl($3, $5);printf("%f is the value\n",$5);}
|   GATE FLOAT NAME EQUAL expression2 SEMICOLON EOL {storeFl($3, $5);printf("%f is the value\n",$5);}
|   GATE CHAR NAME EQUAL QUOTE NAME QUOTE SEMICOLON {storeCr($3, $6);printf("%s is the value \n",$6);}
|   TAKE INT NAME SEMICOLON { readInput(1, $3); }
|   TAKE FLOAT NAME SEMICOLON { readInput(2, $3); }
|   TAKE CHAR NAME SEMICOLON { readInput(3, $3); }
|   TAKE INT NAME SEMICOLON EOL { readInput(1, $3); }
|   TAKE FLOAT NAME SEMICOLON EOL { readInput(2, $3); }
|   TAKE CHAR NAME SEMICOLON EOL { readInput(3, $3); }
|   PRINT LEFTPAREN NAME RIGHTPAREN SEMICOLON {showVal($3);}
|   PRINT LEFTPAREN VAR_INT RIGHTPAREN SEMICOLON {showVal($3);}
|   PRINT LEFTPAREN VAR_FLOAT RIGHTPAREN SEMICOLON {showVal($3);}
|   EOL {}
    ;

expression:
     expression PLUS expression   { $$ = $1 + $3; }
    | expression MINUS expression  { $$ = $1 - $3; }
    | expression MULTIPLY expression    { $$ = $1 * $3; }
    | expression DIVISION expression    { $$ = $1 / $3; }
    |fact;


    fact:
    NUMBER { $$ = $1; }
|   VAR_INT   { $$ = getIn($1); }
|   LEFTPAREN expression RIGHTPAREN {$$ = $2;} 


expression2:
    expression2 PLUS expression2 { $$ = $1 + $3; }
|   expression2 MINUS expression2 { $$ = $1 - $3; }
|   expression2 MULTIPLY expression2 { $$ = $1 * $3; }
|   expression2 DIVISION expression2 { $$ = $1 / $3; }
|   expression PLUS expression2 { $$ = $1 + $3; }
|   expression MINUS expression2 { $$ = $1 - $3; }
|   expression MULTIPLY expression2 { $$ = $1 * $3; }
|   expression DIVISION expression2 { $$ = $1 / $3; }
|   expression2 PLUS expression  { $$ = $1 + $3; }
|   expression2 MINUS expression { $$ = $1 - $3; }
|   expression2 MULTIPLY expression { $$ = $1 * $3; }
|   expression2 DIVISION expression { $$ = $1 / $3; }
|   fact2;

fact2:
    FRACTION { $$ = $1; }
|   VAR_FLOAT { $$ = getFl($1); }
|   LEFTPAREN expression2 RIGHTPAREN {$$ = $2;}

%%

/* User Section */

int getIndex(char *name) {
    for(int i = 0; i < table_count; i++) {
        if(strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1; 
}
int checkType(char *name) {
    int idx = getIndex(name);
    if (idx == -1) return 0; // Not found
    
    if (symbol_table[idx].type == TYPE_IN) return 1;
    if (symbol_table[idx].type == TYPE_FL) return 2;
    return 0;
}
// Store a 'in'
void storeIn(char *name, int val) {
    int idx = getIndex(name);
    if(idx == -1) { idx = table_count++; symbol_table[idx].name = name; }
    
    symbol_table[idx].type = TYPE_IN;
    symbol_table[idx].Data.val_in = val;
}

// Store a 'fl'
void storeFl(char *name, float val) {
    int idx = getIndex(name);
    if(idx == -1) { idx = table_count++; symbol_table[idx].name = name; }
    
    symbol_table[idx].type = TYPE_FL;
    symbol_table[idx].Data.val_fl = val;
}

// Store 'cr'
void storeCr(char *name, char *val) {
    int idx = getIndex(name);
    if(idx == -1) { idx = table_count++; symbol_table[idx].name = name; }
    
    symbol_table[idx].type = TYPE_CR;
    symbol_table[idx].Data.val_cr = val;
}

// Retrieve a 'in' for math
int getIn(char *name) {
    int idx = getIndex(name);
    if(idx == -1) { printf("Error: Variable %s not found.\n", name); return 0; }
    return symbol_table[idx].Data.val_in;
}

// Retrieve a 'fl' for math
float getFl(char *name) {
    int idx = getIndex(name);
    if(idx == -1) { printf("Error: Variable %s not found.\n", name); return 0.0; }
    return symbol_table[idx].Data.val_fl;
}

// Execute the 'show' command
void showVal(char *name) {
    int idx = getIndex(name);
    if(idx == -1) {
        printf("Error: Variable '%s' does not exist.\n", name);
        return;
    }
    
    if(symbol_table[idx].type == TYPE_IN) {
        printf("%d\n", symbol_table[idx].Data.val_in);
    } else if(symbol_table[idx].type == TYPE_FL) {
        printf("%f\n", symbol_table[idx].Data.val_fl);
    } else if(symbol_table[idx].type == TYPE_CR) {
        printf("%s\n", symbol_table[idx].Data.val_cr);
    }
}
void readInput(int type, char* name) {
    printf("Enter value for %s: ", name);
    
    if (type == 1) { // INT
        int val;
        scanf("%d", &val);
        storeIn(name, val);
    } 
    else if (type == 2) { // FLOAT
        float val;
        scanf("%f", &val);
        storeFl(name, val);
    } 
    else if (type == 3) { 
        char buffer[100];
        scanf("%s", buffer); 
        storeCr(name, strdup(buffer)); // Use strdup to save the string safely
    }
}
int main(void) {
    yyin = fopen("input.txt", "r");
    int res=yyparse();
    fclose(yyin);
    return res;
}

int yyerror(const char *s) {
    printf("ERROR: %s \n", s);
    return 0;
}