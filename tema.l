%{
	#include "y.tab.h"
	int lineNo = 1;
	int colNo = 1;
%}

%%
"PROGRAM"	{ colNo+=strlen(yytext);  return TOK_PROGRAM; }
"VAR"		{ colNo+=strlen(yytext);  return TOK_VAR; }
"BEGIN"		{ colNo+=strlen(yytext);  return TOK_BEGIN; }
"END"		{ colNo+=strlen(yytext);  return TOK_END; }
"INTEGER"	{ colNo+=strlen(yytext);  return TOK_INTEGER; }
"DIV"		{ colNo+=strlen(yytext);  return TOK_DIV; }
"READ"		{ colNo+=strlen(yytext);  return TOK_READ; }
"WRITE"		{ colNo+=strlen(yytext);  return TOK_WRITE; }
"FOR"		{ colNo+=strlen(yytext);  return TOK_FOR; }
"DO"		{ colNo+=strlen(yytext);  return TOK_DO; }
"TO"		{ colNo+=strlen(yytext);  return TOK_TO; }
"+"		{ colNo++; return TOK_PLUS; }
"-"		{ colNo++; return TOK_MINUS; }
"*"		{ colNo++; return TOK_MULTIPLY; }
"("		{ colNo++; return TOK_LEFT; }
")"		{ colNo++; return TOK_RIGHT; }
":="		{ colNo++; return TOK_SET; }
","		{ colNo++; return TOK_COMMA; }
";"		{ colNo++; return TOK_SMCOL; }
":"		{ colNo++; return TOK_COLON; }
"."		{ colNo++; return TOK_DOT; }
[a-zA-Z][_a-zA-Z0-9]*   { colNo+=strlen(yytext); 
			yylloc.first_line = lineNo;
			 yylloc.first_column = colNo;
			 yylval.sir = strdup(yytext);
			 return TOK_ID; }
[1-9][0-9]*	{ colNo+=strlen(yytext);  
		  yylloc.first_line = lineNo;
		  yylloc.first_column = colNo;
  		  yylval.val = atoi(yytext);
		  return TOK_INT; }
[ ]		{ colNo++; }
[\t]		{ colNo+=8; }
\n		{ lineNo++;colNo=1; }
.		{ colNo++; return TOK_ERROR; }

%%
