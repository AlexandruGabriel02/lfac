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

"vars" {return STRUCT_VARS;}
"methods" {return STRUCT_METHODS;}

"const" {return DECL_CONSTANT;}
"int"|"float"|"char"|"string"|"bool" {return DECL_TYPE;}

"return" {return FUNC_RETURN;}

$[_a-zA-Z][_a-zA-Z0-9]* {return IDENTIFIER;}
[_a-zA-Z][_a-zA-Z0-9]* {return NAME;}

"<-" {return ASSIGN;}

'[_a-zA-Z0-9]*' {return STRING_VAL;}
0|([1-9][0-9]*) {return INT_VAL;}
(0|[1-9][0-9]*)\.[0-9]* {return FLOAT_VAL;}


[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

