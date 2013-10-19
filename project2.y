%{
#include <stdio.h>

extern char *yytext;
extern int myCol, myLine;

int yylex(void);
void yyerror(const char *);
%}

%union {int ival; float fval; char sval[256]; char cval;}

%token BLOCK_COMMENT LINE_COMMENT NEW_LINE WHITE_SPACE BAD_CHAR
%token IDENTIFIER
%token <ival> INT_LITERAL
%token <fval> FLT_LITERAL
%token <dval> STR_LITERAL
%token <cval> CHR_LITERAL
%token SQR_OP INC_OP DEC_OP
%token INT FLOAT STRING BOOL VOID MATRIX SENSOR
%token FOREACH FOR UNTIL WHILE DO IF ELSE SELECT INTERVAL BREAK CONTINUE CASE DEFAULT IN TO
%token FUNC RETURN
%token FALSE TRUE AND_OP OR_OP
%token MUL_ASSIGN_OP DIV_ASSIGN_OP MOD_ASSIGN_OP ADD_ASSIGN_OP SUB_ASSIGN_OP ASSIGN_OP
%token MUL_OP DIV_OP MOD_OP ADD_OP SUB_OP
%token LE_OP GE_OP NE_OP EQ_OP LS_OP GR_OP
%token SEMICOLON COMMA COLON DOT
%token L_BRACE R_BRACE L_PARANTHESES R_PARANTHESES L_BRACKET R_BRACKET

%start program;

%glr-parser

%%

program
	: function
	| program function
	;
function
	: FUNC IDENTIFIER L_PARANTHESES parameter_list R_PARANTHESES COLON return_type block
	;
block
	: L_BRACE statement_list R_BRACE		
	;
return_type
	: data_type		
	;
parameter_list
	:
	| data_type IDENTIFIER		
	| parameter_list COMMA IDENTIFIER		
	;
statement_list
	: statement	SEMICOLON
	| statement_list statement SEMICOLON		
	;
statement
	: declaration_statement		
	| assign_statement		
	| conditional_statement	
	| loop_statement		
	| function_calling		
	;
declaration_statement
	: basic_type_declaration
	| sensor_declaration_statement
	| matrix_declaration_statement
	;
basic_type_declaration
	: basic_data_type IDENTIFIER
	| basic_type_declaration assign_operator rvalue
	| basic_type_declaration COMMA IDENTIFIER
	;
sensor_declaration_statement
	: SENSOR IDENTIFIER assign_operator SENSOR INT_LITERAL
	;
matrix_declaration_statement
	: MATRIX IDENTIFIER L_BRACKET dimension_format R_BRACKET
	| MATRIX IDENTIFIER L_BRACKET dimension_format R_BRACKET ASSIGN_OP L_BRACE identifier_list R_BRACE
	; 
dimension_format
	: INT_LITERAL
	| dimension_format COMMA INT_LITERAL
	;
assign_statement
	: IDENTIFIER assign_operator rvalue
	| IDENTIFIER unary_op
	| IDENTIFIER L_BRACKET INT_LITERAL R_BRACKET assign_operator rvalue
	| IDENTIFIER ASSIGN_OP L_BRACE identifier_list R_BRACE
	;
unary_op
	: INC_OP
	| DEC_OP
	| SQR_OP
	;
assign_operator
	: ASSIGN_OP
	| ADD_ASSIGN_OP
	| SUB_ASSIGN_OP
	| MUL_ASSIGN_OP
	| DIV_ASSIGN_OP
	| MOD_ASSIGN_OP
	;
rvalue
	: arithmetic_expression
	| function_calling
	;
arithmetic_expression
	: term
	| arithmetic_expression ADD_OP term
	| arithmetic_expression SUB_OP term
	;
term
	: primary
	| term MUL_OP primary
	| term DIV_OP primary
	| term MOD_OP primary
	;
primary
	: constant
	| IDENTIFIER
	;
constant
	: STR_LITERAL
	| CHR_LITERAL
	| INT_LITERAL
	| FLT_LITERAL
	;
conditional_statement
	: if_statement
	| select_statement
	| interval_statement
	;
if_statement
	: IF L_PARANTHESES boolean_expression R_PARANTHESES block
	| if_statement ELSE IF L_PARANTHESES boolean_expression R_PARANTHESES block
	| if_statement ELSE block
	;
