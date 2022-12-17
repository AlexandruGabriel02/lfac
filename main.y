%{
#include <stdio.h>
#include <stdlib.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
int yyerror(char* s);
int yylex(void);
%}



%%

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 