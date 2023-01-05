%{
#include <stdio.h>
#include "declarations.h"
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
"int"|"float"|"char"|"string"|"bool" {yylval.strval = strdup(yytext); return DECL_TYPE;}

"if" {return IF;}
"else" {return ELSE;}
"elif" {return ELSE_IF;}
"while" {return WHILE;}
"for" {return FOR;}
"in" {return IN;}
"repeat" {return REPEAT;}
"until" {return UNTIL;}

\"[_a-zA-Z0-9]*\" {yylval.strval = strdup(yytext); return STRING_VAL;}
\'[a-zA-Z0-9]\' {yylval.strval = strdup(yytext); return CHAR_VAL;}
0|([1-9][0-9]*) {yylval.strval = strdup(yytext); return INT_VAL;}
(0|[1-9][0-9]*)\.[0-9]* {yylval.strval = strdup(yytext); return FLOAT_VAL;}
"true"|"false" {yylval.strval = strdup(yytext); return BOOL_VAL;} 

">"|">="|"<"|"<="|"=="|"!=" {return COMPARATION_OP;}
"and"|"or"|"xor" {return LOGICAL_OP;}

"return" {return FUNC_RETURN;}

$[_a-zA-Z][_a-zA-Z0-9]* {yylval.strval = strdup(yytext); return IDENTIFIER;}
[_a-zA-Z][_a-zA-Z0-9]* {yylval.strval = strdup(yytext); return NAME;}

"<-" {return ASSIGN;}
"->" {return POINT_TO;}


[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

