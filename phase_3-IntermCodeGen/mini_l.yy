%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations


%code requires
{
	/* you may need these deader files 
	 * add more header file if you need more
	 */
#include <list>
#include <functional>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
	/* define the sturctures using as types for non-terminals */
struct functiontype {
	std::string code;
};
	/* end the structures for non-terminal types */
}


%code
{
#include "parser.tab.hh"

	/* you may need these deader files 
	 * add more header file if you need more
	 */
#include <sstream>
#include <vector>
#include <map>
#include <regex>
#include <set>
#include <string>
#include <stack>
#include <fstream>
yy::parser::symbol_type yylex();
std::vector<std::string> paramtab;
std::vector<std::string> functab;
std::vector<std::string> symtab;
std::vector<int> symtype; 
std::vector<std::string> op;
std::vector<std::string> statetab;
std::string tempstr;
int tempcount;
int labelcount;
std::vector <std::vector <std::string> > iflabel;
std::vector <std::vector <std::string> > looplabel;
std::stack <std::string> pstack;
std::stack <std::string> rstack;
std::stringstream ms;
bool addparam = false;
bool insymtab(std::string s, const yy::location& l);
bool inarrtab(std::string s, const yy::location& l);
bool infunctab(std::string s, const yy::location& l);
	/* define your symbol table, global variables,
	 * list of keywords or any function you may need here */
	
	/* end of your code */
}

%token END 0 "end of file";
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN COMMENT
%token <int> NUMBER
%token <std::string> IDENT
%type <std::string> ident
%type <functiontype> functions function funkyfresh
/*%type <string> ident decl*/
%left MULT DIV MOD ADD SUB
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN






	/* specify tokens, type of non-terminals and terminals here */

	/* end of token specifications */

%%



	/* define your grammars here use the same grammars 
	 * you used in Phase 2 and modify their actions to generate codes
	 * assume that your grammars start with prog_start
	 */

program:
         functions {
	int flag = 0;
	for (unsigned i = 0; i < functab.size(); i++) {
		if (functab.at(i) == "main") {
			flag = 1;
		}
	}
	if (flag == 0) {
	std::cerr << "Main function not found\n";
	}
	std::cout << $1.code;}
        ;

functions:
        /*empty*/ { $$.code="";}
        | functions function { $$.code = $1.code+$2.code;}
        ;
beginp:
	BEGIN_PARAMS
	{
	addparam = true;
	}
	;
endp:
	END_PARAMS
	{
	addparam = false;
	}
funkyfresh:
	FUNCTION ident
	{
	functab.push_back($2);
	$$.code = "func " + $2 + "\n";
	}
function:
        funkyfresh SEMICOLON beginp declaration endp BEGIN_LOCALS declaration END_LOCALS BEGIN_BODY statement END_BODY 
	{
	$$.code = $1.code;	
	std::string str1;
	for (unsigned varit = 0; varit < symtab.size(); varit++) {
		if (symtype.at(varit)  == -1 ) {
			str1 = ". " + symtab.at(varit) + "\n";
			$$.code += str1;
			str1.clear();
		}
		else {
			str1 = ".[] " + symtab.at(varit) + ", " + std::to_string(symtype.at(varit)) + "\n";
			$$.code += str1;
			str1.clear();
		}
	}	
	for (unsigned i = 0; i < paramtab.size(); ++i) {
		str1 = "= " + paramtab.at(i) + ", $" + std::to_string(i) + "\n";
		$$.code += str1;
		str1.clear();
	}
	for (unsigned j = 0; j < statetab.size(); ++j) {
		str1 = statetab.at(j) + "\n";
		$$.code += str1;
		str1.clear();
	}
	statetab.clear();
	symtab.clear();
	symtype.clear();
	paramtab.clear();
	std::string endf = "endfunc\n\n";
	$$.code += endf; 
	}
        ;

declaration:
        /*empty*/
        | declaration decl SEMICOLON
        ;

statement:
        state SEMICOLON
        | state SEMICOLON statement
        ;
