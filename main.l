%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%

"_GLOBAL_VARS_" {return LABEL_VAR;}
"_STRUCTURES_" {return LABEL_STRUCT;}
"_FUNCTIONS_" {return LABEL_FUNC;}
"_BEGIN_PROGR_" {return LABEL_MAIN;}

"var" {return DECL_VAR;}
"custom" {return DECL_CUSTOM;}
"function" {return DECL_FUNCTION;}
"array" {return DECL_ARRAY;}

"vars" {return STRUCT_VARS;}
"methods" {return STRUCT_METHODS;}

"const" {return DECL_CONSTANT;}
"int"|"float"|"char"|"string"|"bool" {return DECL_TYPE;}

"if" {return IF;}
"else" {return ELSE;}
"elif" {return ELSE_IF;}
"while" {return WHILE;}
"for" {return FOR;}
"in" {return IN;}
"repeat" {return REPEAT;}
"until" {return UNTIL;}

">"|">="|"<"|"<="|"=="|"!=" {return COMPARATION_OP;}
"and"|"or"|"xor" {return LOGICAL_OP;}

"return" {return FUNC_RETURN;}

$[_a-zA-Z][_a-zA-Z0-9]* {return IDENTIFIER;}
[_a-zA-Z][_a-zA-Z0-9]* {return NAME;}

"<-" {return ASSIGN;}
"->" {return POINT_TO;}

'[_a-zA-Z0-9]*' {return STRING_VAL;}
0|([1-9][0-9]*) {return INT_VAL;}
(0|[1-9][0-9]*)\.[0-9]* {return FLOAT_VAL;}


[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

