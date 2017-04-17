%option noyywrap
%{
	
#include "TAC.h"

#include "first.tab.h"
#include <string.h>


%}





digit [0-9]
letter [a-zA-Z]
id {letter}({letter}|{digit})*
integer [0-9]+
comment "//".*

%%

":="		{ 	return ASSIGN; }
"+"			{ 	return ADD; }
"-"			{ 	return SUB; }
"*"			{ 	return MUL; }
"/"			{ 	return DIV; }
"("     	{ 	return OP; }
")"     	{ 	return CP; }
","			{ 	return COMMA; }
";"			{ 	return SEMICOLON; }
"::"		{	return ELIF; }
"&&"		{ 	return AND; }
"||"		{ 	return OR; }
"<="		{ 	return LE; }	
">="		{ 	return GE; }
"~="		{ 	return NE; }
"~"			{ 	return NOT; }
">"			{ 	return GREATER; }
"<"			{ 	return LESS; }
"true"		{ 	strcpy(yylval.node.code, yytext); 
  					   	  						return BOOLEAN; }
"false"		{ 	strcpy(yylval.node.code, yytext); return BOOLEAN; }
<<EOF>>		{	return END_OF_FILE; }
if			{	return IF; }
fi			{ 	return FI; }
do 			{	return DO;	}
od			{	return OD;	}
"?"			{	return THEN; }
else		{	return ELSE; }

{integer}	{	strcpy(yylval.node.code, yytext); 
	   		  	return INTEGER; 
	   		}
	   		
	   		
({integer}\.{integer})(E[+-]?{integer})? 	{	strcpy(yylval.node.code, yytext); 
  					   	  						return REAL; }
{id} 		{	strcpy(yylval.node.code, yytext);  return ID; }


"//".*		{ printf("comment detected\n"); }
 
%%


int main()
{

	if(!(yyin = fopen("input", "r"))){
		perror("Read: ");
		return 1;
	}
	 yyparse();
	 return 0;
}


