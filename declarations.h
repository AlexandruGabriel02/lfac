#include <stdbool.h>

struct ListNode
{
    char* val;
    struct ListNode* next;
};

struct List 
{
    struct ListNode* begin;
    struct ListNode* end;
};

struct ExprInfo
{
    char* type;
    int value;
    bool isEvaluable;
};

struct AST
{
    struct ExprInfo info;
    struct AST* left;
    struct AST* right;
};