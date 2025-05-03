#include "ej1.h"

string_proc_list* string_proc_list_create(void){
	string_proc_list* list = malloc(sizeof(string_proc_list));
	list->first = list->last = NULL;
	return list;
}

string_proc_node* string_proc_node_create(uint8_t type, char* hash){
	string_proc_node* node = malloc(sizeof(string_proc_node));
	node->next = node->previous = NULL;
	node->hash = hash;
	node->type = type;
	return node;
}

void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash){
	string_proc_node* newNode = string_proc_node_create(type, hash);
	
	if(list->first == NULL){
		list->first = list->last = newNode;
	} else{
		string_proc_node* oldLast = list->last;
		list->last = oldLast->next = newNode;
		newNode->previous = oldLast;
	}
}

char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
	string_proc_node* actualNode = list->first;
	char* newHash = strdup(hash);					// Usa memoria dinamica para duplicarlo, si no, luego no puedo hacer free

	while(actualNode != NULL){
		if(actualNode->type == type){
			char* temp = newHash;
			newHash = str_concat(newHash, actualNode->hash);
			free(temp);
		}
		actualNode = actualNode->next;
	}

	return newHash;
}


/** AUX FUNCTIONS **/

void string_proc_list_destroy(string_proc_list* list){

	/* borro los nodos: */
	string_proc_node* current_node	= list->first;
	string_proc_node* next_node		= NULL;
	while(current_node != NULL){
		next_node = current_node->next;
		string_proc_node_destroy(current_node);
		current_node	= next_node;
	}
	/*borro la lista:*/
	list->first = NULL;
	list->last  = NULL;
	free(list);
}
void string_proc_node_destroy(string_proc_node* node){
	node->next      = NULL;
	node->previous	= NULL;
	node->hash		= NULL;
	node->type      = 0;			
	free(node);
}


char* str_concat(char* a, char* b) {
	int len1 = strlen(a);
    int len2 = strlen(b);
	int totalLength = len1 + len2;
    char *result = (char *)malloc(totalLength + 1); 
    strcpy(result, a);
    strcat(result, b);
    return result;  
}

void string_proc_list_print(string_proc_list* list, FILE* file){
        uint32_t length = 0;
        string_proc_node* current_node  = list->first;
        while(current_node != NULL){
                length++;
                current_node = current_node->next;
        }
        fprintf( file, "List length: %d\n", length );
		current_node    = list->first;
        while(current_node != NULL){
                fprintf(file, "\tnode hash: %s | type: %d\n", current_node->hash, current_node->type);
                current_node = current_node->next;
        }
}