decl:   
        identifier COLON assign
        ;
assign:
	INTEGER {symtype.push_back(-1);}
	| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
	{
	std::stringstream s;
	s << $3;
	std::string str = s.str();
	symtype.push_back(atoi(s.str().c_str()));
	}
	;
identifier:
        ident { symtab.push_back($1); 
	if (addparam) {
		paramtab.push_back($1);
	}
	}
        | identifier COMMA ident { symtab.push_back($3); symtype.push_back(-1);}
        ;

state:
	stateone
	|state2 
	|state3
	|state4
	|state5
	|state6
	|state7
	|state8
        ;
stateone:
	ident ASSIGN expression
	{
	std::string v = $1;
	if (!insymtab(v, @1)) {
		exit(0);
	}
	statetab.push_back("= " + v + ", " + op.back());
	op.pop_back();
	}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET ASSIGN expression
	{
	std::string v = $1;
	if (!inarrtab(v, @1)) {
		exit(0);
	}
	std::string arr_res = op.back();
	op.pop_back();
	std::string arr_exp = op.back();
	op.pop_back();
	statetab.push_back("[]= " + $1 + ", " + arr_exp + ", " + arr_res );
	}
	;
if:
	IF boolexp THEN {
	labelcount++;
	
	ms.str("");
	ms << labelcount;
	std::string l1 = "_tlabel_" + ms.str();
	std::string l2 = "_flabel_" + ms.str();
	std::string l3 = "_elabel_" + ms.str();
	std::vector<std::string> t;
	t.push_back(l1);
	t.push_back(l2);
	t.push_back(l3);
	iflabel.push_back(t);
	statetab.push_back("?:= " + iflabel.back().at(0) + ", " + op.back());
	op.pop_back();
	statetab.push_back(":= " + iflabel.back().at(1));
	statetab.push_back(": " + iflabel.back().at(0));
	}
	;
elif:
	if statement ELSE
	{
	statetab.push_back(":= " + iflabel.back().at(2));
	statetab.push_back(": " + iflabel.back().at(1));
	}
	;
state2:
	if statement ENDIF
	{
	statetab.push_back(": " + iflabel.back().at(1));
	iflabel.pop_back();
	}
	| elif statement ENDIF
	{
	statetab.push_back(": "+iflabel.back().at(2));
	iflabel.pop_back();
	}
	;
while_token: WHILE
	{
	labelcount++;
	
	ms.str("");
	ms << labelcount;
	std::string l1 = "_wlabel_" + ms.str();
	std::string l2 = "_cwtlabel_" + ms.str();
	std::string l3 = "_cwflabel_" + ms.str();
	std::vector<std::string> t;	
	t.push_back(l1);
	t.push_back(l2);
	t.push_back(l3);
	looplabel.push_back(t);
	statetab.push_back(": " + looplabel.back().at(0));
	}
	;
while:
	while_token boolexp BEGINLOOP
	{
	statetab.push_back("?:= " + looplabel.back().at(1) + ", " + op.back());
	op.pop_back();
	statetab.push_back(":= " + looplabel.back().at(2));
	statetab.push_back(": " + looplabel.back().at(1));
	}
	;
state3:
	while statement ENDLOOP 
	{
	statetab.push_back(":= " + looplabel.back().at(0));
	statetab.push_back(": "+looplabel.back().at(2));
	looplabel.pop_back();
	}
	;
do_token:
	DO BEGINLOOP
	{
	labelcount++;
	
	ms.str("");
	ms << labelcount;
	std::string l1 = "_dwlabel_" + ms.str();
	std::string l2 = "_dwclabel_" + ms.str();
	std::vector<std::string> t;
	t.push_back(l1);
	t.push_back(l2);
	looplabel.push_back(t);
	statetab.push_back(": " + l1);
	}
	;
do:
	do_token statement ENDLOOP
	{
	statetab.push_back(": "+ looplabel.back().at(1));
	}
