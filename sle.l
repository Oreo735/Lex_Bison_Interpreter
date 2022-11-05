%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef enum { TRUE =1 ,FALSE=0} bool;
typedef enum { INTEGER, FLOAT, PROGNAME, ERROR} Type;
typedef struct {
  int ival;
  float fval;
  Type type;
} Number;

#include "si_tab.h"

int cntLine = 1;
int cntColumn = 1;

%}
%x COMMENT_MODE

LETTER          [a-zA-Z]
DIGIT           [0-9]
ID              {LETTER}({LETTER}|{DIGIT})*
NUM             ([1-9]{DIGIT}*)|({DIGIT}*("."{DIGIT}+))
WS              [ \t]+
NEWLINE 		\n



%%
"/*"                            {BEGIN(COMMENT_MODE);}
<COMMENT_MODE>"*/"              {BEGIN(INITIAL);} 
<COMMENT_MODE>{NEWLINE}         {}
<COMMENT_MODE>.                 {}
start                       {ECHO; cntColumn+=yyleng; return START;}
do                          {ECHO; cntColumn+=yyleng; return DO;}
else                        {ECHO; cntColumn+=yyleng; return ELSE;}
if                          {ECHO; cntColumn+=yyleng; return IF;}
endi                        {ECHO; cntColumn+=yyleng; return ENDI;}
int                         {ECHO; cntColumn+=yyleng; return INT;}
put                         {ECHO; cntColumn+=yyleng; return PUT;}
prog                        {ECHO; cntColumn+=yyleng; return PROG;}
get                         {ECHO; cntColumn+=yyleng; return GET;}
real                        {ECHO; cntColumn+=yyleng; return REAL;}
then                        {ECHO; cntColumn+=yyleng; return THEN;}
var                         {ECHO; cntColumn+=yyleng; return VAR;}
loop                        {ECHO; cntColumn+=yyleng; return LOOP;}
endl                        {ECHO; cntColumn+=yyleng; return ENDL;}
until                       {ECHO; cntColumn+=yyleng; return UNTIL;}
endp                        {ECHO; cntColumn+=yyleng; return ENDP;}

"."                         {ECHO; cntColumn+=yyleng; return DOT;}
";"                         {ECHO; cntColumn+=yyleng; return SEMICOLON;}
":"		                    {ECHO; cntColumn+=yyleng; return COLON;}
","                         {ECHO; cntColumn+=yyleng; return COMMA;}
"("                         {ECHO; cntColumn+=yyleng; return LPAR;}
")"                         {ECHO; cntColumn+=yyleng; return RPAR;}

"<"|">"|"="                 {ECHO; yylval.opr =*yytext; cntColumn+=yyleng; return RELOP;}
"<>"                        {ECHO; yylval.opr ='!'; cntColumn+=yyleng; return RELOP;}
"&"|"~"                     {ECHO; yylval.opr =*yytext; cntColumn+=yyleng; return LOGOP;}
"+"|"-"                     {ECHO; yylval.opr =*yytext; cntColumn+=yyleng; return ADDOP;}
"*"|"/"                     {ECHO; yylval.opr =*yytext; cntColumn+=yyleng; return MULOP;}
"mod"                       {ECHO; yylval.opr ='%'; cntColumn+=yyleng; return MULOP;}
"<="                        {ECHO; cntColumn+=yyleng; return ASSIGNOP;}

{ID}                        {ECHO; strcpy(yylval.id, yytext); cntColumn+=yyleng; return ID;}
{NUM}                       {ECHO;  if(strchr(yytext,'.')){
					                    yylval.num.fval= atof(yytext);
					                    yylval.num.type = FLOAT;
				                    }else{
					                    yylval.num.ival = atoi(yytext);
					                    yylval.num.type = INTEGER;
				                    }
                                    cntColumn+=yyleng;
                                    return NUM;                         }
{WS}						{ECHO; cntColumn+=yyleng; }
{NEWLINE}						{ECHO; fprintf(yyout,"%d ", ++cntLine); cntColumn = 1;}
.							{fprintf(yyout,"Error: in line %d \"%s\" is not a valid token\n",cntLine, yytext); exit(3);}

%%


int yywrap(){return 1;}