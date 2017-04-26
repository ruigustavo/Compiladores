%{
  #include <stdio.h>
  #include <string.h>
  #include <stdarg.h>
  #include "functions.h"



  void yyerror(const char *s);
  int yylex();
  extern int flag;
  extern int n_line;
  extern int n_column;
  extern char* yytext;

  int flagTreeErros;

  node* root;
  node* main_node;
  node* main2_node;
  node* aux_node;
  node* aux2_node;
  node* present_node;
  node* value_node;


%}

%union{
  char *string;
  struct node *node;
}

%token BOOL CLASS DO DOTLENGTH DOUBLE ELSE IF INT PARSEINT PRINT PUBLIC RETURN STATIC STRING VOID WHILE OCURV CCURV OBRACE CBRACE OSQUARE CSQUARE AND OR LT GT EQ NEQ GEQ LEQ
%token PLUS MINUS STAR DIV MOD NOT ASSIGN SEMI COMMA
%token <string>  REALLIT DECLIT BOOLLIT ID STRLIT RESERVED

%left COMMA
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT LEQ GEQ GT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left OBRACE CBRACE CCURV OCURV OSQUARE CSQUARE

%right ELSE




%type <node> Program FieldDecl MethodDecl MethodHeader MethodBody FormalParams VarDecl Type Statement Assignment MethodInvocation ParseArgs Expr
%type <node> auxProgram auxFieldDecl AuxMethodBody auxFormalParams auxVarDecl auxStatement1 auxStatement2 auxStatement4 auxStatement5 AuxMethodInvocation1 AuxMethodInvocation2 auxExpr
%%

Program: CLASS ID OBRACE auxProgram CBRACE {{($$)=root=new_node("Program","Program");
    aux_node=new_node("Id",$2);
    add_brother(aux_node,$4);
    add_son($$,aux_node);

};}
;
auxProgram: %empty      {if(flagTreeErros ==1){$$ = NULL;};}
| FieldDecl auxProgram {if(flagTreeErros ==1){add_brother($1,$2);
    $$=$1;};}
| MethodDecl auxProgram  {if(flagTreeErros ==1){add_brother($1, $2);
    $$=$1;};}
| SEMI auxProgram {if(flagTreeErros ==1){$$=$2;};}
;


FieldDecl: PUBLIC STATIC auxFieldDecl SEMI     {{$$ = $3;};}
  | error SEMI                                 {$$=new_node("Error","Error");flagTreeErros = 0;}
;
auxFieldDecl: Type ID                           {{$$  = new_node("FieldDecl","FieldDecl");add_son($$,$1);
                                                                      add_brother($$->son, new_node("Id",$2));};}
  | auxFieldDecl COMMA ID                      {{$1= new_node("FieldDecl","FieldDecl");
                                                                        add_son($1,new_node($$->son->type,$$->son->type));
                                                                        add_brother($1->son,new_node("Id",$3)); add_brother($$,$1);};}
;

MethodDecl:  PUBLIC STATIC MethodHeader MethodBody {{$$ = new_node("MethodDecl","MethodDecl");add_son($$,$3);add_brother($3,$4);};}
;

MethodHeader:  Type ID OCURV FormalParams CCURV  {{$$= new_node("MethodHeader","MethodHeader");
                                                                            add_son($$,$1);
                                                                          add_brother($1,new_node("Id",$2));
                                                                          add_brother($1,$4);};}
  | VOID ID OCURV FormalParams CCURV {               {$$= new_node("MethodHeader","MethodHeader");
                                                                            add_son($$,aux_node=new_node("Void","Void"));
                                                                            add_brother(aux_node,new_node("Id",$2));
                                                                            add_brother(aux_node,$4);};}
;

MethodBody:OBRACE AuxMethodBody CBRACE {{$$= new_node("MethodBody","MethodBody");add_son($$,$2);};}
;
AuxMethodBody:   %empty                               {{$$=NULL;};}
  |  VarDecl    AuxMethodBody                           {{   if($1==NULL){
                                                                                      $$=$2;
                                                                                    }
                                                                                  else{add_brother($1,$2);
                                                                                  $$=$1;}
                                                                                };}
  |  Statement AuxMethodBody                            {{ if($1==NULL){$$=$2;}
                                                                                else{add_brother($1,$2);
                                                                                $$=$1;}
                                                                                };}
;

FormalParams:  Type ID auxFormalParams                  {{$$= new_node("MethodParams","MethodParams");
                                                                                  aux2_node=new_node("ParamDecl","ParamDecl");
                                                                                  add_son(aux2_node,$1);
                                                                                  add_brother($1,new_node("Id",$2));
                                                                                  add_brother(aux2_node,$3);
                                                                                  add_son($$,aux2_node);
                                                                                  };}
  | STRING OSQUARE CSQUARE ID                           {{ $$= new_node("MethodParams","MethodParams");
                                                                                aux2_node = new_node("ParamDecl","ParamDecl");
                                                                                main_node = new_node("StringArray","StringArray");
                                                                                add_son($$,aux2_node);
                                                                                add_brother(main_node,new_node("Id",$4));
                                                                                add_son(aux2_node,main_node);
                                                                                };}
  | %empty                                              {$$= new_node("MethodParams","MethodParams");}
