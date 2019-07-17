%{
#include <iostream>
#define YY_DECL yy::parser::symbol_type yylex()
#include "parser.tab.hh"

static yy::location loc(loc);
%}

%option noyywrap 
%option nounput
%{
#define YY_USER_ACTION loc.columns(yyleng);
%}

	/* your definitions here */
FUNCTION        "function"
BEGIN_PARAMS    "beginparams"
END_PARAMS      "endparams"
BEGIN_LOCALS    "beginlocals"
END_LOCALS      "endlocals"
BEGIN_BODY      "beginbody"
END_BODY        "endbody"
INTEGER         "integer"
ARRAY           "array"
OF              "of"
IF              "if"
THEN            "then"
ENDIF           "endif"
ELSE            "else"
WHILE           "while"
DO              "do"
BEGINLOOP       "beginloop"
ENDLOOP         "endloop"
CONTINUE        "continue"
READ            "read"
WRITE           "write"
AND             "and"
OR              "or"
NOT             "not"
TRUE            "true"
FALSE           "false"
RETURN          "return"
SUB             "-"
ADD             "+"
MULT            "*"
DIV             "/"
MOD             "%"
EQ              "=="
NEQ             "<>"
LT              "<"
GT              ">"
LTE             "<="
GTE             ">="
SEMICOLON       ";"
COLON           ":"
COMMA           ","
L_PAREN         "("
R_PAREN         ")"
L_SQUARE_BRACKET        "["
R_SQUARE_BRACKET        "]"
ASSIGN          ":="
NUMBER          [0-9]
COMMENT         "##"
                                                                     
	/* your definitions */
%%

%{
loc.step(); 
%}

	/* your rules here */
{COMMENT}.*
{FUNCTION}         return yy::parser::make_FUNCTION(loc);
{BEGIN_PARAMS}     return yy::parser::make_BEGIN_PARAMS(loc);
{END_PARAMS}       return yy::parser::make_END_PARAMS(loc);
{BEGIN_LOCALS}     return yy::parser::make_BEGIN_LOCALS(loc);
{END_LOCALS}       return yy::parser::make_END_LOCALS(loc);
{BEGIN_BODY}       return yy::parser::make_BEGIN_BODY(loc);
{END_BODY}         return yy::parser::make_END_BODY(loc);
{INTEGER}          return yy::parser::make_INTEGER(loc);
{ARRAY}            return yy::parser::make_ARRAY(loc);
{OF}               return yy::parser::make_OF(loc);
{IF}               return yy::parser::make_IF(loc);
{THEN}             return yy::parser::make_THEN(loc);
{ENDIF}            return yy::parser::make_ENDIF(loc);
{ELSE}             return yy::parser::make_ELSE(loc);
{WHILE}            return yy::parser::make_WHILE(loc);
{DO}               return yy::parser::make_DO(loc);
{BEGINLOOP}        return yy::parser::make_BEGINLOOP(loc);
{ENDLOOP}          return yy::parser::make_ENDLOOP(loc);
{CONTINUE}         return yy::parser::make_CONTINUE(loc);
{READ}             return yy::parser::make_READ(loc);
{WRITE}            return yy::parser::make_WRITE(loc);
{AND}              return yy::parser::make_AND(loc);
{OR}               return yy::parser::make_OR(loc);
{NOT}              return yy::parser::make_NOT(loc);
{TRUE}             return yy::parser::make_TRUE(loc);
{FALSE}            return yy::parser::make_FALSE(loc);
{RETURN}           return yy::parser::make_RETURN(loc);
{SUB}              return yy::parser::make_SUB(loc);
{ADD}              return yy::parser::make_ADD(loc);
{MULT}             return yy::parser::make_MULT(loc);
{DIV}              return yy::parser::make_DIV(loc);
{MOD}              return yy::parser::make_MOD(loc);
{EQ}               return yy::parser::make_EQ(loc);
{NEQ}              return yy::parser::make_NEQ(loc);
{LT}               return yy::parser::make_LT(loc);
{GT}               return yy::parser::make_GT(loc);
{LTE}              return yy::parser::make_LTE(loc);
{GTE}              return yy::parser::make_GTE(loc);
{SEMICOLON}        return yy::parser::make_SEMICOLON(loc);
{COLON}            return yy::parser::make_COLON(loc);
{COMMA}            return yy::parser::make_COMMA(loc);
{L_PAREN}          return yy::parser::make_L_PAREN(loc);
{R_PAREN}          return yy::parser::make_R_PAREN(loc);
{L_SQUARE_BRACKET}         return yy::parser::make_L_SQUARE_BRACKET(loc);
{R_SQUARE_BRACKET}         return yy::parser::make_R_SQUARE_BRACKET(loc);
{ASSIGN}           return yy::parser::make_ASSIGN(loc);
{NUMBER}+          return yy::parser::make_NUMBER(atoi(yytext),loc);
([a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9])|[a-zA-Z]        return yy::parser::make_IDENT(yytext,loc);
"\n"            
[\t]             
[ ]              

                                                                                      

	/* use this structure to pass the Token :
	 * return yy::parser::make_yy::parser::make_TokenName(loc)
	 * if the token has a type you can pass it's value
	 * as the first argument. as an example we put
	 * the rule to return yy::parser::make_token function.
	 */



 <<EOF>>	{return yy::parser::make_END(loc);}
	/* your rules end */

%%

