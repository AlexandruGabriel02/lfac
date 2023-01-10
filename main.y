%{
#include <stdio.h>
#include <stdlib.h>
#include "semantics.h"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
int yyerror(char* s);
int yylex(void);
%}

%union
{
    char* strval;
    struct List list;
    struct AST* tree;
    struct ExprInfo expr_info;
}

%start program

%token LABEL_VAR LABEL_FUNC LABEL_STRUCT LABEL_MAIN
%token DECL_VAR DECL_CUSTOM DECL_FUNCTION DECL_ARRAY
%token<strval> DECL_TYPE 
%token DECL_CONSTANT 
%token<strval> STRING_VAL INT_VAL FLOAT_VAL CHAR_VAL BOOL_VAL
%token<strval> IDENTIFIER NAME 
%token ASSIGN POINT_TO
%token STRUCT_VARS STRUCT_METHODS
%token FUNC_RETURN
%token COMPARATION_OP LOGICAL_OP
%token IF ELSE ELSE_IF WHILE FOR IN REPEAT UNTIL 
%token TYPE_OF EVAL

%left '+' '-'
%left '*' '/' '%'

%type<strval> return_instr
%type<list> initializer_list call_list
%type<expr_info> var_value rvalue lvalue function_call 
%type<tree> expression

%%
program: struct_section global_section function_section main_section {printf("Program compilat cu succes!\n");}


/* Variabile globale */
global_section: LABEL_VAR var_declaration ;

var_declaration: var_declaration decl_line ';' 
                | /* epsilon */
                ;
decl_line: DECL_VAR DECL_TYPE {setVarType($2);} var_list {resetGlobal();}
          | DECL_VAR DECL_CONSTANT DECL_TYPE {setVarType($3); setConstant();} var_list {resetGlobal();}
          | DECL_CUSTOM NAME {checkStructName($2); setVarType($2);} custom_list {resetGlobal();}
          | DECL_CUSTOM DECL_CONSTANT NAME {checkStructName($3); setVarType($3); setConstant();} custom_list {resetGlobal();}
          | DECL_ARRAY DECL_TYPE {setVarType($2);} array_list {resetGlobal();}
          | DECL_ARRAY DECL_CONSTANT DECL_TYPE {setVarType($3); setConstant();} array_list {resetGlobal();}
          ;
var_list: IDENTIFIER {pushToSymTable("variabila", $1, NULL);}
        | IDENTIFIER ASSIGN var_value {pushToSymTable("variabila", $1, $3.value);}
        | var_list ',' IDENTIFIER {pushToSymTable("variabila", $3, NULL);}
        | var_list ',' IDENTIFIER ASSIGN var_value {pushToSymTable("variabila", $3, $5.value);}
        ;
custom_list: IDENTIFIER {pushToSymTable("custom", $1, NULL);}
           | IDENTIFIER '(' initializer_list ')' {pushToSymTable("custom", $1, &$3);}
           | custom_list ',' IDENTIFIER {pushToSymTable("custom", $3, NULL);}
           | custom_list ',' IDENTIFIER '(' initializer_list ')' {pushToSymTable("custom", $3, &$5);}
           ;
array_list: IDENTIFIER {pushToSymTable("array", $1, NULL);}
          | IDENTIFIER ASSIGN '[' initializer_list ']'  {pushToSymTable("array", $1, &$4);}
          | array_list ',' IDENTIFIER {pushToSymTable("array", $3, NULL);}
          | array_list ',' IDENTIFIER ASSIGN '[' initializer_list ']' {pushToSymTable("array", $3, &$6);}

var_value: INT_VAL {setExprInfo(&$$, "int", atoi($1), $1, true);} | STRING_VAL {setExprInfo(&$$, "string", 0, $1, false);} 
         | FLOAT_VAL {setExprInfo(&$$, "float", 0, $1, false);} | CHAR_VAL {setExprInfo(&$$, "char", 0, $1, false);} | BOOL_VAL {setExprInfo(&$$, "bool", 0, $1, false);} ;
initializer_list: initializer_list ',' var_value {addToList(&$$, $3.value);}
                | var_value {initList(&$$); addToList(&$$, $1.value);}
                ;


/* Structuri definite de user (structura aka 'custom') */
struct_section: LABEL_STRUCT struct_declaration {resetStructContext();};

struct_declaration: struct_declaration singular_struct
                  | /* epsilon */
                  ;
singular_struct: DECL_CUSTOM NAME {setStructContext($2);} '{' struct_code '}' {addToCustomsList();}
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
singular_function: DECL_FUNCTION NAME '(' list_param ')' ':' DECL_TYPE {pushToFuncTable($2, $7);}
                '{' code_block return_instr {checkMatchingType($7, $11);} '}' {tempResetStructContext(NULL);}
                | DECL_FUNCTION NAME '(' ')' ':' DECL_TYPE {pushToFuncTable($2, $6);}
                '{' code_block return_instr {checkMatchingType($6, $10);} '}' {tempResetStructContext(NULL);}
                | DECL_FUNCTION NAME '(' list_param ')' {pushToFuncTable($2, "void");}
                '{' code_block '}' {tempResetStructContext(NULL);}
                | DECL_FUNCTION NAME '(' ')' {pushToFuncTable($2, "void");}
                '{' code_block '}' {tempResetStructContext(NULL);}
                ;