;
auxFormalParams: COMMA Type ID auxFormalParams {{$$ = new_node("ParamDecl","ParamDecl");
                                                                        add_son($$,$2);
                                                                        add_brother($2,new_node("Id",$3));
                                                                        add_brother($$,$4);};}
  | %empty                                                            {$$=NULL;}
;

VarDecl: auxVarDecl SEMI      {{$$ = $1;};}
;
auxVarDecl : Type ID          {{$$  = new_node("VarDecl","VarDecl");add_son($$,$1);
                                                                      add_brother($1, new_node("Id",$2));};}
  | auxVarDecl COMMA ID       {{$1= new_node("VarDecl","VarDecl");
                                                                        add_son($1,new_node($$->son->type,$$->son->type));
                                                                        add_brother($1->son,new_node("Id",$3)); add_brother($$,$1);};}
;

Type: BOOL  {{$$=new_node("Bool","Bool");};}
  | INT     {{$$=new_node("Int","Int");};}
  | DOUBLE  {{$$=new_node("Double","Double");};}
;
Statement: OBRACE auxStatement4 CBRACE                  {{
                                                            if($2!=NULL){
                                                              if((cntbrothers($2))==1){
                                                                $$ = $2;
                                                              }
                                                              else{
                                                                $$ = new_node("Block","Block");
                                                                add_son($$,$2);}
                                                              }
                                                            else{
                                                                $$=NULL;
                                                            }
                                                            };}
  | IF OCURV Expr CCURV Statement ELSE Statement        {{$$=new_node("If","If");
                                                          if($7==NULL){
                                                            $7 = new_node("Block","Block");
                                                          }
                                                          if($5==NULL){
                                                            $5 = new_node("Block","Block");
                                                          }
                                                          add_son($$,$3);
                                                          add_brother($3,$5);
                                                          add_brother($3,$7);
                                                          };}
  | IF OCURV Expr CCURV Statement %prec ELSE            {{
    if($5==NULL){
      $5 = new_node("Block","Block");
    }
                                                          $$ = new_node("If","If");
                                                          add_son($$,$3);
                                                          add_brother ($3,$5);
                                                          add_brother ($3,new_node("Block","Block"));
                                                        };}
  | WHILE OCURV Expr CCURV Statement                    {{$$=new_node("While","While");
                                                            add_son($$,$3);
                                                            add_brother($3,$5);
                                                            if($5==NULL){
                                                                add_brother ($3,new_node("Block","Block"));
                                                            }

                                                        };}
  | DO Statement WHILE OCURV Expr CCURV SEMI            {{$$=new_node("DoWhile","DoWhile");
                                                              if($2==NULL){
                                                                $2 = new_node("Block","Block");
                                                              }
                                                            add_son($$,$2);
                                                            add_brother($2,$5);
                                                          };}
  | PRINT OCURV auxStatement2 CCURV SEMI                {{$$=new_node("Print","Print");
                                                          add_son($$,$3);

                                                        };}
  | auxStatement1 SEMI                                  {{$$=$1;};}
  | RETURN auxStatement5 SEMI                           {{$$ = new_node("Return","Return");
                                                                              if($2!=NULL){
                                                                                  add_son($$,$2);
                                                                              }
                                                                              };}
  | error SEMI                                          {$$=new_node("Error","Error");flagTreeErros = 0;}
;
auxStatement1: Assignment               {{$$=$1;};}
  | MethodInvocation                    {{$$=$1;};}
  | ParseArgs                           {{$$=$1;};}
  | %empty                              {$$=NULL;}
;
auxStatement2: Expr                     {{$$=$1;};}
  | STRLIT                              {{$$=new_node("StrLit",$1);};}
;
auxStatement4: Statement auxStatement4      {{
                                            if($1==NULL){
                                              $$=$2;
                                            }
                                            else{$$=$1;add_brother($1,$2);}};}
  | %empty                                  {$$=NULL;}
;
auxStatement5: Expr                      {{$$=$1;};}
  |%empty                                {$$=NULL;}
;

Assignment: ID ASSIGN Expr  {{$$=new_node("Assign","Assign");
                                                      aux_node= new_node("Id",$1);
                                                      add_brother(aux_node,$3);
                                                      add_son($$,aux_node);};}


