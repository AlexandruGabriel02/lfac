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

struct Value
{
    bool undefined;
    char* valType;
    char* val;
    struct List* list;
};

struct Symbols 
{
    char* name;
    char* symType;
    bool isConstant;
    struct Value value;
};

char* currType;
bool isConstant = false;
int symCount = 0;

struct Symbols symbolTable[N];

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

void pushToSymTable(const char* p_symType, const char* p_identifier, void* p_val)
{
    symbolTable[symCount].name = strdup(p_identifier);
    symbolTable[symCount].symType = strdup(p_symType);
    symbolTable[symCount].isConstant = isConstant;
    symbolTable[symCount].value.valType = strdup(currType);

    if (p_val != NULL)
    {
        symbolTable[symCount].value.undefined = false;
        if (strcmp(p_symType,"variabila") == 0)
            symbolTable[symCount].value.val = strdup((char*)p_val);
        else if (strcmp(p_symType, "array") == 0)
        {
            symbolTable[symCount].value.list = (struct List*) malloc(sizeof(struct List));
            memcpy(symbolTable[symCount].value.list, p_val, sizeof(struct List));
            printf("%s\n", symbolTable[symCount].value.list->begin->next->val);
        }
    }
    else 
    {
        symbolTable[symCount].value.undefined = true;
    }



    symCount++;
}

void printTable()
{
    FILE* fin = fopen("symbol_table.txt", "w");
    char constAns[3];
    for (int i = 0; i < symCount; i++)
    {
        strcpy(constAns, "Nu");
        if (symbolTable[i].isConstant)
            strcpy(constAns, "Da");
        fprintf(fin, "%d. Nume: %s, Tip declarare: %s, Constant: %s, Nume tip de date: %s, Valoare: ", 
        i, symbolTable[i].name, symbolTable[i].symType, constAns, symbolTable[i].value.valType);

        if (symbolTable[i].value.undefined == true)
        {
            fprintf(fin, "Undefined\n");
            continue;
        }

        if (strcmp(symbolTable[i].symType, "array") == 0)
        {
            fprintf(fin, "[");
            struct ListNode* l = symbolTable[i].value.list->begin;
            while (true)
            {
                fprintf(fin, "%s, ", l->val);

                if (l == symbolTable[i].value.list->end)
                    break;
                l = l->next;
            }
            fprintf(fin, "]");
        }
        else if (strcmp(symbolTable[i].symType, "variabila") == 0)
        {
            fprintf(fin, "%s", symbolTable[i].value.val);
        }
        fprintf(fin, "\n");
    }

    fclose(fin);
}