state4:
	do WHILE boolexp
	{
	statetab.push_back("?:= "+ looplabel.back().at(0)+", "+op.back());
	op.pop_back();
	looplabel.pop_back();
	}
	;
mult:
	/*empty*/
	|COMMA ident mult
	{
	std::string v = $2;
	if (!insymtab(v, @2)) {
		exit(0);
	}
	rstack.push(".< " + $2);
	}
	| COMMA ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET mult
	{	
	std::string v = $2;
		if (!inarrtab(v, @2)) {
			exit(0);
		}
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	rstack.push(".< " + newt);
	rstack.push("[]= "+ $2 +", "+op.back()+", " + newt);
	op.pop_back();
	}
	;
state5:
	READ ident mult
	{
	std::string v = $2;
	if (!insymtab(v, @2)) {
		exit(0);
	}
	statetab.push_back(".< " + $2);
	while (!rstack.empty()) {
		statetab.push_back(rstack.top());
		rstack.pop();
	}
	}
	| READ ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET mult
	{
	std::string v =  $2;
	if (!inarrtab(v, @2)) {
		exit(0);
	}
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	statetab.push_back(".< " + newt);
	statetab.push_back("[]= " + $2 + ", " + op.back() + ", " + newt);
	op.pop_back();
	while(!rstack.empty()) {
		statetab.push_back(rstack.top());
		rstack.pop();
	}
	}
	;
psuedostate:	/*empty*/
	|COMMA pterm psuedostate
state6:
	WRITE pterm psuedostate 
	{
		while (!op.empty()) {
			std::string v = op.front();
			op.erase(op.begin());
			statetab.push_back(".> " + v);
		}
		op.clear();
	}
	;
state7:
	CONTINUE
	{
	if (!looplabel.empty()) {
		if (looplabel.back().at(0).at(0) == 'd') {
			statetab.push_back(":= "+ looplabel.back().at(1)); 
		}
		else {
			statetab.push_back(":= "+ looplabel.back().at(0));
		}
	}
	}
	;
state8:
	RETURN expression
	{
		statetab.push_back("ret "+op.back());
		op.pop_back();
	}
	;

boolexp:
        relandexpr
        | boolexp OR relandexpr
        {
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o2 = op.back();
	op.pop_back();
	statetab.push_back("|| "+ newt + ", "+o2+", "+o);
	op.push_back(newt);
	}
	;

relandexpr:
        relexpr 
        | relandexpr AND relexpr
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("&& " + newt + ", " + o + ", "  + o1);
	op.push_back(newt);
	}
        ;

relexpr:
        relex
        | NOT relex
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	statetab.push_back("! " + newt + ", " + o);
	op.push_back(newt);
	}
        ;

relex: 
        TRUE 
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	statetab.push_back("= " + newt + ", 1");
	op.push_back(newt);
	}
        | FALSE
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	statetab.push_back("= " + newt + ", 0");
	op.push_back(newt);
	}
        | L_PAREN boolexp R_PAREN
        |expression EQ expression
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("== "+ newt + ", "+o1+", "+o);
	op.push_back(newt);
	}
        | expression NEQ expression
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("!= "+ newt + ", "+o1+", "+o);
	op.push_back(newt);
	}
        | expression LT expression
	{	
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("< "+ newt + ", "+o1+", "+o);
	op.push_back(newt);
	}
        | expression GT expression
	{	
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("> "+ newt + ", "+o1+", "+o);
	op.push_back(newt);
	}
        | expression LTE expression
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("<= "+ newt + ", "+o1+", "+o);
	op.push_back(newt);
	}
        | expression GTE expression
	{	
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back(">= "+ newt + ", "+o1+", "+o);
	op.push_back(newt);
	}
	;

expression:
	multex 
	| expression ADD multex
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("+ " + newt + ", " + o1 + ", " + o);
	op.push_back(newt);
	}
        | expression SUB multex
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("- " + newt + ", " + o1 + ", " + o);
	op.push_back(newt);
	}
        ;



