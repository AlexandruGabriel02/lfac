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
extern int yylineno;

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

bool isDeclared(const char* p_name)
{
    for (int i = 0; i < symCount; i++)
        if (strcmp(p_name, symbolTable[i].name) == 0)
        {
            return true;
        }
    return false;
}

char* getTypeFromVal(const char* value)
{
    char* type;
    if (value[0] == '\"')
        type = strdup("string");
    else if (value[0] == '\'')
        type = strdup("char");
    else if (!strcmp(value, "true") || !strcmp(value, "false")) 
        type = strdup("bool");
    else if (strchr(value, '.'))
        type = strdup("float");
    else 
        type = strdup("int");

    return type;    
}

bool isCorrectType(const char* p_val, const char* p_type)
{
    char* actual_valType = getTypeFromVal(p_val);
    if (strcmp(p_type, actual_valType) != 0)
    {
        free(actual_valType);
        return false;
    }
    free(actual_valType);

    return true;
}

void checkIfDeclared(const char* p_type1, const char* p_name1, const char* p_type2, const char* p_name2)
{
    bool found = false;
    const char* custom;
    for (int i = 0; i < symCount; i++)
    {
        if (strcmp(p_type1, symbolTable[i].symType) == 0 && strcmp(p_name1, symbolTable[i].name) == 0
        && strcmp(symbolTable[i].structName, "none") == 0)
        {
            found = true;
            custom = strdup(symbolTable[i].value.valType);
        }
    }
    
    if (found == false)
    {
        printf("[EROARE linia %d]: Variabila %s nedeclarata / folosita incorect\n", yylineno, p_name1);
        exit(-1);
    }

    if (p_type2 != NULL) 
    {
        for (int i = 0; i < symCount; i++)
        {
            if (strcmp(p_type2, symbolTable[i].symType) == 0 && strcmp(p_name2, symbolTable[i].name) == 0
                && strcmp(custom, symbolTable[i].structName) == 0)
            {
                return;
            }
        }

        printf("%s\n", custom);
        printf("[EROARE linia %d]: Variabila %s nedeclarata / folosita incorect\n", yylineno, p_name2);
        exit(-1);
    }

}

void pushToSymTable(const char* p_symType, const char* p_identifier, void* p_val)
{
    if (isDeclared(p_identifier))
    {
        printf("[EROARE linia %d]: Variabila %s declarata deja\n", yylineno, p_identifier);
        exit(-1);
    }

    symbolTable[symCount].name = strdup(p_identifier);
    symbolTable[symCount].symType = strdup(p_symType);
    symbolTable[symCount].isConstant = isConstant;
    symbolTable[symCount].value.valType = strdup(currType);
    symbolTable[symCount].structName = strdup(structContext);

    if (p_val != NULL)
    {
        symbolTable[symCount].value.undefined = false;
        if (strcmp(p_symType,"variabila") == 0)
        {
            if (!isCorrectType(p_val, currType))
            {
                printf("[EROARE linia %d]: Valoarea variabilei %s nu respecta tipul %s\n",
                 yylineno, p_identifier, currType);
                exit(-1);
            }

            symbolTable[symCount].value.val = strdup((char*)p_val);
        }
        else
        {
            symbolTable[symCount].value.list = (struct List*) malloc(sizeof(struct List));
            memcpy(symbolTable[symCount].value.list, p_val, sizeof(struct List));

            if (strcmp(p_symType, "array") == 0)
            {
                struct ListNode* l = symbolTable[symCount].value.list->begin;
                while (l != NULL)
                {
                    if (!isCorrectType(l -> val, currType))
                    {
                        printf("[EROARE linia %d]: Valorile din vectorul %s nu respecta tipul %s\n",
                        yylineno, p_identifier, currType);
                        exit(-1);
                    }
                    if (l == symbolTable[symCount].value.list->end)
                        break;
                    l = l -> next;
                }
            }
            else //custom
            {
                int i;
                for (i = 0; i < symCount; i++)
                {
                    if (strcmp(symbolTable[i].structName, currType) == 0)
                        break;
                }

                if (i == symCount)
                {
                    printf("[EROARE linia %d]: Nu exista structura %s\n",
                    yylineno, currType);
                    exit(-1);
                }

                struct ListNode* l = symbolTable[symCount].value.list->begin;
                while (l != NULL && i < symCount)
                {
                    if (strcmp(symbolTable[i].structName, currType) != 0)
                    {
                        printf("[EROARE linia %d]: Prea multe elemente in initializarea variabilei custom %s\n",
                         yylineno, p_identifier);
                        exit(-1);
                    }

                    if (!isCorrectType(l -> val, symbolTable[i].value.valType))
                    {
                        printf("[EROARE linia %d]: Initializarea variabilei custom %s nu respecta tipurile de date corespunzatoare\n", 
                        yylineno, p_identifier);
                        exit(-1);
                    }

                    if (l == symbolTable[symCount].value.list->end)
                        break;
                    l = l -> next;
                    i++;
                }
            }
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