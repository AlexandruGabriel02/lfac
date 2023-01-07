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
    char* value;
};