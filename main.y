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
%token DECL_VAR DECL_CUSTOM DECL_FUNCTION DECL_ARRAY
%token DECL_CONSTANT DECL_TYPE
%token STRING_VAL INT_VAL FLOAT_VAL
%token IDENTIFIER ASSIGN NAME POINT_TO
%token STRUCT_VARS STRUCT_METHODS
%token FUNC_RETURN
%token COMPARATION_OP LOGICAL_OP
%token IF ELSE ELSE_IF WHILE FOR IN REPEAT UNTIL 
%left '+' '-'
%left '*' '/' '%'
%%
program: global_section struct_section function_section main_section {printf("program corect sintactic\n");}


/* Variabile globale */
global_section: LABEL_VAR var_declaration ;

var_declaration: var_declaration decl_line ';' 
                | /* epsilon */
                ;
decl_line: DECL_VAR DECL_TYPE var_list
          | DECL_VAR DECL_CONSTANT DECL_TYPE var_list
          | DECL_CUSTOM NAME custom_list 
          | DECL_CUSTOM DECL_CONSTANT NAME custom_list
          | DECL_ARRAY DECL_TYPE array_list
          | DECL_ARRAY DECL_CONSTANT DECL_TYPE array_list
          ;
var_list: IDENTIFIER 
        | IDENTIFIER ASSIGN var_value
        | var_list ',' IDENTIFIER
        | var_list ',' IDENTIFIER ASSIGN var_value
        ;
custom_list: IDENTIFIER 
           | IDENTIFIER '(' initializer_list ')'
           | custom_list ',' IDENTIFIER
           | custom_list ',' IDENTIFIER '(' initializer_list ')'
           ;
array_list: IDENTIFIER 
          | IDENTIFIER ASSIGN '[' initializer_list ']'
          | array_list ',' IDENTIFIER 
          | array_list ',' IDENTIFIER ASSIGN '[' initializer_list ']'

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
parameter: DECL_VAR DECL_TYPE IDENTIFIER
         | DECL_VAR DECL_CONSTANT DECL_TYPE IDENTIFIER
         | DECL_ARRAY DECL_TYPE IDENTIFIER
         | DECL_ARRAY DECL_CONSTANT DECL_TYPE IDENTIFIER
         | DECL_CUSTOM NAME IDENTIFIER
         | DECL_CUSTOM DECL_CONSTANT NAME IDENTIFIER
        ;
return_instr: FUNC_RETURN expression ';'

function_call: NAME '(' ')'
             | NAME '(' call_list ')'
             ;
call_list: call_list ',' expression
         | expression
         ;



/* Main */
main_section: LABEL_MAIN code_block;

code_block: code_block code_statement
          | /* epsilon */
          ;
//de adaugat mai multe
code_statement: lvalue ASSIGN expression ';'
              | while_statement
              | repeat_statement
              | for_statement
              | if_statement
              ; 


/* Diverse */
lvalue: IDENTIFIER mem_location
      | IDENTIFIER mem_location POINT_TO lvalue //structura
      ;
rvalue:   function_call
        | var_value
        | IDENTIFIER mem_location POINT_TO function_call
        | lvalue
        ;
mem_location: '[' INT_VAL ']' 
            | /* epsilon */
            ;
expression: rvalue
          | expression '+' expression 
          | expression '-' expression
          | expression '*' expression
          | expression '/' expression
          | expression '%' expression
          | '(' expression ')'
          ;
bool_expression: expression COMPARATION_OP expression
                | expression
                ;

list_expression: list_expression LOGICAL_OP bool_expression
               | bool_expression
               ;

while_statement: WHILE list_expression '{' code_block '}'
               ;

repeat_statement : REPEAT '{' code_block '}' UNTIL list_expression ';'
                 ;

for_statement: FOR IDENTIFIER IN lvalue  '{' code_block '}'
             ;

if_statement: IF list_expression '{' code_block '}' elseif_statement else_statement
            ;

elseif_statement: elseif_statement ELSE_IF list_expression '{' code_block '}'
                | /* epsilon */
                ;

else_statement: ELSE '{' code_block '}'
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