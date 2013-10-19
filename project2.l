%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

#ifdef YYDEBUG
#undef YYDEBUG
#endif
#define YYDEBUG 0

int myLine =  1;
int myCol  =  0;
int prev   = -1;

int  take(int);
void comment_line(void);
void comment_block(void);

%}

L	[a-zA-Z_IýÞþÖöÇçÐðÜü]
D	[0-9]

%%
 /* comments */
"#>"					{ take(BLOCK_COMMENT); comment_block(); }
"#"						{ take(LINE_COMMENT); comment_line(); } 

 /* data types */
int						{ return take(INT); }
float					{ return take(FLOAT); }
string					{ return take(STRING); }
bool					{ return take(BOOL); }
void					{ return take(VOID); }
matrix					{ return take(MATRIX); }
sensor					{ return take(SENSOR); }

 /* loops */
foreach					{ return take(FOREACH); }
for						{ return take(FOR); }
until					{ return take(UNTIL); }
while					{ return take(WHILE); }
do						{ return take(DO); }
break					{ return take(BREAK); }
continue				{ return take(CONTINUE); }

 /* conditional statements */
if						{ return take(IF); }
else					{ return take(ELSE); }
select					{ return take(SELECT); }
interval				{ return take(INTERVAL); }
case					{ return take(CASE); }
in						{ return take(IN); }
to						{ return take(TO); }
default					{ return take(DEFAULT); }

 /* function definitons */
func					{ return take(FUNC); }
return					{ return take(RETURN); }

 /* boolean literals */
false					{ return take(FALSE); }
true					{ return take(TRUE); }

 /* boolean operators */
and						{ return take(AND_OP); }
or						{ return take(OR_OP); }

 /* assignment operators */
"*<<"					{ return take(MUL_ASSIGN_OP); }
"/<<"					{ return take(DIV_ASSIGN_OP); }
"%<<"					{ return take(MOD_ASSIGN_OP); }
"+<<"					{ return take(ADD_ASSIGN_OP); }
"-<<"					{ return take(SUB_ASSIGN_OP); }
"<<"					{ return take(ASSIGN_OP); }

 /* relational operators */
"<="					{ return take(LE_OP); }
">="					{ return take(GE_OP); }
"<>"					{ return take(NE_OP); }
"="						{ return take(EQ_OP); }
"<"						{ return take(LS_OP); } /* angle bracket (chevron) */
">"						{ return take(GR_OP); }

 /* unary operators */
"**"					{ return take(SQR_OP); }
"++"					{ return take(INC_OP); }
"--"					{ return take(DEC_OP); }

 /* binary operators */
"*"						{ return take(MUL_OP); }
"/"						{ return take(DIV_OP); }
"%"						{ return take(MOD_OP); }
"+"						{ return take(ADD_OP); }
"-"						{ return take(SUB_OP); }

";"						{ return take(SEMICOLON); }
"{"						{ return take(L_BRACE); } /* curly bracket (brace) */
"}"						{ return take(R_BRACE); }
","						{ return take(COMMA); }
":"						{ return take(COLON); }
"("						{ return take(L_PARANTHESES); } /* round bracket (parantheses) */
")"						{ return take(R_PARANTHESES); }
"["						{ return take(L_BRACKET); } /* box/square bracket */
"]"						{ return take(R_BRACKET); }

[\-+]?{D}+				{ return take(INT_LITERAL); }
[\-+]?{D}*"."{D}+		{ return take(FLT_LITERAL); }
\"(\\.|[^\\"])*\"		{ return take(STR_LITERAL); } /* match any char between two nails other than a nail */
\'(\\.|[^\\'])+\'		{ return take(CHR_LITERAL); } /* match any char between two nails other than a nail */
{L}({D}|{L})*			{ return take(IDENTIFIER); }


"."						{ return take(DOT); }
(\r|\n|\r\n)			{ take(NEW_LINE); }
[ \t\v\f]+				{ take(WHITE_SPACE); /* ignore white spaces */ }
.						{ take(BAD_CHAR); }

%%

yywrap(){
	return 1;
}

int take(int type){
	prev = type;
	if( type == NEW_LINE ){
		myLine++;
		myCol = 0;
	} else {
		myCol += strlen(yytext);
	}
	if(type == BAD_CHAR){
		yyerror("bad char");
	}
	if(YYDEBUG) printf("%s", yytext);
	return type;
}

int  check_last(void){
	return ( prev == INT_LITERAL || prev == FLT_LITERAL )
		&& ( yytext[0] == '-' )
			? -1
			:  1;
}

void comment_block(void){
	if(YYDEBUG) printf("BLOCK COMMENT \"");
	char c1, c2;
	while(1){ // streaming comment starts with "#>" and ends with "<#"
		while ((c1 = input()) != '<' && c1 != 0){
			myCol++;
			if( c1 == '\n' || c1 == '\r' ){
				myLine++;
				myCol = 0;
				if(YYDEBUG) printf(" | ");
			}
			else if(YYDEBUG){
				putchar(c1);
			}
		}
		if (c1 == 0 || (c2 = input()) == '#'){
			myCol++;
			break;
		}
		unput(c2);
		myCol--;
	}
	if (c1 != 0 && c2 != '#') if(YYDEBUG) putchar(c2);
	if(YYDEBUG) printf("\"\n");
}

void comment_line(void){
	if(YYDEBUG) printf("LINE COMMENT \"");
	char c1;
	while ((c1 = input()) != '\n' && c1 != '\r' && c1 != '\0')
		if(YYDEBUG) putchar(c1);
	if(YYDEBUG) printf("\"\n");
	myLine++;
	myCol = 0;
}
