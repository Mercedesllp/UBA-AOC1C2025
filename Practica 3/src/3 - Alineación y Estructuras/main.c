#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Estructuras.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */
	uint32_t res = 0;
	lista_t* list = malloc(sizeof(lista_t*));
	nodo_t* n1 = malloc(sizeof(nodo_t));
	n1->next = NULL;
	list->head = n1;
	assert(cantidad_total_de_elementos(list) == 1);
	free(n1);
	free(list);

	return 0;
}
