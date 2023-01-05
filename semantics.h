#pragma once
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include "declarations.h"
#define N 2000

void initList(struct List* L)
{
    L->begin = L->end = NULL;
}

void addToList(struct List* L, const char* value)
{
    struct ListNode* node = (struct ListNode*) malloc(sizeof(struct ListNode));
    node->val = strdup(value);
    node->next = NULL;

    if (L->begin == NULL)
    {
        L->begin = L->end = node;
    }
    else 
    {
        L->end->next = node;
        L->end = node;
    }
}

void printList(FILE* fin, struct List* L, char delim, char open_ch, char close_ch)
{
    struct ListNode* l = L->begin;

    fprintf(fin, "%c", open_ch);
    while (l != NULL)
    {
        fprintf(fin, "%s", l->val);
        if (l == L->end)
            break;
        fprintf(fin, "%c ", delim);
        l = l->next;
    }
    fprintf(fin, "%c", close_ch);
}

/* --- pentru tabelul de variabile --- */
struct Value
{
    bool undefined;
    char* valType;
    char* val; //in caz ca am variabila simpla
    struct List* list; //in caz ca am array sau structura
};

struct Symbols 
{
    char* structName;
    char* name;
    char* symType;
    bool isConstant;
    struct Value value;
};
/* --- */

/* pentru tabelul de functii */
struct Parameters
{
    struct List isConstant;
    struct List nameList;
    struct List typeList;
};

struct Functions
{
    char* name;
    char* returnType;
    char* structName;
    struct Parameters params;
};
/* --- */

char* structContext;
char* currType;
bool isConstant = false;
int symCount = 0;
int funcCount;

struct Symbols symbolTable[N];
struct Functions funcTable[N];

void setVarType(const char* str)
{
    currType = strdup(str);
    //printf("Am declarat: %s\n", currType);
}

void setConstant()
{
    isConstant = true;
}

void resetGlobal()
{
    isConstant = false;
    free(currType);
}

void setStructContext(const char* p_structName)
{
    free(structContext);
    structContext = strdup(p_structName);
}

void resetStructContext()
{
    free(structContext);
    structContext = strdup("none");
}

void pushToSymTable(const char* p_symType, const char* p_identifier, void* p_val)
{
    symbolTable[symCount].name = strdup(p_identifier);
    symbolTable[symCount].symType = strdup(p_symType);
    symbolTable[symCount].isConstant = isConstant;
    symbolTable[symCount].value.valType = strdup(currType);
    symbolTable[symCount].structName = strdup(structContext);

    if (p_val != NULL)
    {
        symbolTable[symCount].value.undefined = false;
        if (strcmp(p_symType,"variabila") == 0)
            symbolTable[symCount].value.val = strdup((char*)p_val);
        else if (strcmp(p_symType, "array") == 0 || strcmp(p_symType, "custom") == 0)
        {
            symbolTable[symCount].value.list = (struct List*) malloc(sizeof(struct List));
            memcpy(symbolTable[symCount].value.list, p_val, sizeof(struct List));
        }
    }
    else 
    {
        symbolTable[symCount].value.undefined = true;
    }



    symCount++;
}

void initParams()
{
    initList(&funcTable[funcCount].params.isConstant);
    initList(&funcTable[funcCount].params.nameList);
    initList(&funcTable[funcCount].params.typeList);
}

void addParam(const char* p_type, bool p_isConst, const char* p_name)
{
    addToList(&funcTable[funcCount].params.nameList, p_name);
    addToList(&funcTable[funcCount].params.typeList, p_type);
    
    if (p_isConst)
        addToList(&funcTable[funcCount].params.isConstant, "const");
    else 
        addToList(&funcTable[funcCount].params.isConstant, "");
}

void pushToFuncTable(const char* p_funcName, const char* p_returnType)
{
    funcTable[funcCount].name = strdup(p_funcName);
    funcTable[funcCount].returnType = strdup(p_returnType);
    funcTable[funcCount].structName = strdup(structContext);

    funcCount++;
}

void printSymTable(const char* fileName)
{
    FILE* fin = fopen(fileName, "w");
    char constAns[3];
    for (int i = 0; i < symCount; i++)
    {
        strcpy(constAns, "Nu");
        if (symbolTable[i].isConstant)
            strcpy(constAns, "Da");
        fprintf(fin, "%d. Nume: %s, Structura: %s, Tip declarare: %s, Constant: %s, Nume tip de date: %s, Valoare: ", 
        i + 1, symbolTable[i].name, symbolTable[i].structName, symbolTable[i].symType, constAns, symbolTable[i].value.valType);

        if (symbolTable[i].value.undefined == true)
        {
            fprintf(fin, "Undefined\n");
            continue;
        }

        if (strcmp(symbolTable[i].symType, "array") == 0)
        {
            printList(fin, symbolTable[i].value.list, ',', '[', ']');
        }
        else if (strcmp(symbolTable[i].symType, "custom") == 0)
        {
            printList(fin, symbolTable[i].value.list, ',', '(', ')');
        }
        else if (strcmp(symbolTable[i].symType, "variabila") == 0)
        {
            fprintf(fin, "%s", symbolTable[i].value.val);
        }
        fprintf(fin, "\n");
    }

    fclose(fin);
}

void printFuncTable(const char* fileName)
{
    FILE* fin = fopen(fileName, "w");

    for (int i = 0; i < funcCount; i++)
    {
        fprintf(fin, "Antet functie: %s", funcTable[i].name);

        struct ListNode* l_const = funcTable[i].params.isConstant.begin;
        struct ListNode* l_type = funcTable[i].params.typeList.begin;
        fprintf(fin, "(");
        while (l_type != NULL)
        {
            fprintf(fin, "%s ", l_type->val);
            fprintf(fin, "%s", l_const->val);
            if (l_type == funcTable[i].params.typeList.end)
                break;
            fprintf(fin, ", ");
            l_type = l_type->next;
            l_const = l_const->next;
        }
        fprintf(fin, "), ");

        fprintf(fin, "Nume parametri: ");
        printList(fin, &funcTable[i].params.nameList, ',', '(', ')');
        fprintf(fin, " Tip return: %s, Structura: %s\n", funcTable[i].returnType, funcTable[i].structName);

    }

}