select_statement
	: SELECT L_BRACE select_case_statement R_BRACE
	| SELECT L_BRACE select_case_statement default_conditional_statement R_BRACE
	;
select_case_statement
	: CASE boolean_expression COLON statement_list
	| CASE boolean_expression COLON statement_list BREAK
	| CASE boolean_expression COLON statement_list select_case_statement
	| CASE boolean_expression COLON statement_list BREAK select_case_statement
	;
interval_statement
	: INTERVAL L_PARANTHESES number_type R_PARANTHESES L_BRACE interval_case_statement R_BRACE
	| INTERVAL L_PARANTHESES number_type R_PARANTHESES L_BRACE interval_case_statement default_conditional_statement R_BRACE
	;
number_type
	: IDENTIFIER
	| INT_LITERAL
	| FLT_LITERAL
	;
interval_case_statement
	: CASE number_type TO number_type COLON statement_list BREAK
	| CASE number_type TO number_type COLON statement_list
	| CASE number_type TO number_type COLON statement_list BREAK interval_case_statement
	| CASE number_type TO number_type COLON statement_list interval_case_statement
	;
default_conditional_statement
	: DEFAULT COLON statement_list BREAK
	| DEFAULT COLON statement_list
	;
loop_statement
	: while_loop
	| until_loop
	| do_while_loop
	| do_until_loop
	| for_loop
	| foreach_loop
	;
while_loop
	: WHILE L_PARANTHESES boolean_expression R_PARANTHESES block
	;
until_loop
	: UNTIL L_PARANTHESES boolean_expression R_PARANTHESES block
	;
do_while_loop
	: DO block WHILE L_PARANTHESES boolean_expression R_PARANTHESES block
	;
do_until_loop
	: DO block UNTIL L_PARANTHESES boolean_expression R_PARANTHESES block
	;
for_loop
	: FOR L_PARANTHESES for_inititation SEMICOLON boolean_expression SEMICOLON assign_statement R_PARANTHESES block
	;
for_inititation
	: declaration_statement
	| assign_statement
	| empty
	;
foreach_loop
	: FOREACH L_PARANTHESES foreach_loop_type IDENTIFIER IN IDENTIFIER R_PARANTHESES block
	;
foreach_loop_type
	: basic_data_type
	| SENSOR
	;
function_calling
	: IDENTIFIER L_PARANTHESES identifier_list R_PARANTHESES
	| IDENTIFIER DOT function_calling
	;
identifier_list
	: empty
	| call_parameter
	| identifier_list COMMA call_parameter
	;
call_parameter
	: IDENTIFIER
	| constant
	| IDENTIFIER L_BRACKET INT_LITERAL R_BRACKET
	| IDENTIFIER L_BRACKET IDENTIFIER R_BRACKET
	;
boolean_expression
	: TRUE
	| FALSE
	| IDENTIFIER
	| logical_expression
	;

logical_expression
	: boolean_expression boolean_op boolean_expression_sub
	| boolean_expression relation_op boolean_expression_sub
	;
boolean_expression_sub
	: TRUE
	| FALSE
	| IDENTIFIER
	| constant
	;
boolean_op
	: AND_OP
	| OR_OP
	;
relation_op
	: LS_OP
	| LE_OP
	| GR_OP
	| GE_OP
	| EQ_OP
	| NE_OP
	;
data_type
	: basic_data_type
	| complex_data_type
	;
basic_data_type
	: VOID
	| BOOL
	| number_types
	| STRING
	;
number_types
	: INT
	| FLOAT
	;
complex_data_type
	: SENSOR
	| MATRIX
	;
empty
	: /* empty */
	;

%%

void yyerror(const char *err) {
    fprintf(stderr, "%s in line %d around column %d\n", err, myLine, myCol  );
}

int main(int argc, char *argv[])
{
	printf("\n---------------------------------------------------------- ");
	printf("\n-                  SweetHome v0.1 Parser                 - ");
	printf("\n-                (C) 2010 Ilknur KABADAYI                - ");
	printf("\n---------------------------------------------------------- \n");

	if( yyparse() )
		printf("\n!!! ERROR(S) OCCURED DURING PARSING PROCESS!\n\n");
	else
		printf("PARSING COMPLETED SUCCESSFULLY!\n\n");
	
	
	return 0;
}