list_param: list_param ',' parameter
          | {initParams(); tempResetStructContext("none");} parameter
          ; 
parameter: DECL_VAR DECL_TYPE IDENTIFIER {addParam($2, false, $3); setVarType($2); pushToSymTable("variabila", $3, NULL); resetGlobal();}
         | DECL_VAR DECL_CONSTANT DECL_TYPE IDENTIFIER {addParam($3, true, $4); setVarType($3); setConstant(); pushToSymTable("variabila", $4, NULL); resetGlobal();}
        //  | DECL_ARRAY DECL_TYPE IDENTIFIER
        //  | DECL_ARRAY DECL_CONSTANT DECL_TYPE IDENTIFIER
        //  | DECL_CUSTOM NAME IDENTIFIER
        //  | DECL_CUSTOM DECL_CONSTANT NAME IDENTIFIER
        ;
return_instr: FUNC_RETURN expression ';' {$$ = strdup($2->info.type);}

function_call: NAME '(' ')' {checkFuncName($1); checkFuncParams($1, NULL); setExprInfo(&$$, getTypeFromFuncName($1), 0, NULL, false);}
             | NAME '(' {checkFuncName($1);} call_list ')' {checkFuncParams($1, &$4); setExprInfo(&$$, getTypeFromFuncName($1), 0, NULL, false);}
             ;
call_list: call_list ',' expression {addToList(&$$, $3->info.type);}
         | expression {initList(&$$); addToList(&$$, $1->info.type);}
         ;



/* Main */
main_section: LABEL_MAIN code_block;

code_block: code_block code_statement
          | /* epsilon */
          ;

code_statement: lvalue {checkIfConstAssign();} ASSIGN expression ';' {checkMatchingType($1.type, $4->info.type);}
              | while_statement
              | repeat_statement
              | for_statement
              | if_statement
              | decl_line ';'
              | function_call ';'
              | IDENTIFIER POINT_TO {checkIfDeclaredVar("custom", $1, NULL, NULL);} function_call ';'
              | TYPE_OF '(' expression ')' ';' {printf("Tipul expresiei de la linia %d: %s\n", yylineno, $3->info.type);}
              | EVAL '(' expression ')' ';' { printEvalResult($3); }
              ; 


/* Diverse */
lvalue: IDENTIFIER {checkIfDeclaredVar("variabila", $1, NULL, NULL); setInfoFromVarName(&$$, $1, -1);}
      | IDENTIFIER '[' INT_VAL ']'  {checkIfDeclaredVar("array", $1, NULL, NULL); setInfoFromVarName(&$$, $1, atoi($3));}
      | IDENTIFIER POINT_TO IDENTIFIER {checkIfDeclaredVar("custom", $1, "variabila", $3); setInfoFromVarName(&$$, $1, -1);}
      | IDENTIFIER POINT_TO IDENTIFIER '[' INT_VAL ']' {checkIfDeclaredVar("custom", $1, "array", $3); setInfoFromVarName(&$$, $1, atoi($5));}
      ;
rvalue:   function_call {$$ = $1;}
        | var_value {$$ = $1;}
        | IDENTIFIER POINT_TO {checkIfDeclaredVar("custom", $1, NULL, NULL);} function_call {$$ = $4;}
        | lvalue {$$ = $1; resetConstant();}
        ;

expression: rvalue {$$ = buildAST(&$1, NULL, NULL, OPERAND_NODE);}
          | expression '+' expression {checkMatchingType($1->info.type, $3->info.type); $$ = buildAST("+", $1, $3, OPERATOR_NODE);} 
          | expression '-' expression {checkMatchingType($1->info.type, $3->info.type); $$ = buildAST("-", $1, $3, OPERATOR_NODE);} 
          | expression '*' expression {checkMatchingType($1->info.type, $3->info.type); $$ = buildAST("*", $1, $3, OPERATOR_NODE);} 
          | expression '/' expression {checkMatchingType($1->info.type, $3->info.type); $$ = buildAST("/", $1, $3, OPERATOR_NODE);} 
          | expression '%' expression {checkMatchingType($1->info.type, $3->info.type); $$ = buildAST("\%", $1, $3, OPERATOR_NODE);} 
          | '(' expression ')' {$$ = $2;}
          ;
bool_expression: expression COMPARATION_OP expression { checkMatchingType($1->info.type, $3->info.type); }
                | expression
                ;

list_expression: list_expression LOGICAL_OP bool_expression
               | bool_expression
               ;

while_statement: WHILE list_expression '{' code_block '}'
               ;

repeat_statement : REPEAT '{' code_block '}' UNTIL list_expression ';'
                 ;

for_statement: FOR lvalue IN lvalue  {checkMatchingType($2.type, $4.type);} '{' code_block '}'
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

int yyerror(char * s)
{
    printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv)
{
    yyin=fopen(argv[1],"r");
    yyparse();

    printSymTable("symbol_table.txt");
    printFuncTable("symbol_table_functions.txt");

} 