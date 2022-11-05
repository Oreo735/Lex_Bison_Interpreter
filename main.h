#ifndef MAIN_H
#define MAIN_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

#define ALLOC(typ, no) ((typ *)checked_malloc(sizeof(typ) * (no)))

#define CHECK_EXIST(node, id)                      \
    {                                              \
        if (!isUndefinedExist(id))                 \
        {                                          \
            insertToUndeclaredTable(id);           \
            printf(" ERROR: Id %s undefined", id); \
        }                                          \
    }

#define FILE_OPEN_CHECK(file, path)                       \
    {                                                     \
        if ((file = fopen(path, "r")) == NULL)            \
        {                                                 \
            fprintf(stderr, "%s", "File open failed!\n"); \
            exit(1);                                      \
        }                                                 \
    }

#define PRINT_ERR(err)              \
    {                               \
        fprintf(stderr, "%s", err); \
        exit(1);                    \
    }

typedef enum
{
    TRUE = 1,
    FALSE = 0
} bool;
typedef enum
{
    INTEGER,
    FLOAT,
    PROGNAME,
    ERROR
} Type;
typedef struct
{
    int ival;
    float fval;
    Type type;
} Number;

typedef struct node_t
{
    char id[20];
    Number attr;
    bool visited;
    struct node_t *next;
} Node;

typedef struct
{
    Node *head;
} List;

List smb_list;

typedef struct undeclared_t
{
    char id[20];
    struct undeclared_t *next;
} undeclared;

typedef struct
{
    undeclared *head;
} Error_var_list;

Error_var_list error_list;

#include "si_tab.h"

char *input_file;

extern int yyparse();
extern FILE *yyin, *yyout;

bool fileNameCheck(char *fileName);
void *checked_malloc(unsigned int size);
void insertToTable(const char *id, Number type);
void assignElement(const char *id, Number val);
Node *findById(const char *id);
void assignOp(const char *id, Number val);
bool isUndefinedExist(const char *id);
void insertToUndeclaredTable(const char *id);
void printExpression(Number num);
Number getValueById(const char *id);
bool boolExp(Number lhs, char opr, Number rhs);
Number addOp(Number lhs, char opr, Number rhs);
Number mulOp(Number lhs, char opr, Number rhs);

#endif
