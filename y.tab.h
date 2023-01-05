/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    LABEL_VAR = 258,               /* LABEL_VAR  */
    LABEL_FUNC = 259,              /* LABEL_FUNC  */
    LABEL_STRUCT = 260,            /* LABEL_STRUCT  */
    LABEL_MAIN = 261,              /* LABEL_MAIN  */
    DECL_VAR = 262,                /* DECL_VAR  */
    DECL_CUSTOM = 263,             /* DECL_CUSTOM  */
    DECL_FUNCTION = 264,           /* DECL_FUNCTION  */
    DECL_ARRAY = 265,              /* DECL_ARRAY  */
    DECL_TYPE = 266,               /* DECL_TYPE  */
    DECL_CONSTANT = 267,           /* DECL_CONSTANT  */
    STRING_VAL = 268,              /* STRING_VAL  */
    INT_VAL = 269,                 /* INT_VAL  */
    FLOAT_VAL = 270,               /* FLOAT_VAL  */
    CHAR_VAL = 271,                /* CHAR_VAL  */
    BOOL_VAL = 272,                /* BOOL_VAL  */
    IDENTIFIER = 273,              /* IDENTIFIER  */
    NAME = 274,                    /* NAME  */
    ASSIGN = 275,                  /* ASSIGN  */
    POINT_TO = 276,                /* POINT_TO  */
    STRUCT_VARS = 277,             /* STRUCT_VARS  */
    STRUCT_METHODS = 278,          /* STRUCT_METHODS  */
    FUNC_RETURN = 279,             /* FUNC_RETURN  */
    COMPARATION_OP = 280,          /* COMPARATION_OP  */
    LOGICAL_OP = 281,              /* LOGICAL_OP  */
    IF = 282,                      /* IF  */
    ELSE = 283,                    /* ELSE  */
    ELSE_IF = 284,                 /* ELSE_IF  */
    WHILE = 285,                   /* WHILE  */
    FOR = 286,                     /* FOR  */
    IN = 287,                      /* IN  */
    REPEAT = 288,                  /* REPEAT  */
    UNTIL = 289                    /* UNTIL  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define LABEL_VAR 258
#define LABEL_FUNC 259
#define LABEL_STRUCT 260
#define LABEL_MAIN 261
#define DECL_VAR 262
#define DECL_CUSTOM 263
#define DECL_FUNCTION 264
#define DECL_ARRAY 265
#define DECL_TYPE 266
#define DECL_CONSTANT 267
#define STRING_VAL 268
#define INT_VAL 269
#define FLOAT_VAL 270
#define CHAR_VAL 271
#define BOOL_VAL 272
#define IDENTIFIER 273
#define NAME 274
#define ASSIGN 275
#define POINT_TO 276
#define STRUCT_VARS 277
#define STRUCT_METHODS 278
#define FUNC_RETURN 279
#define COMPARATION_OP 280
#define LOGICAL_OP 281
#define IF 282
#define ELSE 283
#define ELSE_IF 284
#define WHILE 285
#define FOR 286
#define IN 287
#define REPEAT 288
#define UNTIL 289

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 13 "main.y"

    char* strval;
    struct List list;

#line 140 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
