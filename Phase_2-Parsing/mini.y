%{
#include "heading.h"
int yyerror(const char *s);
int yylex(void); 
%}

%union{ 
	string* str;
	int intval;
}
%error-verbose
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN COMMENT
%token <intval> NUMBER
%token <str> IDENT
%right ASSIGN
%left AND OR
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

%%

program:
	 functions { printf("program->functions\n"); }
	;

functions:
	/*empty*/ { printf("functions->epsilon\n"); }
	| functions function { printf("functions->functions function\n"); }
	;

function:
	FUNCTION ident SEMICOLON BEGIN_PARAMS declaration END_PARAMS BEGIN_LOCALS declaration END_LOCALS BEGIN_BODY statement END_BODY { printf("function->FUNCTION ident SEMICOLON BEGIN_PARAMS declaration END_PARAMS BEGIN_LOCALS declaration END_LOCALS BEGIN_BODY statment END_BODY\n"); }
	;

declaration:
	/*empty*/ { printf("declarations->epsilon\n"); }
	| declaration decl SEMICOLON { printf("declaration->declaration decl SEMICOLON\n"); }
	;

statement:
	state SEMICOLON { printf("statement->state SEMICOLON\n"); }
	| statement state SEMICOLON { printf("statement->statement state SEMICOLON\n"); }
	;
decl:   
	identifier COLON INTEGER { printf("decl->identifier COLON INTEGER\n"); }
	| identifier COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("decl->identifier COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); }
	; 

identifier:
	ident { printf("identifier->ident\n"); }
	| identifier COMMA ident { printf("identifier->identifier COMMA ident\n"); }
	;

state: 
	var ASSIGN expression { printf("state->var ASSGIN expression\n"); }
	| IF boolexp THEN statement ENDIF { printf("state->IF boolexp THEN statement ENDIF\n"); }
	| IF boolexp THEN statement ELSE statement ENDIF { printf("state->IF boolexp THEN statement ELSE statement ENDIF\n"); }
	| WHILE boolexp BEGINLOOP statement ENDLOOP { printf("state->WHILE boolexp BEGINLOOP statement ENDLOOP\n"); }
	| DO BEGINLOOP statement ENDLOOP WHILE boolexp { printf("state->DO BEGINLOOP statement ENDLOOP WHILE boolexp\n"); }
	| READ vars { printf("state->READ vars\n"); }
	| WRITE vars { printf("state->WRITE vars\n"); }
	| CONTINUE { printf("state-> CONTINUE\n"); }
	| RETURN expression { printf("state->RETURN expression\n"); }
	;

vars:
	var { printf("vars->var\n"); }
	| vars COMMA var { printf("vars->vars COMMA var\n"); }
	;

boolexp:
	relandexpr { printf("boolexp->relandexpr\n"); }
	| boolexp OR relandexpr { printf("boolexp->boolexp OR relandexpr\n"); }
	;

relandexpr:
	relexpr { printf("relandexpr->relexpr\n"); }
	| relandexpr AND relexpr { printf("relandexpr->relandexpr AND relexpr\n"); }
	;

relexpr:
	relex { printf("relexpr->relex\n"); }
	| NOT relex { printf("relexpr->NOT relex\n"); }
	;

relex:
	expression comp expression { printf("relex->expression comp expression\n"); }
	| TRUE { printf("relex->TRUE\n"); }
	| FALSE { printf("relex->FALSE\n"); }
	| L_PAREN boolexp R_PAREN { printf("relex->L_PAREN boolexp R_PAREN\n"); }
	;
comp:
	EQ { printf("comp->EQ\n"); }
	| NEQ { printf("comp-> NEQ\n"); }
	| LT { printf("comp->LT\n"); }
	| GT { printf("comp->GT\n"); }
	| LTE { printf("comp->LTE\n"); }
	| GTE { printf("comp->GTE\n"); }
	;

expression:
	multex { printf("expression->multex\n"); }
	| expression ADD multex { printf("expression->expression ADD multex\n");}
	| expression SUB multex { printf("expression->expression SUB multex\n");}
	;

multex:
	term { printf("multex->term\n"); }
	| multex MULT term { printf("multex->multex MULT term\n"); }
	| multex DIV term { printf("multex->multex DIV term\n"); }
	| multex MOD term { printf("multex->multex MOD term\n"); }
	;
term: 
	var { printf("term->var\n"); }
	| NUMBER { printf("term->NUMBER\n"); }
	| L_PAREN expression R_PAREN { printf("term->L_PAREN expression R_PAREN\n"); }
	| SUB var { printf("term->SUB var\n"); }
	| SUB NUMBER { printf("term->SUB NUMBER\n"); }
	| SUB L_PAREN expression R_PAREN { printf("term->SUB L_PAREN expression R_PAREN\n"); }
	| ident L_PAREN expressions R_PAREN { printf("term->ident L_PAREN expressions R_PAREN\n"); }
	| ident L_PAREN R_PAREN { printf("term->ident L_PAREN R_PAREN\n"); }
	;

expressions:
	expression { printf("expressions->expression\n"); }
	| expressions COMMA expression { printf("expressions->expressions COMMA expression\n"); }
	;
	
var: 
	ident { printf("var->ident\n"); }
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET { printf("var->ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n"); }
	;
		
ident:
	IDENT { printf("ident->IDENT %s\n", ($1)->c_str()); }
	;

%%

int yyerror(string s) {
	extern int row;
	extern char *yytext;
	cerr << "ERROR: " << s << " at symbol \"" << yytext;
	cerr << "\" on line " << row << endl;
	exit(1);
}
int yyerror(const char *s) {
	return yyerror(string(s));
}
