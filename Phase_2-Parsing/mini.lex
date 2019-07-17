%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);
%}
%option nounput
FUNCTION	"function"
BEGIN_PARAMS	"beginparams"
END_PARAMS	"endparams"
BEGIN_LOCALS	"beginlocals"
END_LOCALS	"endlocals"
BEGIN_BODY	"beginbody"
END_BODY	"endbody"
INTEGER		"integer"
ARRAY		"array"
OF		"of"
IF		"if"
THEN		"then"
ENDIF		"endif"
ELSE		"else"
WHILE		"while"
DO		"do"
BEGINLOOP	"beginloop"
ENDLOOP		"endloop"
CONTINUE	"continue"
READ		"read"
WRITE		"write"
AND		"and"
OR		"or"
NOT		"not"
TRUE		"true"
FALSE		"false"
RETURN		"return"
SUB		"-"
ADD		"+"
MULT		"*"
DIV		"/"
MOD		"%"
EQ		"=="
NEQ		"<>"
LT		"<"
GT		">"
LTE		"<="
GTE		">="
SEMICOLON	";"
COLON		":"
COMMA		","
L_PAREN		"("
R_PAREN		")"
L_SQUARE_BRACKET	"["
R_SQUARE_BRACKET	"]"
ASSIGN		":="
NUMBER		[0-9]
COMMENT		"##"

%{
	int colum = 1;
	int row = 1;
%}

%%

{COMMENT}.*		 
{FUNCTION}	 colum = colum + yyleng; return FUNCTION;
{BEGIN_PARAMS}	 colum = colum + yyleng; return BEGIN_PARAMS;
{END_PARAMS}	 colum = colum + yyleng; return END_PARAMS;
{BEGIN_LOCALS}	 colum = colum + yyleng; return BEGIN_LOCALS;
{END_LOCALS}	 colum = colum + yyleng; return END_LOCALS;
{BEGIN_BODY}	 colum = colum + yyleng; return BEGIN_BODY;
{END_BODY}	 colum = colum + yyleng; return END_BODY;
{INTEGER}	 colum = colum + yyleng; return INTEGER;
{ARRAY}	 	 colum = colum + yyleng; return ARRAY;
{OF}		 colum = colum + yyleng; return OF;
{IF}		 colum = colum + yyleng; return IF;
{THEN}		 colum = colum + yyleng; return THEN;
{ENDIF}		 colum = colum + yyleng; return ENDIF;
{ELSE}		 colum = colum + yyleng; return ELSE;
{WHILE}		 colum = colum + yyleng; return WHILE;
{DO}	 	 colum = colum + yyleng; return DO;
{BEGINLOOP}	 colum = colum + yyleng; return BEGINLOOP;
{ENDLOOP}	 colum = colum + yyleng; return ENDLOOP;
{CONTINUE}	 colum = colum + yyleng; return CONTINUE;
{READ}		 colum = colum + yyleng; return READ;
{WRITE}		 colum = colum + yyleng; return WRITE;
{AND}		 colum = colum + yyleng; return AND;
{OR}		 colum = colum + yyleng; return OR;
{NOT}		 colum = colum + yyleng; return NOT;
{TRUE}		 colum = colum + yyleng; return TRUE;
{FALSE}	 	 colum = colum + yyleng; return FALSE;
{RETURN}	 colum = colum + yyleng; return RETURN;
{SUB}		 colum = colum + yyleng; return SUB;
{ADD}		 colum = colum + yyleng; return ADD;
{MULT}		 colum = colum + yyleng; return MULT;
{DIV}		 colum = colum + yyleng; return DIV;
{MOD}		 colum = colum + yyleng; return MOD;
{EQ}		 colum = colum + yyleng; return EQ;
{NEQ}		 colum = colum + yyleng; return NEQ;
{LT}		 colum = colum + yyleng; return LT;
{GT}	 	 colum = colum + yyleng; return GT;
{LTE}		 colum = colum + yyleng; return LTE;
{GTE}		 colum = colum + yyleng; return GTE;
{SEMICOLON}	 colum = colum + yyleng; return SEMICOLON;
{COLON}		 colum = colum + yyleng; return COLON;
{COMMA}		 colum = colum + yyleng; return COMMA;
{L_PAREN}	 colum = colum + yyleng; return L_PAREN;
{R_PAREN}	 colum = colum + yyleng; return R_PAREN;
{L_SQUARE_BRACKET}	 colum = colum + yyleng; return L_SQUARE_BRACKET;
{R_SQUARE_BRACKET}	 colum = colum + yyleng; return R_SQUARE_BRACKET;
{ASSIGN}	 colum = colum + yyleng; return ASSIGN;
{NUMBER}+	 colum = colum + yyleng; yylval.intval = atoi(yytext); return NUMBER;
[0-9_][a-zA-Z_0-9]+		printf("Error at line %d, column : %d identifier ",row, colum); ECHO; printf(" must begin with a letter\n"); colum = colum + yyleng; exit(1);
[a-zA-Z][a-zA-Z0-9_]*[_]	printf("Error at line %d, column : %d identifier ",row,colum); ECHO; printf(" cannot end with underscore\n"); colum = colum + yyleng; exit(1);
[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]*	colum = colum + yyleng; yylval.str = new string(yytext); return IDENT;
"\n"		row = row + 1; colum = 1;	
[\t]		colum = colum + yyleng;
[ ]		colum = colum + yyleng;		 
.		printf("Error at line %d, column %d: unrecognized symbol ", row, colum); ECHO; printf("\n"); colum = colum + yyleng; exit(1);
