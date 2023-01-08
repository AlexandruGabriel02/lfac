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

enum nodeType
{
    OPERAND_NODE,
    OPERATOR_NODE
};

struct ExprInfo
{
    char* type;
    char* value;
    int intVal;
    bool isEvaluable;
};

struct AST
{
    struct ExprInfo info;
    struct AST* left;
    struct AST* right;
};