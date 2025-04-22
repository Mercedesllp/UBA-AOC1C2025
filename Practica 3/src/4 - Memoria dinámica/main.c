#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Memoria.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */
	char* string = strClone("Hola");
	char* word_for_file = "";
	assert(strCmp("Feros", "Omega 4") == 1);
	assert(strLen("Feros") == 5);
	assert(strCmp(string,"Hola") == 0);
	strDelete(string);

	FILE *fptr = fopen("text.txt","r");
	strPrint(word_for_file,fptr);			// Me gustaria cheuear el resultado no manualmente, pero ni idea, funciona.
	fclose(fptr);


	return 0;
}
