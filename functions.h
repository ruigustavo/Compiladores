#ifndef _functions_h
#define _functions_h
#include <stdio.h>
#include <stdlib.h>
 //arvore
 typedef struct node {
  char* type;
  char* value;
  char* type_print;
  struct node *son;
  struct node *brother;
  //faltam cenas COMEBACK HERE
} node;

node* new_node(char* type, char* value);
void print_tree(node* aux, int tabs);
node* append_brother(node* first);
node* add_son(node* parent, node* new_son);
node* add_brother(node* brother, node* new_brother);
int cntbrothers(node* root);
#endif