multex: 
        term
        | multex MULT term 	
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("* " + newt + ", " + o1 + ", " + o);
	op.push_back(newt);
	}
        | multex DIV term
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("/ " + newt + ", " + o1 + ", " + o);
	op.push_back(newt);
	}
        | multex MOD term
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	op.pop_back();
	std::string o1 = op.back();
	op.pop_back();
	statetab.push_back("% " + newt + ", " + o1 + ", " + o);
	op.push_back(newt);
	}
        ;
pterm: 
	var
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::string o = op.back();
	if (o.at(0) == '[') {
		statetab.push_back("=[] "+newt + ", " + o.substr(3,o.length()-3));
	}
	else {
		statetab.push_back("= "+ newt + ", " + op.back());
	}
	op.pop_back();
	op.push_back(newt);
	}
	| NUMBER
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	std::stringstream s;
	s << $1;
	statetab.push_back("= " + newt + ", " + s.str());
	op.push_back(newt);
	}
	| L_PAREN expression R_PAREN
	;
term: 
        pterm
	| SUB pterm
	{  
	
	ms.str("");
	ms << tempcount;   
	tempcount++;
	std::string newt ="__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);  
	statetab.push_back("- "+ newt + ", 0, " + op.back());    
        op.pop_back(); 
	op.push_back(newt);
	}
	| ident iterm
	{
	
	ms.str("");
	ms << tempcount;
	tempcount++;
	std::string newt = "__temp__" + ms.str();
	symtab.push_back(newt);
	symtype.push_back(-1);
	if (!infunctab($1, @1)) {
		exit(0);
	}
	statetab.push_back("call " + $1 + ", " + newt);
	op.push_back(newt);
	}	
	;   
iterm:
	L_PAREN expressions R_PAREN
	{
	while (!pstack.empty()) {
		statetab.push_back("param " + pstack.top());
		pstack.pop();
	}
	}
	| L_PAREN R_PAREN
	;
  
                                                                                      
expressions:
        expression
	{
	pstack.push(op.back());
	op.pop_back();
	}
        | expressions COMMA expression
	{
	pstack.push(op.back());
	op.pop_back();
	}
        ;

var: 
        ident 
	{
	std::string v =  $1;
	if (!insymtab(v, @1)) {
		exit(0);
	}
	op.push_back(v);
	}
        | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
	{
	std::string o = op.back();
	op.pop_back();
	std::string v = $1;
	if (!inarrtab(v, @1)) {
		exit(0);
	}
	op.push_back("[] " + v + ", " + o);
	}
        ;

ident:
        IDENT {$$=$1;}
        ;




%%

int main(int argc, char *argv[])
{
	#ifdef YYDEBUG
		int yydebug = 1;
	#endif
	//std::ifstream ifs;
	//ifs.open(argv[1], std::ifstream::in);
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
	std::cerr << l << ": " << m << std::endl;
}

bool inarrtab(std::string s, const yy::location& l) {
	for (unsigned i = 0; i < symtab.size(); i++) {
		if (symtab.at(i) == s) {
			if (symtype.at(i) == -1) {
				std::cout << l << ": Semantic Error: Incompatible Datatype\n";
				return false;
			}
			else {
				return true;
			}
		}
	}
	std::cerr << l << ": Semantic Error: Undeclared\n";
	return false;
}

bool insymtab(std::string s, const yy::location& l) {
	for (unsigned i = 0; i < symtab.size(); i++) {
		if (symtab.at(i) == s) {
			if (symtype.at(i) == -1) {
				return true;
			}
			else {
				std::cout << l << ": Semantic Error: Incompatible Datatype\n";
				return false;
			}
		}
	}
	std::cerr << l << ": Semantic Error: Undeclared\n";
	return false;
}

bool infunctab(std::string s, const yy::location& l) {
	for (unsigned i = 0; i < functab.size(); i++) {
		if (functab.at(i) == s) {
			return true;
		}
	}
	std::cerr << l << ": Semantic Error: Undeclared Function\n";
	return false;
}
