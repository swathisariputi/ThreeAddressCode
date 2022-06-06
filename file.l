%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include <ctype.h>
    #include "y.tab.h"
	/* prints grammar violation message */
	extern void yyerror(const char *);  
%}


delim     [ \t\r\v\f\n]
ws        {delim}+  
letter    [A-Za-z] 
digit     [0-9]	
id        {letter}({letter}|{digit})*
number    {digit}+(\.{digit}+)?([eE][+\-]?{digit}+)?


/* pattern actions/Rules */
%%

{ws}                                    { ; }


{number}  								{strcpy(yylval.num , yytext); return NUM;}
[-+/*^=,;(){}%]                          {return yytext[0];}


"=="                        			|
"!="                        			|
">"                         			|
">="                        			|
"<"                         			|
"<="                        			{strcpy(yylval.relo, yytext); return RELOP;}

"||"                                    |
"!"                                     |
"&&"                                    {strcpy(yylval.log, yytext); return LOG;}

"while"                     			{return WHILE;}
"do"                                    {return DO;}

"int"                                   {return INT;}
{id}                        			{strcpy(yylval.id , yytext); return ID;}
.					        			{printf("Error occured ...\n");}

%%
