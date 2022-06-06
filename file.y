%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include <ctype.h>

    int create_Var          = 1;
    int While_Lable_Counter = 1;
    int DO_Lable_Counter = 1;
  
    char Myvar[50];
    char Mynum[50];
    char sign[50];


    extern int yylex();
    extern FILE *yyin;

    /* prints grammar violation message */
    void yyerror(char *msg);

%}

%start Program

%union{
    int labelCounter;
    char relo[500];
    char id[500];
    char num[500];
    char nonTerminal[500];
    char log[500];
}


%token <num> NUM
%token <id> ID
%token <labelCounter>  WHILE INT DO
%token <relo>  RELOP
%token <log>  LOG

%type <nonTerminal>  block stmts stmt  optexpr IDs expr rel rel1 add term term1 factor 

/* Precedence Operator */

%right '='
%left  LOG
%left  RELOP
%left  '-' '+'
%left  '*' '/'
%right '^'

%%

Program : block                       { ; }
        ;

block   : '{' stmts '}'               { printf("\n"); }
        | stmts                       { printf("\n"); }
        ;

stmts   : stmts  stmt                 { ; }
        |                      
        ;

stmt    : optexpr ';'	              { printf(";\n"); }
        | expr    ';'	              { printf(""); }
        |INT IDs ';'                   {printf("int %s;\n",$2);}

        |DO                           {printf("DO_BEGIN1:\n"); printf("\n");}   
        stmt                          { printf("goto WHILE_CONDITION_%d;\n", $1=DO_Lable_Counter); printf("\n"); }
        WHILE                        { printf("WHILE_BEGIN_%d:\n", $1=DO_Lable_Counter++); printf("\n"); } 
        '('                           { printf("WHILE_CONDITION_%d:\n", $1); printf("\n"); }
        expr ')'                      { printf("ifFalse  goto DO_WHILE_END;\n"); printf("\n"); }   
        ';'                           { printf("goto DO_BEGIN%d;\n", $1);  printf("\n"); printf("DO_WHILE_END_%d:\n", $1); }
        
        |WHILE                        { printf("WHILE_BEGIN_%d:\n", $1=While_Lable_Counter++); printf("\n"); } 
        '('                           { printf("WHILE_CONDITION_%d:\n", $1); printf("\n"); }
        expr ')'                      { printf("ifFalse (%s) goto WHILE_END_%d;\n", $5, $1); printf("goto WHILE_CODE_%d;\n", $1); printf("\n"); printf("WHILE_CODE_%d:\n", $1); } 
        stmt                          { printf("goto WHILE_CONDITION_%d;\n", $1); printf("\n"); printf("WHILE_END_%d:\n", $1); }

        |block                        
        ;

optexpr:    
        expr                         { strcpy($$, $1); }
        | ID                         { strcpy($$, $1); printf("%s = 0;\n", $1); strcpy(Myvar, $1);}
        | NUM                        { strcpy($$, $1); strcpy(Mynum, $1);}
        |                     
        ;

IDs     : IDs ',' ID	             { sprintf($$, "%s, %s", $1, $3); }
	| ID			                 { sprintf($$, "%s",$1);}
	| ID '=' expr	                 { sprintf($$, "%s = %s", $1, $3); }
	;


expr    : ID '=' expr               { strcpy($$, $3); printf("%s = %s;\n", $1, $3); }
        | rel                       { strcpy($$, $1); }
        | rel1                      { strcpy($$, $1); }      
        ;
rel1     :rel1 LOG add              { sprintf($$, "t%d", create_Var++); printf("%s = %s %s %s;\n", $$, $1, $2, $3); }
        | add                       { strcpy($$, $1);}
        |rel1 RELOP rel              { sprintf($$, "t%d", create_Var++); printf("%s = %s %s %s;\n", $$, $1, $2, $3); }
        ;
rel     : rel RELOP add             { sprintf($$, "t%d", create_Var++); printf("%s = %s %s %s;\n", $$, $1, $2, $3); }
        | add                       { strcpy($$, $1);}
        ;
add     : add '+' term              { sprintf($$, "t%d", create_Var++); printf("%s = %s + %s;\n", $$, $1, $3); }
        | add '-' term              { sprintf($$, "t%d", create_Var++); printf("%s = %s - %s;\n", $$, $1, $3); }
        | term                      { strcpy($$, $1);}
        ;

term    : term '*' term1           { sprintf($$, "t%d", create_Var++); printf("%s = %s * %s;\n", $$, $1, $3); }
        | term '/'  term1            {
                                      if(strcmp($3,"0") == 0){
                                      sprintf($$, "t%d", create_Var++);
                                      printf("%s = %s / %s;\n", $$, $1, $3);
                                      printf("Error : Can not divide by zero\n");return 0;}else{
                                      sprintf($$, "t%d", create_Var++);
	                              printf("%s = %s / %s;\n", $$, $1, $3);
                                      } }
        | term '%'  term1            { sprintf($$, "t%d", create_Var++); printf("%s = %s %% %s;\n", $$, $1, $3); }
        | term '^' term1            {sprintf($$, "t%d", create_Var++); printf("%s = %s ^ %s;\n", $$, $1, $3);
                                     if(strcmp($1,"0")==0 && atoi($3)<=0){
 	                              printf("Error : The power of 0 is undefined for negative exponent\n");
                                      return 0;
                                     }}
        | term1                     { strcpy($$, $1); }
        ;

term1  :  factor                   { strcpy($$, $1); }
        ;

factor  : '(' expr ')'             { strcpy($$, $2); }
        | '-' factor               { strcpy(sign,"-"); strcat(sign,$2); strcpy($$, sign); }
        | NUM                      { strcpy($$, $1); }
        | ID                       { strcpy($$, $1); }
        ;

%%

void yyerror(char *msg) {
    fprintf(stderr,"%s\n",msg);
    exit(1);
}


int yywrap() {
    return 1;
}

int main() {
   yyparse();
}