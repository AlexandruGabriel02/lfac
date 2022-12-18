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
%token IDENTIFIER ASSIGN NAME POINT_TO
%token STRUCT_VARS STRUCT_METHODS
%token FUNC_RETURN

%%
program: global_section struct_section function_section main_section {printf("program corect sintactic\n");}


/* Variabile globale */
global_section: LABEL_VAR var_declaration ;

var_declaration: var_declaration decl_line ';' 
                | /* epsilon */
                ;
decl_var_dimension: DECL_VAR 
                  | decl_var_dimension '[' INT_VAL ']'
                  ;
decl_struct_dimension: DECL_CUSTOM
                     | decl_struct_dimension '[' INT_VAL ']'
                     ;
decl_line: decl_var_dimension DECL_TYPE var_list 
          | decl_var_dimension DECL_CONSTANT DECL_TYPE const_list
          | decl_struct_dimension NAME var_list 
          | decl_struct_dimension DECL_CONSTANT NAME const_list
          ;
var_list: IDENTIFIER 
        | IDENTIFIER ASSIGN var_value
        | IDENTIFIER '(' initializer_list ')'
        | var_list ',' IDENTIFIER
        | var_list ',' IDENTIFIER ASSIGN var_value
        ;
const_list: IDENTIFIER ASSIGN var_value
        | IDENTIFIER '(' initializer_list ')'
        | var_list ',' IDENTIFIER ASSIGN var_value
        ;
var_value: INT_VAL | STRING_VAL | FLOAT_VAL ;
initializer_list: initializer_list ',' var_value 
                | var_value
                ;



/* Structuri definite de user (structura aka 'custom') */
struct_section: LABEL_STRUCT  struct_declaration;

struct_declaration: struct_declaration singular_struct
                  | /* epsilon */
                  ;
singular_struct: DECL_CUSTOM NAME '{' struct_code '}'
                ;
struct_code: STRUCT_VARS ':' str_vars_section STRUCT_METHODS ':' str_methods_section
           | /* epsilon */
           ;
str_vars_section: var_declaration ;
str_methods_section: func_declaration ;




/* Functii */
function_section: LABEL_FUNC func_declaration;

func_declaration: func_declaration singular_function
                | /* epsilon */ 
                ;
singular_function: DECL_FUNCTION NAME '(' list_param ')' ':' DECL_TYPE 
                '{' code_block return_instr '}' 
                | DECL_FUNCTION NAME '(' ')' ':' DECL_TYPE 
                '{' code_block return_instr '}'
                | DECL_FUNCTION NAME '(' list_param ')' 
                '{' code_block '}'
                | DECL_FUNCTION NAME '(' ')'
                '{' code_block '}'
                ;
list_param: list_param ',' parameter
          | parameter
          ; 
parameter: decl_var_dimension DECL_TYPE IDENTIFIER
         | decl_var_dimension DECL_CONSTANT DECL_TYPE IDENTIFIER
        ;
return_instr: FUNC_RETURN rvalue ';'

function_call: NAME '(' ')'
             | NAME '(' call_list ')'
             ;
call_list: call_list ',' rvalue
         | rvalue
         ;



/* Main */
main_section: LABEL_MAIN code_block;

code_block: code_block code_statement
          | /* epsilon */
          ;
//de adaugat mai multe
code_statement: lvalue ASSIGN rvalue ';'
              ; //exemplu de test; remove this




/* Diverse */
lvalue: IDENTIFIER mem_location
      | IDENTIFIER mem_location POINT_TO lvalue //structura
      ;
rvalue:   function_call
        | var_value
        | IDENTIFIER mem_location POINT_TO function_call
        | lvalue
        ;
mem_location: mem_location '[' INT_VAL ']'
            | /* epsilon */
            ;


%%

int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 