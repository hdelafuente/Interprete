%{
	#include <stdio.h>

	#include "mem.h"
	extern double var_values[100];
	extern int var_set[100];
	int yylex();
	int yyparse();
	FILE *yyin;
	int yylex();
	void yyerror(const char *s);

%}

%union{
    int index;
    double num;
    char *str;
}


%token NUMBER NAME STRING
%token<num> LET EQUIV
%token<num> ADD MUTL DIV LES POW
%token<num> EOL
%token<num> BGNP ENDP PRINT

%type<num> NUMBER
%type<str> STRING
%type<index> NAME
%type<num> program
%type<num> line
%type<num> stmt
%type<num> exp
%type<num> assign
%type<num> function

%left ADD
%left MUTL
%left DIV
%left LES
%left RIGHT
%left LEFT

%left LBR RBR

%%
final_program: BGNP program ENDP EOL

program: { printf("\n"); }
| program line
;

line:
EOL
| stmt EOL
| stmt stmt
;

stmt: exp
| assign
| function
;

assign: LET NAME EQUIV exp { $$ = set_var($2, $4); }
;

exp: NUMBER { $$ = $1; }
| NAME { $$ = var_values[$1]; }
| exp ADD exp EOL { $$ = $1 + $3; }
| exp MUTL exp { $$ = $1 * $3; }
| exp DIV exp { $$ = $1 / $3; }
| exp LES exp { $$ = $1 - $3; }
| exp POW exp { $$ = $1; for(int i = 0; i < $3; i++) {$$ *= $1;}} 
| LBR exp RBR { $$ = $2; }
;


function: PRINT exp { printf("%.2f\n", $2); }
| PRINT STRING {printf("%s\n",$2); }
;
%%
int main(int argc, char **argv)
{
	line_num = 1;
	var_counter = 0;
	FILE *input = fopen("code.jr", "r" );
	if(input==NULL) {
		printf("File not found\n");
		return -1;
	}
	yyin = input;
	yylex();
	yyparse();

}
void yyerror(const char *s)
{
    fprintf(stderr, "error: %s found  in line %d\n", s, line_num);
}
int set_var(int index, double val)
{
    var_values[index] = val;
    var_set[index] = 1;
    
    return val;
}
