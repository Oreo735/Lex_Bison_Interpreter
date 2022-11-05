%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


typedef enum { TRUE =1 ,FALSE=0} bool;
typedef enum { INTEGER , FLOAT, PROGNAME, ERROR} Type;
typedef struct {
  int ival;
  float fval;
  Type type;	
} Number;

extern int yylex();
extern int yyparse();
extern FILE *yyin, *yyout;
extern int cntLine, cntColumn, yyleng;
extern char* yytext;
extern char* input_file;

extern void insertToTable(const char* id, Number type );
extern void assignOp(const char* id, Number val);
extern bool isUndefinedExist(const char* id);
extern void insertToUndeclaredTable(const char* id);	
extern void printExpression(Number num);
extern Number getValueById(const char* id);
extern bool boolExp(Number lhs, char opr, Number rhs);
extern Number addOp(Number lhs, char opr, Number rhs);
extern Number mulOp(Number lhs, char opr, Number rhs);

int yyerror(char * err){
	fprintf(stderr,"\n\nIn file: %s, line: %d, column:%d ==>\n==> %s \nAt token: %s \n", input_file, cntLine, cntColumn-yyleng, err, yytext);
	return 1;
}
%}

%union {
	Number num;
 	char id[20];
 	char opr;
 	bool boolean;
}


/*                    TOKENS                 */

%token  <id> ID
%token  <num> NUM 
%left	<opr> ADDOP MULOP RELOP LOGOP
%token START DO ELSE IF ENDI INT PUT PROG
%token GET REAL THEN VAR LOOP ENDL UNTIL ENDP
%token DOT SEMICOLON COLON COMMA LPAR RPAR
%left ASSIGNOP

/*        Variables that has attributes       */
%type <num>Type
%type <num>Expression
%type <num>Term
%type <num>Factor
%type <opr>Case
%type <boolean>BoolExp

%%

Program: PROG ID SEMICOLON Declarations START StmtList ENDP DOT		{Number progname; progname.type = PROGNAME; insertToTable($2, progname);}
	|PROG ID SEMICOLON Declarations START StmtList ENDP error		{yyerror("Missing '.'");}
	|PROG ID SEMICOLON Declarations START StmtList error			{yyerror("Missing 'endp.'.");}
	|PROG ID SEMICOLON Declarations error							{yyerror("Missing 'start'.");}
	|PROG ID error													{yyerror("Missing ';' after program name declaration.");}
	|PROG error														{yyerror("Program name must not be empty.");}
    |error 															{yyerror("Missing 'prog'.");}
;
Declarations: VAR DecList SEMICOLON	 								
	|VAR DecList error												{yyerror("Missing ';'.");}
	|error															{yyerror("Missing variables decleration.");}
;
DecList: DecList COMMA ID COLON Type								{insertToTable($3, $5);}
	|DecList COMMA ID error											{yyerror("Missing ':'.");}
	|DecList COMMA error											{yyerror("Expected variable name after ','.");}
	|DecList error													{yyerror("Expected ',' name after decleration");}
	|ID COLON Type													{insertToTable($1, $3);}
	|ID error 														{yyerror("Expected ':'.");}
    |error 															{yyerror("Expected variable after 'var'.");}
;
Type: INT 															{$$.type = INTEGER;}
	|REAL															{$$.type = FLOAT;}
	|error															{yyerror("Unknown type declared.");}
;
StmtList: StmtList Statment SEMICOLON 								{}
	|StmtList Statment error										{yyerror("Missing ';' after statement.");}
	| 																{}
;
Statment: ID ASSIGNOP Expression									{assignOp($1, $3);}
	|ID error 														{yyerror("Undefined operation.");}
	|PUT Expression													{printExpression($2);}
	|GET ID															{}
	|GET error														{yyerror("'Get' function: Missing arguments");}
	|IF BoolExp THEN StmtList ELSE StmtList ENDI					{}
	|IF BoolExp THEN StmtList ELSE StmtList error					{yyerror("Expected 'ENDI'.");}
	|IF BoolExp THEN StmtList ENDI									{}
	|IF BoolExp THEN StmtList error									{yyerror("Expected 'ENDI' or 'ELSE'.");}
	|IF BoolExp error												{yyerror("Expected 'THEN'.");}
	|LOOP BoolExp DO StmtList ENDL									{}
	|LOOP BoolExp DO StmtList error									{yyerror("expected 'ENDL'.");}
	|LOOP BoolExp error												{yyerror("expected 'DO' after 'LOOP'.");}
	|DO StmtList UNTIL BoolExp ENDL									{}
	|DO StmtList UNTIL BoolExp error								{yyerror("Expected 'ENDL' after 'DO...UNTILE'.");}
	|DO StmtList error												{yyerror("Expected 'UNTILE' after 'DO'.");}
	|error															{yyerror("Undefinded statement");}
;
BoolExp: Expression Case Expression									{$$ = boolExp($1, $2, $3);}
;
Case: RELOP 														{$$=$1;}
	|LOGOP															{$$=$1;}
;
Expression: Expression ADDOP Term 									{$$ = addOp($1, $2, $3);}
	|Expression error												{yyerror("Opearation missing.");}
	|Term															{$$=$1;}
;
Term: Term MULOP Factor												{$$ = mulOp($1, $2, $3);}
	|Term error														{yyerror("Opearation missing.");}
	|Factor															{$$ = $1;}
;
Factor: ID 															{$$ = getValueById($1);}
	|NUM 															{$$ = $1;}
	|LPAR Expression RPAR											{$$ = $2;}
	|LPAR Expression error											{yyerror("Invalid parentheses");}
	|error 															{yyerror("Unknown command.");}
;


%%


