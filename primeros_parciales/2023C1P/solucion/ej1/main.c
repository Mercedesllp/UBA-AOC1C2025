#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <stddef.h>

#include "ej1.h"

int main (void){
	/* Acá pueden realizar sus propias pruebas */

	printf("OFFSETS: \n %lu \n %lu \n %lu \n SIZE: \n %lu\n",
		 offsetof(templo, colum_largo), offsetof(templo, nombre),
		 offsetof(templo, colum_corto), sizeof(templo));
	printf("SIZE OF SIZE_T:\n %lu\n", sizeof(size_t));
	return 0;    
}


