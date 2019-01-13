%{
#pragma warning(disable:4996)
	#include <stdio.h>
	#include <string.h>
	#include <iostream>
	#include <stdlib.h>
	#include <malloc.h>
	using namespace std;
	
	int yylex();
	int yyerror(const char *msg);
	
	int isCorrect = 0;
	char msg[50];
	int yydebug=1;

	class var
	{
		char *name;
		int value;
		var* next;
		bool isInit;

	public:
		static var * head;
		static var* tail;

		var();
		var(char *n);
		var(char *n, int v);
		bool exists(char* n);
		void add(char* n, int v);
		void add(char *n);
		int getValue(char* n);
		void setValue(char* n, int v);
		void read(char* n);
		void write(char *n);
		bool checkinit(char *n);
		void changeState(char* n);
	};


	var* var::head;
	var* var::tail;

	var::var()
	{
	  var::head=NULL;
	  var::tail=NULL;
	}

	var::var(char *n) {
		{
			this->name = new char[strlen(n) + 1];
			strcpy(this->name, n);
			isInit = false;
		}
	}
	var::var(char *n, int v) {
		this->name = new char[strlen(n) + 1];
		strcpy(this->name, n);
		this->value = v;
	}

	bool var::exists(char* n) {
		var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
				return true;
			p = p->next;
		}
		return false;
	}
	void var::add(char *n){
		var* elem = new var(n);
		elem->isInit=false;
		if (head == NULL)
		{
			var::head = var::tail = elem;
		}
		else
		{
			var::tail->next = elem;
			var::tail = elem;
		}
	}


	void var::add(char* n, int v) {

		var* elem = new var(n, v);
		elem->isInit=true;
		if (head == NULL)
		{
			var::head = var::tail = elem;
		}
		else
		{
			var::tail->next = elem;
			var::tail = elem;
		}
	}

	int var::getValue(char* n){
		var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
				return p->value;

			p = p->next;
		}
	}

	void var::setValue(char* n, int v) {
		var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
			{
				p->value = v;
				p->isInit=true;
			}
			p = p->next;
		}
	}

	void var::read(char* n)
	{
	 var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
				{p->isInit=true; break;}
			p = p->next;
		}
	}

	void var::write(char* n)
	{
		var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
			{
			  
			printf("Afisez variabila %s \n",n);
			 
			}
			p = p->next;
		}
	}

	bool var::checkinit(char *n){
		var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
				return p->isInit;
			p = p->next;
		}
	}	

	void var::changeState(char* n){
		var* p = var::head;
		while (p != NULL)
		{
			if (strcmp(p->name, n) == 0)
				p->isInit=1;
			p = p->next;
		}

	}

   var *ts=new var();
%}

%union
{
	char* sir;
	int val;
}

%locations
%token TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIV TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_LEFT TOK_RIGHT TOK_SET TOK_COMMA TOK_SMCOL TOK_COLON TOK_DOT TOK_ERROR
%token <sir> TOK_ID 
%token <val> TOK_INT
 
%type <sir> idlist
%type <val> factor
%type <val> term
%type <val> exp

%start S

%right TOK_SET
%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIV
%left TOK_LEFT TOK_RIGHT

%%

S:  TOK_PROGRAM progname TOK_VAR declist TOK_BEGIN stmtlist TOK_END TOK_DOT {isCorrect=1; };

progname: TOK_ID 
	   ;

declist: dec
	 | 
	 declist TOK_SMCOL dec
	 ;

dec: idlist TOK_COLON type { if($1!=NULL)
				{char* s=strtok($1,",");
				 while(s!=NULL)
					{
					if(!ts->exists(s))
		   				ts->add(s);
					else  {
						sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, s);
						yyerror(msg);
		 				YYERROR;
						}
					 s=strtok(NULL,",");
					}
			 	}
			   }
     ;

type: TOK_INTEGER 
      ;

idlist: TOK_ID 
	|
	idlist TOK_COMMA TOK_ID { strcat($1,","); strcat($1,$3); }
	;

stmtlist: stmt 
	  |
	  stmtlist TOK_SMCOL stmt   
	  ;

stmt: assign
      | 
      read 
      |
      write
      |
      for
      ;

assign: TOK_ID TOK_SET exp      { if(!ts->exists($1)){
				      sprintf(msg,"%d:%d Eroare semantica: %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
					yyerror(msg);
		 			YYERROR;
				    }
				  if(ts->checkinit($1) == false)
					ts->changeState($1); }  
	;

exp: term {$$=$1;}
     |
     exp TOK_PLUS term {$$=$1+$3;}
     |
     exp TOK_MINUS term {$$=$1-$3;}
     ;

term: factor   {$$=$1;}
      | 
      term TOK_MULTIPLY factor {$$=$1*$3;}
      | 
      term TOK_DIV factor    {$$=$1/$3;}
      ;

factor: TOK_ID  {if(!ts->exists($1)){
			sprintf(msg,"%d:%d Eroare semantica: %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
			yyerror(msg);
		 	YYERROR;
			}
		else { if(ts->checkinit($1) == false ) {
			sprintf(msg,"%d:%d Eroare semantica: %s nu a fost initializata!", @1.first_line, @1.first_column, $1);	
			yyerror(msg);
		 	YYERROR;
			}
		     }

		if(ts->exists($1))
			$$=ts->getValue($1); }
        | 
        TOK_INT  {$$=$1;}
	|
        TOK_LEFT exp TOK_RIGHT {$$=$2;}
	;

read: TOK_READ TOK_LEFT idlist TOK_RIGHT {
			if($3!=NULL)
				{char* s=strtok($3,",");
				 while(s!=NULL)
					{
					if(!ts->exists(s))
		   				 {
						sprintf(msg,"%d:%d Eroare semantica: %s nu a fost declarata!", @1.first_line, @1.first_column, s);
						yyerror(msg);
		 				YYERROR;
						}
					ts->read(s);
					 s=strtok(NULL,",");
					}
			 	}
			 }
      ;

write: TOK_WRITE TOK_LEFT idlist TOK_RIGHT { 
			if($3!=NULL)
				{char* s=strtok($3,",");
				 while(s!=NULL)
					{
					if(!ts->exists(s))
		   				 {
						sprintf(msg,"%d:%d Eroare semantica: %s nu a fost declarata!", @1.first_line, @1.first_column, s);
						yyerror(msg);
		 				YYERROR;
						}
					 if(ts->checkinit(s) == false)
						 {
						sprintf(msg,"%d:%d Eroare semantica: %s nu a fost initializata!", @1.first_line, @1.first_column, s);
						yyerror(msg);
		 				YYERROR;
						}
					 ts->write(s);
					 s=strtok(NULL,",");
					}
			 	}
			 }
       ;

for: TOK_FOR indexexp TOK_DO body 
     ;

indexexp: TOK_ID TOK_SET exp TOK_TO exp {
		{if(!ts->exists($1)){
			sprintf(msg,"%d:%d Eroare semantica: %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
			yyerror(msg);
		 	YYERROR;
			}
		else { if(ts->checkinit($1) == false ) {
			ts->changeState($1);
			}
		     }
		}
	  }	
          ;

body: stmt
      | 
      TOK_BEGIN stmtlist TOK_END
      ;

%%

int main()
{

	yyparse();
	if(isCorrect == 1)
	{
		printf("CORRECT");		
	}	
	else
	{
		printf("INCORRECT");
	}

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}