MethodInvocation: ID OCURV AuxMethodInvocation1 CCURV   {$$= new_node("Call","Call");
                                                          aux_node = new_node("Id",$1);
                                                          add_son($$,aux_node);
                                                          if($3!=NULL){
                                                          add_brother(aux_node,$3);}
                                                          ;}
  | ID OCURV error CCURV {$$=new_node("Error","Error");flagTreeErros=0;}
;
AuxMethodInvocation1: Expr AuxMethodInvocation2 {$$=$1;
                                                  add_brother($1,$2);}
  | %empty{$$=NULL;}
;
AuxMethodInvocation2: COMMA Expr AuxMethodInvocation2 {$$=$2;add_brother($2,$3);}
  | %empty{$$=NULL;}
;


ParseArgs: PARSEINT OCURV ID OSQUARE Expr CSQUARE CCURV   {{$$= new_node("ParseArgs","ParseArgs");
                                                              add_son($$,aux2_node=new_node("Id",$3));
                                                              add_brother(aux2_node,$5);
                                                              };}
  | PARSEINT OCURV error CCURV                            {$$=new_node("Error","Error");flagTreeErros = 0;}
;

Expr: Assignment                    {{$$=$1;};}
  | auxExpr {$$=$1;}
;
 auxExpr: MethodInvocation                {{$$=$1;};}
  | ParseArgs                             {{$$=$1;};}
  | auxExpr AND auxExpr                   {{$$=new_node("And","And");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr OR auxExpr                    {{ $$=new_node("Or","Or");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);
                                                                };}
  | auxExpr EQ auxExpr                    {{$$ =new_node("Eq","Eq");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);
                                                                  };}
  | auxExpr GEQ auxExpr                   {{$$=new_node("Geq","Geq");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr GT auxExpr                    {{$$=new_node("Gt","Gt");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr LEQ auxExpr                   {{$$=new_node("Leq","Leq");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);
                                                                  };}
  | auxExpr LT auxExpr                    {{$$=new_node("Lt","Lt");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr NEQ auxExpr                   {{$$=new_node("Neq","Neq");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr PLUS auxExpr                  {{$$=new_node("Add","Add");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr MINUS auxExpr                  {{$$=new_node("Sub","Sub");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr STAR auxExpr                  {{$$=new_node("Mul","Mul");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);};}
  | auxExpr DIV auxExpr                   {{$$=new_node("Div","Div");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);
                                                                  };}
  | auxExpr MOD auxExpr                   {{$$=new_node("Mod","Mod");
                                                                  add_son($$,$1);
                                                                  add_brother($1,$3);
                                                                  };}
  | PLUS  auxExpr       %prec NOT             {{$$=new_node("Plus","Plus");
                                                                  add_son($$,$2);
                                                                  };}
  | MINUS auxExpr       %prec NOT          {{$$=new_node("Minus","Minus");
                                                                  add_son($$,$2);
                                                                  };}
  | NOT  auxExpr        %prec NOT             {{$$=new_node("Not","Not");
                                                                  add_son($$,$2);
                                                                  };}
  | ID DOTLENGTH                            {{$$=new_node("Length","Length");
                                                                  add_son($$,new_node("Id",$1));
                                                                  };}
  | ID                                      {{$$=new_node("Id",$1);
                                                                      };}
  | OCURV Expr CCURV                        {{$$=$2;};}
  | BOOLLIT                                   {{$$=new_node("BoolLit",$1);};}
  | DECLIT                                  {{$$=new_node("DecLit", $1);};}
  | REALLIT                                 {{$$=new_node("RealLit",$1);};}
  | OCURV error CCURV                       {$$=new_node("Error","Error");flagTreeErros = 0;}


%%

void yyerror (const char *s) {
  printf ("Line %d, col %lu: %s: %s\n", n_line, n_column-strlen(yytext), s, yytext);
}

int main(int argv, char **argc){
  if(argv > 1){
    if(strcmp(argc[1], "-l")==0 || strcmp(argc[1], "-1")==0){
      if(strcmp(argc[1], "-l")==0){
        flag = 1;
      }
      yylex();
    }
    else if(strcmp(argc[1], "-t")==0 || strcmp(argc[1], "-2")==0){
      flag=2;
      flagTreeErros = 1;
      yyparse();

      if(flagTreeErros == 1 && root!=NULL && strcmp(argc[1], "-t")==0 ){
        print_tree(root,0);
      }
    }
    else if(strcmp(argc[1], "-s")==0){
      flag= 2;
      flagTreeErros = 1;
      yyparse();
      if(flagTreeErros == 1 && root!=NULL ){
        analiseSemantica(root);
        printTable();
        printf("\n");
        print_tree(root,0);
      }
    }
    else{
    	flag=2;
    	yyparse();
    }
  }
  else{
    flag=2;
    flagTreeErros = 1;
    yyparse();
    if(flagTreeErros == 1 && root!=NULL ){
      analiseSemantica(root);
    }
  }
return 0;
}
