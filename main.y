%{
#include <stdio.h>
#include <stdlib.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
int yyerror(char* s);
int yylex(void);
%}
 
%start program
%token LABEL_VAR LABEL_FUNC LABEL_STRUCT LABEL_MAIN
%token DECL_VAR DECL_CUSTOM DECL_FUNCTION
%token DECL_CONSTANT DECL_TYPE
%token STRING_VAL INT_VAL FLOAT_VAL
%token IDENTIFIER ASSIGN

%%
program: global_section struct_section function_section main_section {printf("program corect sintactic\n");}

/* Variabile globale */
global_section: LABEL_VAR var_declaration ;

var_declaration: var_declaration decl_line ';' 
                | /* epsilon */
                ;
decl_line: DECL_VAR DECL_TYPE var_list 
          | DECL_VAR DECL_CONSTANT DECL_TYPE const_list
          ;
var_list: IDENTIFIER 
        | IDENTIFIER ASSIGN INT_VAL
        | IDENTIFIER ASSIGN FLOAT_VAL
        | IDENTIFIER ASSIGN STRING_VAL
        | var_list ',' IDENTIFIER
        | var_list ',' IDENTIFIER ASSIGN INT_VAL
        | var_list ',' IDENTIFIER ASSIGN STRING_VAL
        | var_list ',' IDENTIFIER ASSIGN FLOAT_VAL
        ;
const_list: IDENTIFIER ASSIGN INT_VAL
        | IDENTIFIER ASSIGN STRING_VAL
        | IDENTIFIER ASSIGN FLOAT_VAL
        | var_list ',' IDENTIFIER ASSIGN INT_VAL
        | var_list ',' IDENTIFIER ASSIGN STRING_VAL
        | var_list ',' IDENTIFIER ASSIGN FLOAT_VAL
        ;

/* Structuri definite de user */
struct_section: LABEL_STRUCT ;

/* Functii */
function_section: LABEL_FUNC ;

/* Main */
main_section: LABEL_MAIN ;

%%

int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 